import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss
    let todoId: String

    @State private var title = ""
    @State private var memo = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var priority: Priority = .none
    @State private var categoryName: String? = nil
    @State private var reminderMinutes: Int? = 60
    @State private var showDeleteConfirm = false
    @State private var showDatePicker = false

    private let reminderPresets: [(String, Int?)] = [
        ("없음", nil), ("정시", 0), ("5분 전", 5), ("15분 전", 15),
        ("30분 전", 30), ("1시간 전", 60), ("1일 전", 1440),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 헤더 (liquid glass 방지)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.txt2)
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Button { save() } label: {
                    Text("저장").font(.system(size: 15, weight: .semibold))
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
                    deleteSection
                }.padding(24)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteConfirm) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                if let todo = findTodo() { store.softDelete(todo) }
                dismiss()
            }
        } message: { Text("이 작업은 되돌릴 수 없습니다.") }
        .fullScreenCover(isPresented: $showDatePicker) {
            CustomDatePicker(selectedDate: $dueDate)
        }
        .onAppear { loadTodo() }
    }

    // MARK: - Subviews

    private var titleField: some View {
        TextField("제목", text: $title, prompt: Text("제목").foregroundColor(.txt2))
            .font(.system(size: 28, weight: .black)).tracking(-1)
            .foregroundColor(.txt1)
    }

    private var memoField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("메모", systemImage: "note.text")
                .font(.system(size: 11, weight: .medium)).tracking(1.2).foregroundColor(.txt3)
            TextEditor(text: $memo)
                .font(.system(size: 14)).frame(minHeight: 100)
                .foregroundColor(.txt1)
                .scrollContentBackground(.hidden)
                .padding(12).background(Color.gray.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("마감일", systemImage: "calendar")
                    .font(.system(size: 11, weight: .medium)).tracking(1.2).foregroundColor(.txt3)
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
            Label("알림", systemImage: "bell")
                .font(.system(size: 11, weight: .medium)).tracking(1.2).foregroundColor(.txt3)
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
                .font(.system(size: 11, weight: .medium)).tracking(1.2).foregroundColor(.txt3)
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
                .font(.system(size: 11, weight: .medium)).tracking(1.2).foregroundColor(.txt3)
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
        if let d = todo.dueDate { dueDate = d; hasDueDate = true }
        priority = todo.priority
        categoryName = todo.categoryName
        reminderMinutes = todo.reminderMinutes
    }

    private func save() {
        store.update(
            id: todoId, title: title, memo: memo.isEmpty ? nil : memo,
            dueDate: hasDueDate ? dueDate : nil, priority: priority,
            categoryName: categoryName,
            categoryColor: TodoCategory.defaults.first { $0.name == categoryName }?.color,
            reminderMinutes: reminderMinutes
        )

        if let todo = findTodo() {
            if reminderMinutes != nil && hasDueDate {
                NotificationService.shared.scheduleReminder(for: todo, minutesBefore: reminderMinutes)
            } else if reminderMinutes != nil && !hasDueDate {
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
