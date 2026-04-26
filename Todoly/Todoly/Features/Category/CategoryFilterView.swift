import SwiftUI

struct CategoryFilterView: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss
    let category: TodoCategory

    private var filteredTodos: [Todo] {
        TodoFilterLogic.incompleteTodos(forCategory: category.name, from: store.incomplete)
    }

    var body: some View {
        VStack(spacing: 0) {
            filterHeader
            if filteredTodos.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredTodos) { todo in
                            TaskCardView(todo: todo)
                        }
                    }.padding(24)
                }
            }
        }
        .background(Color.brandBg)
    }

    private var filterHeader: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left").font(.system(size: 18)).foregroundColor(.txt1)
            }
            ZStack {
                Circle().fill(Color(hex: category.color).opacity(0.2)).frame(width: 28, height: 28)
                Text(category.emoji).font(.system(size: 14))
            }
            Text(category.name)
                .font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.txt1)
            Spacer()
            Text("\(filteredTodos.count)개 할 일")
                .font(.system(size: 12, design: .rounded)).foregroundColor(.txt3)
        }
        .padding(.horizontal, 24).padding(.vertical, 16)
        .background(Color.brandBg.opacity(0.95).shadow(color: .black.opacity(0.04), radius: 12, y: 4))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("📭").font(.system(size: 48))
            Text("이 카테고리에 할 일이 없어요")
                .font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(.txt2)
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("CategoryFilterView") {
    NavigationStack {
        CategoryFilterView(category: TodoCategory(name: "업무", color: "4DC87B", emoji: "💼"))
    }
    .environmentObject(TodoStore())
}
