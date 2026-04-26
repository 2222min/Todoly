import SwiftUI

struct UndoToast: View {
    let title: String
    var onUndo: () -> Void
    @State private var progress: CGFloat = 1

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("🗑")
                Text("\"\(title)\" 삭제됨")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white).lineLimit(1)
                Spacer()
                Button { onUndo() } label: {
                    Text("되돌리기")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.accent3)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.white.opacity(0.15)).clipShape(Capsule())
                }
                .buttonStyle(SoftPressStyle())
            }.padding(.horizontal, 16).padding(.vertical, 12)
            GeometryReader { g in
                Rectangle()
                    .fill(LinearGradient(colors: [.accent3, .accent2],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: g.size.width * progress, height: 3)
            }.frame(height: 3)
        }
        .background(Color(hex: "2D2D2D")).clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 6)
        .padding(.horizontal, 24)
        .onAppear { withAnimation(.linear(duration: 3)) { progress = 0 } }
    }
}

// MARK: - Preview

#Preview("UndoToast") {
    ZStack {
        Color.brandBg.ignoresSafeArea()
        UndoToast(title: "테스트 할 일", onUndo: {})
    }
}
