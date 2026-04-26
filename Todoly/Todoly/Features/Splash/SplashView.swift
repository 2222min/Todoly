import SwiftUI

struct SplashView: View {
    @EnvironmentObject var app: AppState
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var rotation: Double = -10

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.warmGrad1, .warmGrad2, .warmGrad3, Color(hex: "D5E8FF")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            Circle().fill(Color.white.opacity(0.2)).frame(width: 200).offset(x: -120, y: -250)
            Circle().fill(Color.white.opacity(0.15)).frame(width: 150).offset(x: 140, y: 200)
            Circle().fill(Color.accent2.opacity(0.1)).frame(width: 100).offset(x: 100, y: -180)

            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.4)).frame(width: 120, height: 120).blur(radius: 20)
                    Text("📋").font(.system(size: 72)).rotationEffect(.degrees(rotation))
                }
                Text("Todoly")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .tracking(-1).foregroundColor(.txt1)
                Text("할 일 관리의 새로운 시작 ✨")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.txt2)
            }
            .scaleEffect(scale).opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1; opacity = 1; rotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { app.screen = .login }
        }
    }
}

// MARK: - Preview

#Preview("Splash") {
    SplashView()
        .environmentObject(AppState())
}
