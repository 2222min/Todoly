# 기술 설계: 캘린더 뷰 & 디자인 개선

## 개요

Todoly 앱에 캘린더 기반 할 일 조회 기능을 추가하고, 기존 디자인 시스템을 개선한다. 이 설계는 기존 아키텍처(SwiftUI + `@ObservableObject` 패턴의 `TodoStore`, `Utilities.swift` 디자인 토큰)와 완전히 일관되게 구현한다.

주요 변경 사항:
- `CalendarView.swift` 신규 화면 추가
- `MainTabView.swift`에 Calendar 탭 추가 (두 번째 위치)
- `TodoStore.swift`에 날짜 기반 필터링 computed property 추가
- `Utilities.swift` 디자인 토큰은 이미 요구사항에 부합하므로 최소 변경

## 아키텍처

### 기존 아키텍처와의 관계

```mermaid
graph TD
    A[TodolyApp] --> B[RootView]
    B --> C[MainTabView]
    C --> D[MainListView - Tasks 탭]
    C --> E[CalendarView - Calendar 탭 ✨신규]
    C --> F[CategoryListView - Categories 탭]
    C --> G[TrashView - Trash 탭]
    E --> H[CalendarHeaderView - 연월 + 월 이동]
    E --> I[CalendarGridView - 월간 그리드 ← 슬라이드 트랜지션]
    E --> J[DayTaskListView - 날짜별 할 일 목록 ← 슬라이드+페이드 인]
    E --> N[NoDueDateSection - 📌 날짜 미지정 접이식 섹션]
    J --> K[DayTaskRow - 개별 항목 ← TodoCheckbox + staggered 등장]
    N --> K
    K --> L[TaskDetailView - 시트]
    
    M[TodoStore] -.->|@EnvironmentObject| D
    M -.->|@EnvironmentObject| E
    M -.->|@EnvironmentObject| F
    M -.->|@EnvironmentObject| G
```

### 설계 원칙

1. 기존 `TodoStore`를 그대로 활용 — 새로운 상태 관리 객체를 만들지 않음
2. `@EnvironmentObject`를 통한 데이터 공유 패턴 유지
3. `Utilities.swift`의 기존 디자인 토큰(Color extension) 재사용
4. 기존 `CustomDatePicker.swift`의 캘린더 그리드 로직을 참고하되, CalendarView 전용으로 구현
5. 모든 전환에 `.spring(response:dampingFraction:)` 기반 유려한 애니메이션 적용

### 탭 구조 변경

```
변경 전: Tasks | Categories | Trash
변경 후: Tasks | Calendar | Categories | Trash
```

### 화면 레이아웃 구조

CalendarView는 상단 캘린더 그리드가 고정되고, 날짜를 클릭하면 하단에 해당 날짜의 할 일 목록이 나타나는 구조이다.

```
┌─────────────────────────────┐
│  CalendarHeaderView         │  ← 연월 표시 + ◀ ▶ 월 이동 버튼
│  (yyyy년 M월)               │
├─────────────────────────────┤
│  CalendarGridView           │  ← 7열 날짜 그리드 (고정 영역)
│  일 월 화 수 목 금 토        │     월 이동 시 좌/우 슬라이드 트랜지션
│  ·  ·  ·  1  2  3  4       │     날짜 선택 시 원형 배경 스케일+페이드
│  5  6  7  8  9  10 11      │
│  ...                        │
├─────────────────────────────┤
│  DayTaskListView            │  ← 날짜 선택 시 아래에서 위로 슬라이드 인
│  ┌─ DayTaskRow (delay 0) ─┐│     각 항목은 staggered animation으로
│  │ ☐ 📋 할 일 항목 1      ││     순차적으로 등장 (체크박스 탭 완료)
│  └────────────────────────┘│
│  ┌─ DayTaskRow (delay 1) ─┐│     완료 항목도 동일 DayTaskRow (투명도 0.55)
│  │ ☑ 📋 할 일 항목 2      ││     completedAt 시간 표시
│  └────────────────────────┘│
│  ...                        │
├─────────────────────────────┤
│  📌 날짜 미지정 [접기/펼치기]│  ← dueDate nil 미완료 할일 (항상 표시)
│  ┌─ DayTaskRow ───────────┐│
│  │ ☐ 📋 날짜 없는 할 일   ││
│  └────────────────────────┘│
└─────────────────────────────┘
```

