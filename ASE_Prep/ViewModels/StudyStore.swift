import Foundation
import SwiftUI

enum QuizMode: Equatable {
    case quick10Quiz
    case practiceAll(shuffled: Bool)
    case domainDrill(ASEDomain)
    case archetypeDrill(String)
    case simulatedExam // Weighted questions, official timer, feedback at end
    case missedQuestions
    case bookmarkedQuestions

    var title: String {
        switch self {
        case .quick10Quiz:
            return "Quick 10 Daily Quiz"
        case .practiceAll:
            return "Full Question Bank Practice"
        case .domainDrill(let domain):
            return "\(domain.shortLabel) Drill"
        case .archetypeDrill(let arch):
            return "\(arch) Drill"
        case .simulatedExam:
            return "Official Simulated Exam"
        case .missedQuestions:
            return "Missed Questions Review"
        case .bookmarkedQuestions:
            return "Bookmarked Questions"
        }
    }

    func title(for exam: ASEExamID) -> String {
        switch self {
        case .quick10Quiz:
            return "\(exam.code) Quick 10 Daily Quiz"
        case .practiceAll:
            return "\(exam.code) Full Practice"
        case .domainDrill(let domain):
            let spec = exam.spec(for: domain)
            return "\(exam.code) \(domain.shortLabel): \(spec.title)"
        case .archetypeDrill(let arch):
            return "\(exam.code) \(arch) Drill"
        case .simulatedExam:
            return "Official ASE \(exam.code) Simulated Exam"
        case .missedQuestions:
            return "\(exam.code) Missed Questions"
        case .bookmarkedQuestions:
            return "\(exam.code) Bookmarked Questions"
        }
    }

    var isTimedExam: Bool {
        if case .simulatedExam = self { return true }
        return false
    }
}

@MainActor
final class StudyStore: ObservableObject {
    @Published var selectedExam: ASEExamID = .a1 {
        didSet {
            guard oldValue != selectedExam else { return }
            UserDefaults.standard.set(selectedExam.rawValue, forKey: selectedExamKey)
            loadCurrentExamBankAndState()
        }
    }

    /// Full question bank for the currently selected exam
    @Published private(set) var fullExamQuestions: [Question] = []

    /// Questions accessible to the user based on unlock tier (Full bank if unlocked, or 15-Q Free Sampler)
    var allQuestions: [Question] {
        if isExamUnlocked(selectedExam) {
            return fullExamQuestions
        } else {
            return Array(fullExamQuestions.prefix(freeSamplerQuestionLimit))
        }
    }

    let freeSamplerQuestionLimit: Int = 15

    @Published var bookmarkedIDs: Set<Int> = [] {
        didSet {
            guard !isSwitchingExam else { return }
            saveBookmarks()
        }
    }

    /// Maps Question ID -> Bool (true = answered correctly most recently, false = missed most recently)
    @Published var questionMastery: [Int: Bool] = [:] {
        didSet {
            guard !isSwitchingExam else { return }
            saveMastery()
        }
    }

    @Published var examHistory: [ExamSessionRecord] = [] {
        didSet {
            guard !isSwitchingExam else { return }
            saveExamHistory()
        }
    }

    // MARK: - StoreKit / Entitlement State (Single Test $9.99 & Master Tech Bundle $39.99)

    @Published var unlockedExams: Set<ASEExamID> = [.a1] {
        didSet { saveEntitlements() }
    }

    @Published var hasMasterBundle: Bool = false {
        didSet { saveEntitlements() }
    }

    @Published var hasCompletedExamOnboarding: Bool = false {
        didSet {
            UserDefaults.standard.set(hasCompletedExamOnboarding, forKey: onboardingKey)
        }
    }

    private var isSwitchingExam: Bool = false
    private let selectedExamKey = "ase_selected_exam_v2"
    private let unlockedExamsKey = "ase_unlocked_exams_v2"
    private let masterBundleKey = "ase_master_bundle_v2"
    private let onboardingKey = "ase_completed_exam_onboarding_v1"

    private func bookmarksKey(for exam: ASEExamID) -> String {
        exam == .a1 ? "ase_a1_bookmarks_v1" : "ase_\(exam.rawValue.lowercased())_bookmarks_v2"
    }

    private func masteryKey(for exam: ASEExamID) -> String {
        exam == .a1 ? "ase_a1_mastery_v1" : "ase_\(exam.rawValue.lowercased())_mastery_v2"
    }

    private func historyKey(for exam: ASEExamID) -> String {
        exam == .a1 ? "ase_a1_history_v1" : "ase_\(exam.rawValue.lowercased())_history_v2"
    }

    init() {
        loadEntitlements()
        self.hasCompletedExamOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        if let savedRaw = UserDefaults.standard.string(forKey: selectedExamKey),
           let savedExam = ASEExamID(rawValue: savedRaw) {
            self.selectedExam = savedExam
        }
        loadCurrentExamBankAndState()
    }

