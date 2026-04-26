# 📐 Todoly 텍스트 처리 가이드 (개발자용)

## 목적
각 화면의 텍스트 요소가 긴 내용일 때 **truncate(말줄임)** 할지 **multiline(여러 줄)** 로 표시할지 정의합니다.
개발 시 이 문서를 기준으로 구현해주세요.

---

## 공통 규칙

| 규칙 | 설명 |
|------|------|
| Truncate 표시 | `...` (말줄임표) |
| Multiline 최대 | 별도 명시 없으면 제한 없음 (자동 확장) |
| 최소 터치 타겟 | 44x44pt (iOS HIG) |
| 폰트 | Inter (전체 통일) |

---

## 1. Main List (메인 할 일 목록)

### 1-1. 미완료 카드 (Bento 2열 그리드)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 카테고리 라벨 | **Truncate** | 1줄 | 10pt Medium | "WORK", "SHOPPING" 등 짧으므로 거의 잘리지 않음 |
| 마감일 배지 | **Truncate** | 1줄 | 9pt Bold | "OVERDUE", "TODAY", "D-5" 고정 텍스트 |
| 할 일 제목 | **Truncate** | 1줄 | 15~16pt Bold | 카드 너비 제한으로 반드시 1줄 truncate. 전체 제목은 상세 화면에서 확인 |
| 할 일 메모 | **Multiline** | 최대 2줄 | 12pt Medium | 2줄 초과 시 truncate. `lineLimit(2)` + `.truncationMode(.tail)` |
| 완료 시간 | **Truncate** | 1줄 | 11pt Regular | "Personal • 08:00 AM" |

```swift
// SwiftUI 예시
Text(todo.title)
    .font(.system(size: 15, weight: .bold))
    .lineLimit(1)
    .truncationMode(.tail)

Text(todo.memo ?? "")
    .font(.system(size: 12, weight: .medium))
    .lineLimit(2)
    .truncationMode(.tail)
    .foregroundColor(.gray)
```

### 1-2. 완료 항목 (리스트 형태)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 할 일 제목 | **Truncate** | 1줄 | 14pt Regular + 취소선 | 긴 제목은 말줄임 |
| 부가 정보 | **Truncate** | 1줄 | 11pt Regular | "Work • 10:30 AM" |

### 1-3. Quick Add 입력

| 요소 | 처리 | 비고 |
|------|------|------|
| Placeholder | **Truncate** | 1줄 고정 |
| 사용자 입력 | **Truncate** | 1줄. 엔터 시 추가 실행 |

### 1-4. Hero 인사말

| 요소 | 처리 | 비고 |
|------|------|------|
| "Hello, Planner. 👋" | **Truncate** | 1줄. 사용자 이름이 길면 truncate |
| 부제 | **Truncate** | 1줄 |

---

## 2. Task Detail (할 일 상세)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 제목 | **Multiline** | 최대 3줄 | 32pt Black | 긴 제목 허용. 3줄 초과 시 truncate |
| Notes 메모 | **Multiline** | 제한 없음 | 13pt Regular | 자동 높이 확장. ScrollView 내부 배치 |
| 마감일 | **Truncate** | 1줄 | 20pt Bold | "04/28/2026" 고정 포맷 |
| 우선순위 칩 | **Truncate** | 1줄 | 12pt Semi Bold | "High", "Medium", "Low" 고정 |
| 카테고리 칩 | **Truncate** | 1줄 | 13pt Medium | 칩 너비 자동. 긴 이름은 truncate |
| 알림 정보 | **Truncate** | 1줄 | 14pt Semi Bold | "1시간 전 · 오전 9:00" |
| 삭제 버튼 | **Truncate** | 1줄 | 14pt Medium | 고정 텍스트 |

```swift
// Notes - 자동 확장
TextEditor(text: $memo)
    .font(.system(size: 13))
    .frame(minHeight: 120)  // 최소 높이 보장
    // 높이 제한 없음 - 내용에 따라 자동 확장

// 제목 - 최대 3줄
TextField("제목", text: $title)
    .font(.system(size: 32, weight: .black))
    .lineLimit(1...3)
```

---

## 3. Trash (휴지통)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 안내 배너 텍스트 | **Multiline** | 최대 2줄 | 11pt Regular | 화면 너비에 따라 줄바꿈 허용 |
| 할 일 제목 | **Truncate** | 1줄 | 16pt Bold | 복원/삭제 버튼 영역 확보 위해 truncate |
| 삭제 날짜 | **Truncate** | 1줄 | 11pt Regular | "삭제일: 4월 23일" |
| 하단 안내 메시지 | **Multiline** | 2줄 | 13pt Medium | 고정 텍스트 |

```swift
// 할 일 제목 - 버튼 영역 확보
Text(todo.title)
    .font(.system(size: 16, weight: .bold))
    .lineLimit(1)
    .truncationMode(.tail)
    .frame(maxWidth: .infinity, alignment: .leading)
    // 우측에 복원+삭제 버튼 공간 최소 120pt 확보
```

---

## 4. Empty State (빈 상태)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 메인 타이틀 | **Truncate** | 1줄 | 24pt Bold | 고정 텍스트 |
| 서브 메시지 | **Multiline** | 2줄 | 16pt Regular | 고정 텍스트, 중앙 정렬 |
| CTA 버튼 | **Truncate** | 1줄 | 16pt Semi Bold | 고정 텍스트 |

---

## 5. Categories (카테고리 관리)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 카테고리 이름 | **Truncate** | 1줄 | 16pt Semi Bold | 더보기(⋯) 버튼 영역 확보 |
| 할 일 수 | **Truncate** | 1줄 | 12pt Regular | "3개 할 일" |
| 힌트 메시지 | **Multiline** | 2줄 | 13pt Regular | 고정 텍스트 |

