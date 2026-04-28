import Foundation

struct Todo: Identifiable, Codable {
    var id = UUID().uuidString
    var title: String
    var memo: String?
    var dueDate: Date?
    var priority: Priority = .none
    var categoryName: String?
    var categoryColor: String?
    var isCompleted = false
    var completedAt: Date?
    var isDeleted = false
    var deletedAt: Date?
    var createdAt = Date()
    var reminderMinutes: Int?

    // MARK: - 연속 할일 (Period Task)
    var startDate: Date?
    var endDate: Date?
    var dailyCompletions: [String: Date] = [:]

    /// 연속 할일 여부
    var isPeriodTask: Bool {
        startDate != nil && endDate != nil
    }

    /// 특정 날짜에 활성 상태인지
    func isActiveOn(_ date: Date) -> Bool {
        guard let start = startDate, let end = endDate else { return false }
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)
        return day >= cal.startOfDay(for: start) && day <= cal.startOfDay(for: end)
    }

    /// 특정 날짜에 완료했는지
    func isCompletedOn(_ date: Date) -> Bool {
        dailyCompletions[Self.dateKey(for: date)] != nil
    }

    /// 날짜 키 생성 ("yyyy-MM-dd")
    static func dateKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }

    /// 기간 내 총 일수
    var totalDays: Int {
        guard let start = startDate, let end = endDate else { return 0 }
        let cal = Calendar.current
        return (cal.dateComponents([.day], from: cal.startOfDay(for: start), to: cal.startOfDay(for: end)).day ?? 0) + 1
    }

    /// 완료한 일수
    var completedDays: Int {
        dailyCompletions.count
    }

    /// 오늘이 시작일로부터 몇 일째인지 (1-based)
    func dayNumber(on date: Date) -> Int {
        guard let start = startDate else { return 0 }
        let cal = Calendar.current
        return (cal.dateComponents([.day], from: cal.startOfDay(for: start), to: cal.startOfDay(for: date)).day ?? 0) + 1
    }
}
