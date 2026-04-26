---
inclusion: auto
---

# 🛡️ Todoly 코드 품질 필수 규칙

이 steering은 코드를 생성하거나 수정할 때 항상 자동으로 적용됩니다.

---

## 프로젝트 구조 (필수)

```
Todoly/Todoly/
├── App/              # @main, AppDelegate, AppState, RootView
├── Core/
│   ├── Components/   # 공통 UI 컴포넌트 (SoftPressStyle, UndoToast 등)
│   └── Extensions/   # Color+Brand, Date+Badge 등
├── Data/
│   ├── Store/        # TodoStore (ObservableObject, 부수 효과 담당)
│   └── Services/     # NotificationService 등 외부 서비스
├── Domain/
│   ├── Models/       # Todo, TodoCategory, Priority, BadgeStyle, TodoAlarmAttributes
│   ├── Logic/        # 순수 함수 비즈니스 로직 (TodoMutationLogic, TodoFilterLogic 등)
│   └── Protocols/    # TodoStoring, NotificationScheduling 등 추상화
└── Features/
    ├── Alarm/        # AlarmView (풀스크린 알람)
    ├── Auth/         # LoginView
    ├── Calendar/     # CalendarView, CalendarGridView, DayTaskRow 등
    ├── Category/     # CategoryListView, CategoryAddSheet, CategoryRow 등
    ├── Search/       # SearchView
    ├── Splash/       # SplashView
    ├── Tab/          # MainTabView, BottomNavBar, Tab enum
    ├── TaskDetail/   # TaskDetailView, AddTaskSheet
    ├── TaskList/     # MainListView, TaskCardView, CompletedRow
    └── Trash/        # TrashView, TrashItemRow
```

## 1. 순수 함수 (Pure Functions) — 필수

- 비즈니스 로직은 반드시 `Domain/Logic/` 폴더의 순수 함수로 작성
- 같은 입력 → 항상 같은 출력. 외부 상태 변경 금지
- Store/ViewModel은 순수 로직을 호출하고 결과를 적용하는 역할만 수행
- 부수 효과(알림, 네트워크, DB)는 순수 로직과 반드시 분리

```swift
// ✅ Domain/Logic/TodoFilterLogic.swift
static func incompleteTodos(for date: Date, from incomplete: [Todo]) -> [Todo] {
    incomplete.filter { guard let due = $0.dueDate else { return false }; return Calendar.current.isDate(due, inSameDayAs: date) }
}

// ❌ Store에서 직접 필터링 로직 구현
func incompleteTodos(for date: Date) -> [Todo] {
    self.incomplete.filter { ... }  // 외부 상태 직접 참조
}
```

## 2. 단일 책임 원칙 (SRP) — 필수

- 하나의 파일 = 하나의 역할. 300줄 초과 시 분리 검토
- 하나의 함수 = 하나의 일. "and"가 들어가는 함수명은 분리 대상
- View는 렌더링만, Logic은 계산만, Store는 상태 관리만
- 큰 View는 private subview로 분리 (computed property 활용)

```swift
// ✅ 분리된 책임
struct TaskCardView: View { ... }     // 카드 렌더링만
struct BadgeView: View { ... }        // 배지 렌더링만
struct CategoryRow: View { ... }      // 카테고리 행 렌더링만
struct TrashItemRow: View { ... }     // 휴지통 아이템 렌더링만

// ❌ 하나의 View에 모든 것
struct MainView: View { /* 500줄짜리 모든 것 포함 */ }
```

## 3. Protocol 기반 추상화 (DI) — 필수

- 서비스는 반드시 Protocol을 정의하고 구체 구현을 주입
- Store/ViewModel은 구체 타입이 아닌 Protocol에 의존
- 새 서비스 추가 시: Protocol 정의 → 구현 → 주입

```swift
// ✅ Protocol 기반
protocol NotificationScheduling { func scheduleReminder(for todo: Todo, minutesBefore: Int?) }
final class TodoStore: ObservableObject {
    private let notificationService: NotificationScheduling
    init(notificationService: NotificationScheduling = NotificationService.shared) { ... }
}

// ❌ 구체 타입 직접 의존
final class TodoStore: ObservableObject {
    func softDelete(_ todo: Todo) { NotificationService.shared.cancelReminder(todoId: todo.id) }
}
```

## 4. Preview 필수 구현

- 모든 View 파일에 `#Preview` 매크로를 반드시 포함
- Preview에서 필요한 EnvironmentObject는 더미 데이터로 주입
- 여러 상태를 보여주는 Preview가 있으면 더 좋음

```swift
#Preview("TaskCardView") {
    TaskCardView(todo: Todo(title: "테스트", priority: .high))
        .environmentObject(TodoStore())
}
```

## 5. 모듈화 규칙

- 새 기능 추가 시 `Features/[FeatureName]/` 폴더에 생성
- 공통 컴포넌트는 `Core/Components/`에 배치
- 모델은 `Domain/Models/`, 로직은 `Domain/Logic/`에 배치
- 파일 간 의존성: Features → Domain, Core / Data → Domain / App → 전체

## 6. 코드 생성 시 자체 체크리스트

| # | 체크 항목 |
|---|----------|
| 1 | 비즈니스 로직이 Domain/Logic의 순수 함수로 분리되어 있는가? |
| 2 | 한 파일이 300줄을 넘지 않는가? |
| 3 | 각 함수가 하나의 일만 하는가? |
| 4 | 함수명만 보고 역할을 알 수 있는가? |
| 5 | 구체 구현이 아닌 Protocol에 의존하는가? |
| 6 | 모든 View에 #Preview가 있는가? |
| 7 | 부수 효과가 순수 로직과 분리되어 있는가? |
| 8 | 새 파일이 올바른 폴더에 위치하는가? |


