import SwiftUI

struct CompletedRow: View {
    let todo: Todo
    @EnvironmentObject var store: TodoStore

    var body: some View {
        HStack(spacing: 12) {
            uncompleteButton
            todoInfo
            Spacer()
            deleteButton
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Color.white.opacity(0.6)).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var uncompleteButton: some View {
        TodoCheckbox(isCompleted: true) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { store.toggleComplete(todo) }
        }
    }

    private var todoInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(todo.title)
                .font(.system(size: 14, design: .rounded)).strikethrough()
                .foregroundColor(.txt3).lineLimit(1)
            Text(completedInfoText)
                .font(.system(size: 11, design: .rounded)).foregroundColor(.txt3).lineLimit(1)
        }
    }

    private var deleteButton: some View {
        Button { withAnimation { store.softDelete(todo) } } label: {
            Image(systemName: "trash").font(.system(size: 13)).foregroundColor(.txt3)
                .frame(width: 44, height: 44)
        }
    }

    /// 순수 함수: 완료 정보 텍스트 생성
    var completedInfoText: String {
        let cat = todo.categoryName ?? ""
        let time = todo.completedAt?.formatted(date: .omitted, time: .shortened) ?? ""
        return [cat, time].filter { !$0.isEmpty }.joined(separator: " • ")
    }
}

// MARK: - Preview

#Preview("CompletedRow") {
    CompletedRow(todo: Todo(
        title: "아침 운동", categoryName: "개인", isCompleted: true, completedAt: .now
    ))
    .padding()
    .background(Color.brandBg)
    .environmentObject(TodoStore())
}
