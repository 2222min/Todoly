import SwiftUI

/// 할일 탭 상단 주간 캘린더 스트립
struct WeeklyCalendarStrip: View {
    @EnvironmentObject var store: TodoStore
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private let weekdays = ["일","월","화","수","목","금","토"]

    var body: some View {
        VStack(spacing: 12) {
            // 월 표시
            HStack {
                Text(monthString)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.txt1)
                Spacer()
                Text("\(incompleteCount)개 남음")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.txt3)
            }
            .padding(.horizontal, 4)

            // 주간 날짜 스트립
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let count = taskCount(for: date)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedDate = date }
                    } label: {
                        VStack(spacing: 6) {
                            Text(isToday ? "오늘" : weekdayString(for: date))
                                .font(.system(size: 11, weight: isToday ? .bold : .medium, design: .rounded))
                                .foregroundColor(isSelected ? .accent1 : (isToday ? .accent1 : .txt3))

                            ZStack {
                                Circle()
                                    .fill(isSelected
                                          ? LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                                          : LinearGradient(colors: [.clear, .clear],
                                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 38, height: 38)

                                if isToday && !isSelected {
                                    Circle()
                                        .fill(Color.accent1.opacity(0.12))
                                        .frame(width: 38, height: 38)
                                }

                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 15, weight: isSelected || isToday ? .bold : .medium, design: .rounded))
                                    .foregroundColor(isSelected ? .white : (isToday ? .accent1 : .txt1))
                            }

                            // 할일 개수 dot
                            HStack(spacing: 3) {
                                if count > 0 {
                                    Circle()
                                        .fill(isSelected ? Color.white.opacity(0.8) : Color.accent1)
                                        .frame(width: 5, height: 5)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 5, height: 5)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers

    private var weekDates: [Date] {
        let today = calendar.startOfDay(for: selectedDate)
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private var monthString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "M월"
        return df.string(from: selectedDate)
    }

    private var incompleteCount: Int {
        let date = selectedDate
        if calendar.isDateInToday(date) {
            return store.todayIncompleteCount
        }
        let incomplete = TodoFilterLogic.calendarIncompleteTodos(for: date, from: store.incomplete).count
        let period = TodoFilterLogic.periodTodosActive(on: date, from: store.incomplete)
            .filter { !$0.isCompletedOn(date) }.count
        return incomplete + period
    }

    private func taskCount(for date: Date) -> Int {
        let cal = calendar
        let incomplete = cal.isDateInToday(date)
            ? TodoFilterLogic.todayIncompleteRegular(from: store.incomplete).count
            : TodoFilterLogic.calendarIncompleteTodos(for: date, from: store.incomplete).count
        let period = TodoFilterLogic.periodTodosActive(on: date, from: store.incomplete).count
        let completed = cal.isDateInToday(date)
            ? TodoFilterLogic.todayCompletedTodos(from: store.completed).count
            : TodoFilterLogic.completedTodos(for: date, from: store.completed, incomplete: store.incomplete).count
        return incomplete + period + completed
    }

    private func weekdayString(for date: Date) -> String {
        let idx = calendar.component(.weekday, from: date) - 1
        return weekdays[idx]
    }
}

// MARK: - Preview

#Preview("WeeklyCalendarStrip") {
    WeeklyCalendarStrip(selectedDate: .constant(Date()))
        .environmentObject(TodoStore())
        .padding()
        .background(Color.brandBg)
}
