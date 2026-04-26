import Foundation

extension Date {
    /// 날짜 배지 — 순수 로직에 위임
    var badge: (String, BadgeStyle)? {
        DateBadgeLogic.badge(for: self)
    }
}
