import SwiftUI

private struct TodoSheetItem: Identifiable {
    let id: String
}

struct CalendarView: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var displayMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var monthTransitionDirection: Edge = .trailing
    @State private var selectedTodoId: TodoSheetItem? = nil

    private var effectiveMonthSlide: Animation {
        reduceMotion ? .default : CalendarAnimationConstants.monthSlide
    }

    private var effectiveTaskListAppear: Animation {
        reduceMotion ? .default : CalendarAnimationConstants.taskListAppear
    }

    var body: some View {
        VStack(spacing: 0) {
            calendarTopHeader

            CalendarHeaderView(
                displayMonth: displayMonth,
                onPrevious: { changeMonth(-1) },
                onNext: { changeMonth(1) }
            )
            .padding(.horizontal, 16).padding(.top, 16)

            CalendarGridView(
                displayMonth: displayMonth,
                selectedDate: $selectedDate,
                store: store,
                reduceMotion: reduceMotion
            )
            .id(displayMonth)
            .transition(.asymmetric(
                insertion: .move(edge: monthTransitionDirection),
                removal: .move(edge: monthTransitionDirection == .trailing ? .leading : .trailing)
            ))
            .padding(.horizontal, 16).padding(.top, 16)

            selectedDateContent
            Spacer()
        }
        .background(Color.brandBg)
        .animation(effectiveTaskListAppear, value: selectedDate)
        .fullScreenCover(item: $selectedTodoId) { item in
            NavigationStack { TaskDetailView(todoId: item.id) }
        }
        .onAppear { selectedDate = Date() }
    }

    // MARK: - Selected Date Content

    @ViewBuilder
    private var selectedDateContent: some View {
        if let date = selectedDate {
            let todos = store.calendarIncompleteTodos(for: date)
            let completedTodos = store.completedTodos(for: date)
            let hasAnyContent = !todos.isEmpty || !completedTodos.isEmpty

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !hasAnyContent {
                        emptyMessage("이 날은 할 일이 없어요 🎉")
                    } else {
                        Text(dayHeaderString(for: date))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.txt1)
                            .padding(.horizontal, 16).padding(.top, 16)

                        if !todos.isEmpty {
                            dayTaskList(date: date, todos: todos)
                        }

                        if !completedTodos.isEmpty {
                            completedSection(todos: completedTodos)
                        }
                    }
                }
                .padding(.bottom, 140)
            }
            .id(date)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    emptyMessage("날짜를 선택해주세요 📅")
                }
            }
        }
    }

    private func emptyMessage(_ text: String) -> some View {
        VStack {
            Spacer().frame(height: 40)
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.txt3).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func dayTaskList(date: Date, todos: [Todo]) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(todos.enumerated()), id: \.element.id) { index, todo in
                DayTaskRow(
                    todo: todo, index: index, date: date,
                    onEdit: { selectedTodoId = TodoSheetItem(id: todo.id) },
                    onComplete: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            if todo.isPeriodTask {
                                store.toggleDailyCompletion(todo, date: date)
                            } else {
                                store.toggleComplete(todo)
                            }
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }.padding(.horizontal, 16).padding(.top, 8)
    }

    private func completedSection(todos: [Todo]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("완료됨")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.txt3).padding(.horizontal, 16).padding(.top, 4)
            ForEach(todos) { todo in
                CompletedDayTaskRow(
                    todo: todo,
                    onToggle: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            if todo.isPeriodTask {
                                store.toggleDailyCompletion(todo, date: selectedDate ?? .now)
                            } else {
                                store.toggleComplete(todo)
                            }
                        }
                    },
                    onEdit: { selectedTodoId = TodoSheetItem(id: todo.id) }
                )
                .padding(.horizontal, 16)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
    }

    // MARK: - Top Header

    private var calendarTopHeader: some View {
        HStack {
            Text("캘린더 📅")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.txt1)
            Spacer()
        }
        .padding(.horizontal, 24).padding(.vertical, 16)
        .background(Color.brandBg)
    }

    // MARK: - Actions

    private func changeMonth(_ delta: Int) {
        monthTransitionDirection = delta > 0 ? .trailing : .leading
        withAnimation(effectiveMonthSlide) {
            displayMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayMonth) ?? displayMonth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let cal = Calendar.current
            guard let range = cal.range(of: .day, in: .month, for: displayMonth) else { return }
            var latestDateWithTodos: Date? = nil
            for day in range.reversed() {
                var comps = cal.dateComponents([.year, .month], from: displayMonth)
                comps.day = day
                guard let date = cal.date(from: comps) else { continue }
                if !store.todos(for: date).isEmpty {
                    latestDateWithTodos = date
                    break
                }
            }
            withAnimation(effectiveTaskListAppear) { selectedDate = latestDateWithTodos }
        }
    }

    /// 순수 함수: 날짜 헤더 문자열
    private func dayHeaderString(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "📋 M월 d일 할 일"
        return df.string(from: date)
    }
}

// MARK: - Preview

#Preview("CalendarView") {
    CalendarView()
        .environmentObject(TodoStore())
}
