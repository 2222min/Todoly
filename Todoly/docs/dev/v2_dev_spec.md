# Todoly v2 — 위젯 + Apple Watch 개발 스펙

## 1. SharedDefaults

### 파일: `Todoly/Shared/SharedDefaults.swift`
```swift
import Foundation

enum SharedDefaults {
    static let suiteName = "group.com.todoly.app"
    static let shared = UserDefaults(suiteName: suiteName)!
    
    // Keys
    static let incompleteKey = "todoly_incomplete"
    static let completedKey = "todoly_completed"
    static let trashKey = "todoly_trash"
    static let categoriesKey = "todoly_categories"
    static let migratedKey = "todoly_migrated_to_group"
    
    // MARK: - Read
    static func loadIncomplete() -> [Todo] { decode(forKey: incompleteKey) }
    static func loadCompleted() -> [Todo] { decode(forKey: completedKey) }
    static func loadTrash() -> [Todo] { decode(forKey: trashKey) }
    static func loadCategories() -> [TodoCategory] { decode(forKey: categoriesKey) }
    
    // MARK: - Write
    static func saveAll(incomplete: [Todo], completed: [Todo], trash: [Todo], categories: [TodoCategory]) {
        encode(incomplete, forKey: incompleteKey)
        encode(completed, forKey: completedKey)
        encode(trash, forKey: trashKey)
        encode(categories, forKey: categoriesKey)
    }
    
    // MARK: - Migration
    static func migrateIfNeeded() {
        guard !shared.bool(forKey: migratedKey) else { return }
        let keys = [incompleteKey, completedKey, trashKey, categoriesKey]
        for key in keys {
            if let data = UserDefaults.standard.data(forKey: key) {
                shared.set(data, forKey: key)
            }
        }
        // hasLaunched 플래그도 복사
        if UserDefaults.standard.bool(forKey: "todoly_hasLaunched") {
            shared.set(true, forKey: "todoly_hasLaunched")
        }
        shared.set(true, forKey: migratedKey)
    }
    
    // MARK: - Helpers
    private static func decode<T: Decodable>(forKey key: String) -> [T] {
        guard let data = shared.data(forKey: key),
              let items = try? JSONDecoder().decode([T].self, from: data) else { return [] }
        return items
    }
    
    private static func encode<T: Encodable>(_ items: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(items) {
            shared.set(data, forKey: key)
        }
    }
}
```

## 2. TodoStore 변경사항

### 변경 포인트
1. `save()` → `SharedDefaults.saveAll()` 사용
2. `load()` → `SharedDefaults.load*()` 사용
3. `save()` 후 `WidgetCenter.shared.reloadAllTimelines()` 호출
4. `init`에서 `SharedDefaults.migrateIfNeeded()` 호출

```swift
// 변경 전
private func save() {
    let encoder = JSONEncoder()
    if let d = try? encoder.encode(incomplete) { UserDefaults.standard.set(d, forKey: Self.incompleteKey) }
    ...
}

// 변경 후
private func save() {
    SharedDefaults.saveAll(incomplete: incomplete, completed: completed, trash: trash, categories: categories)
    WidgetCenter.shared.reloadAllTimelines()
}
```

## 3. Widget — TodayWidgetProvider

### 파일: `TodolyWidget/TodayWidget/TodayWidgetProvider.swift`
```swift
struct TodayEntry: TimelineEntry {
    let date: Date
    let incomplete: [Todo]
    let completed: [Todo]
    let incompleteCount: Int
}

struct TodayWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry { ... }
    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) { ... }
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let incomplete = SharedDefaults.loadIncomplete()
        let completed = SharedDefaults.loadCompleted()
        let todayIncomplete = TodoFilterLogic.todayIncompleteRegular(from: incomplete)
        let todayCompleted = TodoFilterLogic.todayCompletedTodos(from: completed)
        
        let entry = TodayEntry(
            date: .now,
            incomplete: todayIncomplete.sorted { $0.priority.sortOrder < $1.priority.sortOrder },
            completed: todayCompleted,
            incompleteCount: TodoFilterLogic.todayIncompleteCount(from: incomplete)
        )
        
        // 자정에 갱신
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}
```

## 4. Widget — ToggleTodoIntent

### 파일: `TodolyWidget/Intent/ToggleTodoIntent.swift`
```swift
import AppIntents
import WidgetKit

struct ToggleTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 완료 토글"
    
    @Parameter(title: "Todo ID")
    var todoId: String
    
    init() {}
    init(todoId: String) { self.todoId = todoId }
    
    func perform() async throws -> some IntentResult {
        var incomplete = SharedDefaults.loadIncomplete()
        var completed = SharedDefaults.loadCompleted()
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
```

## 5. Watch — WatchStore

### 파일: `TodolyWatch/WatchStore.swift`
```swift
import SwiftUI

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
        completed = TodoFilterLogic.todayCompletedTodos(from: allCompleted)
    }
    
    func toggleComplete(_ todo: Todo) {
        var allIncomplete = SharedDefaults.loadIncomplete()
        var allCompleted = SharedDefaults.loadCompleted()
        let result = TodoMutationLogic.toggleComplete(
            todoId: todo.id, incomplete: allIncomplete, completed: allCompleted
        )
        SharedDefaults.saveAll(
            incomplete: result.incomplete,
            completed: result.completed,
            trash: SharedDefaults.loadTrash(),
            categories: SharedDefaults.loadCategories()
        )
        load() // refresh local state
    }
}
```

## 6. Project.swift 변경

### Widget 타겟 sources 확장
기존 `TodoAlarmAttributes.swift`만 공유하던 것을 확장:
```swift
sources: [
    "TodolyWidget/**",
    "Todoly/Domain/Models/Todo.swift",
    "Todoly/Domain/Models/TodoCategory.swift",
    "Todoly/Domain/Models/Priority.swift",
    "Todoly/Domain/Models/TodoAlarmAttributes.swift",
    "Todoly/Domain/Logic/TodoFilterLogic.swift",
    "Todoly/Domain/Logic/TodoMutationLogic.swift",
    "Todoly/Core/Extensions/Color+Brand.swift",
    "Shared/**",
]
```

### Watch 타겟 추가
```swift
Target(
    name: "TodolyWatch",
    platform: .watchOS,
    product: .watch2App,
    bundleId: "com.todoly.app.watchkitapp",
    deploymentTarget: .watchOS(targetVersion: "10.0"),
    sources: [
        "TodolyWatch/**",
        "Todoly/Domain/Models/Todo.swift",
        "Todoly/Domain/Models/TodoCategory.swift",
        "Todoly/Domain/Models/Priority.swift",
        "Todoly/Domain/Logic/TodoFilterLogic.swift",
        "Todoly/Domain/Logic/TodoMutationLogic.swift",
        "Todoly/Core/Extensions/Color+Brand.swift",
        "Shared/**",
    ]
)
```

## 7. Entitlements

### App Group entitlement 필요 (모든 타겟)
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.todoly.app</string>
</array>
```
→ Tuist에서 `entitlements` 파라미터로 설정
