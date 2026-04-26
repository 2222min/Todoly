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
        let noDueDateTodos = store.todosWithoutDueDate

        if let date = selectedDate {
            let todos = store.incompleteTodos(for: date)
            let completedTodos = store.completedTodos(for: date)
            let hasAnyContent = !todos.isEmpty || !completedTodos.isEmpty
            let hasDueDateTodos = !store.todosWithDueDate.isEmpty

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !hasDueDateTodos && noDueDateTodos.isEmpty {
                        emptyMessage("마감일을 설정하면\n캘린더에서 확인할 수 있어요 📅")
                    } else if !hasAnyContent {
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

                    // 날짜 미지정 섹션 (항상 표시, 있을 때만)
                    if !noDueDateTodos.isEmpty {
                        noDueDateSection(todos: noDueDateTodos)
                    }
                }
                .padding(.bottom, 100)
            }
            .id(date)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    emptyMessage("이 달은 할 일이 없어요 📅")

                    if !noDueDateTodos.isEmpty {
                        noDueDateSection(todos: noDueDateTodos)
                    }
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
                    onTap: { selectedTodoId = TodoSheetItem(id: todo.id) },
                    onComplete: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            store.toggleComplete(todo)
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
                            store.toggleComplete(todo)
                        }
                    }
                )
                .padding(.horizontal, 16)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
    }

    // MARK: - No Due Date Section

    @State private var isNoDueDateExpanded = true

    private func noDueDateSection(todos: [Todo]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 구분선
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 1)
                .padding(.horizontal, 20).padding(.top, 8)

            // 헤더
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isNoDueDateExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("📌")
                        .font(.system(size: 14))
                    Text("날짜 미지정")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.txt2)
                    Text("\(todos.count)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.accent1)
                        .padding(.horizontal, 7).padding(.vertical, 2)
                        .background(Color.accent1.opacity(0.1)).clipShape(Capsule())
                    Spacer()
                    Image(systemName: isNoDueDateExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.txt3)
                }
                .padding(.horizontal, 24)
            }

            // 할일 목록
            if isNoDueDateExpanded {
                VStack(spacing: 8) {
                    ForEach(todos) { todo in
                        NoDueDateTaskRow(
                            todo: todo,
                            onTap: { selectedTodoId = TodoSheetItem(id: todo.id) },
                            onComplete: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    store.toggleComplete(todo)
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 0.95).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, 24)
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
        .background(Color.white.opacity(0.95).shadow(color: .black.opacity(0.04), radius: 12, y: 4))
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
