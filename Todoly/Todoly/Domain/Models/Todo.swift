import Foundation

struct Todo: Identifiable, Codable {
    var id = UUID().uuidString
    var title: String
    var memo: String?
    var dueDate: Date?
    var priority: Priority = .none
    var categoryName: String?
    var categoryColor: String?
    var isCompleted = false
    var completedAt: Date?
    var isDeleted = false
    var deletedAt: Date?
    var createdAt = Date()
    var reminderMinutes: Int?
}
