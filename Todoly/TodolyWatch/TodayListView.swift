import SwiftUI

/// Watch 메인 화면 — 오늘 미완료 할 일
struct TodayListView: View {
    @EnvironmentObject var store: WatchStore

    var body: some View {
        NavigationStack {
            Group {
                if store.incomplete.isEmpty {
                    VStack(spacing: 8) {
                        Text("🎉")
                            .font(.system(size: 36))
                        Text("모두 완료!")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.incomplete) { todo in
                            WatchTodoRow(todo: todo) {
                                store.toggleComplete(todo)
                            }
                        }
                    }
                }
            }
            .navigationTitle("오늘 할 일")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(store.incomplete.count)개")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
            }
        }
        .onAppear { store.load() }
    }
}

#Preview {
    TodayListView()
        .environmentObject(WatchStore())
}
