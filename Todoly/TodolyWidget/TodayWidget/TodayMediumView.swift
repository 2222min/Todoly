import SwiftUI
import WidgetKit
import AppIntents

/// Medium Widget — 오늘 할 일 리스트 (최대 3개, Interactive)
struct TodayMediumView: View {
    let entry: TodayEntry

    private var displayItems: [Todo] {
        Array(entry.incomplete.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text("📋 오늘 할 일")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.txt1)
                Spacer()
                Text("\(entry.incompleteCount)개")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accent1)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 10)

            if displayItems.isEmpty {
                Spacer()
                Text("오늘 할 일이 없어요 🎉")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.txt3)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ForEach(displayItems) { todo in
                    todoRow(todo)
                    if todo.id != displayItems.last?.id {
                        Divider().opacity(0.3)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color.brandBg
        }
    }

    @ViewBuilder
    private func todoRow(_ todo: Todo) -> some View {
        HStack(spacing: 10) {
            Button(intent: ToggleTodoIntent(todoId: todo.id)) {
                Circle()
                    .strokeBorder(Color(hex: todo.priority.color), lineWidth: 2)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)

            Text(todo.title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.txt1)
                .lineLimit(1)

            Spacer()

            Circle()
                .fill(Color(hex: todo.priority.color))
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 6)
    }
}

#Preview(as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(
        date: .now,
        incomplete: [
            Todo(title: "프로젝트 보고서", priority: .high),
            Todo(title: "장보기", priority: .medium),
            Todo(title: "책 읽기", priority: .low),
        ],
        completed: [],
        incompleteCount: 3,
        periodTodos: []
    )
}