    func selectExam(_ exam: ASEExamID) {
        selectedExam = exam
        if !hasCompletedExamOnboarding {
            hasCompletedExamOnboarding = true
        }
    }

    private func loadCurrentExamBankAndState() {
        isSwitchingExam = true
        defer { isSwitchingExam = false }

        self.fullExamQuestions = loadQuestionsFromBundle(for: selectedExam)

        if let data = UserDefaults.standard.data(forKey: bookmarksKey(for: selectedExam)),
           let decoded = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            self.bookmarkedIDs = decoded
        } else {
            self.bookmarkedIDs = []
        }

        if let data = UserDefaults.standard.data(forKey: masteryKey(for: selectedExam)),
           let decoded = try? JSONDecoder().decode([Int: Bool].self, from: data) {
            self.questionMastery = decoded
        } else {
            self.questionMastery = [:]
        }

        if let data = UserDefaults.standard.data(forKey: historyKey(for: selectedExam)),
           let decoded = try? JSONDecoder().decode([ExamSessionRecord].self, from: data) {
            self.examHistory = decoded
        } else {
            self.examHistory = []
        }
    }

    func loadQuestionsFromBundle(for exam: ASEExamID) -> [Question] {
        for fileName in exam.resourceFileNames {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([Question].self, from: data),
               !decoded.isEmpty {
                return decoded.sorted { $0.id < $1.id }
            }
        }
        return ASEExamID.builtInSamplerQuestions(for: exam)
    }

    // MARK: - Persistence Helpers

    private func saveBookmarks() {
        if let data = try? JSONEncoder().encode(bookmarkedIDs) {
            UserDefaults.standard.set(data, forKey: bookmarksKey(for: selectedExam))
        }
    }

    private func saveMastery() {
        if let data = try? JSONEncoder().encode(questionMastery) {
            UserDefaults.standard.set(data, forKey: masteryKey(for: selectedExam))
        }
    }

    private func saveExamHistory() {
        if let data = try? JSONEncoder().encode(examHistory) {
            UserDefaults.standard.set(data, forKey: historyKey(for: selectedExam))
        }
    }

    private func loadEntitlements() {
        if let data = UserDefaults.standard.data(forKey: unlockedExamsKey),
           let decoded = try? JSONDecoder().decode(Set<ASEExamID>.self, from: data) {
            self.unlockedExams = decoded
        }
        if UserDefaults.standard.object(forKey: masterBundleKey) != nil {
            self.hasMasterBundle = UserDefaults.standard.bool(forKey: masterBundleKey)
        }
    }

    private func saveEntitlements() {
        if let data = try? JSONEncoder().encode(unlockedExams) {
            UserDefaults.standard.set(data, forKey: unlockedExamsKey)
        }
        UserDefaults.standard.set(hasMasterBundle, forKey: masterBundleKey)
    }

    // MARK: - Purchase & Unlock Management

    func isExamUnlocked(_ exam: ASEExamID) -> Bool {
        hasMasterBundle || unlockedExams.contains(exam)
    }

    var isCurrentExamUnlocked: Bool {
        isExamUnlocked(selectedExam)
    }

    /// True if user owns at least one individual exam and qualifies for the $29.99 Master Bundle Upgrade
    var qualifiesForBundleUpgradeDiscount: Bool {
        !hasMasterBundle && !unlockedExams.isEmpty
    }

    var masterBundleDisplayPrice: String {
        qualifiesForBundleUpgradeDiscount ? "$29.99" : "$39.99"
    }

    func unlockSingleExam(_ exam: ASEExamID) {
        unlockedExams.insert(exam)
    }

    func unlockMasterBundle() {
        hasMasterBundle = true
        unlockedExams = Set(ASEExamID.allCases)
    }

    func lockExamForTesting(_ exam: ASEExamID) {
        hasMasterBundle = false
        unlockedExams.remove(exam)
    }

    // MARK: - Exam Summary Helpers for Catalog Switcher

    func questionCount(for exam: ASEExamID) -> Int {
        if exam == selectedExam {
            return fullExamQuestions.count
        }
        return loadQuestionsFromBundle(for: exam).count
    }

    func readinessScore(for exam: ASEExamID) -> Int {
        if exam == selectedExam {
            return readinessScore
        }
        let qs = loadQuestionsFromBundle(for: exam)
        guard !qs.isEmpty else { return 0 }
        let masteryMap: [Int: Bool]
        if let data = UserDefaults.standard.data(forKey: masteryKey(for: exam)),
           let decoded = try? JSONDecoder().decode([Int: Bool].self, from: data) {
            masteryMap = decoded
        } else {
            return 0
        }
        let answered = masteryMap.count
        guard answered > 0 else { return 0 }
        let mastered = masteryMap.values.filter { $0 }.count
        let coverageRatio = Double(answered) / Double(qs.count)
        let accuracyRatio = Double(mastered) / Double(answered)
        let blended = (accuracyRatio * 0.65 + coverageRatio * 0.35) * 100.0
        return min(100, Int(blended.rounded()))
    }

    // MARK: - Active Exam Domain Metadata

    var activeDomains: [ASEDomain] {
        selectedExam.activeDomains
    }

    func domainTitle(for domain: ASEDomain) -> String {
        selectedExam.spec(for: domain).title
    }

    func domainWeight(for domain: ASEDomain) -> Int {
        selectedExam.spec(for: domain).weightPercentage
    }

    func domainExamQuestionCount(for domain: ASEDomain) -> Int {
        selectedExam.spec(for: domain).examQuestionCount
    }

    func domainIcon(for domain: ASEDomain) -> String {
        selectedExam.spec(for: domain).iconName
    }

    // MARK: - Actions

    func toggleBookmark(for questionID: Int) {
        if bookmarkedIDs.contains(questionID) {
            bookmarkedIDs.remove(questionID)
        } else {
            bookmarkedIDs.insert(questionID)
        }
    }

    func isBookmarked(_ questionID: Int) -> Bool {
        bookmarkedIDs.contains(questionID)
    }

    func recordAnswer(questionID: Int, isCorrect: Bool) {
        questionMastery[questionID] = isCorrect
    }

    func recordExamSession(_ record: ExamSessionRecord) {
        examHistory.insert(record, at: 0)
    }

    func resetAllProgress() {
        questionMastery.removeAll()
        examHistory.removeAll()
        bookmarkedIDs.removeAll()
    }

    // MARK: - Computed Metrics

    var totalAnsweredCount: Int {
        questionMastery.count
    }

    var totalMasteredCount: Int {
        questionMastery.values.filter { $0 }.count
    }

    var totalMissedCount: Int {
        questionMastery.values.filter { !$0 }.count
    }

    var overallAccuracyPercentage: Double {
        guard totalAnsweredCount > 0 else { return 0 }
        return (Double(totalMasteredCount) / Double(totalAnsweredCount)) * 100.0
    }

    func questions(for domain: ASEDomain) -> [Question] {
        allQuestions.filter { $0.domain == domain }
    }

    func masteredCount(for domain: ASEDomain) -> Int {
        questions(for: domain).filter { questionMastery[$0.id] == true }.count
    }

    func answeredCount(for domain: ASEDomain) -> Int {
        questions(for: domain).filter { questionMastery[$0.id] != nil }.count
    }

    var missedQuestionsList: [Question] {
        allQuestions.filter { questionMastery[$0.id] == false }
    }

    var bookmarkedQuestionsList: [Question] {
        allQuestions.filter { bookmarkedIDs.contains($0.id) }
    }

    var readinessScore: Int {
        guard !fullExamQuestions.isEmpty else { return 0 }
        let coverageRatio = Double(totalAnsweredCount) / Double(fullExamQuestions.count)
        let accuracyRatio = totalAnsweredCount > 0 ? (Double(totalMasteredCount) / Double(totalAnsweredCount)) : 0.0
        let blended = (accuracyRatio * 0.65 + coverageRatio * 0.35) * 100.0
        return min(100, Int(blended.rounded()))
    }

    var questionOfTheDay: Question? {
        guard !allQuestions.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let idx = (dayOfYear - 1) % allQuestions.count
        return allQuestions[idx]
    }

    func buildQuestions(for mode: QuizMode) -> [Question] {
        switch mode {
        case .quick10Quiz:
            let priority = allQuestions.filter { questionMastery[$0.id] != true }.shuffled()
            if priority.count >= 10 {
                return Array(priority.prefix(10))
            } else {
                let remaining = allQuestions.filter { questionMastery[$0.id] == true }.shuffled()
                return Array((priority + remaining).prefix(10))
            }
        case .practiceAll(let shuffled):
            return shuffled ? allQuestions.shuffled() : allQuestions
        case .domainDrill(let domain):
            return questions(for: domain)
        case .archetypeDrill(let archetype):
            return allQuestions.filter { $0.archetype == archetype }
        case .missedQuestions:
            return missedQuestionsList
        case .bookmarkedQuestions:
            return bookmarkedQuestionsList
        case .simulatedExam:
            var examSet: [Question] = []
            for spec in selectedExam.domainSpecs {
                let domainPool = questions(for: spec.domain)
                let unseen = domainPool.filter { questionMastery[$0.id] == nil }.shuffled()
                let missed = domainPool.filter { questionMastery[$0.id] == false }.shuffled()
                let mastered = domainPool.filter { questionMastery[$0.id] == true }.shuffled()
                let prioritizedPool = unseen + missed + mastered
                let slice = prioritizedPool.prefix(spec.examQuestionCount)
                examSet.append(contentsOf: slice)
            }
            return examSet.shuffled()
        }
    }
}
