import Foundation

/// 순수 함수: Todo 필터링 로직
/// 외부 상태를 변경하지 않으며, 같은 입력에 항상 같은 출력을 반환합니다.
enum TodoFilterLogic {

    /// dueDate가 있는 활성 할 일 필터링
    static func todosWithDueDate(from incomplete: [Todo], completed: [Todo]) -> [Todo] {
        (incomplete + completed).filter { $0.dueDate != nil && !$0.isDeleted }
    }

    /// 특정 날짜의 할 일 필터링
    static func todos(for date: Date, from incomplete: [Todo], completed: [Todo]) -> [Todo] {
        todosWithDueDate(from: incomplete, completed: completed).filter {
            Calendar.current.isDate($0.dueDate!, inSameDayAs: date)
        }
    }

    /// 특정 날짜의 미완료 할 일 필터링
    static func incompleteTodos(for date: Date, from incomplete: [Todo]) -> [Todo] {
        incomplete.filter {
            guard let due = $0.dueDate else { return false }
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

    /// dueDate가 없는 미완료 할 일 필터링 (날짜 미지정 섹션용)
    static func todosWithoutDueDate(from incomplete: [Todo]) -> [Todo] {
        incomplete.filter { $0.dueDate == nil && !$0.isDeleted }
    }

    /// 특정 날짜의 완료 할 일 필터링 (dueDate 또는 completedAt 기준)
    /// - dueDate가 있으면 dueDate 기준
    /// - dueDate가 없으면 completedAt 기준
    static func completedTodos(for date: Date, from completed: [Todo]) -> [Todo] {
        completed.filter { todo in
            guard !todo.isDeleted else { return false }
            if let due = todo.dueDate {
                return Calendar.current.isDate(due, inSameDayAs: date)
            } else if let completedAt = todo.completedAt {
                return Calendar.current.isDate(completedAt, inSameDayAs: date)
            }
            return false
        }
    }
}
