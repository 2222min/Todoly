import SwiftUI

struct CalendarGridView: View {
    let displayMonth: Date
    @Binding var selectedDate: Date?
    let store: TodoStore
    let reduceMotion: Bool

    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var effectiveDateSelection: Animation {
        reduceMotion ? .default : CalendarAnimationConstants.dateSelection
    }

    var body: some View {
        VStack(spacing: 8) {
            weekdayHeader
            daysGrid
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                Text(day)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(weekdayColor(index: index))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(CalendarDateLogic.daysInMonth(for: displayMonth), id: \.self) { day in
                if day <= 0 {
                    Color.clear.frame(height: 48)
                } else {
                    dayCell(day: day)
                }
            }
        }
    }

    private func dayCell(day: Int) -> some View {
        let date = CalendarDateLogic.makeDate(day: day, in: displayMonth)
        let isToday = Calendar.current.isDateInToday(date)
        let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
        let todoCount = store.todos(for: date).count
        let dots = DateBadgeLogic.dotPriorityColors(for: store.todos(for: date))

        return Button { selectedDate = date } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isToday && !isSelected {
                        Circle().fill(Color.accent1.opacity(0.15)).frame(width: 36, height: 36)
                    }
                    Circle()
                        .fill(LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 36, height: 36)
                        .scaleEffect(isSelected ? 1.0 : 0.0)
                        .opacity(isSelected ? 1.0 : 0.0)
                        .animation(effectiveDateSelection, value: selectedDate)
                    Text("\(day)")
                        .font(.system(size: 14, weight: isSelected || isToday ? .bold : .medium, design: .rounded))
                        .foregroundColor(dateTextColor(
                            isSelected: isSelected, isToday: isToday,
                            weekdayIndex: CalendarDateLogic.weekdayIndex(for: day, in: displayMonth)
                        ))
                }.frame(width: 36, height: 36)

                HStack(spacing: 2) {
                    ForEach(Array(dots.enumerated()), id: \.offset) { _, priority in
                        Circle().fill(Color(hex: priority.color)).frame(width: 4, height: 4)
                    }
                }.frame(height: 4)
            }
        }
        .frame(height: 48)
        .accessibilityLabel("\(Calendar.current.component(.month, from: date))월 \(day)일, 할 일 \(todoCount)개")
    }

    // MARK: - Pure Helpers

    private func weekdayColor(index: Int) -> Color {
        switch index {
        case 0: return Color(hex: "FF6B6B")
        case 6: return Color(hex: "5B9BF5")
        default: return .txt3
        }
    }

    private func dateTextColor(isSelected: Bool, isToday: Bool, weekdayIndex: Int) -> Color {
        if isSelected { return .white }
        if isToday { return .accent1 }
        switch weekdayIndex {
        case 0: return Color(hex: "FF6B6B")
        case 6: return Color(hex: "5B9BF5")
        default: return .txt1
        }
    }
}

// MARK: - Preview

#Preview("CalendarGrid") {
    CalendarGridView(
        displayMonth: Date(),
        selectedDate: .constant(Date()),
        store: TodoStore(),
        reduceMotion: false
    )
    .padding()
}