### 애니메이션 시스템 설계

모든 애니메이션은 `.spring(response:dampingFraction:)` 커브를 사용하여 자연스럽고 유려한 전환을 구현한다.

| 전환 유형 | 애니메이션 방식 | 파라미터 |
|----------|---------------|---------|
| 월 이동 (이전/다음) | 캘린더 그리드 좌/우 슬라이드 `.transition(.move(edge:))` | `.spring(response: 0.4, dampingFraction: 0.8)` |
| 날짜 선택 | 선택 원형 배경 스케일+페이드 `.scaleEffect` + `.opacity` | `.spring(response: 0.35, dampingFraction: 0.7)` |
| 할 일 목록 표시/숨김 | 아래→위 슬라이드+페이드 `.transition(.move(edge: .bottom).combined(with: .opacity))` | `.spring(response: 0.45, dampingFraction: 0.8)` |
| 할 일 항목 개별 등장 | staggered animation (순차적 딜레이) | `.spring(response: 0.4, dampingFraction: 0.75)`, delay: `index * 0.06` |
| 탭 전환 | 기존 스프링 애니메이션 유지 | `.spring(response: 0.35, dampingFraction: 0.7)` |

#### 월 이동 슬라이드 트랜지션 구현 방식

월 이동 방향을 추적하는 `@State private var monthTransitionDirection: Edge = .trailing`을 사용하여, 다음 달 이동 시 `.trailing`(우→좌), 이전 달 이동 시 `.leading`(좌→우)으로 슬라이드한다. `displayMonth`를 `id`로 사용하여 SwiftUI가 뷰 교체를 인식하도록 한다.

```swift
// 월 이동 트랜지션 핵심 구조
@State private var monthTransitionDirection: Edge = .trailing

// 캘린더 그리드 영역
CalendarGridView(displayMonth: displayMonth, ...)
    .id(displayMonth)
    .transition(.asymmetric(
        insertion: .move(edge: monthTransitionDirection),
        removal: .move(edge: monthTransitionDirection == .trailing ? .leading : .trailing)
    ))

// 월 이동 함수
private func changeMonth(_ delta: Int) {
    monthTransitionDirection = delta > 0 ? .trailing : .leading
    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        displayMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayMonth) ?? displayMonth
    }
}
```

#### 날짜 선택 애니메이션 구현 방식

선택된 날짜의 원형 배경이 스케일(0→1) + 페이드(0→1)로 나타나는 애니메이션을 적용한다.

```swift
// 날짜 셀 내부
Circle()
    .fill(LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                          startPoint: .topLeading, endPoint: .bottomTrailing))
    .scaleEffect(isSelected ? 1.0 : 0.0)
    .opacity(isSelected ? 1.0 : 0.0)
    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedDate)
```

#### 할 일 목록 슬라이드 인/아웃 구현 방식

날짜 선택 시 하단 할 일 목록이 아래에서 위로 슬라이드하며 페이드 인으로 나타난다.

```swift
// DayTaskListView 트랜지션
if let selectedDate = selectedDate {
    DayTaskListView(date: selectedDate, todos: store.incompleteTodos(for: selectedDate))
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: selectedDate)
}
```

#### Staggered Animation (순차적 등장) 구현 방식

할 일 목록의 각 항목이 순차적으로 등장하여 리듬감 있는 UI를 제공한다.

```swift
// DayTaskListView 내부
ForEach(Array(todos.enumerated()), id: \.element.id) { index, todo in
    DayTaskRow(todo: todo)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(
            .spring(response: 0.4, dampingFraction: 0.75)
            .delay(Double(index) * 0.06),
            value: selectedDate
        )
}
```

## 컴포넌트 및 인터페이스

### 1. Tab enum 확장 (MainTabView.swift)

```swift
enum Tab: String, CaseIterable {
    case tasks = "할 일"
    case calendar = "캘린더"      // ✨ 신규
    case categories = "카테고리"
    case trash = "휴지통"
    
    var icon: String {
        switch self {
        case .tasks: "list.bullet"
        case .calendar: "calendar"   // ✨ 신규
        case .categories: "square.grid.2x2"
        case .trash: "trash"
        }
    }
}
```

