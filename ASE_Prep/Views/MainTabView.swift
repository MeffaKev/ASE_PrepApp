import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: StudyStore

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Study & Exam", systemImage: "wrench.and.screwdriver.fill")
                }

            TestPrepGuideView()
                .tabItem {
                    Label("Test Prep", systemImage: "graduationcap.fill")
                }

            StudyReferenceView()
                .tabItem {
                    Label("Shop Reference", systemImage: "book.pages.fill")
                }

            ExamHistoryView()
                .tabItem {
                    Label("Scores", systemImage: "chart.bar.fill")
                }
        }
    }
}
