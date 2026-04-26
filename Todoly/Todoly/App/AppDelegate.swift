import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    /// 포그라운드에서 알림 수신 → 풀스크린 알람 뷰 + Live Activity 트리거
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let content = notification.request.content
        let todoId = content.userInfo["todoId"] as? String ?? ""
        NotificationService.shared.startAlarmLiveActivity(
            todoTitle: content.body, subtitle: content.subtitle, todoId: todoId
        )
        NotificationService.shared.onAlarmTriggered?(content.body, content.subtitle)
        completionHandler([])
    }

    /// 백그라운드에서 알림 탭 → 앱 열면서 알람 뷰 + Live Activity 트리거
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let content = response.notification.request.content
        let todoId = content.userInfo["todoId"] as? String ?? ""
        NotificationService.shared.startAlarmLiveActivity(
            todoTitle: content.body, subtitle: content.subtitle, todoId: todoId
        )
        NotificationService.shared.onAlarmTriggered?(content.body, content.subtitle)
        completionHandler()
    }
}
