import Foundation

/// 순수 함수: Todo 필터링 로직
/// 외부 상태를 변경하지 않으며, 같은 입력에 항상 같은 출력을 반환합니다.
enum TodoFilterLogic {

    /// dueDate가 있는 활성 할 일 필터링 (+ 연속 할일)
    static func todosWithDueDate(from incomplete: [Todo], completed: [Todo]) -> [Todo] {
        (incomplete + completed).filter { ($0.dueDate != nil || $0.isPeriodTask) && !$0.isDeleted }
    }

    /// 특정 날짜의 할 일 필터링 (일반 + 연속 할일)
    static func todos(for date: Date, from incomplete: [Todo], completed: [Todo]) -> [Todo] {
        let regular = todosWithDueDate(from: incomplete, completed: completed).filter { todo in
            if todo.isPeriodTask { return todo.isActiveOn(date) }
            guard let due = todo.dueDate else { return false }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }
        return regular
    }

    /// 특정 날짜의 미완료 할 일 필터링 (일반 + 연속 할일)
    static func incompleteTodos(for date: Date, from incomplete: [Todo]) -> [Todo] {
        incomplete.filter { todo in
            guard !todo.isDeleted else { return false }
            // 연속 할일: 해당 날짜에 활성이고 미완료
            if todo.isPeriodTask {
                return todo.isActiveOn(date) && !todo.isCompletedOn(date)
            }
            // 일반 할일: dueDate 기준
            guard let due = todo.dueDate else { return false }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }
    }

    /// 카테고리별 미완료 할 일 필터링
    static func incompleteTodos(forCategory name: String, from incomplete: [Todo]) -> [Todo] {
        incomplete.filter { $0.categoryName == name }
    }

    /// 검색어로 할 일 필터링
    static func search(query: String, in todos: [Todo]) -> [Todo] {
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else { return [] }
        return todos.filter {
            $0.title.lowercased().contains(trimmed) ||
            ($0.memo?.lowercased().contains(trimmed) ?? false) ||
            ($0.categoryName?.lowercased().contains(trimmed) ?? false)
        }
    }

    /// 캘린더용: 특정 날짜의 미완료 할 일 (오늘이면 dueDate 없는 할일도 포함)
    static func calendarIncompleteTodos(for date: Date, from incomplete: [Todo]) -> [Todo] {
        let isToday = Calendar.current.isDateInToday(date)
        return incomplete.filter { todo in
            guard !todo.isDeleted else { return false }
            if todo.isPeriodTask {
                return todo.isActiveOn(date) && !todo.isCompletedOn(date)
            }
            guard let due = todo.dueDate else { return isToday }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }
    }

    /// dueDate가 없는 미완료 할 일 필터링 (날짜 미지정 섹션용, 연속 할일 제외)
    static func todosWithoutDueDate(from incomplete: [Todo]) -> [Todo] {
        incomplete.filter { $0.dueDate == nil && !$0.isPeriodTask && !$0.isDeleted }
    }

    /// 특정 날짜의 완료 할 일 필터링 (dueDate 또는 completedAt 기준 + 연속 할일)
    /// - dueDate가 있으면 dueDate 기준
    /// - dueDate가 없으면 completedAt 기준
    /// - 연속 할일은 해당 날짜의 dailyCompletions 기준
    static func completedTodos(for date: Date, from completed: [Todo], incomplete: [Todo] = []) -> [Todo] {
        var result = completed.filter { todo in
            guard !todo.isDeleted, !todo.isPeriodTask else { return false }
            if let due = todo.dueDate {
                return Calendar.current.isDate(due, inSameDayAs: date)
            } else if let completedAt = todo.completedAt {
                return Calendar.current.isDate(completedAt, inSameDayAs: date)
            }
            return false
        }
        // 연속 할일 중 해당 날짜에 완료된 것
        let completedPeriod = incomplete.filter { todo in
            todo.isPeriodTask && !todo.isDeleted && todo.isActiveOn(date) && todo.isCompletedOn(date)
        }
        result.append(contentsOf: completedPeriod)
        return result
    }

    // MARK: - 오늘 필터 (할일 탭용)

    /// 오늘 미완료 일반 할일 (dueDate == 오늘/지연 + 마감일 없는 할일)
    static func todayIncompleteRegular(from incomplete: [Todo], today: Date = .now) -> [Todo] {
        let cal = Calendar.current
        return incomplete.filter { todo in
            guard !todo.isPeriodTask, !todo.isDeleted else { return false }
            // 마감일 없는 할일 → 항상 오늘 탭에 노출
            guard let due = todo.dueDate else { return true }
            // 마감일 있는 할일 → 오늘이거나 지연
            return cal.isDate(due, inSameDayAs: today) || cal.startOfDay(for: due) < cal.startOfDay(for: today)
        }
    }

    /// 오늘 활성 연속 할일 (완료/미완료 모두)
    static func todayActivePeriodTodos(from incomplete: [Todo], today: Date = .now) -> [Todo] {
        incomplete.filter { todo in
            guard todo.isPeriodTask, !todo.isDeleted else { return false }
            return todo.isActiveOn(today)
        }
    }

    /// 오늘 완료된 일반 할일 (completedAt == 오늘)
    static func todayCompletedTodos(from completed: [Todo], today: Date = .now) -> [Todo] {
        let cal = Calendar.current
        return completed.filter { todo in
            guard !todo.isDeleted, !todo.isPeriodTask else { return false }
            guard let completedAt = todo.completedAt else { return false }
            return cal.isDate(completedAt, inSameDayAs: today)
        }
    }

    /// 오늘 미완료 카운트 (Hero용)
    static func todayIncompleteCount(from incomplete: [Todo], today: Date = .now) -> Int {
        let regular = todayIncompleteRegular(from: incomplete, today: today).count
        let period = todayActivePeriodTodos(from: incomplete, today: today)
            .filter { !$0.isCompletedOn(today) }.count
        return regular + period
    }

    // MARK: - 캘린더용 연속 할일 필터

    /// 특정 날짜에 활성인 연속 할일 (캘린더용)
    static func periodTodosActive(on date: Date, from incomplete: [Todo]) -> [Todo] {
        incomplete.filter { $0.isPeriodTask && !$0.isDeleted && $0.isActiveOn(date) }
    }
}
