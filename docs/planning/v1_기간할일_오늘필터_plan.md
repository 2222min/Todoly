# 📋 Todoly 기획 초안 — 기간 할일 & 오늘 필터

## 문서 정보
| 항목 | 내용 |
|------|------|
| 버전 | v1 (초안) |
| 작성일 | 2026-04-28 |
| 상태 | 📝 Step 1 기획 초안 |

---

## 1. 변경 요약

### 요구사항 3가지

| # | 요구사항 | 설명 |
|---|---------|------|
| 1 | 할일 탭 오늘 필터 | 할일 탭에 오늘 할일만 노출. 완료된 것도 오늘 완료된 것만 표시 |
| 2 | 기간 할일 도입 | "마감일" 단일 날짜 대신 "시작일~종료일" 기간 개념 추가. 기간 내 매일 할일 탭에 노출 |
| 3 | 기간 할일 날짜별 완료 | 4/2~4/5 기간 할일에서 4/2 완료해도 4/3에 미완료로 다시 노출 |

---

## 2. 용어 정의

### "기간 할일" (Period Task)

> 시작일부터 종료일까지 **매일 반복적으로 수행해야 하는** 할일.
> 하루 완료해도 다음 날 다시 미완료로 등장한다.

| 용어 | 영문 | 설명 |
|------|------|------|
| 기간 할일 | Period Task | startDate~endDate가 설정된 할일 |
| 시작일 | startDate | 할일이 처음 노출되는 날짜 |
| 종료일 | endDate | 할일이 마지막으로 노출되는 날짜 |
| 일별 완료 기록 | Daily Completion | 날짜별 완료 여부를 추적하는 딕셔너리 |

### 할일 유형 분류 (변경 후)

| 유형 | 조건 | 할일 탭 노출 기준 |
|------|------|------------------|
| 일반 할일 (마감일 있음) | dueDate만 설정 | dueDate == 오늘 |
| 일반 할일 (마감일 없음) | dueDate nil, startDate nil | 생성일 == 오늘 (또는 항상 노출 — 아래 정책 참고) |
| 기간 할일 | startDate + endDate 설정 | startDate ≤ 오늘 ≤ endDate |

---

## 3. 데이터 모델 변경

### Todo 모델 필드 추가

```swift
struct Todo: Identifiable, Codable {
    // 기존 필드 유지
    var id: String
    var title: String
    var memo: String?
    var dueDate: Date?           // 기존 마감일 (단일 날짜 할일용)
    var priority: Priority
    var categoryName: String?
    var categoryColor: String?
    var isCompleted: Bool         // 일반 할일용 (기존)
    var completedAt: Date?        // 일반 할일용 (기존)
    var isDeleted: Bool
    var deletedAt: Date?
    var createdAt: Date
    var reminderMinutes: Int?

    // ✅ 신규 필드
    var startDate: Date?          // 기간 할일 시작일
    var endDate: Date?            // 기간 할일 종료일
    var dailyCompletions: [String: Date]  // 날짜별 완료 기록 (key: "yyyy-MM-dd", value: 완료 시각)
}
```

### dailyCompletions 설계

| 키 | 값 | 예시 |
|----|-----|------|
| "yyyy-MM-dd" 형식 문자열 | 완료 시각 (Date) | `["2026-04-02": Date(), "2026-04-03": Date()]` |

- 기간 할일의 날짜별 완료 여부를 추적
- 일반 할일은 이 필드를 사용하지 않음 (빈 딕셔너리)
- Codable 호환 (String 키 + Date 값)

### 기간 할일 판별

```swift
/// 기간 할일 여부
var isPeriodTask: Bool {
    startDate != nil && endDate != nil
}

/// 특정 날짜에 이 할일이 활성 상태인지
func isActiveOn(_ date: Date) -> Bool {
    guard let start = startDate, let end = endDate else { return false }
    let cal = Calendar.current
    let day = cal.startOfDay(for: date)
    return day >= cal.startOfDay(for: start) && day <= cal.startOfDay(for: end)
}

/// 특정 날짜에 완료했는지
func isCompletedOn(_ date: Date) -> Bool {
    let key = Self.dateKey(for: date)
    return dailyCompletions[key] != nil
}

/// 날짜 키 생성 헬퍼
static func dateKey(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
```

---