### 2. CalendarView (신규 파일: CalendarView.swift)

CalendarView는 상단에 캘린더 그리드가 고정되고, 날짜를 클릭하면 하단에 해당 날짜의 할 일 목록이 슬라이드/페이드 인으로 나타나는 구조이다.

```swift
struct CalendarView: View {
    @EnvironmentObject var store: TodoStore
    @State private var displayMonth: Date = Date()
    @State private var selectedDate: Date? = nil     // nil이면 할 일 목록 숨김
    @State private var showDetail: String? = nil
    @State private var monthTransitionDirection: Edge = .trailing  // 월 이동 방향 추적
    @State private var isNoDueDateExpanded: Bool = true  // 날짜 미지정 섹션 접기/펼치기 (기본 펼침)
    
    var body: some View {
        VStack(spacing: 0) {
            // ── 상단 고정 영역: 캘린더 ──
            VStack(spacing: 16) {
                CalendarHeaderView(
                    displayMonth: displayMonth,
                    onPrevious: { changeMonth(-1) },
                    onNext: { changeMonth(1) }
                )
                
                CalendarGridView(
                    displayMonth: displayMonth,
                    selectedDate: $selectedDate,
                    store: store
                )
                .id(displayMonth)
                .transition(.asymmetric(
                    insertion: .move(edge: monthTransitionDirection),
                    removal: .move(edge: monthTransitionDirection == .trailing ? .leading : .trailing)
                ))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // ── 하단 영역: 날짜 선택 시 할 일 목록 슬라이드 인 ──
            if let date = selectedDate {
                DayTaskListView(
                    date: date,
                    incompleteTodos: store.incompleteTodos(for: date),
                    completedTodos: store.completedTodos(for: date),
                    onToggleComplete: { todo in store.toggleComplete(todo) }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // ── 📌 날짜 미지정 섹션 (항상 표시) ──
            NoDueDateSection(
                todos: store.noDueDateIncompleteTodos,
                isExpanded: $isNoDueDateExpanded,
                onToggleComplete: { todo in store.toggleComplete(todo) }
            )
            
            Spacer()
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: selectedDate)
        .onAppear { selectedDate = Date() }
    }
}
```

#### 하위 컴포넌트 구조

| 컴포넌트 | 역할 | 애니메이션 | 파일 |
|---------|------|----------|------|
| CalendarHeaderView | 연월 표시 + 이전/다음 월 버튼 | — | `CalendarHeaderView.swift` |
| CalendarGridView | 7열 날짜 그리드 + Dot Indicator | 월 이동 시 좌/우 슬라이드 `.transition(.move(edge:))` | `CalendarGridView.swift` |
| DayTaskRow | 개별 할 일 항목 (체크박스 탭 완료/미완료 토글) | staggered animation (순차적 딜레이 `index * 0.06`) | `DayTaskRow.swift` |
| NoDueDateTaskRow | 날짜 미지정 할일 카드 | — | `NoDueDateTaskRow.swift` |
| CalendarDateLogic | 날짜 계산 순수 함수 (daysInMonth, makeDate 등) | — | `CalendarConstants.swift` |
| CalendarAnimationConstants | 애니메이션 파라미터 상수 | — | `CalendarConstants.swift` |

각 하위 컴포넌트는 SRP 원칙에 따라 별도 파일로 분리되어 있다. 기존 설계에서는 단일 파일 내 private view로 계획했으나, 리팩토링 과정에서 파일별 분리로 변경되었다.

> **변경 (2026-04-26):** 완료 항목도 미완료와 동일한 DayTaskRow 카드 UI를 사용한다 (별도 CompletedDayTaskRow 스타일 제거). 체크박스 on/off + 색상 처리 + 투명도 0.55로 구분한다. 스와이프 완료를 제거하고 체크박스 탭만 사용한다.

#### 날짜 셀 선택 애니메이션

날짜 셀을 탭하면 선택 원형 배경이 스케일(0→1) + 페이드(0→1)로 부드럽게 나타난다.

