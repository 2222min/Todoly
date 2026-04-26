---
inclusion: auto
---

# 🏗️ Todoly 프로젝트 아키텍처 맵

이 문서는 에이전트가 코드를 이해하고 구현하는 데 필요한 아키텍처 전체 맥락을 제공합니다.
코드를 읽거나 수정하기 전에 반드시 참고합니다.

---

## 아키텍처 개요

Todoly는 **레이어드 아키텍처 + Feature 기반 모듈화** 구조입니다.

```
App → Features → Domain, Core
                  Data → Domain
```

- **App**: 앱 진입점, 라우팅, AppDelegate
- **Domain**: 모델, 순수 비즈니스 로직, Protocol 정의 (의존성 없음)
- **Data**: Store(상태 관리), Services(외부 서비스) — Domain에만 의존
- **Core**: 공통 UI 컴포넌트, Extension — Domain에만 의존
- **Features**: 화면별 View — Domain, Core, Data에 의존

### 의존성 방향 (위반 금지)
```
Features ──→ Domain ←── Data
    │            ↑
    └──→ Core ───┘
    
App ──→ 전체
```

- Domain은 어디에도 의존하지 않는다 (순수 레이어)
- Features끼리 직접 의존하지 않는다 (Store를 통해 간접 통신)
- Data는 Domain의 Protocol을 구현한다

---

## 폴더 구조 → 파일 맵

### App/ (앱 진입점)
| 파일 | 역할 |
|------|------|
| `TodolyApp.swift` | `@main` 진입점, Scene 구성, 알림 권한 요청 |
| `AppDelegate.swift` | `UNUserNotificationCenterDelegate`, 포그라운드 알림 표시 |
| `AppState.swift` | 앱 전역 상태 (splash → login → main 화면 전환) |
| `RootView.swift` | AppState 기반 화면 라우팅 |

### Domain/Models/ (데이터 모델)
| 파일 | 역할 |
|------|------|
| `Todo.swift` | 할 일 모델 (Identifiable, Codable) |
| `TodoCategory.swift` | 카테고리 모델 (emoji 포함) + defaults + Hashable |
| `Priority.swift` | 우선순위 enum (color, label, sortOrder) |
| `BadgeStyle.swift` | 날짜 배지 스타일 enum |
| `TodoAlarmAttributes.swift` | Live Activity 속성 (ActivityKit) |

### Domain/Logic/ (순수 함수 — 핵심 비즈니스 로직)
| 파일 | 역할 | 주요 함수 |
|------|------|----------|
| `TodoMutationLogic.swift` | Todo 상태 변환 | `toggleComplete()`, `softDelete()`, `restore()`, `update()`, `isValidTitle()` |
| `TodoFilterLogic.swift` | Todo 필터링 | `todosWithDueDate()`, `todos(for:)`, `incompleteTodos(for:)`, `completedTodos(for:)`, `todosWithoutDueDate(from:)`, `incompleteTodos(forCategory:)`, `search()` |
| `CategoryMutationLogic.swift` | 카테고리 CRUD | `updateCategory()`, `deleteCategory()` |
| `DateBadgeLogic.swift` | 날짜 배지/dot 계산 | `badge(for:)`, `dotPriorityColors(for:)` |

**핵심 패턴**: 모든 Logic 함수는 `static func`이며, 입력 배열을 받아 새 배열을 반환합니다. 외부 상태를 절대 변경하지 않습니다.

```swift
// 패턴 예시: 입력 → 새 결과 반환
static func toggleComplete(todoId: String, incomplete: [Todo], completed: [Todo]) -> ToggleResult
```

### Domain/Protocols/ (추상화)
| 파일 | 역할 |
|------|------|
| `TodoStoring.swift` | TodoStore 추상화 (CRUD 메서드 정의) |
| `NotificationScheduling.swift` | 알림 서비스 추상화 |

### Data/Store/ (상태 관리)
| 파일 | 역할 |
|------|------|
| `TodoStore.swift` | 중앙 데이터 저장소 (`@MainActor ObservableObject`). 순수 로직을 호출하고 결과를 `@Published` 프로퍼티에 적용. 부수 효과(알림 취소, undo 타이머) 처리. UserDefaults + Codable로 영속화. |

**TodoStore 패턴**:
```swift
func toggleComplete(_ todo: Todo) {
    let result = TodoMutationLogic.toggleComplete(...)  // 순수 로직 호출
    incomplete = result.incomplete                       // 결과 적용 (부수 효과)
    completed = result.completed
}
```

### Data/Services/ (외부 서비스)
| 파일 | 역할 |
|------|------|
| `NotificationService.swift` | `NotificationScheduling` 프로토콜 구현. UNUserNotificationCenter 래핑. |

