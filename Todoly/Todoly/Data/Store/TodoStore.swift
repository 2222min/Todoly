import SwiftUI

/// 중앙 데이터 저장소 — 순수 로직은 Domain/Logic에 위임
@MainActor
final class TodoStore: ObservableObject, TodoStoring {
    @Published var incomplete: [Todo] = []
    @Published var completed: [Todo] = []
    @Published var trash: [Todo] = []
    @Published var categories: [TodoCategory] = TodoCategory.defaults
    @Published var undoItem: Todo?
    @Published var showUndo = false

    private let notificationService: NotificationScheduling

    init(notificationService: NotificationScheduling = NotificationService.shared, useSeedData: Bool = false) {
        self.notificationService = notificationService
        if useSeedData {
            seed()
        } else {
            load()
        }
    }

    // MARK: - Persistence

    private static let incompleteKey = "todoly_incomplete"
    private static let completedKey = "todoly_completed"
    private static let trashKey = "todoly_trash"
    private static let categoriesKey = "todoly_categories"
    private static let hasLaunchedKey = "todoly_hasLaunched"

    private func save() {
        let encoder = JSONEncoder()
        if let d = try? encoder.encode(incomplete) { UserDefaults.standard.set(d, forKey: Self.incompleteKey) }
        if let d = try? encoder.encode(completed) { UserDefaults.standard.set(d, forKey: Self.completedKey) }
        if let d = try? encoder.encode(trash) { UserDefaults.standard.set(d, forKey: Self.trashKey) }
        if let d = try? encoder.encode(categories) { UserDefaults.standard.set(d, forKey: Self.categoriesKey) }
    }

    private func load() {
        let decoder = JSONDecoder()

        // 첫 실행이면 시드 데이터 사용
        guard UserDefaults.standard.bool(forKey: Self.hasLaunchedKey) else {
            seed()
            UserDefaults.standard.set(true, forKey: Self.hasLaunchedKey)
            save()
            return
        }

        if let d = UserDefaults.standard.data(forKey: Self.incompleteKey),
           let items = try? decoder.decode([Todo].self, from: d) { incomplete = items }
        if let d = UserDefaults.standard.data(forKey: Self.completedKey),
           let items = try? decoder.decode([Todo].self, from: d) { completed = items }
        if let d = UserDefaults.standard.data(forKey: Self.trashKey),
           let items = try? decoder.decode([Todo].self, from: d) { trash = items }
        if let d = UserDefaults.standard.data(forKey: Self.categoriesKey),
           let items = try? decoder.decode([TodoCategory].self, from: d) { categories = items }
    }

    // MARK: - Todo CRUD

    func add(_ title: String) {
        guard TodoMutationLogic.isValidTitle(title) else { return }
        incomplete.insert(Todo(title: title, priority: .medium), at: 0)
        save()
    }

    func toggleComplete(_ todo: Todo) {
        let result = TodoMutationLogic.toggleComplete(
            todoId: todo.id, incomplete: incomplete, completed: completed
        )
        incomplete = result.incomplete
        completed = result.completed
        save()
    }

