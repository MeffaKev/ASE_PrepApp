import SwiftUI

struct TestPrepGuideView: View {
    @EnvironmentObject var store: StudyStore
    @State private var selectedSection: PrepSection = .register
    @State private var checkedChecklistItems: Set<String> = []
    @State private var showingQuestionBankSheet: Bool = false

    enum PrepSection: String, CaseIterable, Identifiable {
        case register = "Registration"
        case expect = "Test Day"
        case tips = "Passing Tips"
        case experience = "Certification"
        var id: String { rawValue }
    }

    private let checklistItems: [(id: String, title: String, subtitle: String)] = [
        ("account", "Create or Find Your myASE Account", "Use your exact legal name as it appears on your government-issued photo ID."),
        ("purchase", "Purchase Test Within 90-Day Window", "Bundle multiple ASE tests in one cart to pay the $34 registration fee only once."),
        ("schedule", "Schedule Prometric Appointment", "Pick your date and testing center early; confirm your Admission Ticket details."),
        ("id", "Pack Valid Government Photo ID", "Must be unexpired, original, with photo and signature matching your myASE name."),
        ("early", "Arrive 30 Minutes Early", "Late arrivals are turned away by Prometric and forfeit test fees.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    domainOrSectionContent

                    legalDisclaimerFooter
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .top) {
                Picker("Prep Guide Section", selection: $selectedSection) {
                    ForEach(PrepSection.allCases) { sec in
                        Text(sec.rawValue).tag(sec)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .liquidGlassFloatingBar(cornerRadius: 18)
                .padding(.horizontal, 14)
                .padding(.top, 4)
            }
            .navigationTitle("Preparing for ASE \(store.selectedExam.code)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingQuestionBankSheet = true
                    } label: {
                        Label("Browse \(store.allQuestions.count) Qs", systemImage: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingQuestionBankSheet) {
                QuestionBankBrowserView()
                    .environmentObject(store)
            }
        }
    }

    @ViewBuilder
    private var domainOrSectionContent: some View {
        switch selectedSection {
        case .register:
            registrationSection
        case .expect:
            whatToExpectSection
        case .tips:
            testTakingTipsSection
        case .experience:
            workExperienceSection
        }
    }

    private var legalDisclaimerFooter: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("© 2026 Treanor Corp. All rights reserved.")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text("Disclaimer: ASE® and National Institute for Automotive Service Excellence® are registered trademarks of the National Institute for Automotive Service Excellence. This application is developed independently by Treanor Corp and is not affiliated with, endorsed by, or sponsored by ASE.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineSpacing(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 1. Registration & Scheduling Section

    private var registrationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            heroHeaderCard(
                badge: "STEP-BY-STEP REGISTRATION",
                title: "How to Register & Save on Fees",
                subtitle: "All ASE test purchases and Prometric appointments are managed through your official myASE portal at ASE.com.",
                icon: "person.badge.key.fill",
                color: .blue
            )

            // Interactive Pre-Exam Checklist
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Interactive Pre-Exam Checklist")
                        .font(.headline)
                    Spacer()
                    Text("\(checkedChecklistItems.count)/\(checklistItems.count) Done")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.blue)
                }

                ForEach(checklistItems, id: \.id) { item in
                    let isChecked = checkedChecklistItems.contains(item.id)
                    Button {
                        withAnimation(.snappy) {
                            if isChecked {
                                _ = checkedChecklistItems.remove(item.id)
                            } else {
                                _ = checkedChecklistItems.insert(item.id)
                            }
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(isChecked ? .green : .secondary)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(isChecked ? .secondary : .primary)
                                    .strikethrough(isChecked)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            guideCard(
                stepNumber: "1",
                color: .blue,
                title: "Never Create a Duplicate myASE Account",
                bodyText: "If you have ever registered for an ASE student test, entry-level test, or certification exam in the past, you already have an ASE ID. Use the 'Find My Account' tool on myASE—creating a second profile splits your test history and delays certification."
            )

            guideCard(
                stepNumber: "2",
                color: .indigo,
                title: "Fee Structure & The Single-Cart Money Saver",
                bodyText: "ASE charges a flat $34 registration fee per order/checkout, plus ~$62 per individual A-Series test (A1–A9).\n\n• Pro Tip: If you plan to take A1 plus another test (e.g., A8 Engine Performance) within the next 3 months, buy them in the SAME cart so you only pay the $34 registration fee once."
            )

            guideCard(
                stepNumber: "3",
                color: .teal,
                title: "The 90-Day Eligibility Window",
                bodyText: "From the day you purchase your test, you have exactly 90 days to schedule and sit for the exam at a Prometric Test Center. If your plans change before your 90-day window expires, you can reschedule or request a refund directly inside myASE."
            )
        }
    }

    // MARK: - 2. What to Expect on Test Day

    private var whatToExpectSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            heroHeaderCard(
                badge: "PROMETRIC TEST CENTER LOGISTICS",
                title: "What to Expect on Exam Day (\(store.selectedExam.code))",
                subtitle: "Initial \(store.selectedExam.fullTitle) certification exams are administered in person at proctored Prometric Test Centers.",
                icon: "building.columns.fill",
                color: .indigo
            )

            // Exam Blueprint Numbers Grid
            HStack(spacing: 10) {
                metricBox(value: "\(store.selectedExam.totalExamQuestions)", label: "Total Qs", detail: "\(store.selectedExam.scoredExamQuestions) Scored + 10 Research")
                metricBox(value: "\(store.selectedExam.examTimeLimitMinutes)m", label: "Time Limit", detail: "Official Prometric Timer")
                metricBox(value: "Instant", label: "Results", detail: "Score on screen at end")
            }

            guideCard(
                stepNumber: "ID",
                color: .red,
                title: "Strict Identification & Name-Match Rule",
                bodyText: "Bring a valid, unexpired government-issued photo ID with a signature (Driver's License, State ID, Passport, or Military ID). The first and last name on your ID must match your myASE account registration exactly—otherwise the proctor cannot sign you in."
            )

            guideCard(
                stepNumber: "🔒",
                color: .orange,
                title: "Airport-Style Security & Locker Rules",
                bodyText: "• Arrive 30 minutes before your scheduled appointment.\n• All personal items (phones, smartwatches, keys, wallets, hats, hoodies with pockets, notes, and calculators) must be locked in the provided locker.\n• You will undergo a brief security check (pocket turn-out, eyewear check, and metal detector wand) before entering the quiet computer lab.\n• The proctor provides an erasable noteboard/scratch paper and marker for calculations."
            )

            guideCard(
                stepNumber: "🧪",
                color: .purple,
                title: "Why There Are \(store.selectedExam.totalExamQuestions) Questions (10 Unscored)",
                bodyText: "Your \(store.selectedExam.code) exam contains \(store.selectedExam.scoredExamQuestions) scored questions that count toward your grade, plus 10 unscored ASE statistical research questions mixed in randomly. Because there is no way to tell which 10 are unscored, treat all \(store.selectedExam.totalExamQuestions) questions with equal care."
            )

            guideCard(
                stepNumber: "💻",
                color: .blue,
                title: "Prometric 'Flag for Review' & App Exam Controls",
                bodyText: "• At the Prometric test center, you can click 'Flag for Review' on any tough question and jump back to it from the Review Summary screen before time expires.\n• In this app's 55-Q Mock Exam mode, tap the Flag icon (⚑) at the bottom of the screen to mark a question for review, then tap the Grid icon (⊞) in the top-right corner to see all flagged and unanswered questions at a glance.\n• There is NO penalty for guessing—never leave a question blank!"
            )
        }
    }

