import SwiftUI

struct ExamHistoryView: View {
    @EnvironmentObject var store: StudyStore

    var body: some View {
        NavigationStack {
            Group {
                if store.examHistory.isEmpty {
                    ContentUnavailableView(
                        "No Completed Sessions Yet",
                        systemImage: "chart.bar.xaxis",
                        description: Text("Complete a Timed Simulated Exam or Category Drill to track your score history and domain mastery.")
                    )
                } else {
                    List {
                        Section("\(store.selectedExam.fullTitle) Domain Mastery") {
                            ForEach(store.activeDomains) { domain in
                                let total = store.questions(for: domain).count
                                let mastered = store.masteredCount(for: domain)
                                let pct = total > 0 ? (Double(mastered) / Double(total)) * 100.0 : 0
                                let dTitle = store.domainTitle(for: domain)

                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("\(domain.shortLabel): \(dTitle)")
                                            .font(.caption.weight(.semibold))
                                        Spacer()
                                        Text("\(mastered)/\(total) (\(Int(pct.rounded()))%)")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(domain.themeColor)
                                    }
                                    ProgressView(value: Double(mastered), total: Double(max(total, 1)))
                                        .tint(domain.themeColor)
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        Section("Recent Quiz & Exam Sessions") {
                            ForEach(store.examHistory) { record in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(record.modeTitle)
                                            .font(.subheadline.weight(.bold))
                                        Spacer()
                                        Text(String(format: "%.0f%%", record.percentageScore))
                                            .font(.subheadline.weight(.heavy))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background((record.passed ? Color.green : Color.orange).opacity(0.15))
                                            .foregroundStyle(record.passed ? .green : .orange)
                                            .clipShape(Capsule())
                                    }

                                    HStack {
                                        Text("\(record.correctCount) of \(record.totalQuestions) correct")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("•")
                                            .foregroundStyle(.secondary)
                                        Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("\(store.selectedExam.code) Score History")
        }
    }
}
