import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var store: TodoStore
    @State private var showAddSheet = false
    @State private var editingCategory: TodoCategory?
    @State private var deletingCategory: TodoCategory?
    @State private var selectedCategory: TodoCategory?

    var body: some View {
        VStack(spacing: 0) {
            categoryHeader
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(store.categories) { cat in
                        CategoryRow(
                            category: cat,
                            todoCount: TodoFilterLogic.incompleteTodos(forCategory: cat.name, from: store.incomplete).count,
                            onEdit: { editingCategory = cat },
                            onTap: { selectedCategory = cat }
                        )
                    }
                    tipCard
                }.padding(24)
            }
        }
        .background(Color.brandBg)
        .fullScreenCover(isPresented: $showAddSheet) { CategoryAddSheet() }
        .fullScreenCover(item: $selectedCategory) { cat in
            NavigationStack { CategoryFilterView(category: cat) }
        }
        .confirmationDialog("카테고리 관리", isPresented: Binding(
            get: { editingCategory != nil },
            set: { if !$0 { editingCategory = nil } }
        )) {
            if let cat = editingCategory {
                Button("수정") {
                    let _ = cat
                    editingCategory = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showAddSheet = true }
                }
                Button("삭제", role: .destructive) {
                    deletingCategory = cat
                    editingCategory = nil
                }
                Button("취소", role: .cancel) { editingCategory = nil }
            }
        }
        .alert("정말 삭제하시겠습니까?", isPresented: Binding(
            get: { deletingCategory != nil },
            set: { if !$0 { deletingCategory = nil } }
        )) {
            Button("취소", role: .cancel) { deletingCategory = nil }
            Button("삭제", role: .destructive) {
                if let cat = deletingCategory { store.deleteCategory(id: cat.id) }
                deletingCategory = nil
            }
        } message: { Text("이 카테고리의 할 일은 '미분류'로 변경됩니다.") }
    }

    private var categoryHeader: some View {
        HStack {
            Text("카테고리 관리 🏷").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.txt1)
            Spacer()
            Button { showAddSheet = true } label: {
                LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 36, height: 36).clipShape(Circle())
                    .overlay(Image(systemName: "plus").font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                    .shadow(color: .accent1.opacity(0.3), radius: 8, y: 3)
            }.buttonStyle(SoftPressStyle())
        }
        .padding(.horizontal, 24).padding(.vertical, 16)
        .background(Color.white.opacity(0.95).shadow(color: .black.opacity(0.04), radius: 12, y: 4))
    }

    private var tipCard: some View {
        HStack(spacing: 8) {
            Text("💡").font(.system(size: 16))
            Text("카테고리를 탭하면 해당 할 일만 볼 수 있어요!")
                .font(.system(size: 13, design: .rounded)).foregroundColor(.accent2)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accent2.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Preview

#Preview("CategoryListView") {
    CategoryListView()
        .environmentObject(TodoStore())
}