### Core/Extensions/
| 파일 | 역할 |
|------|------|
| `Color+Brand.swift` | `Color(hex:)` 이니셜라이저 + 브랜드 컬러 상수 |
| `Date+Badge.swift` | `Date.badge` computed property (DateBadgeLogic에 위임) |

### Core/Components/
| 파일 | 역할 |
|------|------|
| `SoftPressStyle.swift` | 눌림 애니메이션 ButtonStyle |
| `TodoCheckbox.swift` | 공통 체크박스 (할일 탭 + 캘린더 통일, 히트 영역 44x44) |
| `UndoToast.swift` | 삭제 되돌리기 토스트 |

### Features/ (화면별 모듈)

| 폴더 | 파일들 | 역할 |
|------|--------|------|
| `Alarm/` | `AlarmView.swift` | 풀스크린 알람 (커스텀 사운드 + 진동) |
| `Auth/` | `LoginView.swift` | 로그인 화면 |
| `Splash/` | `SplashView.swift` | 스플래시 화면 |
| `Tab/` | `Tab.swift`, `MainTabView.swift`, `BottomNavBar.swift` | 탭 구조, 하단 네비게이션 |
| `TaskList/` | `MainListView.swift`, `TaskCardView.swift`, `CompletedRow.swift` | 메인 할 일 목록 |
| `TaskDetail/` | `TaskDetailView.swift`, `AddTaskSheet.swift` | 할 일 상세/추가 |
| `Calendar/` | `CalendarView.swift`, `CalendarHeaderView.swift`, `CalendarGridView.swift`, `DayTaskRow.swift`, `NoDueDateTaskRow.swift`, `CustomDatePicker.swift`, `CalendarConstants.swift` | 캘린더 기능 |
| `Category/` | `CategoryListView.swift`, `CategoryAddSheet.swift`, `CategoryFilterView.swift`, `CategoryRow.swift` | 카테고리 관리 |
| `Search/` | `SearchView.swift` | 검색 |
| `Trash/` | `TrashView.swift` (+ `TrashItemRow`) | 휴지통 |

---

## Tuist 프로젝트 구성

`Project.swift`에서 sources를 레이어별로 명시:
```swift
sources: [
    "Todoly/App/**",
    "Todoly/Core/**",
    "Todoly/Data/**",
    "Todoly/Domain/**",
    "Todoly/Features/**",
]
```

새 파일 추가 후 반드시 `tuist generate --no-open` 실행하여 Xcode 프로젝트 재생성.

---

## 데이터 흐름

```
User Action → View → TodoStore.method()
                         ↓
                    Domain/Logic (순수 함수)
                         ↓
                    새 상태 반환 (ToggleResult 등)
                         ↓
                    TodoStore @Published 업데이트
                         ↓
                    SwiftUI 자동 리렌더링
```

### EnvironmentObject 주입 체인
```
TodolyApp
  └─ RootView (.environmentObject(appState))
       └─ MainTabView (@StateObject store = TodoStore())
            └─ .environmentObject(store)
                 ├─ MainListView
                 ├─ CalendarView
                 ├─ CategoryListView
                 └─ TrashView
```

---

## 새 기능 추가 시 체크리스트

1. `Features/[FeatureName]/` 폴더 생성
2. 필요한 모델 → `Domain/Models/`
3. 비즈니스 로직 → `Domain/Logic/[Name]Logic.swift` (순수 함수)
4. 외부 서비스 필요 시 → `Domain/Protocols/` + `Data/Services/`
5. Store 확장 필요 시 → `Data/Store/TodoStore.swift`에 메서드 추가 (순수 로직 호출 패턴)
6. 공통 UI → `Core/Components/`
7. 모든 View에 `#Preview` 매크로 포함
8. `tuist generate --no-open` 실행

---

## 주요 아키텍처 결정 기록

| 결정 | 이유 | 날짜 |
|------|------|------|
| 플랫 구조 → 레이어드 + Feature 기반 | SRP 위반, 파일 간 의존성 불명확 | 2026-04-26 |
| 비즈니스 로직을 static 순수 함수로 분리 | 테스트 용이성, 부수 효과 격리 | 2026-04-26 |
| Protocol 기반 DI (TodoStoring, NotificationScheduling) | 테스트 시 Mock 주입, 구체 구현 교체 용이 | 2026-04-26 |
| Store가 순수 로직 호출 → 결과 적용 패턴 | Store의 역할을 상태 관리 + 부수 효과로 한정 | 2026-04-26 |
| View를 SRP 기반 작은 컴포넌트로 분리 | BadgeView, CategoryRow, TrashItemRow, BottomNavBar 등 | 2026-04-26 |
| CalendarDateLogic 순수 함수 추출 | daysInMonth, makeDate, weekdayIndex 등 캘린더 계산 분리 | 2026-04-26 |
| Tuist sources를 레이어별 glob으로 구성 | 폴더 구조와 빌드 설정 일치 | 2026-04-26 |
