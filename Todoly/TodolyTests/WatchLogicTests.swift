import XCTest
@testable import Todoly

/// Watch 앱에서 사용하는 로직 테스트
final class WatchLogicTests: XCTestCase {

    // MARK: - Watch에서 사용하는 필터 조합 테스트

    func testWatchTodayListFiltering() {
        let cal = Calendar.current
        let todos = [
            Todo(title: "오늘", dueDate: .now, priority: .high),
            Todo(title: "지연", dueDate: cal.date(byAdding: .day, value: -1, to: .now), priority: .medium),
            Todo(title: "마감일 없음", priority: .low),
            Todo(title: "내일", dueDate: cal.date(byAdding: .day, value: 1, to: .now), priority: .none),
        ]

        // Watch 메인 화면: todayIncompleteRegular + 우선순위 정렬
        let filtered = TodoFilterLogic.todayIncompleteRegular(from: todos)
            .sorted { $0.priority.sortOrder < $1.priority.sortOrder }

        XCTAssertEqual(filtered.count, 3)
        // 정렬: high → medium → low
        XCTAssertEqual(filtered[0].priority, .high)
        XCTAssertEqual(filtered[1].priority, .medium)
        XCTAssertEqual(filtered[2].priority, .low)
    }

    func testWatchPeriodTodosIncluded() {
        let cal = Calendar.current
        let todos = [
            Todo(title: "일반", dueDate: .now, priority: .high),
            Todo(title: "연속 할일",
                 priority: .medium,
                 startDate: cal.date(byAdding: .day, value: -1, to: .now),
                 endDate: cal.date(byAdding: .day, value: 5, to: .now)),
        ]

        let regular = TodoFilterLogic.todayIncompleteRegular(from: todos)
        let period = TodoFilterLogic.todayActivePeriodTodos(from: todos)
            .filter { !$0.isCompletedOn(.now) }

        // Watch에서는 regular + period 합쳐서 표시
        let combined = regular + period
        XCTAssertEqual(combined.count, 2)
    }

    func testWatchCompletedPeriodTodoExcluded() {
        let cal = Calendar.current
        var todo = Todo(
            title: "오늘 완료한 연속",
            priority: .medium,
            startDate: cal.date(byAdding: .day, value: -1, to: .now),
            endDate: cal.date(byAdding: .day, value: 5, to: .now),
            dailyCompletions: [Todo.dateKey(for: .now): .now]
        )

        let period = TodoFilterLogic.todayActivePeriodTodos(from: [todo])
            .filter { !$0.isCompletedOn(.now) }

        XCTAssertTrue(period.isEmpty)
    }

    // MARK: - Watch 완료 토글 시뮬레이션

    func testWatchToggleCompleteFlow() {
        let todo = Todo(title: "Watch에서 완료", priority: .high)
        let allIncomplete = [
            todo,
            Todo(title: "다른 할 일", priority: .low),
        ]
        let allCompleted: [Todo] = []

        // 1. 토글
        let result = TodoMutationLogic.toggleComplete(
            todoId: todo.id, incomplete: allIncomplete, completed: allCompleted
        )

        // 2. 검증
        XCTAssertEqual(result.incomplete.count, 1) // "다른 할 일"만 남음
        XCTAssertEqual(result.completed.count, 1)
        XCTAssertEqual(result.completed[0].title, "Watch에서 완료")

        // 3. 필터 재적용 (Watch load() 시뮬레이션)
        let watchIncomplete = TodoFilterLogic.todayIncompleteRegular(from: result.incomplete)
        let watchCompleted = TodoFilterLogic.todayCompletedTodos(from: result.completed)

        XCTAssertEqual(watchIncomplete.count, 1)
        XCTAssertEqual(watchCompleted.count, 1)
    }

    // MARK: - Todo 모델 테스트 (Watch에서 사용하는 속성)

    func testTodoPriorityLabel() {
        XCTAssertEqual(Priority.high.label, "High")
        XCTAssertEqual(Priority.medium.label, "Medium")
        XCTAssertEqual(Priority.low.label, "Low")
        XCTAssertEqual(Priority.none.label, "None")
    }

    func testTodoPriorityColor() {
        XCTAssertEqual(Priority.high.color, "FF6B6B")
        XCTAssertEqual(Priority.medium.color, "FFAB5E")
        XCTAssertEqual(Priority.low.color, "5B9BF5")
        XCTAssertEqual(Priority.none.color, "CCCCCC")
    }

    func testPeriodTodoDayNumber() {
        let cal = Calendar.current
        let start = cal.date(byAdding: .day, value: -2, to: .now)!
        let todo = Todo(
            title: "연속",
            startDate: start,
            endDate: cal.date(byAdding: .day, value: 5, to: .now)
        )

        XCTAssertEqual(todo.dayNumber(on: .now), 3) // 3일째
        XCTAssertEqual(todo.dayNumber(on: start), 1) // 첫째 날
    }

    // MARK: - Todo Codable (Watch ↔ App 데이터 공유)

    func testTodoCodableRoundTrip() throws {
        let cal = Calendar.current
        let original = Todo(
            title: "코딩 테스트",
            memo: "메모입니다",
            dueDate: .now,
            priority: .high,
            categoryName: "업무",
            categoryColor: "4DC87B",
            reminderMinutes: 30,
            startDate: .now,
            endDate: cal.date(byAdding: .day, value: 7, to: .now),
            dailyCompletions: [Todo.dateKey(for: .now): .now]
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Todo.self, from: data)

        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.memo, original.memo)
        XCTAssertEqual(decoded.priority, original.priority)
        XCTAssertEqual(decoded.categoryName, original.categoryName)
        XCTAssertEqual(decoded.reminderMinutes, original.reminderMinutes)
        XCTAssertTrue(decoded.isPeriodTask)
        XCTAssertTrue(decoded.isCompletedOn(.now))
    }

    func testTodoCategoryCodableRoundTrip() throws {
        let original = TodoCategory(name: "테스트", color: "FF0000", emoji: "🧪", count: 5)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TodoCategory.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.color, original.color)
        XCTAssertEqual(decoded.emoji, original.emoji)
    }
}
