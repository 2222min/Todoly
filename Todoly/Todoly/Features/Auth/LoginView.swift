import SwiftUI

struct LoginView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        VStack(spacing: 0) {
            loginHeader
            Spacer().frame(height: 40)
            loginButtons
            Spacer()
            termsText
        }
        .background(Color(hex: "FFFBF7")).ignoresSafeArea(edges: .top)
    }

    // MARK: - Subviews

    private var loginHeader: some View {
        ZStack {
            LinearGradient(colors: [.warmGrad1, .warmGrad2, .warmGrad3],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(Color.white.opacity(0.25)).frame(width: 120).offset(x: -130, y: -60)
            Circle().fill(Color.white.opacity(0.15)).frame(width: 80).offset(x: 140, y: 40)
            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.3)).frame(width: 100).blur(radius: 15)
                    Text("📋").font(.system(size: 56))
                }
                Text("Todoly")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .tracking(-1).foregroundColor(.txt1)
                Text("할 일 관리의 새로운 시작 🚀")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.txt2)
            }
        }.frame(height: 340)
    }

    private var loginButtons: some View {
        VStack(spacing: 14) {
            loginButton(icon: "🍎", label: "Apple로 계속하기", bg: .txt1, fg: .white)
            loginButton(icon: "🔵", label: "Google로 계속하기", bg: .white, fg: .txt1, bordered: true)
            loginButton(icon: "✉️", label: "이메일로 계속하기", bg: .white, fg: .txt1, bordered: true)
        }.padding(.horizontal, 40)
    }

    private var termsText: some View {
        Text("계속하면 이용약관 및 개인정보처리방침에\n동의하는 것으로 간주합니다.")
            .font(.system(size: 11, design: .rounded)).foregroundColor(.txt3)
            .multilineTextAlignment(.center).padding(.bottom, 40)
    }

    private func loginButton(icon: String, label: String, bg: Color, fg: Color, bordered: Bool = false) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { app.screen = .main }
        } label: {
            HStack(spacing: 12) {
                Text(icon).font(.system(size: 20))
                Text(label).font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(fg)
            }
            .frame(maxWidth: .infinity).frame(height: 52)
            .background(bg).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(bordered ? Color.gray.opacity(0.2) : .clear, lineWidth: 1.5))
            .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        }
        .buttonStyle(SoftPressStyle())
    }
}

// MARK: - Preview

#Preview("Login") {
    LoginView()
        .environmentObject(AppState())
}
