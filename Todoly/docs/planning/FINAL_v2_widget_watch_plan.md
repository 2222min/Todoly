# Todoly v2 — 위젯 + Apple Watch 최종 기획서

> 리뷰 반영 완료. Red 항목 모두 수정, Yellow 항목 반영.

---

## 1. 범위 (v1 Core Only)

### 포함
- iOS 홈 화면 위젯: Small / Medium / Large
- Interactive Widget: 완료 토글 (AppIntent)
- Apple Watch 앱: 오늘 할 일 리스트 + 완료 토글
- App Group 기반 데이터 공유
- 기존 데이터 자동 마이그레이션

### 제외 (v2 이후)
- Watch Complication
- 위젯 카테고리 필터 (Configurable)
- Watch에서 할 일 추가

---

## 2. 데이터 공유 아키텍처

### App Group
```
group.com.todoly.app
```

### 공유 방식: Tuist 타겟 sources 공유 (R1 반영)
기존 파일 위치를 유지하면서, 여러 타겟의 `sources`에 동일 파일을 포함.

**공유 대상 파일:**
- `Todoly/Domain/Models/Todo.swift`
- `Todoly/Domain/Models/TodoCategory.swift`
- `Todoly/Domain/Models/Priority.swift`
- `Todoly/Domain/Models/TodoAlarmAttributes.swift`
- `Todoly/Domain/Logic/TodoFilterLogic.swift`
- `Todoly/Core/Extensions/Color+Brand.swift`

### SharedDefaults (App Group UserDefaults 래퍼)
```
Todoly/Shared/SharedDefaults.swift
```
- 위치: `Todoly/Shared/` (새 폴더, 최소한의 공유 코드만)
- 역할: App Group UserDefaults 읽기/쓰기 래퍼
- 모든 타겟(App, Widget, Watch)에서 공유

### 데이터 흐름 (R2 반영)
```
iOS App (TodoStore)
  ├── save() → App Group UserDefaults (SharedDefaults)
  └── WidgetCenter.shared.reloadAllTimelines()

Widget Extension
  └── SharedDefaults에서 읽기 (read-only)
  └── AppIntent → SharedDefaults에 쓰기 → reload

Watch App (watchOS 10+)
  ├── SharedDefaults에서 직접 읽기 (App Group)
  ├── 완료 토글 → SharedDefaults에 직접 쓰기
  └── WatchConnectivity로 iPhone에 변경 알림 (보조)
```

---

## 3. iOS 위젯 상세

