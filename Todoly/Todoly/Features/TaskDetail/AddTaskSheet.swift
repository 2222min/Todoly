import SwiftUI

struct AddTaskSheet: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss

    var initialDate: Date = Date()

    @State private var title = ""
    @State private var memo = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var isPeriodTask = false
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var showEndDatePicker = false
    @State private var priority: Priority = .medium
    @State private var categoryName: String? = nil
    @State private var reminderMinutes: Int? = 60
    @State private var hasReminder = true
    @State private var showDatePicker = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case title, memo }

    private let reminderPresets: [(String, Int?)] = [
        ("없음", nil), ("정시", 0), ("5분 전", 5), ("15분 전", 15),
        ("30분 전", 30), ("1시간 전", 60), ("1일 전", 1440),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 헤더 (추가 버튼 제거 → 하단 CTA로 이동)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold)).foregroundColor(.txt1)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Text("✏️ 새 할 일")
                    .font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                Spacer()
                // 헤더 좌우 균형용 투명 스페이서
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(Color.brandBg)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        titleField
                        memoField
                        dueDateSection
                        reminderSection
                        prioritySection
                        categorySection
                        Color.clear.frame(height: 1).id("bottom")
                    }.padding(24)
                }
                .onChange(of: focusedField) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }
            }

            // 하단 CTA 버튼
            Button(action: addTask) {
                Text("추가하기")
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
        .fullScreenCover(isPresented: $showDatePicker) {
            CustomDatePicker(selectedDate: $dueDate)
        }
        .fullScreenCover(isPresented: $showEndDatePicker) {
            CustomDatePicker(selectedDate: $endDate)
        }
        .onAppear {
            dueDate = initialDate
            endDate = Calendar.current.date(byAdding: .day, value: 7, to: initialDate) ?? initialDate
        }
    }

    // MARK: - Subviews

    private var titleField: some View {
        TextField("할 일 제목을 입력하세요...", text: $title, prompt: Text("할 일 제목을 입력하세요...").foregroundColor(.txt2))
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.txt1)
            .focused($focusedField, equals: .title)
            .padding(16).background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var memoField: some View {
        TextField("메모 (선택)", text: $memo, prompt: Text("메모 (선택)").foregroundColor(.txt2))
            .font(.system(size: 14))
            .foregroundColor(.txt1)
            .focused($focusedField, equals: .memo)
            .padding(16).background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 일정 토글
            HStack {
                Text("📅 일정").font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                Spacer()
                Toggle("", isOn: $hasDueDate).tint(.green).labelsHidden()
                    .background(Capsule().fill(Color.gray.opacity(0.25)).padding(1))
            }
            if hasDueDate {
                // 특정 날짜 / 기간 반복 세그먼트
                HStack(spacing: 8) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { isPeriodTask = false }
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
                        withAnimation(.easeInOut(duration: 0.2)) { isPeriodTask = true }
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
                    // 연속 할일: 시작일 + 마지막날
                    Button { showDatePicker = true } label: {
                        HStack {
                            Text("📅")
                            Text("시작일: \(dueDate.formatted(date: .long, time: .omitted))")
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

                    let days = periodDays
                    if days > 0 {
                        Text("ℹ️ \(days)일간 매일 반복됩니다")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.accent1)
                    }
                    if days > 365 {
                        Text("⚠️ 장기 기간은 진행 현황이 요약으로 표시됩니다")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.priHigh)
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

    private var periodDays: Int {
        let cal = Calendar.current
        return (cal.dateComponents([.day], from: cal.startOfDay(for: dueDate), to: cal.startOfDay(for: endDate)).day ?? 0) + 1
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🔔 알림").font(.system(size: 15, weight: .semibold)).foregroundColor(.txt1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(reminderPresets, id: \.0) { preset in
                        let isSelected = (preset.1 == nil && reminderMinutes == nil) ||
                                         (preset.1 != nil && preset.1 == reminderMinutes)
                        Button {
                            reminderMinutes = preset.1
                            hasReminder = preset.1 != nil
                        } label: {
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
            Text("🎯 우선순위").font(.system(size: 15, weight: .semibold)).foregroundColor(.txt1)
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
            Text("🏷 카테고리").font(.system(size: 15, weight: .semibold)).foregroundColor(.txt1)
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

    // MARK: - Action

    private func addTask() {
        let cat = TodoCategory.defaults.first { $0.name == categoryName }
        let isValidPeriod = isPeriodTask && hasDueDate && periodDays > 0
        let todo = Todo(
            title: title,
            memo: memo.isEmpty ? nil : memo,
            dueDate: (hasDueDate && !isPeriodTask) ? dueDate : nil,
            priority: priority,
            categoryName: categoryName,
            categoryColor: cat?.color,
            reminderMinutes: hasReminder ? reminderMinutes : nil,
            startDate: isValidPeriod ? dueDate : nil,
            endDate: isValidPeriod ? endDate : nil
        )
        store.incomplete.insert(todo, at: 0)

        if hasReminder && hasDueDate && !isPeriodTask {
            NotificationService.shared.scheduleReminder(for: todo, minutesBefore: reminderMinutes)
        }
        if hasReminder && !hasDueDate {
            NotificationService.shared.scheduleTestReminder(for: todo)
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview("AddTaskSheet") {
    AddTaskSheet()
        .environmentObject(TodoStore())
}
