import SwiftUI
import WatchKit

/// Watch용 간이 Store — SharedDefaults(App Group)에서 직접 읽기/쓰기
@MainActor
final class WatchStore: ObservableObject {
    @Published var incomplete: [Todo] = []
    @Published var completed: [Todo] = []

    init() { load() }

    func load() {
        let allIncomplete = SharedDefaults.loadIncomplete()
        let allCompleted = SharedDefaults.loadCompleted()

        incomplete = TodoFilterLogic.todayIncompleteRegular(from: allIncomplete)
            .sorted { $0.priority.sortOrder < $1.priority.sortOrder }

        // 연속 할일 중 오늘 미완료도 포함
        let periodTodos = TodoFilterLogic.todayActivePeriodTodos(from: allIncomplete)
            .filter { !$0.isCompletedOn(.now) }
        incomplete.append(contentsOf: periodTodos)

        completed = TodoFilterLogic.todayCompletedTodos(from: allCompleted)
    }

    func toggleComplete(_ todo: Todo) {
        let allIncomplete = SharedDefaults.loadIncomplete()
        let allCompleted = SharedDefaults.loadCompleted()

        let result = TodoMutationLogic.toggleComplete(
            todoId: todo.id, incomplete: allIncomplete, completed: allCompleted
        )

        SharedDefaults.saveAll(
            incomplete: result.incomplete,
            completed: result.completed,
            trash: SharedDefaults.loadTrash(),
            categories: SharedDefaults.loadCategories()
        )

        // 햅틱 피드백
        WKInterfaceDevice.current().play(.success)

        load()
    }
}
