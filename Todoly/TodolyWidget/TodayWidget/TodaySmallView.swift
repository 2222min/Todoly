import SwiftUI
import WidgetKit

/// Small Widget — 오늘 할 일 요약
struct TodaySmallView: View {
    let entry: TodayEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("📋 오늘 할 일")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.txt2)
                Spacer()
            }

            Spacer()

            if entry.incompleteCount == 0 {
                Text("🎉")
                    .font(.system(size: 36))
                    .frame(maxWidth: .infinity)
                Text("모두 완료!")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.txt1)
                    .frame(maxWidth: .infinity)
            } else {
                Text("\(entry.incompleteCount)개")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.txt1)
                Text("남았어요")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.txt2)
            }

            Spacer()

            // 최우선 할 일
            if let top = entry.incomplete.first {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: top.priority.color))
                        .frame(width: 8, height: 8)
                    Text(top.title)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.txt1)
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color.brandBg
        }
    }
}

#Preview(as: .systemSmall) {
    TodayWidget()
} timeline: {
    TodayEntry(
        date: .now,
        incomplete: [Todo(title: "프로젝트 보고서", priority: .high)],
        completed: [],
        incompleteCount: 3,
        periodTodos: []
    )
}
