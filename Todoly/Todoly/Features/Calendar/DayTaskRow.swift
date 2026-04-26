import SwiftUI

struct DayTaskRow: View {
    let todo: Todo
    let index: Int
    let date: Date
    let onTap: () -> Void
    let onComplete: () -> Void

    var body: some View {
        cardContent
            .accessibilityLabel("\(todo.title), 우선순위 \(todo.priority.label)")
    }

    private var cardContent: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: todo.priority.color)).frame(width: 3, height: 48)

            // 체크박스 버튼 — 통일된 컴포넌트
            TodoCheckbox(isCompleted: false) {
                onComplete()
            }

            // 텍스트 영역 — 탭하면 상세로 이동
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
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16).frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 16)
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

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: todo.priority.color).opacity(0.4))
                .frame(width: 3, height: 48)

            // 체크박스 (완료 상태) — 통일된 컴포넌트
            TodoCheckbox(isCompleted: true) {
                onToggle()
            }

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
            Spacer()
        }
        .padding(.horizontal, 16).frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 16)
        .opacity(0.55)
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
            index: 0, date: Date(), onTap: {}, onComplete: {}
        )
        CompletedDayTaskRow(
            todo: Todo(title: "아침 운동", categoryName: "개인", isCompleted: true),
            onToggle: {}
        ).padding(.horizontal, 16)
    }
    .padding()
    .background(Color.brandBg)
}
