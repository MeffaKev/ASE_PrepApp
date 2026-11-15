import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

struct QuizSessionView: View {
    @EnvironmentObject var store: StudyStore
    @Environment(\.dismiss) private var dismiss

    let mode: QuizMode
    let questions: [Question]

    @State private var currentIndex: Int = 0
    @State private var selectedOptionByQuestionID: [Int: Int] = [:]
    @State private var revealedQuestionIDs: Set<Int> = []
    @State private var flaggedExamQuestionIDs: Set<Int> = []
    @State private var isShowingQuestionNavigator: Bool = false
    @State private var isShowingRationaleSheet: Bool = false
    @State private var isFinished: Bool = false
    @State private var showFinishConfirmation: Bool = false

    // Timer state
    @State private var elapsedSeconds: Int = 0
    @State private var remainingExamSeconds: Int = 75 * 60
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var currentQuestion: Question? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        NavigationStack {
            Group {
                if questions.isEmpty {
                    emptyQuestionsState
                } else if isFinished {
                    ExamResultsView(
                        mode: mode,
                        questions: questions,
                        selectedOptionByQuestionID: selectedOptionByQuestionID,
                        durationSeconds: elapsedSeconds,
                        onDismiss: { dismiss() }
                    )
                } else if let q = currentQuestion {
                    activeQuizContent(for: q)
                }
            }
            .navigationTitle(mode.title(for: store.selectedExam))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                remainingExamSeconds = store.selectedExam.examTimeLimitMinutes * 60
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isFinished ? "Done" : "Exit") {
                        dismiss()
                    }
                }
                if !questions.isEmpty && !isFinished {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 12) {
                            if mode.isTimedExam {
                                HStack(spacing: 4) {
                                    Image(systemName: "timer")
                                    Text(formattedTime(remainingExamSeconds))
                                        .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                                }
                                .foregroundStyle(remainingExamSeconds < 300 ? .red : .primary)
                            }
                            Button {
                                isShowingQuestionNavigator = true
                            } label: {
                                Image(systemName: "square.grid.3x3.fill")
                            }
                            .accessibilityLabel("Question Navigator")
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingQuestionNavigator) {
                questionNavigatorSheet
            }
            .sheet(isPresented: $isShowingRationaleSheet) {
                if let q = currentQuestion {
                    rationaleBottomSheet(for: q)
                }
            }
            .confirmationDialog(
                "Submit Exam?",
                isPresented: $showFinishConfirmation,
                titleVisibility: .visible
            ) {
                Button("Submit & Grade Now", role: .destructive) {
                    finishSession()
                }
                Button("Continue Reviewing", role: .cancel) {}
            } message: {
                let answered = selectedOptionByQuestionID.count
                Text("You have answered \(answered) of \(questions.count) questions.")
            }
            .onReceive(timer) { _ in
                guard !isFinished && !questions.isEmpty else { return }
                elapsedSeconds += 1
                if mode.isTimedExam {
                    if remainingExamSeconds > 0 {
                        remainingExamSeconds -= 1
                    } else {
                        finishSession()
                    }
                }
            }
        }
    }

    // MARK: - Active Question Layout (HIG Ergonomic Card + Thumb-Zone Dock)

    @ViewBuilder
    private func activeQuizContent(for q: Question) -> some View {
        VStack(spacing: 0) {
            // Segmented Progress Strip
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.tertiarySystemFill))
                    Rectangle()
                        .fill(q.domain.themeColor)
                        .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(max(questions.count, 1)))
                        .animation(.snappy, value: currentIndex)
                }
            }
            .frame(height: 5)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerMetaRow(for: q)
                            .id("TOP")

                        // Highlighted Stem Card with Qualifier Callout
                        VStack(alignment: .leading, spacing: 10) {
                            if let qualifierBadge = qualifierWarning(for: q.archetype) {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text(qualifierBadge)
                                        .font(.caption2.weight(.heavy))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                            }

                            Text(q.question)
                                .font(.body.weight(.medium))
                                .lineSpacing(4)
                                .foregroundStyle(.primary)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .liquidGlassCard(cornerRadius: 16)

                        // Full-Width Ergonomic Answer Cards (minHeight 54pt per HIG)
                        VStack(spacing: 12) {
                            ForEach(0..<q.options.count, id: \.self) { idx in
                                optionButton(for: q, optionIndex: idx)
                            }
                        }

                        // Compact Inline Rationale Banner + Expand to Sheet Button
                        if !mode.isTimedExam && revealedQuestionIDs.contains(q.id) {
                            rationalePreviewCard(for: q)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .background(Color(.systemGroupedBackground))
                .safeAreaInset(edge: .bottom) {
                    bottomThumbZoneDock(for: q)
                }
                .gesture(
                    DragGesture(minimumDistance: 45, coordinateSpace: .local)
                        .onEnded { value in
                            // Horizontal swipe > vertical scroll
                            guard abs(value.translation.width) > abs(value.translation.height) * 1.5 else { return }
                            if value.translation.width < -50 && currentIndex < questions.count - 1 {
                                withAnimation(.snappy) { currentIndex += 1 }
                            } else if value.translation.width > 50 && currentIndex > 0 {
                                withAnimation(.snappy) { currentIndex -= 1 }
                            }
                        }
                )
                .onChange(of: currentIndex) { _, _ in
                    isShowingRationaleSheet = false
                    withAnimation {
                        proxy.scrollTo("TOP", anchor: .top)
                    }
                }
            }
        }
    }

    private func qualifierWarning(for archetype: String) -> String? {
        switch archetype {
        case "EXCEPT Qualifier":
            return "NEGATIVE QUALIFIER: WATCH FOR 'EXCEPT'"
        case "LEAST Likely":
            return "NEGATIVE QUALIFIER: WATCH FOR 'LEAST LIKELY'"
        case "Technician A / B":
            return "EVALUATE TECH A & TECH B INDEPENDENTLY"
        default:
            return nil
        }
    }

    @ViewBuilder
    private func headerMetaRow(for q: Question) -> some View {
        HStack(spacing: 8) {
            Text("Q\(currentIndex + 1) / \(questions.count)")
                .font(.subheadline.weight(.heavy))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(q.domain.themeColor.opacity(0.15))
                .foregroundStyle(q.domain.themeColor)
                .clipShape(Capsule())

            Text("\(q.domain.shortLabel) • \(q.archetype)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Text("ID #\(q.id)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
    }

    @ViewBuilder
    private func optionButton(for q: Question, optionIndex: Int) -> some View {
        let isSelected = selectedOptionByQuestionID[q.id] == optionIndex
        let isRevealed = !mode.isTimedExam && revealedQuestionIDs.contains(q.id)
        let isCorrectOption = q.correctIndex == optionIndex

        let borderColor: Color = {
            if isRevealed {
                if isCorrectOption { return .green }
                if isSelected && !isCorrectOption { return .red }
                return Color(.separator).opacity(0.5)
            } else {
                return isSelected ? q.domain.themeColor : Color(.separator).opacity(0.5)
            }
        }()

        let backgroundColor: Color = {
            if isRevealed {
                if isCorrectOption { return Color.green.opacity(0.14) }
                if isSelected && !isCorrectOption { return Color.red.opacity(0.14) }
                return Color(.secondarySystemGroupedBackground)
            } else {
                return isSelected ? q.domain.themeColor.opacity(0.14) : Color(.secondarySystemGroupedBackground)
            }
        }()

        Button {
            selectOption(optionIndex, for: q)
        } label: {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected || (isRevealed && isCorrectOption) ? borderColor : Color(.tertiarySystemFill))
                        .frame(width: 34, height: 34)
                    Text(q.optionLetters[optionIndex])
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isSelected || (isRevealed && isCorrectOption) ? .white : .primary)
                }

                Text(q.options[optionIndex])
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isRevealed {
                    if isCorrectOption {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 56)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: isSelected || (isRevealed && isCorrectOption) ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func rationalePreviewCard(for q: Question) -> some View {
        let userChoice = selectedOptionByQuestionID[q.id]
        let isCorrect = userChoice == q.correctIndex

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(isCorrect ? .green : .orange)
                Text(isCorrect ? "Correct — Answer (\(q.optionLetters[q.correctIndex]))" : "Correct Answer: (\(q.optionLetters[q.correctIndex]))")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(isCorrect ? .green : .orange)

                Spacer()

                Button {
                    isShowingRationaleSheet = true
                } label: {
                    Label("Focus View", systemImage: "arrow.up.left.and.arrow.down.right")
                        .font(.caption2.weight(.bold))
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }

            Divider()

            Text(q.rationale)
                .font(.subheadline)
                .lineSpacing(3)
                .foregroundStyle(.primary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCorrect ? Color.green.opacity(0.5) : Color.orange.opacity(0.5), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Rationale Detent Bottom Sheet (HIG Contextual Sheet)

    @ViewBuilder
    private func rationaleBottomSheet(for q: Question) -> some View {
        let userChoice = selectedOptionByQuestionID[q.id]
        let isCorrect = userChoice == q.correctIndex

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .font(.title2)
                            .foregroundStyle(isCorrect ? .green : .red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isCorrect ? "Spot On!" : "Diagnostic Takeaway")
                                .font(.headline)
                            Text("Correct Choice: (\(q.optionLetters[q.correctIndex])) \(q.options[q.correctIndex])")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    Text("WHY THIS IS CORRECT")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.secondary)

                    Text(q.rationale)
                        .font(.body)
                        .lineSpacing(4)

                    if currentIndex < questions.count - 1 {
                        Button {
                            isShowingRationaleSheet = false
                            currentIndex += 1
                        } label: {
                            Label("Next Question", systemImage: "arrow.right.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 48)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(q.domain.themeColor)
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Question #\(q.id) Explanation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isShowingRationaleSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Ergonomic Thumb-Zone Dock (All Primary & Secondary Controls at Bottom)

    @ViewBuilder
    private func bottomThumbZoneDock(for q: Question) -> some View {
        HStack(spacing: 10) {
            // Previous Button
            Button {
                if currentIndex > 0 {
                    currentIndex -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 48, height: 48)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(currentIndex == 0)
            .opacity(currentIndex == 0 ? 0.4 : 1)
            .accessibilityLabel("Previous Question")

            // Bookmark Toggle in Thumb Zone
            Button {
                triggerSelectionHaptic()
                store.toggleBookmark(for: q.id)
            } label: {
                Image(systemName: store.isBookmarked(q.id) ? "bookmark.fill" : "bookmark")
                    .font(.headline)
                    .foregroundStyle(store.isBookmarked(q.id) ? .yellow : .primary)
                    .frame(width: 48, height: 48)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Bookmark Question")

            // Exam Flag or Rationale Sheet Trigger in Thumb Zone
            if mode.isTimedExam {
                Button {
                    triggerSelectionHaptic()
                    if flaggedExamQuestionIDs.contains(q.id) {
                        flaggedExamQuestionIDs.remove(q.id)
                    } else {
                        flaggedExamQuestionIDs.insert(q.id)
                    }
                } label: {
                    Image(systemName: flaggedExamQuestionIDs.contains(q.id) ? "flag.fill" : "flag")
                        .font(.headline)
                        .foregroundStyle(flaggedExamQuestionIDs.contains(q.id) ? .orange : .primary)
                        .frame(width: 48, height: 48)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Flag Question for Review")
            } else if revealedQuestionIDs.contains(q.id) {
                Button {
                    isShowingRationaleSheet = true
                } label: {
                    Image(systemName: "lightbulb.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .frame(width: 48, height: 48)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Explanation Sheet")
            }

            // Primary Next / Finish Action Button
            if currentIndex < questions.count - 1 {
                Button {
                    currentIndex += 1
                } label: {
                    HStack {
                        Text("Next Question")
                            .font(.subheadline.weight(.bold))
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(q.domain.themeColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    if mode.isTimedExam {
                        showFinishConfirmation = true
                    } else {
                        finishSession()
                    }
                } label: {
                    HStack {
                        Text("Finish & Grade")
                            .font(.subheadline.weight(.bold))
                        Image(systemName: "flag.checkered")
                            .font(.subheadline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .liquidGlassFloatingBar(cornerRadius: 24)
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }

    // MARK: - Question Navigator Sheet

    private var questionNavigatorSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { idx, q in
                        let isAnswered = selectedOptionByQuestionID[q.id] != nil
                        let isFlagged = flaggedExamQuestionIDs.contains(q.id)
                        let isCurrent = idx == currentIndex

                        Button {
                            currentIndex = idx
                            isShowingQuestionNavigator = false
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Text("\(idx + 1)")
                                    .font(.subheadline.weight(.bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        isCurrent ? Color.blue :
                                        (isAnswered ? Color.green.opacity(0.2) : Color(.secondarySystemGroupedBackground))
                                    )
                                    .foregroundStyle(isCurrent ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isAnswered ? Color.green : Color(.separator), lineWidth: 1)
                                    )

                                if isFlagged {
                                    Image(systemName: "flag.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.orange)
                                        .padding(4)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Question Navigator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        isShowingQuestionNavigator = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var emptyQuestionsState: some View {
        ContentUnavailableView(
            "No Questions in Set",
            systemImage: "checkmark.circle",
            description: Text("There are currently no questions matching this filter.")
        )
    }

    // MARK: - Logic & Haptics

    private func selectOption(_ optionIndex: Int, for question: Question) {
        selectedOptionByQuestionID[question.id] = optionIndex
        let isCorrect = (optionIndex == question.correctIndex)

        if !mode.isTimedExam {
            triggerAnswerHaptic(isCorrect: isCorrect)
            withAnimation(.snappy) {
                _ = revealedQuestionIDs.insert(question.id)
            }
            store.recordAnswer(questionID: question.id, isCorrect: isCorrect)
        } else {
            triggerSelectionHaptic()
        }
    }

    private func triggerSelectionHaptic() {
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }

    private func triggerAnswerHaptic(isCorrect: Bool) {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .warning)
        #endif
    }

    private func finishSession() {
        var correctTotal = 0
        var breakdown: [String: ExamSessionRecord.DomainScore] = [:]

        for q in questions {
            let key = q.domain.rawValue
            var dScore = breakdown[key] ?? ExamSessionRecord.DomainScore(total: 0, correct: 0)
            dScore.total += 1

            if let chosen = selectedOptionByQuestionID[q.id] {
                let isCorrect = (chosen == q.correctIndex)
                if isCorrect {
                    correctTotal += 1
                    dScore.correct += 1
                }
                store.recordAnswer(questionID: q.id, isCorrect: isCorrect)
            }
            breakdown[key] = dScore
        }

        let record = ExamSessionRecord(
            id: UUID(),
            date: Date(),
            modeTitle: mode.title(for: store.selectedExam),
            totalQuestions: questions.count,
            correctCount: correctTotal,
            durationSeconds: elapsedSeconds,
            domainBreakdown: breakdown
        )
        store.recordExamSession(record)
        withAnimation {
            isFinished = true
        }
    }

    private func formattedTime(_ totalSeconds: Int) -> String {
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
