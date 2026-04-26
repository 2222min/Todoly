# 구현 계획: 캘린더 뷰 & 디자인 개선

## 개요

Todoly 앱에 캘린더 기반 할 일 조회 기능을 추가한다. TodoStore 확장 → 모델 헬퍼 추가 → Tab 구조 변경 → CalendarView 신규 구현 → 애니메이션 → 접근성 순서로 점진적으로 구현하며, 각 단계에서 이전 코드와 통합된 상태를 유지한다.

## Tasks

- [x] 1. TodoStore 확장 및 Priority 헬퍼 추가
  - [x] 1.1 Priority.sortOrder computed property 추가 (Models.swift)
    - `Priority` enum에 `sortOrder: Int` extension 추가 (high=0, medium=1, low=2, none=3)
    - _Requirements: 2.7_
  - [x] 1.2 TodoStore에 날짜 기반 필터링 computed property 추가 (TodoStore.swift)
    - `todosWithDueDate`: dueDate != nil && !isDeleted인 모든 할 일 반환
    - `todos(for date: Date)`: 특정 날짜의 할 일 필터링
    - `incompleteTodos(for date: Date)`: 특정 날짜의 미완료 할 일 필터링
    - _Requirements: 4.1, 4.4, 3.2_
  - [ ]* 1.3 Property 테스트: 날짜별 미완료 할 일 필터링
    - **Property 4: 날짜별 미완료 할 일 필터링**
    - incompleteTodos(for:) 반환값이 (1) dueDate가 해당 날짜와 같은 날, (2) isCompleted == false, (3) 조건 만족하는 모든 항목 포함 검증
    - **Validates: Requirements 3.2**
  - [ ]* 1.4 Property 테스트: dueDate 필터링 및 삭제 항목 제외
    - **Property 5: dueDate 필터링 및 삭제 항목 제외**
    - todosWithDueDate 반환값이 (1) dueDate != nil, (2) isDeleted == false, (3) 조건 만족하는 모든 항목 포함 검증
    - **Validates: Requirements 4.1, 4.4**
  - [ ]* 1.5 Property 테스트: 완료 처리 상태 전환
    - **Property 6: 완료 처리 상태 전환**
    - toggleComplete 호출 후 isCompleted/completedAt 상태 전환 검증
    - **Validates: Requirements 4.3**

- [x] 2. Tab enum 확장 및 MainTabView 수정
  - [x] 2.1 Tab enum에 .calendar 케이스 추가 (MainTabView.swift)
    - `Tab` enum에 `case calendar = "Calendar"` 추가 (tasks 다음, categories 앞)
    - `icon` computed property에 `case .calendar: "calendar"` 추가
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 2.2 MainTabView body에 CalendarView 분기 추가 (MainTabView.swift)
    - `switch tab` 분기에 `case .calendar: CalendarView()` 추가
    - 기본 선택 탭은 `.tasks` 유지
    - _Requirements: 1.1, 1.4_
  - [ ]* 2.3 단위 테스트: Tab enum 순서 및 속성 검증
    - Tab.allCases 순서가 [.tasks, .calendar, .categories, .trash]인지 확인
    - Tab.calendar.icon == "calendar", Tab.calendar.rawValue == "Calendar" 확인
    - _Requirements: 1.2, 1.3_

- [x] 3. CalendarView 기본 구조 구현 (CalendarView.swift 신규 생성)
  - [x] 3.1 CalendarView 메인 구조체 및 AnimationConstants 정의
    - `CalendarView` 구조체 생성 (@EnvironmentObject store, @State displayMonth/selectedDate/monthTransitionDirection)
    - `AnimationConstants` private enum 정의 (월 이동, 날짜 선택, 목록 등장, staggered 파라미터)
    - onAppear에서 selectedDate를 오늘로 초기화
    - _Requirements: 3.6_
  - [x] 3.2 CalendarHeaderView 구현 (CalendarView.swift 내부 private view)
    - 연월 표시 ("yyyy년 M월" 형식) + 이전/다음 월 이동 버튼
    - 접근성 라벨: "이전 달", "다음 달"
    - _Requirements: 2.2, 2.3, 2.4, 8.4_
  - [x] 3.3 CalendarGridView 구현 (CalendarView.swift 내부 private view)
    - 7열(일~토) 요일 헤더 + LazyVGrid 날짜 그리드
    - 오늘 날짜 강조 (accent 색상 원형 배경)
    - 선택 날짜 그라데이션 원형 배경 (스케일+페이드 애니메이션)
    - Dot Indicator: 날짜별 할 일 우선순위 색상 점 최대 3개, 완료만 있으면 회색
    - 날짜 셀 접근성 라벨: "M월 d일, 할 일 N개"
    - daysInMonth(), makeDate(day:) 헬퍼 함수 (CustomDatePicker 패턴 참고)
    - _Requirements: 2.1, 2.5, 2.6, 2.7, 2.8, 3.1, 8.2, 8.3_
  - [ ]* 3.4 Property 테스트: Dot Indicator 우선순위 색상 및 최대 개수
    - **Property 2: Dot Indicator 우선순위 색상 및 최대 개수**
    - dotColors(for:) 결과가 0~3개 범위이며 미완료 할 일 우선순위 색상과 일치 검증
    - **Validates: Requirements 2.6, 2.7**
  - [ ]* 3.5 Property 테스트: 완료된 할 일만 존재 시 회색 Dot
    - **Property 3: 완료된 할 일만 존재 시 회색 Dot**
    - 모든 할 일이 완료 상태이고 1개 이상이면 dotColors가 [회색] 하나만 반환 검증
    - **Validates: Requirements 2.8**

