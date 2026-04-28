import Foundation

/// 순수 함수: Todo 상태 변환 로직
/// 입력 데이터를 받아 새로운 상태를 반환합니다. 외부 상태를 변경하지 않습니다.
enum TodoMutationLogic {

    struct ToggleResult {
        let incomplete: [Todo]
        let completed: [Todo]
    }

    /// 할 일 완료/미완료 토글 — 새로운 배열을 반환
    static func toggleComplete(
        todoId: String,
        incomplete: [Todo],
        completed: [Todo]
    ) -> ToggleResult {
        var inc = incomplete
        var comp = completed

        if let i = inc.firstIndex(where: { $0.id == todoId }) {
            var t = inc.remove(at: i)
            t.isCompleted = true
            t.completedAt = .now
            comp.insert(t, at: 0)
        } else if let i = comp.firstIndex(where: { $0.id == todoId }) {
            var t = comp.remove(at: i)
            t.isCompleted = false
            t.completedAt = nil
            inc.insert(t, at: 0)
        }

        return ToggleResult(incomplete: inc, completed: comp)
    }

    struct SoftDeleteResult {
        let incomplete: [Todo]
        let completed: [Todo]
        let trash: [Todo]
        let deletedTodo: Todo
    }

    /// 소프트 삭제 — 새로운 배열을 반환
    static func softDelete(
        todo: Todo,
        incomplete: [Todo],
        completed: [Todo],
        trash: [Todo]
    ) -> SoftDeleteResult {
        var inc = incomplete
        var comp = completed
        var tr = trash

        inc.removeAll { $0.id == todo.id }
        comp.removeAll { $0.id == todo.id }

        var t = todo
        t.isDeleted = true
        t.deletedAt = .now
        tr.insert(t, at: 0)

        return SoftDeleteResult(incomplete: inc, completed: comp, trash: tr, deletedTodo: todo)
    }

    struct RestoreResult {
        let incomplete: [Todo]
        let completed: [Todo]
        let trash: [Todo]
    }

    /// 휴지통에서 복원 — 새로운 배열을 반환
    static func restore(
        todo: Todo,
        incomplete: [Todo],
        completed: [Todo],
        trash: [Todo]
    ) -> RestoreResult {
        var inc = incomplete
        var comp = completed
        var tr = trash

        tr.removeAll { $0.id == todo.id }
        var t = todo
        t.isDeleted = false
        t.deletedAt = nil

        if t.isCompleted { comp.insert(t, at: 0) }
        else { inc.insert(t, at: 0) }

        return RestoreResult(incomplete: inc, completed: comp, trash: tr)
    }

    /// 할 일 필드 업데이트 — 새로운 배열을 반환
    static func update(
        id: String,
        title: String,
        memo: String?,
        dueDate: Date?,
        priority: Priority,
        categoryName: String?,
        categoryColor: String?,
        reminderMinutes: Int?,
        incomplete: [Todo],
        completed: [Todo]
    ) -> ToggleResult {
        var inc = incomplete
        var comp = completed

        func applyUpdate(_ todo: inout Todo) {
            todo.title = title
            todo.memo = memo
            todo.dueDate = dueDate
            todo.priority = priority
            todo.categoryName = categoryName
            todo.categoryColor = categoryColor
            todo.reminderMinutes = reminderMinutes
        }

        if let i = inc.firstIndex(where: { $0.id == id }) {
            applyUpdate(&inc[i])
        } else if let i = comp.firstIndex(where: { $0.id == id }) {
            applyUpdate(&comp[i])
        }

        return ToggleResult(incomplete: inc, completed: comp)
    }

    /// 제목 유효성 검사
    static func isValidTitle(_ title: String) -> Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - 연속 할일 날짜별 완료 토글

    /// 연속 할일의 특정 날짜 완료/미완료 토글 — incomplete 배열만 변경
    static func toggleDailyCompletion(
        todoId: String,
        date: Date,
        incomplete: [Todo]
    ) -> [Todo] {
        var inc = incomplete
        guard let i = inc.firstIndex(where: { $0.id == todoId }) else { return inc }

        let key = Todo.dateKey(for: date)
        if inc[i].dailyCompletions[key] != nil {
            inc[i].dailyCompletions.removeValue(forKey: key)
        } else {
            inc[i].dailyCompletions[key] = .now
        }
        return inc
    }

    /// 할 일 필드 업데이트 (연속 할일 포함) — 새로운 배열을 반환
    static func updateWithPeriod(
        id: String,
        title: String,
        memo: String?,
        dueDate: Date?,
        startDate: Date?,
        endDate: Date?,
        priority: Priority,
        categoryName: String?,
        categoryColor: String?,
        reminderMinutes: Int?,
        incomplete: [Todo],
        completed: [Todo]
    ) -> ToggleResult {
        var inc = incomplete
        var comp = completed

        func applyUpdate(_ todo: inout Todo) {
            todo.title = title
            todo.memo = memo
            todo.dueDate = dueDate
            todo.startDate = startDate
            todo.endDate = endDate
            todo.priority = priority
            todo.categoryName = categoryName
            todo.categoryColor = categoryColor
            todo.reminderMinutes = reminderMinutes
        }

        if let i = inc.firstIndex(where: { $0.id == id }) {
            applyUpdate(&inc[i])
        } else if let i = comp.firstIndex(where: { $0.id == id }) {
            applyUpdate(&comp[i])
        }

        return ToggleResult(incomplete: inc, completed: comp)
    }
}