    func softDelete(_ todo: Todo) {
        let result = TodoMutationLogic.softDelete(
            todo: todo, incomplete: incomplete, completed: completed, trash: trash
        )
        incomplete = result.incomplete
        completed = result.completed
        trash = result.trash
        undoItem = result.deletedTodo
        showUndo = true

        notificationService.cancelReminder(todoId: todo.id)
        save()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showUndo = false
            self?.undoItem = nil
        }
    }

    func undoDelete() {
        guard let item = undoItem else { return }
        let result = TodoMutationLogic.restore(
            todo: item, incomplete: incomplete, completed: completed, trash: trash
        )
        incomplete = result.incomplete
        completed = result.completed
        trash = result.trash
        showUndo = false
        undoItem = nil
        save()
    }

    func restore(_ todo: Todo) {
        let result = TodoMutationLogic.restore(
            todo: todo, incomplete: incomplete, completed: completed, trash: trash
        )
        incomplete = result.incomplete
        completed = result.completed
        trash = result.trash
        save()
    }

    func permanentDelete(_ todo: Todo) {
        trash.removeAll { $0.id == todo.id }
        save()
    }

    func emptyTrash() { trash.removeAll(); save() }

    // MARK: - Category CRUD

    func addCategory(name: String, color: String, emoji: String) {
        categories.append(TodoCategory(name: name, color: color, emoji: emoji))
        save()
    }

    func updateCategory(id: String, name: String, color: String, emoji: String) {
        let result = CategoryMutationLogic.updateCategory(
            id: id, name: name, color: color, emoji: emoji,
            categories: categories, incomplete: incomplete, completed: completed
        )
        categories = result.categories
        incomplete = result.incomplete
        completed = result.completed
        save()
    }

    func deleteCategory(id: String) {
        let result = CategoryMutationLogic.deleteCategory(
            id: id, categories: categories, incomplete: incomplete, completed: completed
        )
        categories = result.categories
        incomplete = result.incomplete
        completed = result.completed
        save()
    }

    // MARK: - Update

    func update(
        id: String, title: String, memo: String?, dueDate: Date?,
        priority: Priority, categoryName: String?, categoryColor: String?,
        reminderMinutes: Int? = nil
    ) {
        let result = TodoMutationLogic.update(
            id: id, title: title, memo: memo, dueDate: dueDate,
            priority: priority, categoryName: categoryName,
            categoryColor: categoryColor, reminderMinutes: reminderMinutes,
            incomplete: incomplete, completed: completed
        )
        incomplete = result.incomplete
        completed = result.completed
        save()
    }

    // MARK: - Calendar Queries (delegate to pure logic)

    var todosWithDueDate: [Todo] {
        TodoFilterLogic.todosWithDueDate(from: incomplete, completed: completed)
    }

    func todos(for date: Date) -> [Todo] {
        TodoFilterLogic.todos(for: date, from: incomplete, completed: completed)
    }

    func incompleteTodos(for date: Date) -> [Todo] {
        TodoFilterLogic.incompleteTodos(for: date, from: incomplete)
    }

    /// 날짜 미지정 미완료 할 일
    var todosWithoutDueDate: [Todo] {
        TodoFilterLogic.todosWithoutDueDate(from: incomplete)
    }

    /// 특정 날짜의 완료 할 일 (dueDate 또는 completedAt 기준)
    func completedTodos(for date: Date) -> [Todo] {
        TodoFilterLogic.completedTodos(for: date, from: completed)
    }

    // MARK: - Seed Data

    private func seed() {
        incomplete = [
            Todo(title: "프로젝트 보고서", memo: "Q3 재무 보고서 마감",
                 dueDate: Calendar.current.date(byAdding: .day, value: -2, to: .now),
                 priority: .high, categoryName: "업무", categoryColor: "4DC87B"),
            Todo(title: "장보기", memo: "계란, 우유, 제철 과일",
                 dueDate: .now, priority: .medium, categoryName: "쇼핑", categoryColor: "FFC847"),
            Todo(title: "책 읽기", memo: "디자인 오브 에브리데이 씽스 50p",
                 dueDate: Calendar.current.date(byAdding: .day, value: 5, to: .now),
                 priority: .low, categoryName: "개인", categoryColor: "5A8AF2"),
        ]
        completed = [
            Todo(title: "아침 운동", categoryName: "개인", isCompleted: true, completedAt: .now),
            Todo(title: "클라이언트 이메일 답장", categoryName: "업무", isCompleted: true, completedAt: .now),
        ]
        trash = [
            Todo(title: "운동하기 🏃", isDeleted: true,
                 deletedAt: Calendar.current.date(byAdding: .day, value: -2, to: .now)),
            Todo(title: "영화 예매 🎬", isDeleted: true,
                 deletedAt: Calendar.current.date(byAdding: .day, value: -5, to: .now)),
        ]
    }
}