## 4. 할일 탭 필터링 정책 (오늘 필터)

### 미완료 섹션 — "오늘 할 일"

| 유형 | 노출 조건 |
|------|----------|
| 일반 할일 (dueDate 있음) | dueDate == 오늘 **또는** dueDate < 오늘 (지연) |
| 일반 할일 (dueDate 없음) | 항상 노출 (날짜 미지정은 매일 보여야 함) |
| 기간 할일 | startDate ≤ 오늘 ≤ endDate **이고** 오늘 날짜 미완료 |

### 완료 섹션 — "오늘 완료"

| 유형 | 노출 조건 |
|------|----------|
| 일반 할일 | completedAt이 오늘인 것 |
| 기간 할일 | dailyCompletions에 오늘 날짜 키가 있는 것 |

### Hero 섹션 텍스트 변경

```
기존: "오늘의 할 일" / "N개 남음"
변경: "오늘의 할 일" / "N개 남음" (오늘 기준 필터링된 카운트)
```

---

## 5. 기간 할일 완료 처리 로직

### 체크박스 탭 시 동작

```
기간 할일 체크박스 탭 (오늘 날짜 기준):
1. dailyCompletions["2026-04-28"] = Date.now  ← 오늘 완료 기록
2. 할일 탭에서 미완료 → 완료 섹션으로 이동
3. 다음 날(4/29) 접속 시:
   - dailyCompletions["2026-04-29"]가 없으므로 → 미완료로 노출
```

### 완료 취소 (체크 해제)

```
기간 할일 체크 해제 (오늘 날짜 기준):
1. dailyCompletions["2026-04-28"] 제거
2. 완료 섹션 → 미완료 섹션으로 복귀
```

### 기간 종료 후 처리

```
endDate < 오늘:
- 할일 탭에 더 이상 노출되지 않음
- 캘린더에서는 기간 내 각 날짜에서 확인 가능
- 전체 완료 여부: 모든 날짜가 dailyCompletions에 있으면 완료 처리
```

---

## 6. UI 변경사항

### 6.1 할일 추가 (AddTaskSheet) 변경

기존 "마감일" 섹션을 확장:

```
┌─────────────────────────────────┐
│  📅 날짜 설정                    │
│  ┌─────────────────────────────┐│
│  │ ○ 마감일    ○ 기간 설정      ││  세그먼트 선택
│  └─────────────────────────────┘│
│                                  │
│  [마감일 선택 시]                 │
│  📅 2026년 4월 28일              │
│                                  │
│  [기간 설정 선택 시]              │
│  시작일: 📅 2026년 4월 28일      │
│  종료일: 📅 2026년 5월 2일       │
│  → "5일간 매일 반복됩니다"       │
└─────────────────────────────────┘
```

### 6.2 TaskCardView 변경 — 기간 할일 표시

```
┌──────────────────────────────────┐
│ 🔴│ ☐  매일 운동하기             │  
│   │     개인 · 4/28~5/2 (3/5)   │  ← 기간 + 진행률
└──────────────────────────────────┘
```

- 기간 할일: 카테고리 · 시작~종료 (완료일수/전체일수)
- 일반 할일: 기존과 동일 (카테고리 · 배지)

### 6.3 TaskDetailView 변경

기간 할일 상세에서:
- 시작일/종료일 표시
- 날짜별 완료 현황 (미니 캘린더 또는 진행 바)
- 오늘 완료 여부 체크박스

### 6.4 MainListView 변경

```
기존: store.incomplete / store.completed 전체 표시
변경: 오늘 기준 필터링된 목록만 표시

미완료 섹션:
- 오늘 마감 + 지연된 일반 할일
- 마감일 없는 일반 할일
- 오늘 활성 + 오늘 미완료인 기간 할일

완료 섹션:
- 오늘 completedAt인 일반 할일
- 오늘 dailyCompletions 있는 기간 할일
```

---

## 7. 캘린더 연동

### 기간 할일의 캘린더 표시

- startDate~endDate 범위의 모든 날짜에 Dot Indicator 표시
- 각 날짜 선택 시 해당 날짜의 완료/미완료 상태 표시
- 완료된 날짜: 체크 on + 투명도 0.55
- 미완료 날짜: 체크 off

---

## 8. 순수 로직 변경 목록

### TodoFilterLogic 추가/변경

