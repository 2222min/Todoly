import SwiftUI

@main
struct TodolyWatchApp: App {
    @StateObject private var store = WatchStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                TodayListView()
                    .environmentObject(store)
                CompletedListView()
                    .environmentObject(store)
            }
            .tabViewStyle(.verticalPage)
        }
    }
}
