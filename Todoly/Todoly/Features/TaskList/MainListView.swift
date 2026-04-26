import SwiftUI

struct MainListView: View {
    @EnvironmentObject var store: TodoStore
    @State private var quickText = ""
    @State private var showSearch = false
    @State private var showAddSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                mainHeader
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        heroSection
                        quickAddBar
                        incompleteSection
                        completedSection
                    }.padding(.bottom, 100)
                }
            }

            if store.showUndo {
                UndoToast(title: store.undoItem?.title ?? "", onUndo: { store.undoDelete() })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 90)
            }
        }
        .background(Color.brandBg)
        .fullScreenCover(isPresented: $showSearch) { SearchView() }
        .fullScreenCover(isPresented: $showAddSheet) { AddTaskSheet() }
    }

    // MARK: - Header

    private var mainHeader: some View {
        HStack {
            Text("Todoly")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .tracking(-1).foregroundColor(.txt1)
            Spacer()
            Button { showSearch = true } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium)).foregroundColor(.txt2)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            }
        }
        .padding(.horizontal, 24).padding(.vertical, 14)
        .background(Color.white.opacity(0.95).shadow(color: .black.opacity(0.04), radius: 12, y: 4))
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("오늘의 할 일")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .tracking(-0.5).foregroundColor(.txt1)
            Text("\(store.incomplete.count)개 남음")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.txt3)
        }.padding(.horizontal, 24).padding(.top, 24)
    }

    // MARK: - Quick Add

    private var quickAddBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "pencil").foregroundColor(.txt3).font(.system(size: 14))
            TextField("새로운 할 일 추가...", text: $quickText, prompt: Text("새로운 할 일 추가...").foregroundColor(.txt2))
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.txt1)
                .onSubmit { store.add(quickText); quickText = "" }
            Button { showAddSheet = true } label: {
                LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 36, height: 36).clipShape(Circle())
                    .overlay(Image(systemName: "plus").font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                    .shadow(color: .accent1.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(SoftPressStyle())
        }
        .padding(.leading, 20).padding(.trailing, 8).padding(.vertical, 8)
        .background(Capsule().fill(Color.white).shadow(color: .black.opacity(0.04), radius: 12, y: 4))
        .padding(.horizontal, 24)
    }

    // MARK: - Incomplete

    private var incompleteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("미완료")
                    .font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.txt1)
                Text("\(store.incomplete.count)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundColor(.accent1)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.accent1.opacity(0.1)).clipShape(Capsule())
                Spacer()
            }.padding(.horizontal, 24)

            VStack(spacing: 12) {
                ForEach(store.incomplete) { todo in
                    TaskCardView(todo: todo)
                }
            }.padding(.horizontal, 24)
        }
    }

    // MARK: - Completed

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("완료됨")
                    .font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(.txt3)
                Text("\(store.completed.count)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundColor(.txt3)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1)).clipShape(Capsule())
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .contentShape(Rectangle())

            ForEach(store.completed) { todo in
                CompletedRow(todo: todo).padding(.horizontal, 24)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}

// MARK: - Preview

#Preview("MainListView") {
    MainListView()
        .environmentObject(TodoStore())
}