```swift
// CalendarGridView 내부 날짜 셀
ZStack {
    // 선택 배경 — 스케일+페이드 애니메이션
    Circle()
        .fill(LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                              startPoint: .topLeading, endPoint: .bottomTrailing))
        .scaleEffect(isSelected ? 1.0 : 0.0)
        .opacity(isSelected ? 1.0 : 0.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedDate)
    
    // 오늘 배경
    if isToday && !isSelected {
        Circle().fill(Color.accent1.opacity(0.1))
    }
    
    Text("\(day)")
        .font(.system(size: 15, weight: isSelected ? .bold : .medium, design: .rounded))
        .foregroundColor(isSelected ? .white : (isToday ? .accent1 : .txt1))
}
.frame(width: 40, height: 40)
```

#### DayTaskListView Staggered Animation

할 일 목록의 각 항목이 순차적으로 등장하여 리듬감 있는 UI를 제공한다.

```swift
private struct DayTaskListView: View {
    let date: Date
    let incompleteTodos: [Todo]
    let completedTodos: [Todo]
    let onToggleComplete: (Todo) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if incompleteTodos.isEmpty && completedTodos.isEmpty {
                emptyStateView
            } else {
                // 미완료 항목
                ForEach(Array(incompleteTodos.enumerated()), id: \.element.id) { index, todo in
                    DayTaskRow(todo: todo, onToggleComplete: { onToggleComplete(todo) })
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.75)
                            .delay(Double(index) * 0.06),
                            value: date
                        )
                }
                // 완료 항목 (동일 DayTaskRow, 투명도 0.55)
                ForEach(Array(completedTodos.enumerated()), id: \.element.id) { index, todo in
                    DayTaskRow(todo: todo, onToggleComplete: { onToggleComplete(todo) })
                        .opacity(0.55)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}
```

#### DayTaskRow 체크박스 통일 (변경: 2026-04-26)

DayTaskRow는 TodoCheckbox 공통 컴포넌트를 사용하여 할일 탭과 캘린더 모두 동일한 체크박스 UI를 제공한다.

```swift
private struct DayTaskRow: View {
    let todo: Todo
    let onToggleComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TodoCheckbox(isCompleted: todo.isCompleted, onToggle: onToggleComplete)
            // 우선순위 컬러바 + 제목 + 카테고리 + 시간
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                HStack {
                    if let category = todo.categoryName { Text(category) }
                    if todo.isCompleted, let completedAt = todo.completedAt {
                        Text(completedAt.formatted("a h:mm") + " 완료")  // "오전 8:00 완료"
                    }
                }
            }
        }
    }
}
```

#### NoDueDateSection — 날짜 미지정 섹션 (변경: 2026-04-26)

캘린더 하단에 항상 표시되는 접이식 섹션. dueDate가 nil인 미완료 할일을 표시한다.

```swift
private struct NoDueDateSection: View {
    let todos: [Todo]
    @Binding var isExpanded: Bool
    let onToggleComplete: (Todo) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // 헤더: "📌 날짜 미지정" + 접기/펼치기
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("📌 날짜 미지정")
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            
            if isExpanded {
                ForEach(todos) { todo in
                    DayTaskRow(todo: todo, onToggleComplete: { onToggleComplete(todo) })
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
```

### 3. TodoStore 확장 (TodoStore.swift)

```swift
extension TodoStore {
    /// dueDate가 있는 모든 활성 할 일 (incomplete + completed, isDeleted 제외)
    var todosWithDueDate: [Todo] {
        (incomplete + completed).filter { $0.dueDate != nil && !$0.isDeleted }
    }
    
    /// 특정 날짜의 할 일 필터링
    func todos(for date: Date) -> [Todo] {
        todosWithDueDate.filter {
            Calendar.current.isDate($0.dueDate!, inSameDayAs: date)
        }
    }
    
    /// 특정 날짜의 미완료 할 일
    func incompleteTodos(for date: Date) -> [Todo] {
        incomplete.filter {
            guard let due = $0.dueDate else { return false }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }
    }
    
    /// 특정 날짜의 완료 할 일 (dueDate 기준 + completedAt 기준 통합)
    func completedTodos(for date: Date) -> [Todo] {
        completed.filter { todo in
            guard !todo.isDeleted else { return false }
            // dueDate 있는 완료 할일: dueDate 기준
            if let due = todo.dueDate {
                return Calendar.current.isDate(due, inSameDayAs: date)
            }
            // dueDate 없는 완료 할일: completedAt 기준
            if let completedAt = todo.completedAt {
                return Calendar.current.isDate(completedAt, inSameDayAs: date)
            }
            return false
        }
    }
    
    /// dueDate가 nil인 미완료 할 일 (날짜 미지정 섹션용)
    var noDueDateIncompleteTodos: [Todo] {
        incomplete.filter { $0.dueDate == nil && !$0.isDeleted }
    }
}
```

