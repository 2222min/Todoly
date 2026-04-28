# 🛠 개발 스펙 — 기간 할일 & 오늘 필터

## 구현 순서 (의존성 기반)

1. **Todo 모델 확장** — startDate, endDate, dailyCompletions 추가
2. **순수 로직 추가** — TodoFilterLogic, TodoMutationLogic, DateBadgeLogic
3. **TodoStoring 프로토콜 확장** — toggleDailyCompletion 추가
4. **TodoStore 확장** — 오늘 필터 computed property, toggleDailyCompletion
5. **MainListView 수정** — 오늘 필터 적용, 날짜 미지정 섹션
6. **TaskCardView 수정** — 연속 할일 카드 UI
7. **AddTaskSheet 수정** — 연속 할일 설정 토글
8. **TaskDetailView 수정** — 연속 할일 상세
9. **캘린더 연동** — DayTaskRow, CalendarConstants 수정

## 핵심 설계 원칙

- 모든 비즈니스 로직은 Domain/Logic에 순수 함수로 구현
- Store는 순수 로직 호출 → 결과 적용 + save()
- 기존 일반 할일 동작은 절대 깨지지 않아야 함
- dailyCompletions는 Codable 호환 ([String: Date])
