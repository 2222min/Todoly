import Foundation

/// TodoStore 추상화 — ViewModel이 구체 구현이 아닌 Protocol에 의존
protocol TodoStoring: ObservableObject {
    var incomplete: [Todo] { get set }
    var completed: [Todo] { get set }
    var trash: [Todo] { get set }
    var categories: [TodoCategory] { get set }
    var undoItem: Todo? { get set }
    var showUndo: Bool { get set }

    func add(_ title: String)
    func toggleComplete(_ todo: Todo)
    func softDelete(_ todo: Todo)
    func undoDelete()
    func restore(_ todo: Todo)
    func permanentDelete(_ todo: Todo)
    func emptyTrash()

    func addCategory(name: String, color: String, emoji: String)
    func updateCategory(id: String, name: String, color: String, emoji: String)
    func deleteCategory(id: String)

    func update(
        id: String, title: String, memo: String?, dueDate: Date?,
        priority: Priority, categoryName: String?, categoryColor: String?,
        reminderMinutes: Int?
    )
}
