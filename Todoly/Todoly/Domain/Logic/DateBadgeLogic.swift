import Foundation

/// 순수 함수: 날짜 배지 계산 로직
enum DateBadgeLogic {

    /// 날짜에 대한 배지 텍스트와 스타일을 계산
    static func badge(for date: Date, relativeTo now: Date = .now) -> (String, BadgeStyle)? {
        let cal = Calendar.current
        let days = cal.dateComponents(
            [.day],
            from: cal.startOfDay(for: now),
            to: cal.startOfDay(for: date)
        ).day ?? 0

        if days < 0 { return ("지연", .overdue) }
        if days == 0 { return ("오늘", .today) }
        if days == 1 { return ("내일", .tomorrow) }
        if days <= 7 { return ("D-\(days)", .upcoming) }
        return nil
    }

    /// 캘린더 dot indicator 색상 계산
    static func dotPriorityColors(for todos: [Todo]) -> [Priority] {
        guard !todos.isEmpty else { return [] }

        if todos.allSatisfy({ $0.isCompleted }) {
            return [.none]
        }

        var seen = Set<Priority>()
        var unique: [Priority] = []
        for todo in todos where !todo.isCompleted {
            if seen.insert(todo.priority).inserted {
                unique.append(todo.priority)
            }
        }

        return Array(unique.sorted { $0.sortOrder < $1.sortOrder }.prefix(3))
    }
}
