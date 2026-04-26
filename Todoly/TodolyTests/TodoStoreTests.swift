import XCTest
@testable import Todoly

@MainActor
final class TodoStoreTests: XCTestCase {
    var store: TodoStore!

    override func setUp() {
        store = TodoStore(useSeedData: true)
    }

    // MARK: - Add
    func testAddTodo() {
        let before = store.incomplete.count
        store.add("테스트 할 일")
        XCTAssertEqual(store.incomplete.count, before + 1)
        XCTAssertEqual(store.incomplete.first?.title, "테스트 할 일")
    }

    func testAddEmptyTodoDoesNothing() {
        let before = store.incomplete.count
        store.add("")
        store.add("   ")
        XCTAssertEqual(store.incomplete.count, before)
    }

    // MARK: - Complete
    func testToggleComplete() {
        let todo = store.incomplete.first!
        let incBefore = store.incomplete.count
        let compBefore = store.completed.count
        store.toggleComplete(todo)
        XCTAssertEqual(store.incomplete.count, incBefore - 1)
        XCTAssertEqual(store.completed.count, compBefore + 1)
        XCTAssertTrue(store.completed.contains { $0.id == todo.id })
    }

    func testToggleCompletedBackToIncomplete() {
        let todo = store.completed.first!
        store.toggleComplete(todo)
        XCTAssertTrue(store.incomplete.contains { $0.id == todo.id })
    }

    // MARK: - Delete
    func testSoftDelete() {
        let todo = store.incomplete.first!
        store.softDelete(todo)
        XCTAssertFalse(store.incomplete.contains { $0.id == todo.id })
        XCTAssertTrue(store.trash.contains { $0.id == todo.id })
        XCTAssertTrue(store.showUndo)
    }

    func testUndoDelete() {
        let todo = store.incomplete.first!
        let id = todo.id
        store.softDelete(todo)
        store.undoDelete()
        XCTAssertTrue(store.incomplete.contains { $0.id == id })
        XCTAssertFalse(store.trash.contains { $0.id == id })
        XCTAssertFalse(store.showUndo)
    }

    func testRestore() {
        let todo = store.trash.first!
        store.restore(todo)
        XCTAssertFalse(store.trash.contains { $0.id == todo.id })
    }

    func testPermanentDelete() {
        let todo = store.trash.first!
        store.permanentDelete(todo)
        XCTAssertFalse(store.trash.contains { $0.id == todo.id })
    }

    func testEmptyTrash() {
        XCTAssertFalse(store.trash.isEmpty)
        store.emptyTrash()
        XCTAssertTrue(store.trash.isEmpty)
    }

    // MARK: - Update
    func testUpdateTodo() {
        let todo = store.incomplete.first!
        store.update(id: todo.id, title: "수정됨", memo: "메모", dueDate: nil,
                     priority: .low, categoryName: "개인", categoryColor: "5A8AF2", reminderMinutes: 30)
        let updated = store.incomplete.first { $0.id == todo.id }!
        XCTAssertEqual(updated.title, "수정됨")
        XCTAssertEqual(updated.memo, "메모")
        XCTAssertEqual(updated.priority, .low)
        XCTAssertEqual(updated.reminderMinutes, 30)
    }

    // MARK: - Category CRUD
    func testAddCategory() {
        let before = store.categories.count
        store.addCategory(name: "운동", color: "FF6B6B", emoji: "🏃")
        XCTAssertEqual(store.categories.count, before + 1)
        XCTAssertEqual(store.categories.last?.name, "운동")
    }

    func testUpdateCategory() {
        let cat = store.categories.first!
        store.updateCategory(id: cat.id, name: "변경됨", color: "FFAB5E", emoji: "🎯")
        XCTAssertEqual(store.categories.first?.name, "변경됨")
    }

    func testDeleteCategory() {
        let cat = store.categories.first!
        let catName = cat.name
        store.incomplete[0].categoryName = catName
        store.deleteCategory(id: cat.id)
        XCTAssertFalse(store.categories.contains { $0.id == cat.id })
        XCTAssertNil(store.incomplete[0].categoryName)
    }

    // MARK: - Priority
    func testPriorityColors() {
        XCTAssertEqual(Priority.high.color, "FF6B6B")
        XCTAssertEqual(Priority.medium.color, "FFAB5E")
        XCTAssertEqual(Priority.low.color, "5B9BF5")
    }

    // MARK: - Due Date Badge (순수 함수 테스트)
    func testOverdueBadge() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        let badge = DateBadgeLogic.badge(for: yesterday)
        XCTAssertNotNil(badge)
        XCTAssertEqual(badge?.0, "지연")
    }

    func testTodayBadge() {
        let today = Calendar.current.startOfDay(for: .now)
        let badge = DateBadgeLogic.badge(for: today)
        XCTAssertNotNil(badge)
        XCTAssertEqual(badge?.0, "오늘")
    }

    func testTomorrowBadge() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: .now))!
        let badge = DateBadgeLogic.badge(for: tomorrow)
        XCTAssertNotNil(badge)
        XCTAssertEqual(badge?.0, "내일")
    }

    func testUpcomingBadge() {
        let d5 = Calendar.current.date(byAdding: .day, value: 5, to: .now)!
        let badge = DateBadgeLogic.badge(for: d5)
        XCTAssertNotNil(badge)
        XCTAssertEqual(badge?.0, "D-5")
    }

    // MARK: - Pure Logic Tests
    func testTodoMutationLogicToggle() {
        let todo = Todo(title: "테스트", priority: .high)
        let result = TodoMutationLogic.toggleComplete(
            todoId: todo.id, incomplete: [todo], completed: []
        )
        XCTAssertTrue(result.incomplete.isEmpty)
        XCTAssertEqual(result.completed.count, 1)
        XCTAssertTrue(result.completed.first!.isCompleted)
    }

    func testTodoMutationLogicIsValidTitle() {
        XCTAssertTrue(TodoMutationLogic.isValidTitle("할 일"))
        XCTAssertFalse(TodoMutationLogic.isValidTitle(""))
        XCTAssertFalse(TodoMutationLogic.isValidTitle("   "))
    }

    func testTodoFilterLogicTodosForDate() {
        let today = Date()
        let todos = [
            Todo(title: "오늘", dueDate: today),
            Todo(title: "내일", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: today)),
        ]
        let filtered = TodoFilterLogic.todos(for: today, from: todos, completed: [])
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.title, "오늘")
    }

    func testCategoryMutationLogicDelete() {
        let cat = TodoCategory(name: "업무", color: "4DC87B", emoji: "💼")
        let todo = Todo(title: "테스트", categoryName: "업무", categoryColor: "4DC87B")
        let result = CategoryMutationLogic.deleteCategory(
            id: cat.id, categories: [cat], incomplete: [todo], completed: []
        )
        XCTAssertTrue(result.categories.isEmpty)
        XCTAssertNil(result.incomplete.first?.categoryName)
    }
}
