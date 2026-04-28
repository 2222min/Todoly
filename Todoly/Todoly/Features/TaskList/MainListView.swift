import SwiftUI

struct MainListView: View {
    @EnvironmentObject var store: TodoStore
    @State private var quickText = ""
    @State private var showSearch = false
    @State private var showAddSheet = false
    @State private var selectedDate = Date()

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                mainHeader
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        WeeklyCalendarStrip(selectedDate: $selectedDate)
                            .padding(.top, 8)
                        quickAddBar
                        todaySection
                    }.padding(.bottom, 140)
                }
            }

            if store.showUndo {
                UndoToast(title: store.undoItem?.title ?? "", onUndo: { store.undoDelete() })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 90)
            }
        }
        .background(Color.brandBg)
        .fullScreenCover(isPresented: $showSearch) { SearchView() }
        .fullScreenCover(isPresented: $showAddSheet) { AddTaskSheet(initialDate: selectedDate) }
    }

    // MARK: - Header

    private var mainHeader: some View {
        HStack {
            Text("Todoly")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .tracking(-1).foregroundColor(.txt1)
            Spacer()
            if !Calendar.current.isDateInToday(selectedDate) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedDate = Date() }
                } label: {
                    Text("오늘")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.accent1)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.accent1.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            Button { showSearch = true } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium)).foregroundColor(.txt2)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            }
        }
        .padding(.horizontal, 24).padding(.vertical, 14)
        .background(Color.brandBg)
    }

    // MARK: - Quick Add

    private var quickAddBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "pencil").foregroundColor(.txt3).font(.system(size: 14))
            TextField("새로운 할 일 추가...", text: $quickText, prompt: Text("새로운 할 일 추가...").foregroundColor(.txt2))
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.txt1)
                .onSubmit { quickAdd() }
            Button { showAddSheet = true } label: {
                LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 36, height: 36).clipShape(Circle())
                    .overlay(Image(systemName: "plus").font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                    .shadow(color: .accent1.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(SoftPressStyle())
        }
        .padding(.leading, 20).padding(.trailing, 8).padding(.vertical, 8)
        .background(Capsule().fill(Color.white).shadow(color: .black.opacity(0.04), radius: 12, y: 4))
        .padding(.horizontal, 24)
    }

    // MARK: - Unified Task Section

    private var todaySection: some View {
        let isToday = Calendar.current.isDateInToday(selectedDate)

        // 미완료 일반: 오늘이면 마감일 없는 것도 포함, 다른 날이면 해당 날짜 + 지연 포함
        let incompleteTodos: [Todo] = isToday
            ? store.todayIncompleteRegular
            : store.calendarIncompleteTodos(for: selectedDate)

        // 연속 할일
        let periodTodos = TodoFilterLogic.periodTodosActive(on: selectedDate, from: store.incomplete)

        // 완료
        let completedTodos = isToday
            ? store.todayCompletedTodos
            : store.completedTodos(for: selectedDate)

        let totalIncomplete = incompleteTodos.count + periodTodos.filter { !$0.isCompletedOn(selectedDate) }.count
        let totalCount = incompleteTodos.count + periodTodos.count + completedTodos.count

        // 헤더 텍스트
        let headerText: String = {
            if isToday { return "오늘 할 일" }
            let df = DateFormatter()
            df.locale = Locale(identifier: "ko_KR")
            df.dateFormat = "M월 d일 할 일"
            return df.string(from: selectedDate)
        }()

        return Group {
            if totalCount > 0 {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Text(headerText)
                            .font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.txt1)
                        if totalIncomplete > 0 {
                            Text("\(totalIncomplete)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundColor(.accent1)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color.accent1.opacity(0.1)).clipShape(Capsule())
                        }
                        Spacer()
                    }.padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        // 1) 미완료 일반
                        ForEach(incompleteTodos) { todo in
                            TaskCardView(todo: todo)
                        }

                        // 2) 연속 할일 (미완료 먼저, 완료 나중)
                        let periodIncomplete = periodTodos.filter { !$0.isCompletedOn(selectedDate) }
                        let periodCompleted = periodTodos.filter { $0.isCompletedOn(selectedDate) }

                        ForEach(periodIncomplete) { todo in
                            PeriodTaskCardView(todo: todo)
                        }
                        ForEach(periodCompleted) { todo in
                            PeriodTaskCardView(todo: todo)
                        }

                        // 3) 완료 일반
                        ForEach(completedTodos) { todo in
                            TaskCardView(todo: todo, isCompleted: true)
                        }
                    }.padding(.horizontal, 24)
                }
            } else {
                VStack(spacing: 8) {
                    Text("🎉")
                        .font(.system(size: 36))
                    Text("할 일이 없어요")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.txt3)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            }
        }
    }
    // MARK: - Actions

    private func quickAdd() {
        guard !quickText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let isToday = Calendar.current.isDateInToday(selectedDate)
        var todo = Todo(title: quickText, priority: .medium)
        if !isToday {
            todo.dueDate = selectedDate
        }
        store.incomplete.insert(todo, at: 0)
        quickText = ""
    }
}

// MARK: - Preview

#Preview("MainListView") {
    MainListView()
        .environmentObject(TodoStore())
}
