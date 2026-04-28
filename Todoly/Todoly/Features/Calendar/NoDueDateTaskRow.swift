import SwiftUI

/// 날짜 미지정 할일 카드 — 캘린더 하단 섹션용
struct NoDueDateTaskRow: View {
    let todo: Todo
    let onEdit: () -> Void
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TodoCheckbox(isCompleted: false) { onComplete() }

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.txt1).lineLimit(1)
                if let cat = todo.categoryName {
                    Text(cat)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.txt3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            Button { onEdit() } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.txt3)
                    .frame(width: 28, height: 28)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture { onComplete() }
    }
}

// MARK: - Preview

#Preview("NoDueDateTaskRow") {
    VStack(spacing: 8) {
        NoDueDateTaskRow(
            todo: Todo(title: "비타민 주문하기", categoryName: "쇼핑"),
            onEdit: {}, onComplete: {}
        )
        NoDueDateTaskRow(
            todo: Todo(title: "이력서 업데이트", categoryName: "업무"),
            onEdit: {}, onComplete: {}
        )
    }
    .padding()
    .background(Color.brandBg)
}
