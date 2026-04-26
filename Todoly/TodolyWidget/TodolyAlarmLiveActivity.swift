import ActivityKit
import WidgetKit
import SwiftUI

struct TodolyAlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TodoAlarmAttributes.self) { context in
            // 잠금화면 Live Activity
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Text("🔔")
                        .font(.system(size: 28))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.remainingTime)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.todoTitle)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Text("🔔")
                    .font(.system(size: 14))
            } compactTrailing: {
                Text(context.state.remainingTime)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            } minimal: {
                Text("🔔")
                    .font(.system(size: 12))
            }
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<TodoAlarmAttributes>) -> some View {
        HStack(spacing: 16) {
            // 알람 아이콘
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                Text("🔔")
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Todoly 알림")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                Text(context.attributes.todoTitle)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .lineLimit(1)

                Text(context.attributes.subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 남은 시간 또는 상태
            VStack(spacing: 4) {
                Text(context.state.remainingTime)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                Text("남음")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}