---

## 7. 데이터 영속화 패턴 (UserDefaults)

### 현재 구현
- `Todo`, `Priority`, `TodoCategory` 모델은 `Codable` 준수
- `TodoStore`에서 `UserDefaults`로 JSON 인코딩/디코딩하여 영속화
- 모든 mutation 메서드(`add`, `toggleComplete`, `softDelete`, `update` 등) 끝에 `save()` 호출

### 규칙
- 새 모델 추가 시 반드시 `Codable` 준수
- Store에 새 mutation 메서드 추가 시 반드시 `save()` 호출 포함
- 테스트에서는 `TodoStore(useSeedData: true)`로 시드 데이터 사용 (UserDefaults 의존 제거)
- 첫 실행 판별: `UserDefaults.standard.bool(forKey: "todoly_hasLaunched")`

```swift
// ✅ mutation 후 반드시 save
func add(_ title: String) {
    guard TodoMutationLogic.isValidTitle(title) else { return }
    incomplete.insert(Todo(title: title, priority: .medium), at: 0)
    save()  // 필수!
}

// ✅ 테스트에서는 시드 데이터 사용
override func setUp() {
    store = TodoStore(useSeedData: true)
}
```

---

## 8. 알림 & Live Activity 구현 패턴

### 구조
- `NotificationService` — 로컬 알림 스케줄링 + Live Activity 관리
- `AlarmView` — 포그라운드 풀스크린 알람 (사운드 + 진동 반복)
- `AppDelegate` — 알림 수신 시 `onAlarmTriggered` 콜백 + Live Activity 시작
- `RootView` — `onAlarmTriggered` 콜백 연결, AlarmView 오버레이

### ActivityKit 주의사항
- `#if canImport(ActivityKit)` 가드 필수 (시뮬레이터/테스트 환경 대응)
- `TodoAlarmAttributes`는 앱 타겟 + 위젯 타겟 모두에서 공유
- Widget Extension은 `TodolyWidget/` 폴더에 별도 타겟으로 구성
- `Project.swift`에 Widget Extension 타겟 + `NSSupportsLiveActivities` Info.plist 키 필요

### 커스텀 알람 사운드
- `todoly_alarm.caf` — 30초 두 음 교대 알람음 (번들 리소스)
- `AVAudioSession.playback` 카테고리로 무음모드에서도 재생
- iOS 시스템 알림 사운드는 최대 30초 제한

### Tuist 프로젝트 재생성
- 새 소스 파일 추가 후 반드시 `tuist generate --no-open` 실행
- `.xcodeproj`에 자동 등록되지 않으므로 Tuist regenerate 필수


---

## 9. 공통 컴포넌트 패턴 — 일관성 필수

### TodoCheckbox
할일 완료/미완료 체크박스는 반드시 `Core/Components/TodoCheckbox.swift`를 사용한다.
직접 `Button { } label: { Circle().stroke(...) }` 패턴으로 체크박스를 만들지 않는다.

```swift
// ✅ 공통 컴포넌트 사용
TodoCheckbox(isCompleted: todo.isCompleted) { store.toggleComplete(todo) }

// ❌ 각 화면에서 직접 구현
Button { store.toggleComplete(todo) } label: {
    Circle().stroke(Color.txt3, lineWidth: 1.5).frame(width: 24, height: 24)
}
```

### 적용 대상
- `TaskCardView` (할일 탭 미완료)
- `CompletedRow` (할일 탭 완료)
- `DayTaskRow` (캘린더 미완료)
- `CompletedDayTaskRow` (캘린더 완료)
- `NoDueDateTaskRow` (캘린더 날짜 미지정)

### 새 화면에서 체크박스가 필요하면
반드시 `TodoCheckbox`를 import하여 사용. 히트 영역 44x44, 완료 시 녹색(#34C759) filled + 체크마크.

---

## 10. 캘린더 데이터 필터링 정책

### 표시 기준
| 상태 | 캘린더 표시 기준 |
|------|-----------------|
| 미완료 + dueDate 있음 | dueDate 날짜에 표시 |
| 미완료 + dueDate 없음 | "📌 날짜 미지정" 섹션 |
| 완료 + dueDate 있음 | dueDate 날짜의 완료됨 |
| 완료 + dueDate 없음 | completedAt 날짜의 완료됨 |
| 삭제됨 | 표시 안 함 |

### 관련 함수 (TodoFilterLogic)
- `incompleteTodos(for:)` — dueDate 기준 미완료
- `completedTodos(for:)` — dueDate 또는 completedAt 기준 완료
- `todosWithoutDueDate(from:)` — dueDate nil 미완료
- `todosWithDueDate(from:completed:)` — dueDate 있는 전체

### 새 필터 추가 시
반드시 `TodoFilterLogic`에 순수 함수로 추가하고, `TodoStore`에서 호출만 한다.

---

## 11. 마감일(dueDate) 기본값 정책

- Quick Add (`store.add()`): dueDate = **nil** (마감일 없음)
- AddTaskSheet: hasDueDate = **false** (기본 꺼짐)
- 사용자가 명시적으로 마감일을 설정해야만 dueDate가 지정됨
- dueDate nil인 할일은 캘린더 "날짜 미지정" 섹션에 표시

⚠️ 이 정책을 변경하려면 기획안(FINAL_기획안_Todoly.md)과 스펙 문서를 먼저 업데이트해야 한다.
