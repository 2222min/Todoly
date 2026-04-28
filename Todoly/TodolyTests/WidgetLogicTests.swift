import XCTest
@testable import Todoly

/// 위젯에서 사용하는 필터/뮤테이션 로직 테스트
final class WidgetLogicTests: XCTestCase {

    // MARK: - 위젯용 오늘 미완료 필터

    func testTodayIncompleteRegularForWidget() {
        let cal = Calendar.current
        let todos = [
            Todo(title: "오늘 할 일", dueDate: .now, priority: .high),
            Todo(title: "지연된 할 일", dueDate: cal.date(byAdding: .day, value: -2, to: .now), priority: .medium),
            Todo(title: "내일 할 일", dueDate: cal.date(byAdding: .day, value: 1, to: .now), priority: .low),
            Todo(title: "마감일 없음", priority: .none),
        ]

        let filtered = TodoFilterLogic.todayIncompleteRegular(from: todos)
        // 오늘 + 지연 + 마감일 없음 = 3개 (내일은 제외)
        XCTAssertEqual(filtered.count, 3)
        XCTAssertTrue(filtered.contains { $0.title == "오늘 할 일" })
        XCTAssertTrue(filtered.contains { $0.title == "지연된 할 일" })
        XCTAssertTrue(filtered.contains { $0.title == "마감일 없음" })
        XCTAssertFalse(filtered.contains { $0.title == "내일 할 일" })
    }

    func testTodayIncompleteCountIncludesPeriodTodos() {
        let cal = Calendar.current
        let todos = [
            Todo(title: "일반", dueDate: .now, priority: .high),
            Todo(title: "연속 할일",
                 priority: .medium,
                 startDate: cal.date(byAdding: .day, value: -1, to: .now),
                 endDate: cal.date(byAdding: .day, value: 3, to: .now)),
        ]

        let count = TodoFilterLogic.todayIncompleteCount(from: todos)
        // 일반 1 + 연속(미완료) 1 = 2
        XCTAssertEqual(count, 2)
    }

    func testTodayActivePeriodTodos() {
        let cal = Calendar.current
        let todos = [
            Todo(title: "활성 연속",
                 startDate: cal.date(byAdding: .day, value: -1, to: .now),
                 endDate: cal.date(byAdding: .day, value: 3, to: .now)),
            Todo(title: "종료된 연속",
                 startDate: cal.date(byAdding: .day, value: -5, to: .now),
                 endDate: cal.date(byAdding: .day, value: -2, to: .now)),
            Todo(title: "일반 할일", dueDate: .now),
        ]

        let filtered = TodoFilterLogic.todayActivePeriodTodos(from: todos)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].title, "활성 연속")
    }

    func testTodayCompletedTodos() {
        let completed = [
            Todo(title: "오늘 완료", isCompleted: true, completedAt: .now),
            Todo(title: "어제 완료", isCompleted: true,
                 completedAt: Calendar.current.date(byAdding: .day, value: -1, to: .now)),
        ]

        let filtered = TodoFilterLogic.todayCompletedTodos(from: completed)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].title, "오늘 완료")
    }

    // MARK: - 위젯 Interactive: ToggleTodoIntent 로직

    func testToggleCompleteForWidget() {
        let todo = Todo(title: "위젯에서 완료", priority: .high)
        let incomplete = [todo]
        let completed: [Todo] = []

        let result = TodoMutationLogic.toggleComplete(
            todoId: todo.id, incomplete: incomplete, completed: completed
        )

        XCTAssertTrue(result.incomplete.isEmpty)
        XCTAssertEqual(result.completed.count, 1)
        XCTAssertTrue(result.completed[0].isCompleted)
        XCTAssertNotNil(result.completed[0].completedAt)
    }

    func testToggleCompletedBackForWidget() {
        var todo = Todo(title: "되돌리기", priority: .medium)
        todo.isCompleted = true
        todo.completedAt = .now
        let incomplete: [Todo] = []
        let completed = [todo]

        let result = TodoMutationLogic.toggleComplete(
            todoId: todo.id, incomplete: incomplete, completed: completed
        )

        XCTAssertEqual(result.incomplete.count, 1)
        XCTAssertTrue(result.completed.isEmpty)
        XCTAssertFalse(result.incomplete[0].isCompleted)
        XCTAssertNil(result.incomplete[0].completedAt)
    }

    // MARK: - 우선순위 정렬 (위젯 표시 순서)

    func testPrioritySortOrder() {
        let todos = [
            Todo(title: "낮음", priority: .low),
            Todo(title: "없음", priority: .none),
            Todo(title: "높음", priority: .high),
            Todo(title: "중간", priority: .medium),
        ]

        let sorted = todos.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        XCTAssertEqual(sorted[0].title, "높음")
        XCTAssertEqual(sorted[1].title, "중간")
        XCTAssertEqual(sorted[2].title, "낮음")
        XCTAssertEqual(sorted[3].title, "없음")
    }

    // MARK: - 빈 상태

    func testEmptyIncompleteReturnsZeroCount() {
        let count = TodoFilterLogic.todayIncompleteCount(from: [])
        XCTAssertEqual(count, 0)
    }

    func testEmptyCompletedReturnsEmpty() {
        let filtered = TodoFilterLogic.todayCompletedTodos(from: [])
        XCTAssertTrue(filtered.isEmpty)
    }

    // MARK: - 삭제된 할 일 필터링

    func testDeletedTodosExcludedFromFilters() {
        var todo = Todo(title: "삭제됨", dueDate: .now, priority: .high)
        todo.isDeleted = true

        let filtered = TodoFilterLogic.todayIncompleteRegular(from: [todo])
        XCTAssertTrue(filtered.isEmpty)
    }

    func testDeletedPeriodTodosExcluded() {
        let cal = Calendar.current
        var todo = Todo(
            title: "삭제된 연속",
            startDate: cal.date(byAdding: .day, value: -1, to: .now),
            endDate: cal.date(byAdding: .day, value: 3, to: .now)
        )
        todo.isDeleted = true

        let filtered = TodoFilterLogic.todayActivePeriodTodos(from: [todo])
        XCTAssertTrue(filtered.isEmpty)
    }
}