- [x] 4. Checkpoint — 캘린더 그리드 및 데이터 연동 확인
  - 모든 테스트가 통과하는지 확인하고, 궁금한 점이 있으면 사용자에게 질문하세요.

- [x] 5. DayTaskListView 및 DayTaskRow 구현
  - [x] 5.1 DayTaskListView 구현 (CalendarView.swift 내부 private view)
    - 선택 날짜의 미완료 할 일 목록 표시
    - 빈 상태: "이 날은 할 일이 없어요 🎉" 메시지
    - 전체 dueDate 할 일 없음 시: "마감일을 설정하면 캘린더에서 확인할 수 있어요 📅" 안내
    - 슬라이드+페이드 인 트랜지션
    - _Requirements: 3.2, 3.4, 8.1_
  - [x] 5.2 DayTaskRow 구현 (CalendarView.swift 내부 private view)
    - 우선순위 컬러바, 제목, 카테고리, 마감 시간 표시
    - 탭 시 TaskDetailView 시트 표시
    - 좌측 스와이프로 완료 처리 (store.toggleComplete)
    - staggered animation (순차적 딜레이)
    - 접근성 라벨: "제목, 우선순위 priority"
    - _Requirements: 3.3, 3.5, 3.7, 4.2, 4.3, 8.2_

- [x] 6. 애니메이션 시스템 통합
  - [x] 6.1 월 이동 슬라이드 트랜지션 적용
    - monthTransitionDirection 기반 .asymmetric transition
    - changeMonth 함수에서 withAnimation(.spring) 적용
    - _Requirements: 2.3, 2.4, 6.5_
  - [x] 6.2 Reduce Motion 접근성 대응
    - `@Environment(\.accessibilityReduceMotion)` 감지
    - Reduce Motion 활성화 시 애니메이션 비활성화 또는 간소화
    - _Requirements: 8.2_
  - [ ]* 6.3 Property 테스트: 월 이동 왕복 (Round-trip)
    - **Property 1: 월 이동 왕복**
    - 다음 달 이동 후 이전 달 이동 시 원래 연/월 값 복원 검증
    - **Validates: Requirements 2.3, 2.4**
  - [ ]* 6.4 Property 테스트: 접근성 라벨 포맷
    - **Property 7: 접근성 라벨 포맷**
    - 생성되는 접근성 라벨이 "M월 d일, 할 일 N개" 형식과 일치 검증
    - **Validates: Requirements 8.3**

- [x] 7. Final Checkpoint — 전체 통합 확인
  - 모든 테스트가 통과하는지 확인하고, 궁금한 점이 있으면 사용자에게 질문하세요.

## Notes

- `*` 표시된 태스크는 선택 사항이며 빠른 MVP를 위해 건너뛸 수 있습니다
- 각 태스크는 추적 가능성을 위해 특정 요구사항을 참조합니다
- Checkpoint에서 점진적 검증을 수행합니다
- Property 테스트는 보편적 정확성 속성을 검증합니다
- 단위 테스트는 특정 예시와 엣지 케이스를 검증합니다
- 하위 컴포넌트는 SRP 원칙에 따라 별도 파일로 분리되어 있습니다 (CalendarHeaderView.swift, CalendarGridView.swift, DayTaskRow.swift, NoDueDateTaskRow.swift, CalendarConstants.swift)