| 함수 | 설명 |
|------|------|
| `todayIncompleteTodos(from:today:)` | 오늘 미완료 할일 (일반 + 기간) |
| `todayCompletedTodos(from:completed:today:)` | 오늘 완료 할일 (일반 + 기간) |
| `periodTodosActiveOn(date:from:)` | 특정 날짜에 활성인 기간 할일 |

### TodoMutationLogic 추가/변경

| 함수 | 설명 |
|------|------|
| `toggleDailyCompletion(todoId:date:incomplete:completed:)` | 기간 할일 날짜별 완료 토글 |

### DateBadgeLogic 변경

| 함수 | 설명 |
|------|------|
| `periodBadge(startDate:endDate:today:)` | 기간 할일용 배지 ("D-3 남음" 등) |

---

## 9. 마이그레이션 고려사항

### 기존 데이터 호환성

- `startDate`, `endDate`: Optional이므로 기존 데이터에 nil로 디코딩됨 ✅
- `dailyCompletions`: 기본값 빈 딕셔너리 `[:]`로 초기화 ✅
- 기존 `isCompleted`, `completedAt`: 일반 할일에서 그대로 사용 ✅
- 기간 할일은 `isCompleted`를 사용하지 않음 (dailyCompletions로 관리)

### Codable 호환

```swift
var dailyCompletions: [String: Date] = [:]  // 기본값으로 디코딩 실패 방지
```

---

## 10. 영향 범위 분석

### 변경 파일

| 파일 | 변경 유형 | 내용 |
|------|----------|------|
| `Domain/Models/Todo.swift` | 수정 | startDate, endDate, dailyCompletions 필드 추가 |
| `Domain/Logic/TodoFilterLogic.swift` | 수정 | 오늘 필터 함수 추가, 기간 할일 필터 추가 |
| `Domain/Logic/TodoMutationLogic.swift` | 수정 | 기간 할일 날짜별 완료 토글 추가 |
| `Domain/Logic/DateBadgeLogic.swift` | 수정 | 기간 할일 배지 로직 추가 |
| `Domain/Protocols/TodoStoring.swift` | 수정 | 기간 할일 관련 메서드 추가 |
| `Data/Store/TodoStore.swift` | 수정 | 오늘 필터 computed property, 기간 할일 완료 토글 |
| `Features/TaskList/MainListView.swift` | 수정 | 오늘 필터 적용 |
| `Features/TaskList/TaskCardView.swift` | 수정 | 기간 할일 표시 (기간 + 진행률) |
| `Features/TaskList/CompletedRow.swift` | 수정 | 기간 할일 완료 표시 |
| `Features/TaskDetail/AddTaskSheet.swift` | 수정 | 기간 설정 UI 추가 |
| `Features/TaskDetail/TaskDetailView.swift` | 수정 | 기간 할일 상세 표시 |
| `Features/Calendar/CalendarView.swift` | 수정 | 기간 할일 캘린더 연동 |
| `Features/Calendar/DayTaskRow.swift` | 수정 | 기간 할일 날짜별 상태 표시 |

### 서버 영향 (Firestore)

| 항목 | 영향 |
|------|------|
| Firestore 스키마 | `startDate`, `endDate`, `dailyCompletions` 필드 추가 |
| 보안 규칙 | 변경 없음 (기존 사용자별 격리 유지) |
| Cloud Functions | 변경 없음 |

---

## 11. 미결정 사항 (리뷰 필요)

| # | 항목 | 선택지 | 추천 |
|---|------|--------|------|
| 1 | 마감일 없는 일반 할일의 오늘 탭 노출 | A) 항상 노출 B) 생성일만 노출 C) 별도 섹션 | A) 항상 노출 |
| 2 | 기간 할일 종료 후 상태 | A) 자동 숨김 B) "종료됨" 표시 C) 완료 처리 | A) 자동 숨김 |
| 3 | 기간 할일 알림 | A) 매일 알림 B) 시작일만 C) 미완료 시만 | C) 미완료 시만 |
| 4 | 기간 할일 Quick Add 지원 | A) 지원 (기본 기간 7일) B) 미지원 (상세 추가만) | B) 미지원 |
| 5 | 기존 dueDate 할일과 기간 할일 공존 | A) 공존 B) dueDate 폐지 → 기간으로 통합 | A) 공존 |
