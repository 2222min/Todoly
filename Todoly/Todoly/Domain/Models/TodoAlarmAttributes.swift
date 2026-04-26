import Foundation

#if canImport(ActivityKit)
import ActivityKit

/// Live Activity용 Attributes — 앱 타겟과 위젯 타겟 모두에서 공유
struct TodoAlarmAttributes: ActivityAttributes {
    /// 고정 데이터
    let todoTitle: String
    let subtitle: String
    let todoId: String

    /// 실시간 업데이트 데이터
    struct ContentState: Codable, Hashable {
        let remainingTime: String
        let isRinging: Bool
    }
}
#else
/// ActivityKit 미지원 환경용 fallback
struct TodoAlarmAttributes {
    let todoTitle: String
    let subtitle: String
    let todoId: String

    struct ContentState: Codable, Hashable {
        let remainingTime: String
        let isRinging: Bool
    }
}
#endif
