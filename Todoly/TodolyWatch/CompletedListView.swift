import SwiftUI

/// Watch 완료 화면 — 오늘 완료한 할 일
struct CompletedListView: View {
    @EnvironmentObject var store: WatchStore

    var body: some View {
        NavigationStack {
            Group {
                if store.completed.isEmpty {
                    VStack(spacing: 8) {
                        Text("📋")
                            .font(.system(size: 36))
                        Text("아직 완료한 할 일이 없어요")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.completed) { todo in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.green)

                                Text(todo.title)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .strikethrough()
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("✅ 완료")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(store.completed.count)개")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
            }
        }
        .onAppear { store.load() }
    }
}

#Preview {
    CompletedListView()
        .environmentObject(WatchStore())
}
