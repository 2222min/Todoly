import Foundation

/// 알림 스케줄링 추상화 — 구체 구현이 아닌 Protocol에 의존
protocol NotificationScheduling {
    @discardableResult
    func requestPermission() async -> Bool
    func scheduleReminder(for todo: Todo, minutesBefore: Int?)
    func scheduleTestReminder(for todo: Todo)
    func cancelReminder(todoId: String)
}
