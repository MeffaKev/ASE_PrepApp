import SwiftUI

struct QuestionBankBrowserView: View {
    @EnvironmentObject var store: StudyStore

    @State private var searchText: String = ""
    @State private var selectedDomain: ASEDomain? = nil
    @State private var showBookmarkedOnly: Bool = false
    @State private var expandedQuestionIDs: Set<Int> = []

    private var filteredQuestions: [Question] {
        store.allQuestions.filter { q in
            if let domain = selectedDomain, q.domain != domain {
                return false
            }
            if showBookmarkedOnly && !store.isBookmarked(q.id) {
                return false
            }
            if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                let query = searchText.lowercased()
                let matchQuestion = q.question.lowercased().contains(query)
                let matchRationale = q.rationale.lowercased().contains(query)
                let matchOptions = q.options.contains { $0.lowercased().contains(query) }
                let matchID = "#\(q.id)" == query || "\(q.id)" == query
                return matchQuestion || matchRationale || matchOptions || matchID
            }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                domainFilterStrip

                List {
                    Section {
                        ForEach(filteredQuestions) { q in
                            questionRow(for: q)
                        }
                    } header: {
                        Text("Showing \(filteredQuestions.count) of \(store.allQuestions.count) Questions")
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("\(store.selectedExam.code) Question Bank")
            .searchable(text: $searchText, prompt: "Search \(store.selectedExam.code) symptoms, tools, specs...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBookmarkedOnly.toggle()
                    } label: {
                        Image(systemName: showBookmarkedOnly ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(showBookmarkedOnly ? .yellow : .primary)
                    }
                    .accessibilityLabel("Filter Bookmarked")
                }
            }
        }
    }

    private var domainFilterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All (\(store.allQuestions.count))",
                    isSelected: selectedDomain == nil,
                    color: .blue
                ) {
                    selectedDomain = nil
                }

                ForEach(store.activeDomains) { domain in
                    let count = store.questions(for: domain).count
                    FilterChip(
                        title: "\(domain.shortLabel) (\(count))",
                        isSelected: selectedDomain == domain,
                        color: domain.themeColor
                    ) {
                        selectedDomain = (selectedDomain == domain) ? nil : domain
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.secondarySystemGroupedBackground))
    }

    @ViewBuilder
    private func questionRow(for q: Question) -> some View {
        let isExpanded = expandedQuestionIDs.contains(q.id)
        let mastery = store.questionMastery[q.id]

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("#\(q.id)")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(q.domain.themeColor.opacity(0.15))
                    .foregroundStyle(q.domain.themeColor)
                    .clipShape(Capsule())

                Text(q.archetype)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                if let mastery = mastery {
                    Image(systemName: mastery ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(mastery ? .green : .red)
                }

                Spacer()

                Button {
                    store.toggleBookmark(for: q.id)
                } label: {
                    Image(systemName: store.isBookmarked(q.id) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(store.isBookmarked(q.id) ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }

            Text(q.question)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded {
                        _ = expandedQuestionIDs.remove(q.id)
                    } else {
                        _ = expandedQuestionIDs.insert(q.id)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isExpanded ? "Hide Answer & Rationale" : "Show Options & Answer")
                        .font(.caption.weight(.bold))
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                }
                .foregroundStyle(q.domain.themeColor)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(0..<q.options.count, id: \.self) { idx in
                        let isCorrect = idx == q.correctIndex
                        HStack(alignment: .top, spacing: 6) {
                            Text("(\(q.optionLetters[idx]))")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(isCorrect ? .green : .secondary)
                            Text(q.options[idx])
                                .font(.caption)
                                .fontWeight(isCorrect ? .semibold : .regular)
                                .foregroundStyle(isCorrect ? .green : .primary)
                        }
                    }

                    Divider()
                        .padding(.vertical, 4)

                    Text("Rationale: \(q.rationale)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                }
                .padding(10)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.vertical, 4)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? color : Color(.tertiarySystemFill))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
