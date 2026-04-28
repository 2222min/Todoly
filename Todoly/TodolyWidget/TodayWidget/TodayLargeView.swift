import SwiftUI
import WidgetKit
import AppIntents

/// Large Widget — 오늘 할 일 + 완료 목록
struct TodayLargeView: View {
    let entry: TodayEntry

    private var displayIncomplete: [Todo] {
        Array(entry.incomplete.prefix(5))
    }

    private var displayPeriod: [Todo] {
        entry.periodTodos.filter { !$0.isCompletedOn(.now) }
    }

    private var displayCompleted: [Todo] {
        Array(entry.completed.prefix(2))
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
            .padding(.bottom, 8)

            if displayIncomplete.isEmpty && displayPeriod.isEmpty {
                emptyState
            } else {
                // 미완료 일반 할 일
                ForEach(displayIncomplete) { todo in
                    incompleteRow(todo)
                }

                // 연속 할일
                ForEach(displayPeriod) { todo in
                    periodRow(todo)
                }
            }

            // 완료 섹션
            if !displayCompleted.isEmpty {
                Divider().opacity(0.3).padding(.vertical, 6)

                Text("✅ 완료 \(entry.completed.count)개")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.txt3)
                    .padding(.bottom, 4)

                ForEach(displayCompleted) { todo in
                    completedRow(todo)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color.brandBg
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func incompleteRow(_ todo: Todo) -> some View {
        HStack(spacing: 10) {
            Button(intent: ToggleTodoIntent(todoId: todo.id)) {
                Circle()
                    .strokeBorder(Color(hex: todo.priority.color), lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)

            Text(todo.title)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.txt1)
                .lineLimit(1)

            Spacer()

            Circle()
                .fill(Color(hex: todo.priority.color))
                .frame(width: 7, height: 7)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func periodRow(_ todo: Todo) -> some View {
        HStack(spacing: 10) {
            Button(intent: ToggleTodoIntent(todoId: todo.id)) {
                Circle()
                    .strokeBorder(Color(hex: todo.priority.color), lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)

            Text(todo.title)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.txt1)
                .lineLimit(1)

            Spacer()

            Text("Day \(todo.dayNumber(on: .now))")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.accent2)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func completedRow(_ todo: Todo) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.txt3)

            Text(todo.title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.txt3)
                .strikethrough()
                .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var emptyState: some View {
        Spacer()
        VStack(spacing: 4) {
            Text("🎉")
                .font(.system(size: 32))
            Text("오늘 할 일을 모두 완료했어요!")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.txt3)
        }
        .frame(maxWidth: .infinity)
        Spacer()
    }
}

#Preview(as: .systemLarge) {
    TodayWidget()
} timeline: {
    TodayEntry(
        date: .now,
        incomplete: [
            Todo(title: "프로젝트 보고서", priority: .high),
            Todo(title: "장보기", priority: .medium),
            Todo(title: "책 읽기", priority: .low),
        ],
        completed: [
            Todo(title: "아침 운동", isCompleted: true, completedAt: .now),
        ],
        incompleteCount: 3,
        periodTodos: []
    )
}
