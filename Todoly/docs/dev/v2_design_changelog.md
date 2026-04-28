# Todoly v2 — 디자인 변경 이력 (Figma 반영 필요)

> 코드 구현 완료. Figma 디자인 파일에 아래 변경사항 반영 필요.

---

## 1. CTA 버튼 통일 (3개 화면)

### 변경 전
- AddTaskSheet: 헤더 우측 "추가" 캡슐 버튼
- TaskDetailView: 헤더 우측 "저장" 캡슐 버튼
- CategoryAddSheet: 헤더 우측 "추가/저장" 캡슐 버튼

### 변경 후
- 3개 화면 모두 헤더에서 액션 버튼 제거
- 하단 고정 풀 너비 CTA 버튼 (RoundedRect 16pt)
- AddTaskSheet: "추가하기" (txt1 배경)
- TaskDetailView: "저장하기" (txt1 배경)
- CategoryAddSheet: "추가하기/저장하기" (accent1 배경)
- 비활성 시 gray opacity 0.4

---

## 2. 카테고리 미리보기 위치

### 변경 전
- CategoryAddSheet: 이름 → 색상 → 이모지 → 미리보기 (최하단)

### 변경 후
- CategoryAddSheet: 미리보기 (최상단) → 이름 → 색상 → 이모지

---

## 3. 키보드 UX (3개 화면)

- 키보드 올라올 때 ScrollView 하단으로 자동 스크롤
- 영역 밖 터치 시 키보드 dismiss
- @FocusState 기반 포커스 관리

---

## 4. 할 일 행 인터랙션 변경 (전체)

### 변경 전
- 행 텍스트 영역 탭 → 상세 화면 진입
- 체크박스만 탭 → 완료 토글

### 변경 후
- 행 전체 탭 → 완료 토글 (체크 on/off)
- 우측 연필(✏️) 버튼 → 상세 화면 진입
- 적용 대상: TaskCardView, PeriodTaskCardView, CompletedRow, DayTaskRow, CompletedDayTaskRow, NoDueDateTaskRow

### 수정 버튼 스펙
- 아이콘: SF Symbol "pencil"
- 크기: 32~36pt 원형
- 배경: gray opacity 0.08
- 색상: txt3

---

## 5. 할 일 탭 — 통합 리스트

### 변경 전
```
[미완료 섹션]  헤더 "미완료 3"
[연속 할일 섹션]  헤더 "연속 할일 1"
[오늘 완료됨 섹션]  헤더 "오늘 완료됨 2"
```

### 변경 후
```
[오늘 할 일]  단일 헤더 + 미완료 카운트 배지
  미완료 일반 (우선순위순)
  연속 할일 미완료
  연속 할일 완료 (opacity 0.55)
  완료 일반 (opacity 0.55 + 취소선 + 완료 시간)
```

### TaskCardView isCompleted 모드
- opacity: 0.55
- 제목: txt3 색상 + 취소선
- 체크박스: filled green
- 서브텍스트: 완료 시간 표시 (배지 대신)

### 날짜별 헤더
- 오늘: "오늘 할 일"
- 다른 날: "M월 d일 할 일"

---

## 6. WeeklyCalendarStrip dot 로직 수정

### 변경 전
- dot = `store.todos(for: date)` + 오늘이면 마감일 없는 할 일 추가

### 변경 후
- dot = 미완료 일반 + 연속 할일 + 완료 (리스트 표시와 완전 일치)
- "N개 남음" = 미완료 일반 + 연속 할일 미완료 (연속 할일 포함)

---

## 7. 캘린더 CompletedDayTaskRow 수정 버튼 추가

- 기존: 체크박스 + 텍스트만
- 변경: 우측에 연필 수정 버튼 추가 (옵셔널, onEdit 콜백)
