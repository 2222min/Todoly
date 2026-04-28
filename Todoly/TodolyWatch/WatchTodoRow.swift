import SwiftUI

/// Watch 할 일 행
struct WatchTodoRow: View {
    let todo: Todo
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Circle()
                    .strokeBorder(Color(hex: todo.priority.color), lineWidth: 2.5)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(todo.title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Text(todo.priority.label)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color(hex: todo.priority.color))
                }

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WatchTodoRow(
        todo: Todo(title: "프로젝트 보고서", priority: .high),
        onToggle: {}
    )
}
