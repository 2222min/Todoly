# 📋 Todoly 최종 기획안 — 기간 할일 & 오늘 필터

## 문서 정보
| 항목 | 내용 |
|------|------|
| 버전 | FINAL |
| 작성일 | 2026-04-28 |
| 상태 | ✅ Step 3 최종 기획안 (리뷰 반영 완료) |
| 선행 문서 | v1_기간할일_오늘필터_plan.md, v1_기간할일_오늘필터_review.md |

---

## 1. 변경 요약

| # | 요구사항 | 설명 |
|---|---------|------|
| 1 | 할일 탭 오늘 필터 | 오늘 할일만 노출. 완료도 오늘 완료만 표시 |
| 2 | 연속 할일 도입 | 시작일~종료일 기간 동안 매일 노출되는 할일 |
| 3 | 연속 할일 날짜별 완료 | 4/2 완료해도 4/3에 미완료로 재등장 |

---

## 2. 용어 정의

### "연속 할일" (Recurring Task)

> 시작일부터 종료일까지 매일 수행해야 하는 할일.
> 하루 완료해도 다음 날 미완료로 다시 등장한다.

| 용어 | 설명 |
|------|------|
| 연속 할일 | startDate~endDate가 설정된 할일 |
| 시작일 (startDate) | 할일이 처음 노출되는 날짜 |
| 종료일 (endDate) | 할일이 마지막으로 노출되는 날짜 |
| 일별 완료 기록 (dailyCompletions) | 날짜별 완료 여부 딕셔너리 |

### 할일 유형 분류

| 유형 | 조건 | 할일 탭 노출 기준 |
|------|------|------------------|
| 일반 할일 (마감일 있음) | dueDate만 설정 | dueDate == 오늘 또는 dueDate < 오늘 (지연) |
| 일반 할일 (마감일 없음) | dueDate nil, startDate nil | 항상 오늘 탭 미완료 섹션에 노출 (그냥 할일) |
| 연속 할일 | startDate + endDate 설정 | startDate ≤ 오늘 ≤ endDate |

---

## 3. 데이터 모델 변경

### Todo 모델 신규 필드

```swift
struct Todo: Identifiable, Codable {
    // 기존 필드 전부 유지
    
    // ✅ 신규 필드
    var startDate: Date?                    // 연속 할일 시작일
    var endDate: Date?                      // 연속 할일 종료일
    var dailyCompletions: [String: Date] = [:]  // "yyyy-MM-dd" → 완료 시각
}
```

### 연속 할일 제약

- 최대 기간: 90일
- startDate ≤ endDate (유효성 검사)
- 연속 할일은 `isCompleted` 필드를 사용하지 않음 (dailyCompletions로 관리)

---

## 4. 할일 탭 필터링 정책

### 4.1 미완료 섹션 구조 (위→아래)

```
┌─────────────────────────────────┐
│  오늘의 할 일                    │
│  N개 남음                        │
├─────────────────────────────────┤
│  미완료 (N)                      │
│  │ 🔴│ ☐ 보고서 작성  지연 🔴   │  ← dueDate < 오늘 (지연)
│  │ 🟠│ ☐ 장보기      오늘       │  ← dueDate == 오늘
│  │    │ ☐ 아이디어 정리          │  ← 마감일 없음 (그냥 할일)
│  │    │ ☐ 책 목록 만들기         │  ← 마감일 없음 (그냥 할일)
├─────────────────────────────────┤
│  🔄 연속 할일 (N)                │
│  │ 🔵│ 🔄 ☑ 매일 운동  2일째 ✓  │  ← 연속 할일 (오늘 완료)
│  │ 🔵│ 🔄 ☐ 매일 독서  3일째    │  ← 연속 할일 (오늘 미완료)
├─────────────────────────────────┤
│  오늘 완료됨 (N)                 │
│  │ ☑ 이메일 확인  오전 8:00 완료 │  ← 일반 할일 (completedAt == 오늘)
└─────────────────────────────────┘
```

### 4.2 미완료 섹션 필터 조건

| 유형 | 조건 |
|------|------|
| 지연 일반 할일 | dueDate < 오늘 & !isCompleted |
| 오늘 마감 일반 할일 | dueDate == 오늘 & !isCompleted |
| 마감일 없는 일반 할일 | dueDate nil & !isPeriodTask & !isCompleted (항상 노출) |