### 4. Dot Indicator 로직

날짜 셀 하단에 해당 날짜의 할 일 우선순위를 반영한 점(dot)을 최대 3개 표시한다.

```swift
func dotColors(for date: Date) -> [Color] {
    let dayTodos = store.todos(for: date)
    if dayTodos.allSatisfy({ $0.isCompleted }) && !dayTodos.isEmpty {
        return [.txt3]  // 완료된 할 일만 → 회색
    }
    let priorities = dayTodos
        .filter { !$0.isCompleted }
        .map { $0.priority }
        .uniqued()       // 중복 제거
        .sorted { $0.sortOrder < $1.sortOrder }
        .prefix(3)
    return priorities.map { Color(hex: $0.color) }
}
```

### 5. 접근성 (Accessibility)

| 요소 | 접근성 라벨 | 형식 |
|------|-----------|------|
| 날짜 셀 | `"\(month)월 \(day)일, 할 일 \(count)개"` | `.accessibilityLabel` |
| 이전 달 버튼 | `"이전 달"` | `.accessibilityLabel` |
| 다음 달 버튼 | `"다음 달"` | `.accessibilityLabel` |
| 할 일 항목 | `"\(title), 우선순위 \(priority)"` | `.accessibilityLabel` |

## 데이터 모델

### 기존 모델 변경 없음

`Todo` 구조체는 이미 `dueDate: Date?` 필드를 가지고 있으므로 모델 변경이 필요 없다.

```swift
struct Todo: Identifiable {
    var id = UUID().uuidString
    var title: String
    var memo: String?
    var dueDate: Date?          // ← 캘린더 뷰에서 이 필드 활용
    var priority: Priority = .none
    var categoryName: String?
    var categoryColor: String?
    var isCompleted = false
    var completedAt: Date?
    var isDeleted = false
    var deletedAt: Date?
    var createdAt = Date()
    var reminderMinutes: Int? = nil
}
```

### 캘린더 뷰 전용 헬퍼

`Priority`에 정렬 순서를 추가한다:

```swift
extension Priority {
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        case .none: return 3
        }
    }
}
```

### 날짜 유틸리티

`CalendarView` 내부에서 사용하는 캘린더 계산 로직. 기존 `CustomDatePicker.swift`의 `daysInMonth()`, `makeDate(day:)` 패턴을 재사용한다.

```swift
private func daysInMonth() -> [Int] {
    let cal = Calendar.current
    let range = cal.range(of: .day, in: .month, for: displayMonth)!
    let firstWeekday = cal.component(.weekday, 
        from: cal.date(from: cal.dateComponents([.year, .month], from: displayMonth))!) - 1
    return Array(repeating: 0, count: firstWeekday) + Array(range)
}
```

### 애니메이션 상수 정의

모든 애니메이션 파라미터를 한 곳에서 관리하여 일관성을 유지한다. `CalendarView.swift` 내부에 private enum으로 정의한다.

```swift
private enum AnimationConstants {
    // 월 이동 슬라이드
    static let monthSlide: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    
    // 날짜 선택 스케일+페이드
    static let dateSelection: Animation = .spring(response: 0.35, dampingFraction: 0.7)
    
    // 할 일 목록 슬라이드 인/아웃
    static let taskListAppear: Animation = .spring(response: 0.45, dampingFraction: 0.8)
    
    // 할 일 항목 개별 등장 (staggered)
    static let taskRowAppear: Animation = .spring(response: 0.4, dampingFraction: 0.75)
    static let taskRowStaggerDelay: Double = 0.06  // 항목 간 딜레이 (초)
    
    // 탭 전환 (기존 유지)
    static let tabSwitch: Animation = .spring(response: 0.35, dampingFraction: 0.7)
}
```


## Correctness Properties

*속성(Property)은 시스템의 모든 유효한 실행에서 참이어야 하는 특성 또는 동작이다. 속성은 사람이 읽을 수 있는 명세와 기계가 검증할 수 있는 정확성 보장 사이의 다리 역할을 한다.*

