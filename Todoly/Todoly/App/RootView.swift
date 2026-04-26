import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAlarm = false
    @State private var alarmTitle = ""
    @State private var alarmSubtitle = ""

    var body: some View {
        ZStack {
            switch appState.screen {
            case .splash: SplashView()
            case .login: LoginView()
            case .main: MainTabView()
            }

            if showAlarm {
                AlarmView(
                    todoTitle: alarmTitle,
                    subtitle: alarmSubtitle,
                    onDismiss: { withAnimation { showAlarm = false } }
                )
                .transition(.opacity)
                .zIndex(999)
            }
        }
        .onAppear {
            NotificationService.shared.onAlarmTriggered = { title, subtitle in
                alarmTitle = title
                alarmSubtitle = subtitle
                withAnimation { showAlarm = true }
            }
        }
    }
}

// MARK: - Preview

#Preview("Root - Splash") {
    RootView()
        .environmentObject(AppState())
}

#Preview("Root - Main") {
    let state = AppState()
    state.screen = .main
    return RootView()
        .environmentObject(state)
        .environmentObject(TodoStore())
}
