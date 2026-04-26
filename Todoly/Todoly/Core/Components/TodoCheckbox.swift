import SwiftUI

/// 통일된 체크박스 컴포넌트 — 할일 탭, 캘린더 등 모든 곳에서 사용
struct TodoCheckbox: View {
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(Color(hex: "34C759"))
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .stroke(Color.txt3, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Circle())
        }
        .buttonStyle(SoftPressStyle())
    }
}

// MARK: - Preview

#Preview("TodoCheckbox") {
    HStack(spacing: 20) {
        TodoCheckbox(isCompleted: false, action: {})
        TodoCheckbox(isCompleted: true, action: {})
    }
    .padding()
}
