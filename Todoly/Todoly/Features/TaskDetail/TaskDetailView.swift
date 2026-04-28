import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss
    let todoId: String

    @State private var title = ""
    @State private var memo = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var isPeriodTask = false
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var showEndDatePicker = false
    @State private var priority: Priority = .none
    @State private var categoryName: String? = nil
    @State private var reminderMinutes: Int? = 60
    @State private var showDeleteConfirm = false
    @State private var showDatePicker = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case title, memo }

    private let reminderPresets: [(String, Int?)] = [
        ("없음", nil), ("정시", 0), ("5분 전", 5), ("15분 전", 15),
        ("30분 전", 30), ("1시간 전", 60), ("1일 전", 1440),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 헤더 (저장 버튼 제거 → 하단 CTA)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.txt1)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Text("📝 할 일 수정")
                    .font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(Color.brandBg)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        titleField
                        if isPeriodTask { periodProgressSection }
                        memoField
                        dueDateSection
                        reminderSection
                        prioritySection
                        categorySection
                        deleteSection
                        Color.clear.frame(height: 1).id("bottom")
                    }.padding(24)
                }
                .onChange(of: focusedField) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }
            }

            // 하단 CTA 저장 버튼
            Button(action: save) {
                Text("저장하기")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(title.isEmpty ? Color.gray.opacity(0.4) : Color.txt1)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(title.isEmpty)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.brandBg)
        }
        .background(Color.brandBg)
        .onTapGesture { focusedField = nil }
        .navigationBarHidden(true)
        .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteConfirm) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                if let todo = findTodo() { store.softDelete(todo) }
                dismiss()
            }
        } message: { Text("이 작업은 되돌릴 수 없습니다.") }
        .fullScreenCover(isPresented: $showDatePicker) {
            CustomDatePicker(selectedDate: isPeriodTask ? $startDate : $dueDate)
        }
        .fullScreenCover(isPresented: $showEndDatePicker) {
            CustomDatePicker(selectedDate: $endDate)
        }
        .onAppear { loadTodo() }
    }

    // MARK: - Subviews

    private var titleField: some View {
        TextField("제목", text: $title, prompt: Text("제목").foregroundColor(.txt2))
            .font(.system(size: 28, weight: .black)).tracking(-1)
            .foregroundColor(.txt1)
            .focused($focusedField, equals: .title)
    }

    private var memoField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("메모", systemImage: "note.text")
                .font(.system(size: 13, weight: .semibold)).tracking(1.2).foregroundColor(.txt1)
            TextEditor(text: $memo)
                .font(.system(size: 14)).frame(minHeight: 100)
                .foregroundColor(.txt1)
                .focused($focusedField, equals: .memo)
                .scrollContentBackground(.hidden)
                .padding(12).background(Color.gray.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 일정 토글
            HStack {
                Label("일정", systemImage: "calendar")
                    .font(.system(size: 13, weight: .semibold)).tracking(1.2).foregroundColor(.txt1)
                Spacer()
                Toggle("", isOn: $hasDueDate).tint(.green).labelsHidden()
                    .background(Capsule().fill(Color.gray.opacity(0.25)).padding(1))
            }
            if hasDueDate || isPeriodTask {
                // 특정 날짜 / 기간 반복 세그먼트
                HStack(spacing: 8) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPeriodTask = false
                            hasDueDate = true
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11, weight: .medium))
                            Text("특정 날짜")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(isPeriodTask ? .txt2 : .white)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(isPeriodTask ? Color.gray.opacity(0.08) : Color.txt1)
                        .clipShape(Capsule())
                    }
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPeriodTask = true
                            hasDueDate = true
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                .font(.system(size: 11, weight: .medium))
                            Text("기간 반복")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(isPeriodTask ? .white : .txt2)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(isPeriodTask ? Color.accent1 : Color.gray.opacity(0.08))
                        .clipShape(Capsule())
                    }
                }

                if isPeriodTask {
                    // 연속 할일: 시작일/마지막날
                    Button { showDatePicker = true } label: {
                        HStack {
                            Text("📅")
                            Text("시작일: \(startDate.formatted(date: .long, time: .omitted))")
                                .font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                            Spacer()
                            Text("변경 ▸").font(.system(size: 12, design: .rounded)).foregroundColor(.accent1)
                        }
                        .padding(14).background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    Button { showEndDatePicker = true } label: {
                        HStack {
                            Text("🏁")
                            Text("마지막날: \(endDate.formatted(date: .long, time: .omitted))")
                                .font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                            Spacer()
                            Text("변경 ▸").font(.system(size: 12, design: .rounded)).foregroundColor(.accent1)
                        }
                        .padding(14).background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else {
                    // 일반 할일: 날짜 선택
                    Button { showDatePicker = true } label: {
                        HStack {
                            Text("📅")
                            Text(dueDate.formatted(date: .long, time: .shortened))
                                .font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                            Spacer()
                            Text("변경 ▸").font(.system(size: 12, design: .rounded)).foregroundColor(.accent1)
                        }
                        .padding(14).background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
    }

    /// 연속 할일 진행 현황
    private var periodProgressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("진행 현황", systemImage: "chart.bar")
                .font(.system(size: 13, weight: .semibold)).tracking(1.2).foregroundColor(.txt1)

            if let todo = findTodo() {
                let progress = DateBadgeLogic.periodProgress(for: todo)
                HStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accent1)
                                .frame(width: progress.total > 0 ? geo.size.width * CGFloat(progress.completed) / CGFloat(progress.total) : 0, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(progress.completed)/\(progress.total)일 완료")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.txt3)
                }

                // 날짜별 완료 현황 그리드
                let cal = Calendar.current
                let days = todo.totalDays
                if days > 0 && days <= 90 {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                        ForEach(0..<days, id: \.self) { offset in
                            if let date = cal.date(byAdding: .day, value: offset, to: todo.startDate ?? .now) {
                                let completed = todo.isCompletedOn(date)
                                let isToday = cal.isDateInToday(date)
                                VStack(spacing: 2) {
                                    Text(date.formatted(.dateTime.day()))
                                        .font(.system(size: 10, weight: isToday ? .bold : .regular, design: .rounded))
                                        .foregroundColor(isToday ? .accent1 : .txt3)
                                    Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(completed ? Color(hex: "34C759") : .gray.opacity(0.3))
                                }
                                .frame(height: 36)
                            }
                        }
                    }
                    .padding(12).background(Color.gray.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                } else if days > 90 {
                    // 장기 기간: 요약 뷰
                    let pct = progress.total > 0 ? Int(Double(progress.completed) / Double(progress.total) * 100) : 0
                    let remaining = progress.total - progress.completed
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text("\(pct)%")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.accent1)
                                Text("달성률")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.txt3)
                            }
                            .frame(maxWidth: .infinity)
                            VStack(spacing: 4) {
                                Text("\(progress.completed)일")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "34C759"))
                                Text("완료")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.txt3)
                            }
                            .frame(maxWidth: .infinity)
                            VStack(spacing: 4) {
                                Text("\(remaining)일")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.txt2)
                                Text("남음")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.txt3)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(16).background(Color.gray.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("알림", systemImage: "bell")
                .font(.system(size: 13, weight: .semibold)).tracking(1.2).foregroundColor(.txt1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(reminderPresets, id: \.0) { preset in
                        let isSelected = (preset.1 == nil && reminderMinutes == nil) ||
                                         (preset.1 != nil && preset.1 == reminderMinutes)
                        Button { reminderMinutes = preset.1 } label: {
                            Text(preset.0)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(isSelected ? .white : .txt2)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(isSelected ? Color.txt1 : Color.gray.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("우선순위", systemImage: "target")
                .font(.system(size: 13, weight: .semibold)).tracking(1.2).foregroundColor(.txt1)
            HStack(spacing: 8) {
                ForEach([Priority.high, .medium, .low], id: \.self) { p in
                    Button { priority = p } label: {
                        Text(p.label)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(priority == p ? .white : Color(hex: p.color))
                            .padding(.horizontal, 18).padding(.vertical, 8)
                            .background(priority == p ? Color(hex: p.color) : .clear)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(hex: p.color), lineWidth: 2))
                    }
                }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("카테고리", systemImage: "tag")
                .font(.system(size: 13, weight: .semibold)).tracking(1.2).foregroundColor(.txt1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TodoCategory.defaults) { cat in
                        let isSelected = categoryName == cat.name
                        Button { categoryName = isSelected ? nil : cat.name } label: {
                            HStack(spacing: 4) {
                                if isSelected { Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)) }
                                Text(cat.name).font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(isSelected ? .white : .txt1)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(isSelected ? Color.txt1 : Color.gray.opacity(0.08))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var deleteSection: some View {
        HStack {
            Spacer()
            Button { showDeleteConfirm = true } label: {
                Label("할 일 삭제", systemImage: "trash")
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.danger)
            }
            Spacer()
        }.padding(.top, 20)
    }

    // MARK: - Actions

    private func findTodo() -> Todo? {
        store.incomplete.first { $0.id == todoId } ?? store.completed.first { $0.id == todoId }
    }

    private func loadTodo() {
        guard let todo = findTodo() else { return }
        title = todo.title
        memo = todo.memo ?? ""
        if todo.isPeriodTask {
            isPeriodTask = true
            hasDueDate = true
            if let s = todo.startDate { startDate = s }
            if let e = todo.endDate { endDate = e }
        } else if let d = todo.dueDate {
            dueDate = d; hasDueDate = true
        }
        priority = todo.priority
        categoryName = todo.categoryName
        reminderMinutes = todo.reminderMinutes
    }

    private func save() {
        if isPeriodTask {
            store.updateWithPeriod(
                id: todoId, title: title, memo: memo.isEmpty ? nil : memo,
                dueDate: nil, startDate: startDate, endDate: endDate,
                priority: priority, categoryName: categoryName,
                categoryColor: TodoCategory.defaults.first { $0.name == categoryName }?.color,
                reminderMinutes: reminderMinutes
            )
        } else {
            store.update(
                id: todoId, title: title, memo: memo.isEmpty ? nil : memo,
                dueDate: hasDueDate ? dueDate : nil, priority: priority,
                categoryName: categoryName,
                categoryColor: TodoCategory.defaults.first { $0.name == categoryName }?.color,
                reminderMinutes: reminderMinutes
            )
        }

        if let todo = findTodo() {
            if reminderMinutes != nil && hasDueDate && !isPeriodTask {
                NotificationService.shared.scheduleReminder(for: todo, minutesBefore: reminderMinutes)
            } else if reminderMinutes != nil && !hasDueDate && !isPeriodTask {
                NotificationService.shared.scheduleTestReminder(for: todo)
            } else {
                NotificationService.shared.cancelReminder(todoId: todoId)
            }
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview("TaskDetail") {
    NavigationStack {
        TaskDetailView(todoId: "preview-id")
    }
    .environmentObject(TodoStore())
}
