import SwiftUI
import UserNotifications

@main
struct TodolyApp: App {
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .task {
                    await NotificationService.shared.requestPermission()
                }
        }
    }
}