    // MARK: - 3. Proven ASE Test-Taking Tips

    private var testTakingTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            heroHeaderCard(
                badge: "HIGH-SCORE STRATEGIES",
                title: "How to Think Like an ASE Question Writer",
                subtitle: "ASE questions are written by working master technicians, OEM engineers, and instructors—here is how to beat common traps.",
                icon: "brain.head.profile",
                color: .orange
            )

            guideCard(
                stepNumber: "1",
                color: .green,
                title: "Answer 'By the Book'—Not Shop Shortcuts",
                bodyText: "In a busy repair bay, techs sometimes skip a step based on intuition. On the ASE exam, ALWAYS choose the textbook OEM service manual procedure:\n\n• Always verify the customer complaint first.\n• Always check fluid level/condition and basic mechanical health before condemning expensive assemblies.\n• Never reuse Torque-To-Yield (TTY) bolts or skip precision measurements."
            )

            guideCard(
                stepNumber: "2",
                color: .blue,
                title: "How to Dissect Technician A / Technician B",
                bodyText: "Roughly 30–40% of the exam uses the Technician A / Technician B format:\n\n1. Cover up Technician B and read ONLY Technician A. Decide if Tech A is 100% True or False.\n2. Watch out for 'half-true' traps where Tech A uses the right specification with the wrong tool (e.g., using an outside micrometer to measure cylinder bore taper).\n3. Once you know if Tech A is True or False, you immediately eliminate 2 of the 4 answer choices before even reading Tech B!"
            )

