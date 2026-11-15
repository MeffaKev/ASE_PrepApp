import SwiftUI

struct ExamResultsView: View {
    @EnvironmentObject var store: StudyStore
    let mode: QuizMode
    let questions: [Question]
    let selectedOptionByQuestionID: [Int: Int]
    let durationSeconds: Int
    let onDismiss: () -> Void

    @State private var reviewFilter: ReviewFilter = .all

    enum ReviewFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case missed = "Missed / Unanswered"
        case correct = "Correct"
        var id: String { rawValue }
    }

    private var correctCount: Int {
        questions.filter { selectedOptionByQuestionID[$0.id] == $0.correctIndex }.count
    }

    private var percentage: Double {
        guard !questions.isEmpty else { return 0 }
        return (Double(correctCount) / Double(questions.count)) * 100.0
    }

    private var passed: Bool {
        percentage >= 70.0
    }

    private var filteredQuestions: [Question] {
        switch reviewFilter {
        case .all:
            return questions
        case .missed:
            return questions.filter { selectedOptionByQuestionID[$0.id] != $0.correctIndex }
        case .correct:
            return questions.filter { selectedOptionByQuestionID[$0.id] == $0.correctIndex }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                scoreSummaryCard

                domainBreakdownCard

                reviewQuestionsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var scoreSummaryCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: percentage / 100.0)
                    .stroke(
                        passed ? Color.green : Color.orange,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Text(String(format: "%.0f%%", percentage))
                        .font(.title.weight(.bold))
                    Text("\(correctCount)/\(questions.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: passed ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(passed ? .green : .orange)
                Text(passed ? "Passing Score Achieved (≥70%)" : "Below Passing Benchmark (70% Needed)")
                    .font(.headline)
                    .foregroundStyle(passed ? .green : .orange)
            }

            Text("Time Elapsed: \(formattedDuration(durationSeconds))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                onDismiss()
            } label: {
                Text("Return to Dashboard")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var domainBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ASE \(store.selectedExam.code) Content Area Breakdown")
                .font(.headline)

            ForEach(store.activeDomains) { domain in
                let domainQs = questions.filter { $0.domain == domain }
                if !domainQs.isEmpty {
                    let domainCorrect = domainQs.filter { selectedOptionByQuestionID[$0.id] == $0.correctIndex }.count
                    let domainPct = (Double(domainCorrect) / Double(domainQs.count)) * 100.0
                    let dTitle = store.domainTitle(for: domain)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("\(domain.shortLabel): \(dTitle)")
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                            Spacer()
                            Text("\(domainCorrect)/\(domainQs.count) (\(Int(domainPct.rounded()))%)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(domainPct >= 70 ? .green : .orange)
                        }
                        ProgressView(value: Double(domainCorrect), total: Double(domainQs.count))
                            .tint(domain.themeColor)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlassCard(cornerRadius: 16)
    }

    private var reviewQuestionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Detailed Question Review")
                .font(.headline)

            Picker("Filter", selection: $reviewFilter) {
                ForEach(ReviewFilter.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)

            ForEach(filteredQuestions) { q in
                let chosenIdx = selectedOptionByQuestionID[q.id]
                let isCorrect = chosenIdx == q.correctIndex

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(isCorrect ? .green : .red)
                        Text("Question #\(q.id) • \(q.domain.shortLabel)")
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Text(q.archetype)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                    }

                    Text(q.question)
                        .font(.subheadline.weight(.medium))

                    if let chosenIdx = chosenIdx, chosenIdx != q.correctIndex {
                        Text("Your Answer: (\(q.optionLetters[chosenIdx])) \(q.options[chosenIdx])")
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else if chosenIdx == nil {
                        Text("Your Answer: Unanswered")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Text("Correct Answer: (\(q.optionLetters[q.correctIndex])) \(q.options[q.correctIndex])")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)

                    Divider()

                    Text(q.rationale)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func formattedDuration(_ secs: Int) -> String {
        let m = secs / 60
        let s = secs % 60
        return "\(m)m \(s)s"
    }
}
