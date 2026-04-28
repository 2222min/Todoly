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

    // MARK: - 연속 할일 배지

    /// 연속 할일 배지 텍스트 ("N일째", "N일째 ✓")
    static func periodBadge(for todo: Todo, on date: Date = .now) -> (String, BadgeStyle)? {
        guard todo.isPeriodTask, todo.isActiveOn(date) else { return nil }
        let dayNum = todo.dayNumber(on: date)
        if todo.isCompletedOn(date) {
            return ("\(dayNum)일째 ✓", .today)
        } else {
            return ("\(dayNum)일째", .upcoming)
        }
    }

    /// 연속 할일 진행률 (완료일수, 전체일수)
    static func periodProgress(for todo: Todo) -> (completed: Int, total: Int) {
        (todo.completedDays, todo.totalDays)
    }
}
