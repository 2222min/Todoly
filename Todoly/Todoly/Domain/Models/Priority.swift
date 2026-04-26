import Foundation

enum Priority: String, CaseIterable, Codable {
    case high, medium, low, none

    var color: String {
        switch self {
        case .high: return "FF6B6B"
        case .medium: return "FFAB5E"
        case .low: return "5B9BF5"
        case .none: return "CCCCCC"
        }
    }

    var label: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .none: return "None"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        case .none: return 3
        }
    }
}
