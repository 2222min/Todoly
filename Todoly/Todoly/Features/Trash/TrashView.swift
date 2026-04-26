import SwiftUI

struct TrashView: View {
    @EnvironmentObject var store: TodoStore
    @State private var showDeleteAll = false

    var body: some View {
        VStack(spacing: 0) {
            trashHeader
            ScrollView {
                VStack(spacing: 16) {
                    infoCard
                    ForEach(store.trash) { item in
                        TrashItemRow(item: item)
                    }
                }.padding(24)
            }
        }
        .background(Color.brandBg)
        .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteAll) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) { store.emptyTrash() }
        } message: { Text("이 작업은 되돌릴 수 없습니다.") }
    }

    private var trashHeader: some View {
        HStack {
            Text("휴지통 🗑").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.txt1)
            Spacer()
            Button { showDeleteAll = true } label: {
                Text("전체 삭제").font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundColor(.danger)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.danger.opacity(0.1)).clipShape(Capsule())
            }
            .buttonStyle(SoftPressStyle())
        }
        .padding(.horizontal, 24).padding(.vertical, 16)
        .background(Color.white.opacity(0.95).shadow(color: .black.opacity(0.04), radius: 12, y: 4))
    }

    private var infoCard: some View {
        HStack(spacing: 12) {
            Text("ℹ️").font(.system(size: 14))
            Text("삭제된 항목은 30일 후 자동으로 영구 삭제됩니다.")
                .font(.system(size: 11, design: .rounded)).foregroundColor(.txt2).lineLimit(2)
        }
        .padding(16).background(Color.accent2.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - TrashItemRow (SRP: 휴지통 아이템 렌더링만 담당)

struct TrashItemRow: View {
    let item: Todo
    @EnvironmentObject var store: TodoStore

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.txt1).lineLimit(1)
                HStack(spacing: 4) {
                    Text("📅").font(.system(size: 10))
                    Text("삭제일: \(item.deletedAt?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                        .font(.system(size: 11, design: .rounded)).foregroundColor(.txt2)
                }
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { store.restore(item) }
            } label: {
                Text("복원").font(.system(size: 12, weight: .medium, design: .rounded)).foregroundColor(.accent3)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color.accent3.opacity(0.1)).clipShape(Capsule())
            }.buttonStyle(SoftPressStyle())
            Button {
                withAnimation { store.permanentDelete(item) }
            } label: {
                Text("삭제").font(.system(size: 12, weight: .medium, design: .rounded)).foregroundColor(.danger)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color.danger.opacity(0.1)).clipShape(Capsule())
            }.buttonStyle(SoftPressStyle())
        }
        .padding(20).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 16, y: 6)
    }
}

// MARK: - Preview

#Preview("TrashView") {
    TrashView()
        .environmentObject(TodoStore())
}
