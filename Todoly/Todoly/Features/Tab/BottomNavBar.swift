import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                tabItem(for: tab)
                Spacer()
            }
        }
        .padding(.top, 10).padding(.bottom, 28)
        .background(glassBackground)
    }

    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 26.0, *) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .glassEffect(.regular, in: .rect(cornerRadius: 0))
        } else {
            Color.white.shadow(color: .black.opacity(0.04), radius: 16, y: -4)
        }
    }

    private func tabItem(for tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [.clear, .clear],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 42, height: 42)
                    .shadow(color: isSelected ? .accent1.opacity(0.3) : .clear, radius: 8, y: 3)
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .txt3)
            }
            Text(tab.rawValue)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .accent1 : .txt3)
        }
        .frame(width: 72, height: 60)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTab = tab
        }
    }
}

// MARK: - Preview

#Preview("BottomNavBar") {
    VStack {
        Spacer()
        BottomNavBar(selectedTab: .constant(.tasks))
    }
    .background(Color.brandBg)
}
