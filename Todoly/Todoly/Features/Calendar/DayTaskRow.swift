import SwiftUI

struct DayTaskRow: View {
    let todo: Todo
    let index: Int
    let date: Date
    let onEdit: () -> Void
    let onComplete: () -> Void

    var body: some View {
        cardContent
            .accessibilityLabel("\(todo.title), 우선순위 \(todo.priority.label)")
    }

    private var cardContent: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: todo.priority.color)).frame(width: 3, height: 48)

            TodoCheckbox(isCompleted: false) { onComplete() }

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.txt1).lineLimit(1)
                if !metaText.isEmpty {
                    Text(metaText)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.txt3).lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            // 수정 버튼
            Button { onEdit() } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.txt3)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 16)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture { onComplete() }
    }

    /// 순수 함수: 메타 텍스트 생성
    var metaText: String {
        var parts: [String] = []
        if let cat = todo.categoryName { parts.append(cat) }
        if let due = todo.dueDate {
            let df = DateFormatter()
            df.locale = Locale(identifier: "ko_KR")
            df.dateFormat = "a h:mm"
            parts.append(df.string(from: due))
        }
        return parts.joined(separator: " · ")
    }
}

// MARK: - CompletedDayTaskRow

struct CompletedDayTaskRow: View {
    let todo: Todo
    let onToggle: () -> Void
    var onEdit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: todo.priority.color).opacity(0.4))
                .frame(width: 3, height: 48)

            TodoCheckbox(isCompleted: true) { onToggle() }

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.txt3)
                    .strikethrough(true, color: .txt3)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    if !metaText.isEmpty {
                        Text(metaText)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.txt3).lineLimit(1)
                    }
                    if let completedAt = todo.completedAt {
                        Text("· \(completedTimeString(completedAt))")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.txt3.opacity(0.7))
                    }
                }
            }

            Spacer(minLength: 0)

            if let onEdit {
                Button { onEdit() } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.txt3)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16).frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 16)
        .opacity(0.55)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture { onToggle() }
        .accessibilityLabel("\(todo.title), 완료됨")
    }

    private var metaText: String {
        var parts: [String] = []
        if let cat = todo.categoryName { parts.append(cat) }
        if let due = todo.dueDate {
            let df = DateFormatter()
            df.locale = Locale(identifier: "ko_KR")
            df.dateFormat = "a h:mm"
            parts.append(df.string(from: due))
        }
        return parts.joined(separator: " · ")
    }

    private func completedTimeString(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "a h:mm 완료"
        return df.string(from: date)
    }
}

// MARK: - Preview

#Preview("DayTaskRow") {
    VStack(spacing: 12) {
        DayTaskRow(
            todo: Todo(title: "프로젝트 보고서", dueDate: .now, priority: .high, categoryName: "업무"),
            index: 0, date: Date(), onEdit: {}, onComplete: {}
        )
        CompletedDayTaskRow(
            todo: Todo(title: "아침 운동", categoryName: "개인", isCompleted: true),
            onToggle: {}
        ).padding(.horizontal, 16)
    }
    .padding()
    .background(Color.brandBg)
}
