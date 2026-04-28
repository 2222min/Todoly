import SwiftUI
import WidgetKit

/// 위젯 사이즈별 뷰 분기
struct TodayWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: TodayEntry

    var body: some View {
        switch family {
        case .systemSmall:
            TodaySmallView(entry: entry)
        case .systemMedium:
            TodayMediumView(entry: entry)
        case .systemLarge:
            TodayLargeView(entry: entry)
        default:
            TodaySmallView(entry: entry)
        }
    }
}

/// 오늘 할 일 위젯 정의
struct TodayWidget: Widget {
    let kind = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayWidgetProvider()) { entry in
            TodayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("오늘 할 일")
        .description("오늘의 할 일을 한눈에 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