> 마감일 없는 할일은 별도 섹션 없이 미완료 섹션에 통합. "날짜 미지정" 섹션은 캘린더 탭에서만 유지.

### 4.3 완료 섹션

| 유형 | 조건 |
|------|------|
| 일반 할일 | completedAt이 오늘 |

> 연속 할일은 완료 섹션에 표시하지 않음 (미완료 섹션에서 체크 상태로 유지)

### 4.5 Hero 카운트

```
"N개 남음" = 오늘 미완료 일반 할일 수 (마감일 없는 것 포함) + 오늘 미완료 연속 할일 수
```

---

## 5. 연속 할일 완료 처리

### 5.1 체크박스 탭 (오늘 기준)

```
탭 → dailyCompletions["2026-04-28"] = Date.now
→ 카드: 체크 on + 투명도 0.55 + "N일째 ✓" 배지
→ 미완료 섹션에 유지 (이동 없음)
```

### 5.2 체크 해제 (오늘 기준)

```
탭 → dailyCompletions["2026-04-28"] 제거
→ 카드: 체크 off + 투명도 1.0 + "N일째" 배지
```

### 5.3 기간 종료 후

```
endDate < 오늘:
→ 할일 탭에서 자동 숨김
→ 캘린더에서 기간 내 각 날짜에서 확인 가능
→ 전체 완료 판정: 모든 날짜 dailyCompletions 존재 시 isCompleted = true
```

---

## 6. UI 변경사항

### 6.1 AddTaskSheet — 기간 설정 (R-5 반영: 토글 방식)

```
┌─────────────────────────────────┐
│  📅 마감일                       │
│  [토글 ON]                       │
│  📅 2026년 4월 28일    변경 ▸   │
│                                  │
│  🔄 연속 할일로 설정     [토글]  │  ← 토글 ON 시 종료일 피커 등장
│  종료일: 📅 2026년 5월 2일       │
│  ℹ️ "5일간 매일 반복됩니다"       │
└─────────────────────────────────┘
```

- 기본: 마감일 단일 피커 (기존 UX 유지)
- "연속 할일로 설정" 토글 ON → 마감일이 시작일로 전환 + 종료일 피커 추가
- 최대 90일 제한 (초과 시 경고)

### 6.2 TaskCardView — 연속 할일 표시 (R-4 반영)

```
┌──────────────────────────────────┐
│ 🔵│ 🔄 ☐  매일 운동하기          │  ← 🔄 반복 아이콘으로 시각적 구분
│   │       개인 · 3일째            │  ← "N일째" 배지 (Y-6 반영)
│   │       ▓▓▓░░ 3/5              │  ← 미니 프로그레스 바 (Y-2 반영)
└──────────────────────────────────┘

[오늘 완료 시]
┌──────────────────────────────────┐
│ 🔵│ 🔄 ☑  매일 운동하기  (55%)   │  ← 체크 + 투명도
│   │       개인 · 3일째 ✓          │  ← ✓ 표시
│   │       ▓▓▓░░ 3/5              │
└──────────────────────────────────┘
```

### 6.3 TaskDetailView — 연속 할일 상세

```
┌─────────────────────────────────┐
│  매일 운동하기                    │
│                                  │
│  📅 기간                         │
│  4월 28일 ~ 5월 2일 (5일)        │
│                                  │
│  📊 진행 현황                    │
│  ▓▓▓░░ 3/5일 완료               │
│  4/28 ✓  4/29 ✓  4/30 ✓         │
│  5/1  ○  5/2  ○                  │
└─────────────────────────────────┘
```

### 6.4 MainListView 변경

- Hero: "오늘의 할 일" / "N개 남음" (오늘 기준 카운트)
- 미완료 섹션: 오늘 필터 적용
- 완료 섹션: "오늘 완료됨" 라벨 (Y-3 반영)
- 날짜 미지정 섹션: 접이식 (R-1 반영)

### 6.5 배지 시스템 (연속 할일용)

