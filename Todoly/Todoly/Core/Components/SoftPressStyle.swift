import SwiftUI

/// 부드러운 눌림 애니메이션 버튼 스타일
struct SoftPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("SoftPressStyle") {
    Button("Tap Me") {}
        .padding()
        .background(Color.accent1)
        .foregroundColor(.white)
        .clipShape(Capsule())
        .buttonStyle(SoftPressStyle())
}
