import SwiftUI

/// SRP: 카테고리 행 렌더링만 담당
struct CategoryRow: View {
    let category: TodoCategory
    let todoCount: Int
    let onEdit: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color(hex: category.color).opacity(0.2)).frame(width: 44, height: 44)
                Text(category.emoji).font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(.txt1).lineLimit(1)
                Text("\(todoCount)개 할 일")
                    .font(.system(size: 12, design: .rounded)).foregroundColor(.txt3)
            }
            Spacer()
            Button { onEdit() } label: {
                Image(systemName: "ellipsis").foregroundColor(.txt3).frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.04), radius: 16, y: 6)
        .onTapGesture { onTap() }
    }
}

// MARK: - Preview

#Preview("CategoryRow") {
    CategoryRow(
        category: TodoCategory(name: "업무", color: "4DC87B", emoji: "💼"),
        todoCount: 5,
        onEdit: {},
        onTap: {}
    )
    .padding()
    .background(Color.brandBg)
}
