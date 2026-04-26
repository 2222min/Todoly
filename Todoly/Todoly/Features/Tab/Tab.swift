import Foundation

enum Tab: String, CaseIterable {
    case tasks = "할 일"
    case calendar = "캘린더"
    case categories = "카테고리"
    case trash = "휴지통"

    var icon: String {
        switch self {
        case .tasks: "list.bullet"
        case .calendar: "calendar"
        case .categories: "square.grid.2x2"
        case .trash: "trash"
        }
    }

    var emoji: String {
        switch self {
        case .tasks: "📝"
        case .calendar: "📅"
        case .categories: "🏷"
        case .trash: "🗑"
        }
    }
}
