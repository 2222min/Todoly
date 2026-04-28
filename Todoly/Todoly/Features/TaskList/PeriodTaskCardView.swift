import SwiftUI

/// 연속 할일 카드 — 날짜별 완료 토글, 프로그레스 바 표시
struct PeriodTaskCardView: View {
    let todo: Todo
    @EnvironmentObject var store: TodoStore
    @State private var showDetail = false

    private var isCompletedToday: Bool { todo.isCompletedOn(.now) }

    var body: some View {
        HStack(spacing: 12) {
            priorityBar
            repeatIcon
            checkboxButton
            contentSection
            Spacer(minLength: 0)
            editButton
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
        )
        .opacity(isCompletedToday ? 0.55 : 1.0)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture { toggleDaily() }
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

    private var repeatIcon: some View {
        Image(systemName: "arrow.trianglehead.2.clockwise")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.accent1)
    }

    private var checkboxButton: some View {
        TodoCheckbox(isCompleted: isCompletedToday) { toggleDaily() }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(todo.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.txt1).lineLimit(1)
                .strikethrough(isCompletedToday)

            HStack(spacing: 6) {
                if let cat = todo.categoryName {
                    Text(cat).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.txt3)
                    Text("·").font(.system(size: 11)).foregroundColor(.txt3)
                }
                if let (text, style) = DateBadgeLogic.periodBadge(for: todo) {
                    BadgeView(text: text, style: style)
                }
            }

            // 미니 프로그레스 바
            let progress = DateBadgeLogic.periodProgress(for: todo)
            if progress.total > 0 {
                HStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.accent1)
                                .frame(width: geo.size.width * CGFloat(progress.completed) / CGFloat(progress.total), height: 4)
                        }
                    }
                    .frame(height: 4)

                    Text("\(progress.completed)/\(progress.total)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.txt3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 수정 버튼
    private var editButton: some View {
        Button { showDetail = true } label: {
            Image(systemName: "pencil")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.txt3)
                .frame(width: 36, height: 36)
                .background(Color.gray.opacity(0.08))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func toggleDaily() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            store.toggleDailyCompletion(todo)
        }
    }
}

// MARK: - Preview

#Preview("PeriodTaskCardView") {
    let cal = Calendar.current
    PeriodTaskCardView(todo: Todo(
        title: "매일 운동하기",
        priority: .medium, categoryName: "개인", categoryColor: "5A8AF2",
        startDate: cal.date(byAdding: .day, value: -2, to: .now),
        endDate: cal.date(byAdding: .day, value: 3, to: .now)
    ))
    .padding()
    .background(Color.brandBg)
    .environmentObject(TodoStore())
}
