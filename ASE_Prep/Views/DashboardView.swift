import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: StudyStore
    @State private var activeQuizSession: ActiveSessionItem?
    @State private var showResetAlert: Bool = false
    @State private var showExamCatalogSheet: Bool = false
    @State private var showPaywallSheet: Bool = false
    @State private var qotdSelectedOption: Int? = nil
    @State private var qotdRevealed: Bool = false

    struct ActiveSessionItem: Identifiable {
        let id = UUID()
        let mode: QuizMode
        let questions: [Question]
    }

    private let archetypes = [
        "Technician A / B",
        "MOST Likely",
        "LEAST Likely",
        "EXCEPT Qualifier",
        "Direct Diagnostic"
    ]

    private let twoColumnGrid = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    readinessBentoHeader

                    if !store.isCurrentExamUnlocked {
                        samplerUnlockBanner
                    }

                    studyModesGrid

                    if let qotd = store.questionOfTheDay {
                        questionOfTheDayCard(for: qotd)
                    }

                    domainDrillsSection

                    archetypeDrillsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .top) {
                examSwitcherFloatingBar
            }
            .navigationTitle("ASE \(store.selectedExam.code) Study Hub")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showExamCatalogSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("All 9 Exams")
                                .font(.caption.weight(.bold))
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 10) {
                        if !store.hasMasterBundle {
                            Button {
                                showPaywallSheet = true
                            } label: {
                                Label("Master Bundle", systemImage: "crown.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.orange)
                            }
                        }

                        Button(role: .destructive) {
                            showResetAlert = true
                        } label: {
                            Image(systemName: "arrow.counterclockwise.circle")
                        }
                        .accessibilityLabel("Reset Progress")
                    }
                }
            }
            .alert("Reset \(store.selectedExam.fullTitle) Progress?", isPresented: $showResetAlert) {
                Button("Reset Progress", role: .destructive) {
                    store.resetAllProgress()
                    qotdSelectedOption = nil
                    qotdRevealed = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear your answered history, exam scores, and bookmarked questions for \(store.selectedExam.fullTitle).")
            }
            .onChange(of: store.selectedExam) { _, _ in
                qotdSelectedOption = nil
                qotdRevealed = false
            }
            .sheet(isPresented: $showExamCatalogSheet) {
                ExamCatalogSheet(showPaywallSheet: $showPaywallSheet)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showPaywallSheet) {
                StorePaywallSheet()
                    .environmentObject(store)
            }
            .fullScreenCover(
                isPresented: Binding(
                    get: { !store.hasCompletedExamOnboarding },
                    set: { if !$0 { store.hasCompletedExamOnboarding = true } }
                )
            ) {
                FirstLaunchExamOnboardingView(showPaywallSheet: $showPaywallSheet)
                    .environmentObject(store)
            }
            .fullScreenCover(item: $activeQuizSession) { session in
                QuizSessionView(mode: session.mode, questions: session.questions)
                    .environmentObject(store)
            }
        }
    }

    // MARK: - 0. Floating Liquid Glass A-Series Exam Switcher Ribbon (A1–A9)

    private var examSwitcherFloatingBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ASEExamID.allCases) { exam in
                        let isSelected = (exam == store.selectedExam)
                        let unlocked = store.isExamUnlocked(exam)

                        Button {
                            withAnimation(.snappy) {
                                store.selectExam(exam)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: unlocked ? exam.iconName : "lock.fill")
                                    .font(.caption2.weight(.bold))
                                Text(exam.code)
                                    .font(.caption.weight(.heavy))
                                Text(exam.title)
                                    .font(.caption2.weight(.semibold))
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                isSelected
                                    ? exam.themeColor
                                    : Color(.tertiarySystemFill)
                            )
                            .foregroundStyle(isSelected ? .white : .primary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .id(exam.id)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .liquidGlassFloatingBar(cornerRadius: 20)
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .onChange(of: store.selectedExam) { _, newExam in
                withAnimation(.snappy) {
                    proxy.scrollTo(newExam.id, anchor: .center)
                }
            }
        }
    }

    // MARK: - Free Sampler Unlock Banner

    private var samplerUnlockBanner: some View {
        Button {
            showPaywallSheet = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.open.rotation")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 42, height: 42)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("FREE DIAGNOSTIC SAMPLER MODE")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(.orange)
                        Text("• \(store.allQuestions.count) Qs Active")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Text("Unlock Full \(store.selectedExam.fullTitle) ($9.99) or Master Bundle (\(store.masterBundleDisplayPrice))")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .liquidGlassCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 1. Readiness Bento Header (Pocket Prep / UWorld Style)

    private var readinessBentoHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 18) {
                // Circular Readiness Gauge
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 10)
                        .frame(width: 86, height: 86)

                    Circle()
                        .trim(from: 0, to: CGFloat(store.readinessScore) / 100.0)
                        .stroke(
                            store.readinessScore >= 70 ? Color.green : Color.cyan,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 86, height: 86)
                        .animation(.snappy, value: store.readinessScore)

                    VStack(spacing: 0) {
                        Text("\(store.readinessScore)%")
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(.white)
                        Text("READY")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: store.isCurrentExamUnlocked ? "checkmark.shield.fill" : "sparkles")
                            .foregroundStyle(.cyan)
                        Text(store.selectedExam.fullTitle.uppercased())
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(1)
                    }

                    Text(readinessStatusHeadline)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("\(store.totalMasteredCount) of \(store.allQuestions.count) questions mastered • \(Int(store.overallAccuracyPercentage.rounded()))% accuracy")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer(minLength: 0)
            }

            Divider()
                .overlay(Color.white.opacity(0.2))

            // Primary Action CTA Row inside Hero
            HStack(spacing: 10) {
                Button {
                    launchSession(.quick10Quiz)
                } label: {
                    Label("Quick 10 Quiz", systemImage: "bolt.fill")
                        .font(.subheadline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 46)
                        .background(Color.white)
                        .foregroundStyle(Color.indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    launchSession(.simulatedExam)
                } label: {
                    Label("\(store.selectedExam.totalExamQuestions)-Q Mock Exam", systemImage: "timer")
                        .font(.subheadline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 46)
                        .background(Color.white.opacity(0.18))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.22, blue: 0.52), store.selectedExam.themeColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: store.selectedExam.themeColor.opacity(0.22), radius: 10, x: 0, y: 5)
    }

    private var readinessStatusHeadline: String {
        if store.totalAnsweredCount == 0 {
            return "Start a Quick 10 Quiz to Baseline"
        } else if store.readinessScore >= 75 {
            return "Test-Ready for ASE \(store.selectedExam.code) Certification"
        } else if store.readinessScore >= 50 {
            return "Building Strong Diagnostic Mastery"
        } else {
            return "Focus on Core \(store.selectedExam.code) Domains"
        }
    }

    // MARK: - 2. 2x2 Bento Action Grid

    private var studyModesGrid: some View {
        LazyVGrid(columns: twoColumnGrid, spacing: 12) {
            bentoActionTile(
                title: "Practice All \(store.allQuestions.count)",
                subtitle: "Shuffled + Instant Rationale",
                icon: "shuffle.circle.fill",
                color: store.selectedExam.themeColor,
                isDisabled: false
            ) {
                launchSession(.practiceAll(shuffled: true))
            }

            bentoActionTile(
                title: "Weakest Domain",
                subtitle: weakestDomain.shortLabel + " • Needs Focus",
                icon: "flame.fill",
                color: .orange,
                isDisabled: false
            ) {
                launchSession(.domainDrill(weakestDomain))
            }

            bentoActionTile(
                title: "Missed (\(store.totalMissedCount))",
                subtitle: store.totalMissedCount == 0 ? "0 Missed So Far" : "Retest Incorrect Items",
                icon: "arrow.triangle.2.circlepath.circle.fill",
                color: .red,
                isDisabled: store.totalMissedCount == 0
            ) {
                launchSession(.missedQuestions)
            }

            bentoActionTile(
                title: "Saved (\(store.bookmarkedIDs.count))",
                subtitle: store.bookmarkedIDs.isEmpty ? "Tap Bookmark in Quiz" : "Review Flagged Items",
                icon: "bookmark.circle.fill",
                color: .yellow,
                isDisabled: store.bookmarkedIDs.isEmpty
            ) {
                launchSession(.bookmarkedQuestions)
            }
        }
    }

    private var weakestDomain: ASEDomain {
        store.activeDomains.min { a, b in
            let aTotal = max(store.questions(for: a).count, 1)
            let bTotal = max(store.questions(for: b).count, 1)
            let aRatio = Double(store.masteredCount(for: a)) / Double(aTotal)
            let bRatio = Double(store.masteredCount(for: b)) / Double(bTotal)
            return aRatio < bRatio
        } ?? .sectionA
    }

    private func bentoActionTile(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            .liquidGlassCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - 3. Question of the Day Interactive Card

    private func questionOfTheDayCard(for q: Question) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("\(store.selectedExam.code) QUESTION OF THE DAY", systemImage: "sparkles")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(.orange)
                Spacer()
                Text("Q#\(q.id) • \(q.domain.shortLabel)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(q.question)
                .font(.subheadline.weight(.medium))
                .lineSpacing(2)

            VStack(spacing: 8) {
                ForEach(0..<q.options.count, id: \.self) { idx in
                    let isSelected = qotdSelectedOption == idx
                    let isCorrect = idx == q.correctIndex

                    Button {
                        withAnimation(.snappy) {
                            qotdSelectedOption = idx
                            qotdRevealed = true
                            store.recordAnswer(questionID: q.id, isCorrect: isCorrect)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(q.optionLetters[idx])
                                .font(.caption.weight(.bold))
                                .frame(width: 24, height: 24)
                                .background(
                                    qotdRevealed
                                        ? (isCorrect ? Color.green : (isSelected ? Color.red : Color(.tertiarySystemFill)))
                                        : Color(.tertiarySystemFill)
                                )
                                .foregroundStyle(qotdRevealed && (isCorrect || isSelected) ? .white : .primary)
                                .clipShape(Circle())

                            Text(q.options[idx])
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)

                            Spacer()
                        }
                        .padding(10)
                        .background(
                            qotdRevealed && isCorrect
                                ? Color.green.opacity(0.12)
                                : (qotdRevealed && isSelected ? Color.red.opacity(0.12) : Color(.tertiarySystemGroupedBackground))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }

            if qotdRevealed {
                Text(q.rationale)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(10)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .liquidGlassCard(cornerRadius: 16)
    }

    // MARK: - 4. Domain Drills Section

    private var domainDrillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ASE \(store.selectedExam.code) Official Content Domains")
                    .font(.headline)
                Spacer()
                Text("Tap to Drill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(store.activeDomains) { domain in
                let total = store.questions(for: domain).count
                let mastered = store.masteredCount(for: domain)
                let pct = total > 0 ? Int(((Double(mastered) / Double(total)) * 100.0).rounded()) : 0
                let dTitle = store.domainTitle(for: domain)
                let dWeight = store.domainWeight(for: domain)
                let dIcon = store.domainIcon(for: domain)

                Button {
                    launchSession(.domainDrill(domain))
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Image(systemName: dIcon)
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(domain.themeColor)
                                .clipShape(RoundedRectangle(cornerRadius: 11))

                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(domain.shortLabel)
                                        .font(.caption2.weight(.heavy))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(domain.themeColor.opacity(0.15))
                                        .foregroundStyle(domain.themeColor)
                                        .clipShape(Capsule())

                                    Text("Exam Weight: ~\(dWeight)%")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }

                                Text(dTitle)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(pct)%")
                                    .font(.subheadline.weight(.heavy))
                                    .foregroundStyle(domain.themeColor)
                                Text("\(mastered)/\(total)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        ProgressView(value: Double(mastered), total: Double(max(total, 1)))
                            .tint(domain.themeColor)
                    }
                    .padding(14)
                    .liquidGlassCard(cornerRadius: 16)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 5. Archetype Drills Section

    private var archetypeDrillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Drill by ASE Question Format")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(archetypes, id: \.self) { arch in
                        let count = store.allQuestions.filter { $0.archetype == arch }.count
                        Button {
                            launchSession(.archetypeDrill(arch))
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(arch)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.primary)
                                Text("\(count) Questions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(14)
                            .frame(width: 168, alignment: .leading)
                            .liquidGlassCard(cornerRadius: 14)
                        }
                        .buttonStyle(.plain)
                        .disabled(count == 0)
                        .opacity(count == 0 ? 0.45 : 1.0)
                    }
                }
            }
        }
    }

    private func launchSession(_ mode: QuizMode) {
        let qs = store.buildQuestions(for: mode)
        activeQuizSession = ActiveSessionItem(mode: mode, questions: qs)
    }
}

