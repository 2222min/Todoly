import SwiftUI

/// 날짜 미지정 할일 카드 — 캘린더 하단 섹션용
struct NoDueDateTaskRow: View {
    let todo: Todo
    let onTap: () -> Void
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TodoCheckbox(isCompleted: false) {
                onComplete()
            }

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
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

// MARK: - Preview

#Preview("NoDueDateTaskRow") {
    VStack(spacing: 8) {
        NoDueDateTaskRow(
            todo: Todo(title: "비타민 주문하기", categoryName: "쇼핑"),
            onTap: {}, onComplete: {}
        )
        NoDueDateTaskRow(
            todo: Todo(title: "이력서 업데이트", categoryName: "업무"),
            onTap: {}, onComplete: {}
        )
    }
    .padding()
    .background(Color.brandBg)
}
