import WidgetKit
import SwiftUI

/// 위젯 타임라인 엔트리
struct TodayEntry: TimelineEntry {
    let date: Date
    let incomplete: [Todo]
    let completed: [Todo]
    let incompleteCount: Int
    let periodTodos: [Todo]
}

/// 오늘 할 일 위젯 타임라인 프로바이더
struct TodayWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(
            date: .now,
            incomplete: [
                Todo(title: "할 일 예시", priority: .high),
                Todo(title: "장보기", priority: .medium),
                Todo(title: "책 읽기", priority: .low),
            ],
            completed: [],
            incompleteCount: 3,
            periodTodos: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let entry = makeEntry()
        // 자정에 갱신 (오늘 기준 데이터가 바뀌므로)
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        )
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func makeEntry() -> TodayEntry {
        let incomplete = SharedDefaults.loadIncomplete()
        let completed = SharedDefaults.loadCompleted()

        let todayIncomplete = TodoFilterLogic.todayIncompleteRegular(from: incomplete)
            .sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        let todayCompleted = TodoFilterLogic.todayCompletedTodos(from: completed)
        let periodTodos = TodoFilterLogic.todayActivePeriodTodos(from: incomplete)
        let count = TodoFilterLogic.todayIncompleteCount(from: incomplete)

        return TodayEntry(
            date: .now,
            incomplete: todayIncomplete,
            completed: todayCompleted,
            incompleteCount: count,
            periodTodos: periodTodos
        )
    }
}
