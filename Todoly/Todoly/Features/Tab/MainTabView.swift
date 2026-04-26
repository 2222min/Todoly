import SwiftUI

struct MainTabView: View {
    @StateObject private var store = TodoStore()
    @State private var tab: Tab = .tasks

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                MainListView()
                    .opacity(tab == .tasks ? 1 : 0)
                CalendarView()
                    .opacity(tab == .calendar ? 1 : 0)
                CategoryListView()
                    .opacity(tab == .categories ? 1 : 0)
                TrashView()
                    .opacity(tab == .trash ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.none, value: tab)

            BottomNavBar(selectedTab: $tab)
        }
        .background(Color.brandBg).ignoresSafeArea(edges: .bottom)
        .environmentObject(store)
    }
}

// MARK: - Preview

#Preview("MainTabView") {
    MainTabView()
}
