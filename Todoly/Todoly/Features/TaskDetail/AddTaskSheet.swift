import SwiftUI

struct AddTaskSheet: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var memo = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var priority: Priority = .medium
    @State private var categoryName: String? = nil
    @State private var reminderMinutes: Int? = 60
    @State private var hasReminder = true
    @State private var showDatePicker = false

    private let reminderPresets: [(String, Int?)] = [
        ("없음", nil), ("정시", 0), ("5분 전", 5), ("15분 전", 15),
        ("30분 전", 30), ("1시간 전", 60), ("1일 전", 1440),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 헤더
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium)).foregroundColor(.txt2)
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Text("✏️ 새 할 일")
                    .font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                Spacer()
                Button { addTask() } label: {
                    Text("추가").font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 6)
                        .background(title.isEmpty ? Color.gray : Color.txt1)
                        .clipShape(Capsule())
                }.disabled(title.isEmpty)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(Color.white)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    titleField
                    memoField
                    dueDateSection
                    reminderSection
                    prioritySection
                    categorySection
                }.padding(24)
            }
        }
        .background(Color.white)
        .fullScreenCover(isPresented: $showDatePicker) {
            CustomDatePicker(selectedDate: $dueDate)
        }
    }

    // MARK: - Subviews

    private var titleField: some View {
        TextField("할 일 제목을 입력하세요...", text: $title, prompt: Text("할 일 제목을 입력하세요...").foregroundColor(.txt2))
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.txt1)
            .padding(16).background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var memoField: some View {
        TextField("메모 (선택)", text: $memo, prompt: Text("메모 (선택)").foregroundColor(.txt2))
            .font(.system(size: 14))
            .foregroundColor(.txt1)
            .padding(16).background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("📅 마감일").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(.txt2)
                Spacer()
                Toggle("", isOn: $hasDueDate).tint(.green).labelsHidden()
            }
            if hasDueDate {
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

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🔔 알림").font(.system(size: 13, weight: .medium)).foregroundColor(.txt2)
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
            Text("🎯 우선순위").font(.system(size: 13, weight: .medium)).foregroundColor(.txt2)
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
            Text("🏷 카테고리").font(.system(size: 13, weight: .medium)).foregroundColor(.txt2)
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
        let todo = Todo(
            title: title,
            memo: memo.isEmpty ? nil : memo,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            categoryName: categoryName,
            categoryColor: cat?.color,
            reminderMinutes: hasReminder ? reminderMinutes : nil
        )
        store.incomplete.insert(todo, at: 0)

        if hasReminder && hasDueDate {
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