### 3.1 Small Widget — 오늘 요약
```
┌─────────────────┐
│  📋 오늘 할 일    │
│                 │
│     3개         │
│   남았어요       │
│                 │
│ 🔴 프로젝트 보고서 │
└─────────────────┘
```
- 오늘 미완료 카운트 (큰 숫자)
- 가장 높은 우선순위 할 일 1개
- 배경: `brandBg` (#FFF8F2)
- 탭 → 앱 메인 화면

### 3.2 Medium Widget — 오늘 할 일 리스트
```
┌──────────────────────────────────┐
│  📋 오늘 할 일              3개   │
│ ─────────────────────────────── │
│  ○ 프로젝트 보고서    🔴         │
│  ○ 장보기           🟠         │
│  ○ 책 읽기          🔵         │
└──────────────────────────────────┘
```
- 미완료 할 일 최대 3개 (우선순위 순)
- 각 행: 체크 버튼(Interactive) + 제목 + 우선순위 dot
- 체크 버튼 탭 → `ToggleTodoIntent` 실행

### 3.3 Large Widget — 오늘 할 일 + 완료
```
┌──────────────────────────────────┐
│  📋 오늘 할 일              5개   │
│ ─────────────────────────────── │
│  ○ 프로젝트 보고서    🔴         │
│  ○ 장보기           🟠         │
│  ○ 책 읽기          🔵         │
│  ○ 매일 운동하기     🟠  Day 3  │
│  ○ 영어 공부        🔵  Day 1  │
│ ─────────────────────────────── │
│  ✅ 완료 2개                     │
│  ✓ 아침 운동                     │
│  ✓ 클라이언트 이메일              │
└──────────────────────────────────┘
```
- 미완료 최대 5개 + 완료 최대 2개
- 연속 할일은 Day N 표시
- 완료 항목은 취소선 + 흐린 색상

### 3.4 AppIntent 구조 (R3 반영)
```swift
struct ToggleTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 완료"
    
    @Parameter(title: "Todo ID")
    var todoId: String
    
    func perform() async throws -> some IntentResult {
        // 1. SharedDefaults에서 데이터 로드
        // 2. TodoMutationLogic.toggleComplete() 호출
        // 3. SharedDefaults에 저장
        // 4. WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
```

---

## 4. Apple Watch 상세

### 4.1 메인 화면 — 오늘 할 일
```
┌──────────────┐
│ 📋 오늘 할 일  │
│   3개 남음    │
│──────────────│
│ ○ 프로젝트 보고서│
│   🔴 High    │
│──────────────│
│ ○ 장보기      │
│   🟠 Medium  │
│──────────────│
│ ○ 책 읽기     │
│   🔵 Low     │
└──────────────┘
```
- NavigationStack + List
- 각 행: 제목 + 우선순위 라벨 + 완료 토글 버튼
- 완료 시 WKInterfaceDevice 햅틱

### 4.2 완료 화면
```
┌──────────────┐
│ ✅ 완료       │
│   2개        │
│──────────────│
│ ✓ 아침 운동   │
│ ✓ 이메일 답장  │
└──────────────┘
```
- TabView로 메인/완료 전환

---

## 5. 프로젝트 구조 변경

### 새 파일
```
Todoly/
  Shared/
    SharedDefaults.swift          ← App Group UserDefaults 래퍼
  
  TodolyWidget/
    TodayWidget/
      TodayWidgetProvider.swift   ← TimelineProvider
      TodayWidgetEntryView.swift  ← Entry + View 분기
      TodaySmallView.swift
      TodayMediumView.swift
      TodayLargeView.swift
    Intent/
      ToggleTodoIntent.swift      ← AppIntent (완료 토글)
  
  TodolyWatch/
    TodolyWatchApp.swift          ← @main
    TodayListView.swift           ← 오늘 할 일
    CompletedListView.swift       ← 완료 목록
    WatchTodoRow.swift            ← 할 일 행
    WatchStore.swift              ← Watch용 간이 Store
```

### Project.swift 타겟 변경
```swift
// Widget 타겟 sources 확장
sources: [
    "TodolyWidget/**",
    "Todoly/Domain/Models/Todo.swift",
    "Todoly/Domain/Models/TodoCategory.swift",
    "Todoly/Domain/Models/Priority.swift",
    "Todoly/Domain/Models/TodoAlarmAttributes.swift",
    "Todoly/Domain/Logic/TodoFilterLogic.swift",
    "Todoly/Core/Extensions/Color+Brand.swift",
    "Shared/**",
]

// Watch 타겟 추가
Target(
    name: "TodolyWatch",
    platform: .watchOS,
    product: .watch2App,
    bundleId: "com.todoly.app.watch",
    deploymentTarget: .watchOS(targetVersion: "10.0"),
    sources: [
        "TodolyWatch/**",
        "Todoly/Domain/Models/Todo.swift",
        "Todoly/Domain/Models/TodoCategory.swift",
        "Todoly/Domain/Models/Priority.swift",
        "Todoly/Domain/Logic/TodoFilterLogic.swift",
        "Todoly/Core/Extensions/Color+Brand.swift",
        "Shared/**",
    ]
)
```

---

## 6. 마이그레이션 (Y4 반영)

### 앱 시작 시 자동 마이그레이션
```swift
// SharedDefaults.swift
static func migrateIfNeeded() {
    let migrated = shared.bool(forKey: "todoly_migrated_to_group")
    guard !migrated else { return }
    
    // standard → App Group 복사
    let keys = ["todoly_incomplete", "todoly_completed", "todoly_trash", "todoly_categories"]
    for key in keys {
        if let data = UserDefaults.standard.data(forKey: key) {
            shared.set(data, forKey: key)
        }
    }
    shared.set(true, forKey: "todoly_migrated_to_group")
}
```

---

## 7. 위젯 타임라인 정책 (Y5 반영)

- **Policy**: `.atEnd` — 마지막 엔트리 표시 후 시스템이 새 타임라인 요청
- **엔트리 생성**: 현재 시점 + 자정(다음날) 2개 엔트리
- **수동 갱신**: `TodoStore.save()` 호출 시 `WidgetCenter.shared.reloadAllTimelines()`
- **Relevance**: 미완료 개수가 많을수록 높은 relevance score

---

## 8. 구현 순서

| Phase | 작업 | 예상 |
|-------|------|------|
| 1 | App Group + SharedDefaults + 마이그레이션 | 기반 |
| 2 | TodoStore → SharedDefaults 전환 | 기반 |
| 3 | Widget Provider + Small/Medium/Large View | 위젯 |
| 4 | ToggleTodoIntent (Interactive Widget) | 위젯 |
| 5 | Project.swift 타겟 설정 | 빌드 |
| 6 | Watch App UI + WatchStore | 워치 |
| 7 | 통합 테스트 + regression 확인 | QA |
