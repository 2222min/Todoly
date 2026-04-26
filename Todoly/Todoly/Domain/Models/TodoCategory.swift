import Foundation

struct TodoCategory: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var color: String
    var emoji: String
    var count: Int = 0
}

extension TodoCategory {
    static let defaults: [TodoCategory] = [
        .init(name: "개인", color: "5A8AF2", emoji: "👤", count: 3),
        .init(name: "업무", color: "4DC87B", emoji: "💼", count: 5),
        .init(name: "쇼핑", color: "FFC847", emoji: "🛒", count: 1),
        .init(name: "기타", color: "CCCCCC", emoji: "📦", count: 0),
    ]
}

extension TodoCategory: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: TodoCategory, rhs: TodoCategory) -> Bool { lhs.id == rhs.id }
}