// MARK: - All 9 A-Series Exam Switcher Sheet

struct ExamCatalogSheet: View {
    @EnvironmentObject var store: StudyStore
    @Environment(\.dismiss) private var dismiss
    @Binding var showPaywallSheet: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if !store.hasMasterBundle {
                        Button {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                showPaywallSheet = true
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "crown.fill")
                                    .font(.title2)
                                    .foregroundStyle(.yellow)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("ASE Master Tech Bundle (A1–A9)")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.white)
                                    Text("Unlock all 9 Automobile & Light Diesel tests forever • \(store.masterBundleDisplayPrice)")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white)
                            }
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [Color.indigo, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(ASEExamID.allCases) { exam in
                        let isSelected = (exam == store.selectedExam)
                        let unlocked = store.isExamUnlocked(exam)
                        let qCount = store.questionCount(for: exam)
                        let ready = store.readinessScore(for: exam)

                        Button {
                            store.selectExam(exam)
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(exam.themeColor)
                                        .frame(width: 48, height: 48)
                                    Text(exam.code)
                                        .font(.headline.weight(.heavy))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(exam.title)
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        if isSelected {
                                            Text("ACTIVE")
                                                .font(.system(size: 9, weight: .heavy))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(exam.themeColor.opacity(0.18))
                                                .foregroundStyle(exam.themeColor)
                                                .clipShape(Capsule())
                                        }
                                    }

                                    Text(exam.shortSubtitle)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)

                                    HStack(spacing: 8) {
                                        Label("\(exam.totalExamQuestions) Exam Qs (\(exam.examTimeLimitMinutes)m)", systemImage: "timer")
                                        Text("•")
                                        Text(unlocked ? "Full Access (\(qCount) Qs)" : "Free Sampler")
                                            .foregroundStyle(unlocked ? .green : .orange)
                                            .fontWeight(.semibold)
                                    }
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                                        .foregroundStyle(unlocked ? .green : .orange)
                                    Text("\(ready)%")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(14)
                            .liquidGlassCard(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ASE A-Series Exams (A1–A9)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Treanor Corp StoreKit 2 Pricing & Unlock Sheet ($9.99 Single / $39.99 Master Bundle)

struct StorePaywallSheet: View {
    @EnvironmentObject var store: StudyStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Header Hero
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("NO SUBSCRIPTIONS • OWN FOREVER")
                                .font(.caption2.weight(.heavy))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundStyle(.yellow)
                        }

                        Text("Pass Your ASE Exams on the First Try")
                            .font(.title2.weight(.heavy))
                            .foregroundStyle(.white)

                        Text("Failing a single ASE exam costs $53 in retest fees and another trip to Prometric. Unlock lifetime access with one-time pricing—no recurring monthly fees.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.88))
                            .lineSpacing(3)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.08, green: 0.20, blue: 0.48), Color.indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Option 1: Master Tech Bundle ($39.99 or $29.99 Upgrade)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(store.qualifiesForBundleUpgradeDiscount ? "MASTER BUNDLE UPGRADE DISCOUNT" : "BEST VALUE • SAVE 55%")
                                .font(.caption2.weight(.heavy))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.18))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                            Spacer()
                            if store.qualifiesForBundleUpgradeDiscount {
                                Text("$39.99")
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundStyle(.secondary)
                            }
                            Text(store.masterBundleDisplayPrice)
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(.primary)
                        }

                        Text("ASE Master Tech Bundle (All 9 Exams: A1–A9)")
                            .font(.headline.weight(.bold))

                        Text("• Unlocks all 8 Master Automobile Technician exams (A1–A8) + A9 Light Vehicle Diesel\n• Full 250-question banks per exam, unlimited Timed Mock Exams, and Shop Reference guides\n• One-time lifetime purchase (ideal for initial certification and 5-year A1R–A9R recertification)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)

                        Button {
                            store.unlockMasterBundle()
                            dismiss()
                        } label: {
                            Text(store.hasMasterBundle ? "Master Bundle Unlocked ✓" : "Unlock All 9 Exams (\(store.masterBundleDisplayPrice) Lifetime)")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(store.hasMasterBundle ? Color.green : Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .disabled(store.hasMasterBundle)
                    }
                    .padding(16)
                    .liquidGlassCard(cornerRadius: 18)

                    // Option 2: Single Exam Unlock ($9.99)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("SINGLE EXAM LIFETIME UNLOCK")
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(store.selectedExam.themeColor)
                            Spacer()
                            Text("$9.99")
                                .font(.title3.weight(.heavy))
                        }

                        Text(store.selectedExam.fullTitle)
                            .font(.headline.weight(.bold))

                        Text("• Full question bank, unlimited \(store.selectedExam.totalExamQuestions)-Q Timed Mock Exams (\(store.selectedExam.examTimeLimitMinutes) min), Weakest Section drills, and full shop rationales.\n• Qualifies you for the $29.99 Master Bundle Upgrade later.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)

                        Button {
                            store.unlockSingleExam(store.selectedExam)
                            dismiss()
                        } label: {
                            let isUnlocked = store.isExamUnlocked(store.selectedExam)
                            Text(isUnlocked ? "\(store.selectedExam.code) Unlocked ✓" : "Unlock \(store.selectedExam.fullTitle) ($9.99)")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(isUnlocked ? Color.green : store.selectedExam.themeColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .disabled(store.isExamUnlocked(store.selectedExam))
                    }
                    .padding(16)
                    .liquidGlassCard(cornerRadius: 18)

                    // Simulator / Developer Entitlement Controls
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Developer / Simulator Testing Controls")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            Button {
                                store.lockExamForTesting(store.selectedExam)
                            } label: {
                                Text("Test Free 15-Q Sampler")
                                    .font(.caption.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)

                            Button {
                                store.unlockMasterBundle()
                            } label: {
                                Text("Unlock All (A1–A9)")
                                    .font(.caption.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                store.hasCompletedExamOnboarding = false
                            }
                        } label: {
                            Text("Preview First-Launch Exam Selector Screen")
                                .font(.caption.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(14)
                    .liquidGlassCard(cornerRadius: 14)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Unlock ASE Study Banks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}


// MARK: - First-Launch Welcome & Primary Exam Selector (Shown on First App Open)

struct FirstLaunchExamOnboardingView: View {
    @EnvironmentObject var store: StudyStore
    @Binding var showPaywallSheet: Bool
    @State private var highlightedExam: ASEExamID = .a1

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Welcome Hero Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label("WELCOME TO ASE A-SERIES PREP", systemImage: "wrench.and.screwdriver.fill")
                                .font(.caption2.weight(.heavy))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                            Spacer()
                        }

                        Text("Which ASE Exam Are You Studying For First?")
                            .font(.title2.weight(.heavy))
                            .foregroundStyle(.white)

                        Text("Pick your target certification below to customize your dashboard, official Prometric timer, and diagnostic domain drills. You can switch between A1–A9 anytime at the top of the screen.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.88))
                            .lineSpacing(3)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.08, green: 0.22, blue: 0.52), highlightedExam.themeColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Featured Master Tech Bundle Card (Equal Visual Weight at Top of List)
                    Button {
                        store.selectExam(highlightedExam)
                        store.hasCompletedExamOnboarding = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showPaywallSheet = true
                        }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, Color(red: 0.85, green: 0.45, blue: 0.0)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 46, height: 46)
                                Image(systemName: "crown.fill")
                                    .font(.headline.weight(.heavy))
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text("ASE Master Tech Bundle (A1–A9)")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.primary)
                                    Text("SAVE 55%")
                                        .font(.system(size: 9, weight: .heavy))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.2))
                                        .foregroundStyle(.orange)
                                        .clipShape(Capsule())
                                }
                                Text("Unlock all 9 A-Series exams, 2,250+ questions & unlimited mock exams")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                Text("$39.99 Lifetime Unlock (vs. $89.91 individually)")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.orange)
                            }

                            Spacer()

                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.orange)
                        }
                        .padding(14)
                        .liquidGlassCard(cornerRadius: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.orange.opacity(0.65), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)

                    Text("Or Select an Individual Exam (A1–A9)")
                        .font(.headline)

                    ForEach(ASEExamID.allCases) { exam in
                        let isPicked = (highlightedExam == exam)

                        Button {
                            withAnimation(.snappy) {
                                highlightedExam = exam
                            }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(exam.themeColor)
                                        .frame(width: 46, height: 46)
                                    Text(exam.code)
                                        .font(.headline.weight(.heavy))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(exam.title)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.primary)
                                    Text(exam.shortSubtitle)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                    Text("\(exam.totalExamQuestions) Exam Questions • \(exam.examTimeLimitMinutes) Min Timer")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(exam.themeColor)
                                }

                                Spacer()

                                Image(systemName: isPicked ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(isPicked ? exam.themeColor : .secondary)
                            }
                            .padding(14)
                            .liquidGlassCard(cornerRadius: 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(isPicked ? exam.themeColor : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    Button {
                        store.selectExam(highlightedExam)
                        store.hasCompletedExamOnboarding = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Start Studying \(highlightedExam.fullTitle)")
                                .font(.subheadline.weight(.bold))
                            Image(systemName: "arrow.right")
                                .font(.subheadline.weight(.bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(highlightedExam.themeColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.selectExam(highlightedExam)
                        store.hasCompletedExamOnboarding = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showPaywallSheet = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.subheadline.weight(.bold))
                            Text("Master Tech Bundle (All 9 Exams) • $39.99")
                                .font(.subheadline.weight(.bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.92, green: 0.50, blue: 0.05), Color(red: 0.78, green: 0.36, blue: 0.02)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .liquidGlassFloatingBar(cornerRadius: 24)
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
            }
            .navigationTitle("Choose Your ASE Exam")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
