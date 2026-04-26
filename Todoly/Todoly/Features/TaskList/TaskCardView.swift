import SwiftUI

struct TaskCardView: View {
    let todo: Todo
    @EnvironmentObject var store: TodoStore
    @State private var showDetail = false

    var body: some View {
        HStack(spacing: 12) {
            priorityBar
            checkboxButton
            contentSection
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
        )
        .fullScreenCover(isPresented: $showDetail) {
            NavigationStack { TaskDetailView(todoId: todo.id) }
        }
    }

    private var priorityBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(LinearGradient(
                colors: [Color(hex: todo.priority.color), Color(hex: todo.priority.color).opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            ))
            .frame(width: 4, height: 48)
    }

    private var checkboxButton: some View {
        TodoCheckbox(isCompleted: false) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                store.toggleComplete(todo)
            }
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(todo.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.txt1).lineLimit(1)
            HStack(spacing: 6) {
                if let cat = todo.categoryName {
                    Text(cat).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.txt3)
                }
                if todo.categoryName != nil && todo.dueDate != nil {
                    Text("·").font(.system(size: 11)).foregroundColor(.txt3)
                }
                if let (text, style) = todo.dueDate?.badge {
                    BadgeView(text: text, style: style)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { showDetail = true }
    }
}

// MARK: - BadgeView (SRP: 배지 렌더링만 담당)

struct BadgeView: View {
    let text: String
    let style: BadgeStyle

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    /// 순수 함수: 스타일 → 전경색
    var foregroundColor: Color {
        switch style {
        case .overdue: Color(hex: "D32F2F")
        case .today: Color(hex: "E65100")
        case .tomorrow: Color(hex: "F57F17")
        case .upcoming: .txt2
        }
    }

    /// 순수 함수: 스타일 → 배경색
    var backgroundColor: Color {
        switch style {
        case .overdue: Color(hex: "FFE0E0")
        case .today: Color(hex: "FFF0E0")
        case .tomorrow: Color(hex: "FFFCE0")
        case .upcoming: Color(hex: "F0F0F0")
        }
    }
}

// MARK: - Preview

#Preview("TaskCardView") {
    VStack(spacing: 12) {
        TaskCardView(todo: Todo(
            title: "프로젝트 보고서",
            dueDate: Calendar.current.date(byAdding: .day, value: -1, to: .now),
            priority: .high, categoryName: "업무", categoryColor: "4DC87B"
        ))
        TaskCardView(todo: Todo(
            title: "장보기",
            dueDate: .now,
            priority: .medium, categoryName: "쇼핑", categoryColor: "FFC847"
        ))
        TaskCardView(todo: Todo(
            title: "책 읽기",
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: .now),
            priority: .low, categoryName: "개인"
        ))
    }
    .padding()
    .background(Color.brandBg)
    .environmentObject(TodoStore())
}
