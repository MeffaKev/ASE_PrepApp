import SwiftUI

@main
struct ASE_PrepApp: App {
    @StateObject private var store = StudyStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}