---

## 6. Search (검색)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 검색 입력 | **Truncate** | 1줄 | 15pt Medium | 단일 라인 입력 |
| 최근 검색어 칩 | **Truncate** | 1줄 | 13pt Regular | 칩 너비 자동, 최대 120pt |
| 검색 결과 제목 | **Truncate** | 1줄 | 15pt Bold | 메인 리스트와 동일 |
| 검색 결과 부가정보 | **Truncate** | 1줄 | 11pt Regular | |
| 결과 수 안내 | **Truncate** | 1줄 | 12pt Medium | "\"보고서\"에 대한 검색 결과 1건" |

---

## 7. Login (로그인)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 앱 타이틀 | **Truncate** | 1줄 | 36pt Black | 고정 |
| 서브 메시지 | **Truncate** | 1줄 | 15pt Medium | 고정 |
| 로그인 버튼 텍스트 | **Truncate** | 1줄 | 16pt Semi Bold | 고정 |
| 약관 안내 | **Multiline** | 2줄 | 11pt Regular | 중앙 정렬 |

---

## 8. Reminder Setting (알림 설정)

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 시트 타이틀 | **Truncate** | 1줄 | 20pt Bold | 고정 |
| 할 일 컨텍스트 | **Truncate** | 1줄 | 13pt Regular | 제목이 길면 truncate |
| 프리셋 칩 | **Truncate** | 1줄 | 13pt Medium | 고정 텍스트 |
| 날짜/시간 값 | **Truncate** | 1줄 | 15pt Semi Bold | |
| 사운드 값 | **Truncate** | 1줄 | 13pt Medium | |

---

## 9. UI Components (Undo 토스트 / 스와이프 / 다이얼로그)

### Undo 토스트
| 요소 | 처리 | 최대 | 비고 |
|------|------|------|------|
| 삭제 메시지 | **Truncate** | 1줄 | "\"[제목]\" 삭제됨" - 제목 길면 truncate |
| 되돌리기 버튼 | **Truncate** | 1줄 | 고정 |

### 스와이프 삭제
| 요소 | 처리 | 비고 |
|------|------|------|
| 삭제 라벨 | **Truncate** | 고정 "삭제" |

### 삭제 확인 다이얼로그
| 요소 | 처리 | 최대 | 비고 |
|------|------|------|------|
| 타이틀 | **Truncate** | 1줄 | 고정 |
| 설명 | **Multiline** | 2줄 | 고정 텍스트 |
| 버튼 | **Truncate** | 1줄 | 고정 |

---

## 10. 공통 컴포넌트

### Bottom Navigation Bar
| 요소 | 처리 | 비고 |
|------|------|------|
| 탭 라벨 | **Truncate** | 1줄. "할 일", "캘린더", "카테고리", "휴지통" 고정 |

### Header
| 요소 | 처리 | 비고 |
|------|------|------|
| 앱 타이틀 "Todoly" | **Truncate** | 고정 |
| 화면 타이틀 | **Truncate** | 1줄 |

---

## 11. Calendar (캘린더)

### 11-1. 캘린더 헤더

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 연월 표시 | **Truncate** | 1줄 | 20pt Bold .rounded | "2026년 4월" 고정 포맷 |
| 월 이동 버튼 | — | — | — | ◀ ▶ 아이콘만 |

### 11-2. 날짜별 할 일 목록

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 섹션 헤더 | **Truncate** | 1줄 | 15pt Bold .rounded | "📋 4월 10일 할 일" |
| 할 일 제목 | **Truncate** | 1줄 | 14pt Bold .rounded | 카드 내 1줄 |
| 메타 정보 | **Truncate** | 1줄 | 10pt Medium .rounded | "업무 · 14:00" 또는 "오전 8:00 완료" |
| 빈 상태 메시지 | **Multiline** | 2줄 | 14pt Medium .rounded | "이 날은 할 일이 없어요 🎉" |
| 안내 메시지 | **Multiline** | 2줄 | 13pt Medium .rounded | "마감일을 설정하면 캘린더에서 확인할 수 있어요 📅" |

### 11-3. 날짜 미지정 섹션

| 요소 | 처리 | 최대 | 폰트 | 비고 |
|------|------|------|------|------|
| 섹션 헤더 | **Truncate** | 1줄 | 14pt Semibold .rounded | "📌 날짜 미지정" |
| 할 일 제목 | **Truncate** | 1줄 | 13pt Semibold .rounded | 카드 내 1줄 |
| 카테고리 | **Truncate** | 1줄 | 10pt Medium .rounded | 카테고리명 |

---

## 핵심 요약 (빠른 참조)

### Truncate 해야 하는 것 (1줄 고정)
- 카드 제목 (메인 리스트, 검색 결과, 휴지통, 캘린더)
- 카테고리 라벨, 마감일 배지
- Quick Add 입력/placeholder
- 완료 항목 제목
- 알림 정보 텍스트
- 로그인 버튼 텍스트
- 토스트 메시지
- 모든 칩(chip) 텍스트
- 캘린더 연월 표시, 섹션 헤더, 메타 정보

### Multiline 허용하는 것
- Task Detail 제목 (최대 3줄)
- Task Detail Notes/메모 (제한 없음, 자동 확장)
- 카드 메모/설명 (최대 2줄)
- 안내 배너 텍스트 (최대 2줄)
- 빈 상태 서브 메시지 (2줄)
- 약관 안내 (2줄)
- 삭제 다이얼로그 설명 (2줄)
- 캘린더 빈 상태/안내 메시지 (2줄)
