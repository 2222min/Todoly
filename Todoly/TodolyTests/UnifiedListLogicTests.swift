import XCTest
@testable import Todoly

/// 통합 리스트 + 캘린더에서 사용하는 필터/로직 테스트
final class UnifiedListLogicTests: XCTestCase {

    // MARK: - calendarIncompleteTodos (할일 탭 + 캘린더 공용)

    func testCalendarIncompleteTodosIncludesNoDueDateOnToday() {
        let todos = [
            Todo(title: "마감일 없음", priority: .medium),
            Todo(title: "오늘", dueDate: .now, priority: .high),
        ]
        let filtered = TodoFilterLogic.calendarIncompleteTodos(for: .now, from: todos)
        XCTAssertEqual(filtered.count, 2)
    }

    func testCalendarIncompleteTodosExcludesNoDueDateOnOtherDay() {
        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: .now)!
        let todos = [
            Todo(title: "마감일 없음", priority: .medium),
            Todo(title: "내일", dueDate: tomorrow, priority: .high),
        ]
        let filtered = TodoFilterLogic.calendarIncompleteTodos(for: tomorrow, from: todos)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].title, "내일")
    }

    func testCalendarIncompleteTodosIncludesPeriodTodos() {
        let cal = Calendar.current
        let todo = Todo(
            title: "연속",
            startDate: cal.date(byAdding: .day, value: -1, to: .now),
            endDate: cal.date(byAdding: .day, value: 3, to: .now)
        )
        let filtered = TodoFilterLogic.calendarIncompleteTodos(for: .now, from: [todo])
        XCTAssertEqual(filtered.count, 1)
    }

    func testCalendarIncompleteTodosExcludesCompletedPeriod() {
        let cal = Calendar.current
        let todo = Todo(
            title: "완료된 연속",
            startDate: cal.date(byAdding: .day, value: -1, to: .now),
            endDate: cal.date(byAdding: .day, value: 3, to: .now),
            dailyCompletions: [Todo.dateKey(for: .now): .now]
        )
        let filtered = TodoFilterLogic.calendarIncompleteTodos(for: .now, from: [todo])
        XCTAssertTrue(filtered.isEmpty)
    }

    func testCalendarIncompleteTodosExcludesDeleted() {
        var todo = Todo(title: "삭제됨", dueDate: .now)
        todo.isDeleted = true
        let filtered = TodoFilterLogic.calendarIncompleteTodos(for: .now, from: [todo])
        XCTAssertTrue(filtered.isEmpty)
    }

    // MARK: - toggleDailyCompletion

    func testToggleDailyCompletionAddsCompletion() {
        let cal = Calendar.current
        let todo = Todo(
            title: "연속",
            startDate: cal.date(byAdding: .day, value: -1, to: .now),
            endDate: cal.date(byAdding: .day, value: 5, to: .now)
        )
        let result = TodoMutationLogic.toggleDailyCompletion(
            todoId: todo.id, date: .now, incomplete: [todo]
        )
        XCTAssertTrue(result[0].isCompletedOn(.now))
    }

    func testToggleDailyCompletionRemovesCompletion() {
        let cal = Calendar.current
        let todo = Todo(
            title: "연속",
            startDate: cal.date(byAdding: .day, value: -1, to: .now),
            endDate: cal.date(byAdding: .day, value: 5, to: .now),
            dailyCompletions: [Todo.dateKey(for: .now): .now]
        )
        let result = TodoMutationLogic.toggleDailyCompletion(
            todoId: todo.id, date: .now, incomplete: [todo]
        )
        XCTAssertFalse(result[0].isCompletedOn(.now))
    }

    func testToggleDailyCompletionNonExistentId() {
        let todo = Todo(title: "테스트", startDate: .now, endDate: .now)
        let result = TodoMutationLogic.toggleDailyCompletion(
            todoId: "nonexistent", date: .now, incomplete: [todo]
        )
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(result[0].isCompletedOn(.now))
    }

    // MARK: - DateBadgeLogic.periodBadge

    func testPeriodBadgeActiveDay() {
        let cal = Calendar.current
        let todo = Todo(
            title: "연속",
            startDate: cal.date(byAdding: .day, value: -2, to: .now),
            endDate: cal.date(byAdding: .day, value: 3, to: .now)
        )
        let badge = DateBadgeLogic.periodBadge(for: todo)
        XCTAssertNotNil(badge)
        XCTAssertEqual(badge?.0, "3일째")
        XCTAssertEqual(badge?.1, .upcoming)
    }

    func testPeriodBadgeCompletedDay() {
        let cal = Calendar.current
        let todo = Todo(
            title: "연속",
            startDate: cal.date(byAdding: .day, value: -1, to: .now),
            endDate: cal.date(byAdding: .day, value: 3, to: .now),
            dailyCompletions: [Todo.dateKey(for: .now): .now]
        )
        let badge = DateBadgeLogic.periodBadge(for: todo)
        XCTAssertNotNil(badge)
        XCTAssertTrue(badge!.0.contains("✓"))
    }

    func testPeriodBadgeInactiveTodo() {
        let cal = Calendar.current
        let todo = Todo(
            title: "종료됨",
            startDate: cal.date(byAdding: .day, value: -5, to: .now),
            endDate: cal.date(byAdding: .day, value: -2, to: .now)
        )
        let badge = DateBadgeLogic.periodBadge(for: todo)
        XCTAssertNil(badge)
    }

    // MARK: - DateBadgeLogic.periodProgress

    func testPeriodProgress() {
        let cal = Calendar.current
        let todo = Todo(
            title: "연속",
            startDate: cal.date(byAdding: .day, value: -2, to: .now),
            endDate: cal.date(byAdding: .day, value: 4, to: .now),
            dailyCompletions: [
                Todo.dateKey(for: cal.date(byAdding: .day, value: -2, to: .now)!): .now,
                Todo.dateKey(for: cal.date(byAdding: .day, value: -1, to: .now)!): .now,
            ]
        )
        let progress = DateBadgeLogic.periodProgress(for: todo)
        XCTAssertEqual(progress.total, 7)
        XCTAssertEqual(progress.completed, 2)
    }

    // MARK: - DateBadgeLogic.dotPriorityColors

    func testDotPriorityColorsEmpty() {
        let dots = DateBadgeLogic.dotPriorityColors(for: [])
        XCTAssertTrue(dots.isEmpty)
    }

    func testDotPriorityColorsAllCompleted() {
        let todos = [
            Todo(title: "완료1", isCompleted: true),
            Todo(title: "완료2", isCompleted: true),
        ]
        let dots = DateBadgeLogic.dotPriorityColors(for: todos)
        XCTAssertEqual(dots, [.none])
    }

    func testDotPriorityColorsMaxThree() {
        let todos = [
            Todo(title: "1", priority: .high),
            Todo(title: "2", priority: .medium),
            Todo(title: "3", priority: .low),
            Todo(title: "4", priority: .none),
        ]
        let dots = DateBadgeLogic.dotPriorityColors(for: todos)
        XCTAssertEqual(dots.count, 3)
        XCTAssertEqual(dots[0], .high)
    }

    // MARK: - CalendarDateLogic

    func testDaysInMonthNotEmpty() {
        let days = CalendarDateLogic.daysInMonth(for: .now)
        XCTAssertFalse(days.isEmpty)
        let positiveDays = days.filter { $0 > 0 }
        XCTAssertTrue(positiveDays.count >= 28)
        XCTAssertTrue(positiveDays.count <= 31)
    }

    func testMakeDateCorrectDay() {
        let date = CalendarDateLogic.makeDate(day: 15, in: .now)
        XCTAssertEqual(Calendar.current.component(.day, from: date), 15)
    }

    func testMonthYearStringFormat() {
        let str = CalendarDateLogic.monthYearString(for: .now)
        XCTAssertTrue(str.contains("년"))
        XCTAssertTrue(str.contains("월"))
    }

    func testWeekdayIndexRange() {
        let idx = CalendarDateLogic.weekdayIndex(for: 1, in: .now)
        XCTAssertTrue(idx >= 0 && idx <= 6)
    }

    // MARK: - completedTodos(for:) 날짜별

    func testCompletedTodosForDateByDueDate() {
        let todo = Todo(title: "완료", dueDate: .now, isCompleted: true, completedAt: .now)
        let filtered = TodoFilterLogic.completedTodos(for: .now, from: [todo])
        XCTAssertEqual(filtered.count, 1)
    }

    func testCompletedTodosForDateByCompletedAt() {
        let todo = Todo(title: "마감일 없이 완료", isCompleted: true, completedAt: .now)
        let filtered = TodoFilterLogic.completedTodos(for: .now, from: [todo])
        XCTAssertEqual(filtered.count, 1)
    }

    func testCompletedTodosExcludesOtherDate() {
        let cal = Calendar.current
        let yesterday = cal.date(byAdding: .day, value: -1, to: .now)!
        let todo = Todo(title: "어제 완료", isCompleted: true, completedAt: yesterday)
        let filtered = TodoFilterLogic.completedTodos(for: .now, from: [todo])
        XCTAssertTrue(filtered.isEmpty)
    }

    // MARK: - search

    func testSearchByTitle() {
        let todos = [Todo(title: "프로젝트 보고서"), Todo(title: "장보기")]
        let results = TodoFilterLogic.search(query: "보고서", in: todos)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].title, "프로젝트 보고서")
    }

    func testSearchByMemo() {
        let todos = [Todo(title: "할일", memo: "중요한 메모")]
        let results = TodoFilterLogic.search(query: "메모", in: todos)
        XCTAssertEqual(results.count, 1)
    }

    func testSearchByCategory() {
        let todos = [Todo(title: "할일", categoryName: "업무")]
        let results = TodoFilterLogic.search(query: "업무", in: todos)
        XCTAssertEqual(results.count, 1)
    }

    func testSearchEmptyQuery() {
        let todos = [Todo(title: "할일")]
        let results = TodoFilterLogic.search(query: "", in: todos)
        XCTAssertTrue(results.isEmpty)
    }
}
