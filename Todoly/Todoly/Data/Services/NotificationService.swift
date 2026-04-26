import Foundation
import UserNotifications

#if canImport(ActivityKit)
import ActivityKit
#endif

/// 알림 서비스 — NotificationScheduling 프로토콜 구현
final class NotificationService: NotificationScheduling {
    static let shared = NotificationService()
    private init() {}

    /// 포그라운드 알람 표시를 위한 콜백
    var onAlarmTriggered: ((String, String) -> Void)?

    #if canImport(ActivityKit)
    /// 현재 활성 Live Activity
    private var currentActivity: Activity<TodoAlarmAttributes>?
    #endif
    private var liveActivityTimer: Timer?

    @discardableResult
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("알림 권한 요청 실패: \(error)")
            return false
        }
    }

    func scheduleReminder(for todo: Todo, minutesBefore: Int?) {
        guard let minutes = minutesBefore, let dueDate = todo.dueDate else { return }
        cancelReminder(todoId: todo.id)

        let reminderDate = dueDate.addingTimeInterval(-Double(minutes * 60))
        guard reminderDate > Date() else { return }

        let content = buildNotificationContent(
            title: todo.title,
            subtitle: reminderSubtitle(minutesBefore: minutes),
            todoId: todo.id
        )

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "todo-\(todo.id)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("알림 등록 실패: \(error)") }
        }
    }

    func scheduleTestReminder(for todo: Todo) {
        cancelReminder(todoId: todo.id)

        let content = buildNotificationContent(title: todo.title, subtitle: "알림 테스트", todoId: todo.id)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "todo-\(todo.id)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("테스트 알림 실패: \(error)") }
        }
    }

    func cancelReminder(todoId: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["todo-\(todoId)"])
    }
}

// MARK: - Private Helpers (순수 함수)

private extension NotificationService {

    /// 알림 콘텐츠 생성 — 커스텀 알람 사운드 (30초, 무음모드 관통)
    func buildNotificationContent(title: String, subtitle: String, todoId: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Todoly 📋"
        content.body = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.criticalSoundNamed(
            UNNotificationSoundName("todoly_alarm.caf"), withAudioVolume: 1.0
        )
        content.interruptionLevel = .timeSensitive
        content.userInfo = ["todoId": todoId]
        return content
    }

    /// 알림 부제목 계산 — 순수 함수
    func reminderSubtitle(minutesBefore minutes: Int) -> String {
        if minutes == 0 { return "마감 시간입니다!" }
        if minutes < 60 { return "\(minutes)분 후 마감" }
        if minutes < 1440 { return "\(minutes / 60)시간 후 마감" }
        return "\(minutes / 1440)일 후 마감"
    }
}

// MARK: - Live Activity

extension NotificationService {

    /// 알람 시 Live Activity 시작 — 잠금화면 + Dynamic Island에 표시
    func startAlarmLiveActivity(todoTitle: String, subtitle: String, todoId: String) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TodoAlarmAttributes(
            todoTitle: todoTitle,
            subtitle: subtitle,
            todoId: todoId
        )
        let initialState = TodoAlarmAttributes.ContentState(
            remainingTime: "지금",
            isRinging: true
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity

            // 1분마다 Live Activity 상태 업데이트 (최대 8시간 유지)
            var elapsed = 0
            liveActivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] timer in
                elapsed += 1
                if elapsed >= 480 { // 8시간 후 자동 종료
                    self?.endAlarmLiveActivity()
                    return
                }
                let state = TodoAlarmAttributes.ContentState(
                    remainingTime: "\(elapsed)분 경과",
                    isRinging: true
                )
                Task {
                    await activity.update(.init(state: state, staleDate: nil))
                }
            }
        } catch {
            print("Live Activity 시작 실패: \(error)")
        }
        #endif
    }

    /// Live Activity 종료
    func endAlarmLiveActivity() {
        liveActivityTimer?.invalidate()
        liveActivityTimer = nil

        #if canImport(ActivityKit)
        let finalState = TodoAlarmAttributes.ContentState(
            remainingTime: "완료",
            isRinging: false
        )
        Task {
            await currentActivity?.end(
                .init(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
            currentActivity = nil
        }
        #endif
    }
}

// MARK: - Test Helpers

extension NotificationService {
    /// 테스트용: reminderSubtitle 접근
    func testReminderSubtitle(minutesBefore minutes: Int) -> String {
        reminderSubtitle(minutesBefore: minutes)
    }

    /// 테스트용: buildNotificationContent 접근
    func testBuildContent(title: String, subtitle: String, todoId: String) -> UNMutableNotificationContent {
        buildNotificationContent(title: title, subtitle: subtitle, todoId: todoId)
    }
}
