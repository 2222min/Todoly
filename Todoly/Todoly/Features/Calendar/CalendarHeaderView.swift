import SwiftUI

struct CalendarHeaderView: View {
    let displayMonth: Date
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.txt1)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("이전 달")

            Spacer()

            Text(CalendarDateLogic.monthYearString(for: displayMonth))
                .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.txt1)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.txt1)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("다음 달")
        }
    }
}

// MARK: - Preview

#Preview("CalendarHeader") {
    CalendarHeaderView(displayMonth: Date(), onPrevious: {}, onNext: {})
        .padding()
}