            guideCard(
                stepNumber: "3",
                color: .red,
                title: "Flip the Logic on 'EXCEPT' & 'LEAST Likely'",
                bodyText: "When a question ends with EXCEPT or LEAST likely, three of the choices are TRUE statements or valid causes, and only ONE is false. Mentally write 'T' or 'F' next to (A), (B), (C), and (D) on your scratch board, then pick the odd one out."
            )

            guideCard(
                stepNumber: "4",
                color: .indigo,
                title: "The 'FIRST' vs. 'MOST Likely' Rule",
                bodyText: "• When asked 'What should the technician do FIRST?', pick the fastest, least-invasive test that verifies the symptom (e.g., connecting a mechanical oil pressure gauge or removing the serpentine belt to isolate noise).\n• When asked 'What is the MOST likely cause?', match ALL data points in the prompt (e.g., if wet compression stays low at 95 psi, eliminate piston rings and cylinder walls immediately)."
            )

            guideCard(
                stepNumber: "5",
                color: .teal,
                title: "Two-Pass Flagging Strategy (75 Minutes)",
                bodyText: "With 55 questions in 75 minutes, you have 1 minute and 21 seconds per question.\n\n• Pass 1: Answer every question you know within 45–60 seconds. If a question takes longer than 90 seconds, select your best educated guess, tap the Flag icon (⚑), and move on.\n• Pass 2: Open the Question Navigator grid (⊞ in the top-right corner) during your final 15–20 minutes to jump directly to your orange-flagged questions. Only change an answer if you realized you misread a key word (like EXCEPT or cold vs. hot)."
            )

            guideCard(
                stepNumber: "6",
                color: .purple,
                title: "How to Use the App's Bottom Question Toolbar",
                bodyText: "The bottom thumb bar on every question screen gives you instant one-handed controls:\n\n• Bookmark Icon (🔖): Saves the question to your personal 'Bookmarked' deck on the home screen for long-term study.\n• Lightbulb Icon (💡 — Study Mode): Appears as soon as you pick an answer; tap it anytime to slide up the full Explanation & Shop Tip sheet.\n• Flag Icon (⚑ — Timed Mock Exam): Mirrors the real Prometric exam's 'Flag for Review' button—marks the question in the top-right Navigator Grid (⊞) without revealing the answer until you finish."
            )
        }
    }

    // MARK: - 4. Work Experience & Certification Rules

    private var workExperienceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            heroHeaderCard(
                badge: "EARNING THE BLUE SEAL",
                title: "Work Experience & Recertification",
                subtitle: "Passing your \(store.selectedExam.rawValue) exam is step one—here is how your hands-on experience turns your passing score into official ASE Certification.",
                icon: "medal.fill",
                color: .teal
            )

            guideCard(
                stepNumber: "✓",
                color: .teal,
                title: "Take the Test Anytime—Submit Experience Later",
                bodyText: "You do NOT need to wait until you have completed 2 years of work experience to register and take the ASE \(store.selectedExam.rawValue) exam. You can pass the exam first while the material is fresh, and ASE will hold your passing credit until you complete and submit your Work Experience Form in myASE."
            )

            guideCard(
                stepNumber: "2Y",
                color: .blue,
                title: "How Formal Automotive Training Counts",
                bodyText: "Full ASE Automobile Technician certification requires 2 years of hands-on work experience—OR you can substitute formal automotive training:\n\n• A 2-year degree or certificate in automotive repair from an accredited trade school/college can substitute for up to 1 full year (50%) of the 2-year work requirement.\n• 3 full years of high school automotive training can also substitute for 1 year of work experience."
            )

            guideCard(
                stepNumber: "5Y",
                color: .purple,
                title: "Keeping Your \(store.selectedExam.rawValue) Credential Active (\(store.selectedExam.rawValue)R)",
                bodyText: "ASE certifications are valid for 5 years. To recertify (\(store.selectedExam.rawValue)R), you only take a short recertification test—or you can renew cleanly from your phone/computer using the official 'ASE Renewal App' by answering monthly questions without visiting a test center."
            )
        }
    }

    // MARK: - Reusable UI Components

    private func heroHeaderCard(badge: String, title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(badge)
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline.weight(.bold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func metricBox(value: String, label: String, detail: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.heavy))
                .foregroundStyle(.indigo)
            Text(label)
                .font(.caption.weight(.bold))
            Text(detail)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func guideCard(stepNumber: String, color: Color, title: String, bodyText: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(stepNumber)
                    .font(.caption.weight(.heavy))
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.15))
                    .foregroundStyle(color)
                    .clipShape(Circle())

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
            }

            Text(bodyText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3.5)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlassCard(cornerRadius: 16)
    }
}