| 상태 | 배지 텍스트 | 스타일 |
|------|-----------|--------|
| 오늘 미완료 | "N일째" | 파란색 배지 |
| 오늘 완료 | "N일째 ✓" | 녹색 배지 |
| 종료 N일 전 | "N일 남음" | 회색 텍스트 |

---

## 7. 캘린더 연동

### 연속 할일의 캘린더 표시

| 항목 | 동작 |
|------|------|
| Dot Indicator | startDate~endDate 범위 모든 날짜에 표시 |
| 날짜 선택 | 해당 날짜의 완료/미완료 상태 표시 |
| 완료 날짜 | 체크 on + 투명도 0.55 |
| 미완료 날짜 | 체크 off |
| 체크박스 탭 | 해당 날짜의 dailyCompletions 토글 |

---

## 8. 순수 로직 변경

### TodoFilterLogic 추가

| 함수 | 설명 |
|------|------|
| `todayIncompleteRegular(from:today:)` | 오늘 미완료 (마감일 있으면 오늘/지연, 없으면 항상 노출) |
| `todayActivePeriodTodos(from:today:)` | 오늘 활성 연속 할일 (완료/미완료 모두) |
| `todayCompletedTodos(from:today:)` | 오늘 완료 일반 할일 (completedAt==오늘) |
| `todayIncompleteCount(from:today:)` | 오늘 미완료 카운트 (Hero용) |

### TodoMutationLogic 추가

| 함수 | 설명 |
|------|------|
| `toggleDailyCompletion(todoId:date:todos:)` | 연속 할일 날짜별 완료 토글 |
| `finalizePeriodTask(todo:)` | 기간 종료 시 전체 완료 판정 |

### DateBadgeLogic 추가

| 함수 | 설명 |
|------|------|
| `periodBadge(todo:today:)` | 연속 할일 배지 ("N일째", "N일째 ✓", "N일 남음") |
| `periodProgress(todo:)` | 진행률 (완료일수, 전체일수) |

---

## 9. 영향 범위

### 변경 파일 (13개)

| 파일 | 변경 | 내용 |
|------|------|------|
| `Domain/Models/Todo.swift` | 수정 | startDate, endDate, dailyCompletions, isPeriodTask, isActiveOn, isCompletedOn |
| `Domain/Logic/TodoFilterLogic.swift` | 수정 | 오늘 필터 5개 함수 추가 |
| `Domain/Logic/TodoMutationLogic.swift` | 수정 | toggleDailyCompletion, finalizePeriodTask |
| `Domain/Logic/DateBadgeLogic.swift` | 수정 | periodBadge, periodProgress |
| `Domain/Protocols/TodoStoring.swift` | 수정 | toggleDailyCompletion 메서드 추가 |
| `Data/Store/TodoStore.swift` | 수정 | 오늘 필터 computed property, toggleDailyCompletion |
| `Features/TaskList/MainListView.swift` | 수정 | 오늘 필터 적용, 날짜 미지정 섹션, "오늘 완료됨" 라벨 |
| `Features/TaskList/TaskCardView.swift` | 수정 | 연속 할일 카드 (🔄 아이콘, 프로그레스 바, 배지) |
| `Features/TaskList/CompletedRow.swift` | 수정 | 오늘 완료 필터 반영 |
| `Features/TaskDetail/AddTaskSheet.swift` | 수정 | "연속 할일로 설정" 토글 + 종료일 피커 |
| `Features/TaskDetail/TaskDetailView.swift` | 수정 | 연속 할일 상세 (기간, 진행 현황) |
| `Features/Calendar/DayTaskRow.swift` | 수정 | 연속 할일 날짜별 상태 |
| `Features/Calendar/CalendarConstants.swift` | 수정 | 연속 할일 캘린더 로직 |

### 미결정 사항 해결

| # | 항목 | 결정 |
|---|------|------|
| 1 | 마감일 없는 할일 | 미완료 섹션에 통합 (별도 섹션 없음, 그냥 할일) |
| 2 | 기간 종료 후 | 자동 숨김 (축하 토스트는 v1.1) |
| 3 | 연속 할일 알림 | v1.1 보류 (현재는 알림 없음) |
| 4 | Quick Add 지원 | 미지원 (상세 추가만) |
| 5 | dueDate와 공존 | 공존 (기존 호환성 유지) |
