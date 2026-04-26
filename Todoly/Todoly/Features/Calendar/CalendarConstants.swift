import SwiftUI

/// 캘린더 애니메이션 상수 — 순수 값
enum CalendarAnimationConstants {
    static let monthSlide: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    static let dateSelection: Animation = .spring(response: 0.35, dampingFraction: 0.7)
    static let taskListAppear: Animation = .spring(response: 0.45, dampingFraction: 0.8)
    static let taskRowAppear: Animation = .spring(response: 0.4, dampingFraction: 0.75)
    static let taskRowStaggerDelay: Double = 0.06
}

/// 캘린더 날짜 계산 — 순수 함수
enum CalendarDateLogic {

    /// 해당 월의 날짜 배열 생성 (빈 셀은 음수)
    static func daysInMonth(for displayMonth: Date) -> [Int] {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: displayMonth)!
        let firstWeekday = cal.component(
            .weekday,
            from: cal.date(from: cal.dateComponents([.year, .month], from: displayMonth))!
        ) - 1
        let emptyCells = (1...max(1, firstWeekday)).map { -$0 }
        return (firstWeekday == 0 ? [] : emptyCells) + Array(range)
    }

    /// 특정 일자의 Date 생성
    static func makeDate(day: Int, in displayMonth: Date) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month], from: displayMonth)
        comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    /// 월/년 문자열 포맷
    static func monthYearString(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 M월"
        return df.string(from: date)
    }

    /// 요일 인덱스 (0=일, 6=토)
    static func weekdayIndex(for day: Int, in displayMonth: Date) -> Int {
        let date = makeDate(day: day, in: displayMonth)
        return Calendar.current.component(.weekday, from: date) - 1
    }
}