### Property 1: 월 이동 왕복 (Round-trip)

*For any* 유효한 월(displayMonth)에 대해, 다음 달로 이동한 후 이전 달로 이동하면 원래 월과 동일한 연/월 값을 가져야 한다.

**Validates: Requirements 2.3, 2.4**

### Property 2: Dot Indicator 우선순위 색상 및 최대 개수

*For any* Todo 목록과 날짜에 대해, dotColors(for:) 함수의 결과는 0~3개 범위이며, 각 색상은 해당 날짜의 미완료 할 일 우선순위 색상과 일치해야 한다.

**Validates: Requirements 2.6, 2.7**

### Property 3: 완료된 할 일만 존재 시 회색 Dot

*For any* 날짜에 대해, 해당 날짜의 모든 할 일이 완료 상태(isCompleted == true)이고 최소 1개 이상 존재하면, dotColors는 정확히 [회색] 하나만 반환해야 한다.

**Validates: Requirements 2.8**

### Property 4: 날짜별 미완료 할 일 필터링

*For any* Todo 목록과 날짜에 대해, incompleteTodos(for:) 함수가 반환하는 모든 할 일은 (1) dueDate가 해당 날짜와 같은 날이고, (2) isCompleted == false이며, (3) 해당 조건을 만족하는 모든 할 일이 빠짐없이 포함되어야 한다.

**Validates: Requirements 3.2**

### Property 5: dueDate 필터링 및 삭제 항목 제외

*For any* Todo 목록에 대해, todosWithDueDate가 반환하는 모든 할 일은 (1) dueDate != nil이고, (2) isDeleted == false이며, 원본 목록에서 이 두 조건을 만족하는 모든 항목이 빠짐없이 포함되어야 한다.

**Validates: Requirements 4.1, 4.4**

### Property 6: 완료 처리 상태 전환

*For any* 미완료 할 일(isCompleted == false)에 대해, toggleComplete 호출 후 해당 할 일은 isCompleted == true이고 completedAt이 nil이 아니어야 한다. 역으로, 완료된 할 일에 대해 toggleComplete 호출 후 isCompleted == false이고 completedAt == nil이어야 한다.

**Validates: Requirements 4.3**

### Property 7: 접근성 라벨 포맷

*For any* 유효한 날짜(month: 1~12, day: 1~31)와 할 일 개수(0 이상)에 대해, 생성되는 접근성 라벨은 "\(month)월 \(day)일, 할 일 \(count)개" 형식과 일치해야 한다.

**Validates: Requirements 8.3**

### Property 8: 날짜 미지정 섹션 필터링 (변경: 2026-04-26)

*For any* Todo 목록에 대해, noDueDateIncompleteTodos가 반환하는 모든 할 일은 (1) dueDate == nil이고, (2) isCompleted == false이며, (3) isDeleted == false이고, 원본 목록에서 이 세 조건을 만족하는 모든 항목이 빠짐없이 포함되어야 한다.

**Validates: Requirements 9.2**

### Property 9: 완료 항목 날짜 기준 표시 (변경: 2026-04-26)

*For any* 완료된 할 일(isCompleted == true)에 대해, dueDate가 있으면 dueDate 기준으로 캘린더에 표시되고, dueDate가 nil이면 completedAt 기준으로 표시되어야 한다. completedTodos(for:) 함수는 이 두 조건을 모두 올바르게 처리해야 한다.

**Validates: Requirements 4.5, 4.6**

### Property 10: 체크박스 토글 일관성 (변경: 2026-04-26)

*For any* 할 일에 대해, 캘린더 DayTaskRow의 체크박스 탭과 할일 탭의 체크박스 탭은 동일한 TodoStore.toggleComplete() 함수를 호출하여 동일한 상태 변경 결과를 보장해야 한다.

**Validates: Requirements 10.1, 10.2**

## 에러 처리

### 캘린더 데이터 관련

