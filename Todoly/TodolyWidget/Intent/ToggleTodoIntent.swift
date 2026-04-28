import AppIntents
import WidgetKit

/// Interactive Widget용 — 할 일 완료 토글
struct ToggleTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 완료 토글"

    @Parameter(title: "Todo ID")
    var todoId: String

    init() {}
    init(todoId: String) { self.todoId = todoId }

    func perform() async throws -> some IntentResult {
        let incomplete = SharedDefaults.loadIncomplete()
        let completed = SharedDefaults.loadCompleted()

        let result = TodoMutationLogic.toggleComplete(
            todoId: todoId, incomplete: incomplete, completed: completed
        )

        SharedDefaults.saveAll(
            incomplete: result.incomplete,
            completed: result.completed,
            trash: SharedDefaults.loadTrash(),
            categories: SharedDefaults.loadCategories()
        )

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
