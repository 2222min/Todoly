import Foundation

/// App Group UserDefaults 래퍼 — 앱, 위젯, 워치 모든 타겟에서 공유
enum SharedDefaults {
    static let suiteName = "group.com.todoly.app"
    static let shared = UserDefaults(suiteName: suiteName)!

    // MARK: - Keys

    static let incompleteKey = "todoly_incomplete"
    static let completedKey = "todoly_completed"
    static let trashKey = "todoly_trash"
    static let categoriesKey = "todoly_categories"
    static let hasLaunchedKey = "todoly_hasLaunched"
    private static let migratedKey = "todoly_migrated_to_group"

    // MARK: - Read

    static func loadIncomplete() -> [Todo] { decode(forKey: incompleteKey) }
    static func loadCompleted() -> [Todo] { decode(forKey: completedKey) }
    static func loadTrash() -> [Todo] { decode(forKey: trashKey) }
    static func loadCategories() -> [TodoCategory] {
        let items: [TodoCategory] = decode(forKey: categoriesKey)
        return items.isEmpty ? TodoCategory.defaults : items
    }

    // MARK: - Write

    static func saveAll(
        incomplete: [Todo],
        completed: [Todo],
        trash: [Todo],
        categories: [TodoCategory]
    ) {
        encode(incomplete, forKey: incompleteKey)
        encode(completed, forKey: completedKey)
        encode(trash, forKey: trashKey)
        encode(categories, forKey: categoriesKey)
    }

    // MARK: - Migration (standard → App Group)

    static func migrateIfNeeded() {
        guard !shared.bool(forKey: migratedKey) else { return }

        let keys = [incompleteKey, completedKey, trashKey, categoriesKey]
        for key in keys {
            if let data = UserDefaults.standard.data(forKey: key) {
                shared.set(data, forKey: key)
            }
        }
        if UserDefaults.standard.bool(forKey: hasLaunchedKey) {
            shared.set(true, forKey: hasLaunchedKey)
        }
        shared.set(true, forKey: migratedKey)
        shared.synchronize()
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