| 상황 | 처리 방식 |
|------|----------|
| dueDate가 nil인 할 일 | "📌 날짜 미지정" 접이식 섹션에 미완료 항목 표시 (변경: 2026-04-26) |
| isDeleted가 true인 할 일 | 캘린더에 표시하지 않음 (todosWithDueDate 필터에서 제외) |
| 선택 날짜에 할 일 없음 | "이 날은 할 일이 없어요 🎉" 빈 상태 메시지 표시 |
| 전체 데이터에 dueDate 할 일 없음 | "마감일을 설정하면 캘린더에서 확인할 수 있어요 📅" 안내 메시지 표시 |
| 캘린더 날짜 계산 오류 | Calendar.current API 사용으로 시스템 캘린더에 위임 |

### 월 이동 관련

| 상황 | 처리 방식 |
|------|----------|
| 월 이동 시 날짜 범위 초과 | Calendar.date(byAdding:) nil 반환 시 현재 월 유지 |
| 선택 날짜가 표시 월과 다른 경우 | 월 이동 시 선택 날짜는 유지하되, 해당 월의 할 일 목록만 갱신 |

### 애니메이션 관련

| 상황 | 처리 방식 |
|------|----------|
| 빠른 연속 월 이동 탭 | `withAnimation` 블록 내에서 상태 변경하여 SwiftUI가 자동으로 애니메이션 병합 처리 |
| 월 이동 중 날짜 선택 | 각 애니메이션이 독립적인 `value`를 추적하므로 충돌 없이 동시 실행 |
| 할 일 목록 표시 중 다른 날짜 선택 | `selectedDate` 변경 시 기존 목록 페이드 아웃 → 새 목록 슬라이드 인 자동 전환 |
| 접근성 모드(Reduce Motion) | `@Environment(\.accessibilityReduceMotion)` 감지하여 애니메이션 비활성화 또는 간소화 |

## 테스팅 전략

### 이중 테스트 접근법

이 기능은 순수 데이터 필터링 로직과 UI 렌더링이 혼합되어 있으므로, property-based testing과 example-based testing을 병행한다.

### Property-Based Testing

라이브러리: **SwiftCheck** (Swift용 QuickCheck 구현체)

각 property 테스트는 최소 100회 반복 실행한다.

| Property | 테스트 대상 함수 | 생성기 |
|----------|---------------|--------|
| Property 1 | changeMonth(+1), changeMonth(-1) | 임의의 Date (2000~2100년 범위) |
| Property 2 | dotColors(for:) | 임의의 [Todo] (0~10개, 다양한 priority/dueDate) + 임의의 Date |
| Property 3 | dotColors(for:) | 임의의 [Todo] (모두 isCompleted=true, dueDate=특정날짜) |
| Property 4 | incompleteTodos(for:) | 임의의 [Todo] (완료/미완료 혼합, dueDate 있는/없는 혼합) + 임의의 Date |
| Property 5 | todosWithDueDate | 임의의 [Todo] (dueDate nil/non-nil, isDeleted true/false 혼합) |
| Property 6 | toggleComplete() | 임의의 Todo (isCompleted true/false) |
| Property 7 | accessibilityLabel 생성 함수 | 임의의 month(1~12), day(1~31), count(0~100) |

태그 형식: `Feature: calendar-view-design, Property {number}: {property_text}`

### Example-Based Unit Testing

| 테스트 | 검증 내용 |
|--------|----------|
| Tab enum 순서 | Tab.allCases == [.tasks, .calendar, .categories, .trash] |
| Tab.calendar 속성 | icon == "calendar", rawValue == "Calendar" |
| 기본 선택 탭 | 초기 tab == .tasks |
| 빈 상태 메시지 (날짜) | 할 일 없는 날짜 선택 시 빈 상태 메시지 표시 |
| 빈 상태 메시지 (전체) | dueDate 할 일 0개 시 안내 메시지 표시 |
| 디자인 토큰 값 | Color.brandBg hex == "FFF8F2" 등 |
| 접근성 라벨 (정적) | 이전 달/다음 달 버튼 라벨 확인 |

### 테스트 범위 제외

- UI 레이아웃/스타일링 (시각적 검증 필요 → 수동 QA)
- SwiftUI 프레임워크 반응성 (@Published 동작)
- 스프링 애니메이션 파라미터 값 자체 (시각적 검증 필요)
- 트랜지션 시각적 결과 (`.transition(.move(edge:))` 등의 렌더링 결과)
- staggered animation 타이밍 정확도 (프레임 단위 검증 불가)
- Reduce Motion 접근성 모드 동작 (시뮬레이터/실기기 수동 QA)
