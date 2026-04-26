---
inclusion: auto
---

# 🎨 Figma 디자인 동기화 규칙

## 핵심 원칙
UI/디자인 관련 변경이 발생하면 반드시 Figma 디자인도 함께 생성 또는 업데이트한다.

## 트리거 조건
아래 상황에서 Figma 작업을 자동으로 수행한다:

1. **새 화면/기능 추가 시** → Figma에 해당 화면 디자인 생성
2. **기존 UI 수정 시** → Figma에서 해당 화면 업데이트
3. **디자인 리뷰/확정 시** → Figma 디자인 최종 반영
4. **코드 구현 완료 시** → 구현된 화면을 Figma에 캡처/동기화

## 실행 규칙
- 사용자가 별도로 요청하지 않아도, UI 변경이 포함된 작업이면 Figma 생성/업데이트를 포함한다
- 기존 Figma 파일에 업데이트한다 (아래 Figma 파일 정보 참조)
- 디자인 시스템 컴포넌트가 있으면 `mcp_figma_search_design_system`으로 재사용한다
- 새 화면은 해당 기능의 페이지에 추가한다

## 작업 완료 보고
Figma 작업 완료 시 사용자에게 링크와 함께 알려준다:
> "Figma 디자인도 [생성/업데이트]했어요. [링크]"

---

## 📁 Figma 파일 정보

### 메인 Todoly 디자인 파일
- **파일 URL**: https://www.figma.com/design/KAtwxMVjOZVQmM5DOvrEev
- **fileKey**: `KAtwxMVjOZVQmM5DOvrEev`

### 페이지 구조

| 페이지 | 내용 | 프레임 목록 |
|--------|------|------------|
| Page 1 | v5 Todoly 전체 디자인 | ✨ v5 Color Palette & Style Guide, ✨ v5 Splash, ✨ v5 Login, ✨ v5 Empty State, ✨ v5 Main List, ✨ v5 Trash, ✨ v5 Categories, ✨ v5 Task Detail, ✨ v5 Search (3가지 상태), ✨ v5 Add Task Sheet, ✨ v5 UI Components, ✨ v5 Category Add Sheet, ✨ v5 Custom DatePicker (Full Page), ✨ v5 Category Filter List, ✨ v5 Category Icons, ✨ v5 App Icon (Liquid Glass), ✨ v5 Calendar View, ✨ v5 Calendar View (with No Date Section), ✨ v5 Calendar View - Empty, ✨ v5 Alarm View |
| Legacy (Non-Todoly) | 다른 앱 디자인 (참고용) | 빠른 기록, 통장 관리, 로그인, 설정, 회원가입, 커플 연결, 통장 추가/수정, 스플래시, 온보딩, 거래 내역, 대시보드 |

### 디자인 시스템 (v5)

| 토큰 | 값 | 용도 |
|------|-----|------|
| Brand BG | #FFF8F2 | 앱 배경색 |
| Soft Card | #FFF5EE | 부드러운 카드 배경 |
| Card BG | #FFFFFF | 카드 배경 |
| Accent Coral | #FF8A65 | 주요 액센트 |
| Accent Lavender | #A78BFA | 보조 액센트 |
| Accent Mint | #6DD5C8 | 보조 액센트 |
| Priority High | #FF6B6B | 높은 우선순위 |
| Priority Medium | #FFAB5E | 중간 우선순위 |
| Priority Low | #5B9BF5 | 낮은 우선순위 |
| Text Primary | #2D2D2D | 주요 텍스트 |
| Text Secondary | #6B6B6B | 보조 텍스트 |
| Text Tertiary | #B0B0B0 | 3차 텍스트 |
| Corner Radius | 24px (카드), 16px (입력) | 모서리 반경 |
| Shadow | opacity 0.06, blur 16px | 카드 그림자 |
| Font | SF Pro Rounded (iOS) / Inter Rounded | 서체 |

---

## 🗺️ 화면별 Figma 노드 맵

> 피그마 업데이트 시 메타데이터 조회 없이 바로 접근할 수 있도록 주요 노드 ID를 기록한다.
> 화면 추가/구조 변경 시 이 맵도 함께 업데이트한다.

### 프레임 목록 (최상위)

| 화면 | nodeId | Figma URL | 코드 파일 |
|------|--------|-----------|----------|
| Color Palette & Style Guide | `38:2` | `?node-id=38-2` | — |
| Splash | `41:2` | `?node-id=41-2` | `Features/Splash/SplashView.swift` |
| Login | `41:16` | `?node-id=41-16` | `Features/Auth/LoginView.swift` |
| Empty State | `42:2` | `?node-id=42-2` | `Features/TaskList/MainListView.swift` |
| Main List | `42:23` | `?node-id=42-23` | `Features/TaskList/MainListView.swift` |
| Trash | `43:2` | `?node-id=43-2` | `Features/Trash/TrashView.swift` |
| Categories | `43:23` | `?node-id=43-23` | `Features/Category/CategoryListView.swift` |
| Task Detail | `43:54` | `?node-id=43-54` | `Features/TaskDetail/TaskDetailView.swift` |
| Search | `89:2` | `?node-id=89-2` | `Features/Search/SearchView.swift` |
| Add Task Sheet | `44:20` | `?node-id=44-20` | `Features/TaskDetail/AddTaskSheet.swift` |
| UI Components | `44:58` | `?node-id=44-58` | `Core/Components/` |
| Category Add Sheet | `46:2` | `?node-id=46-2` | `Features/Category/CategoryAddSheet.swift` |
| Custom DatePicker | `46:43` | `?node-id=46-43` | `Features/Calendar/CustomDatePicker.swift` |
| Category Filter List | `46:116` | `?node-id=46-116` | `Features/Category/CategoryFilterView.swift` |
| Category Icons | `65:2` | `?node-id=65-2` | `Features/Category/CategoryAddSheet.swift` |
| App Icon (Liquid Glass) | `70:2` | `?node-id=70-2` | — |
| Calendar View | `52:2` | `?node-id=52-2` | `Features/Calendar/CalendarView.swift` |
| Calendar View (No Date Section) | `73:2` | `?node-id=73-2` | `Features/Calendar/CalendarView.swift` |
| Calendar View - Empty | `52:86` | `?node-id=52-86` | `Features/Calendar/CalendarView.swift` |
| Alarm View | `85:2` | `?node-id=85-2` | `Features/Alarm/AlarmView.swift` |

### 주요 하위 노드 (자주 수정되는 컴포넌트)

#### Search (`89:2` — 3가지 상태 프레임으로 분리)
| 요소 | nodeId | 프레임 이름 | 설명 |
|------|--------|-----------|------|
| 초기 상태 | `89:2` | ✨ v5 Search | 최근 검색어 칩 표시, 검색바 상단 |
| 검색 결과 | `89:22` | ✨ v5 Search - Results | 검색 결과 카드 표시 |
| 빈 결과 | `89:40` | ✨ v5 Search - Empty Result | 결과 없음 상태 |

#### Calendar View (`52:2`)
| 요소 | nodeId | 설명 |
|------|--------|------|
| Header BG | `52:3` | 상단 헤더 배경 |
| Month Title | `52:5` | "2026년 4월" |
| Prev Month Button | `54:2` | ◀ 버튼 영역 |
| Next Month Button | `54:3` | ▶ 버튼 영역 |
| Day Header | `52:57` | "📋 4월 10일 할 일" |
| Task - 보고서 | `52:58` | 태스크 카드 (체크박스 `63:3`, 제목 `63:4`, 메타 `63:5`) |
| Task - 장보기 | `52:64` | 태스크 카드 (체크박스 `63:7`, 제목 `63:8`, 메타 `63:9`) |
| Task - 책 읽기 | `52:70` | 태스크 카드 (체크박스 `63:11`, 제목 `63:12`, 메타 `63:13`) |
| 완료됨 라벨 | `57:2` | "완료됨" |
| Completed Task | `67:2` | 완료 카드 — 미완료와 동일 구조 (체크박스filled `67:4`, 제목 `67:6`, 메타 `67:7`, opacity 0.55) |
| Tab Bar | `52:76` | 하단 탭 바 |

#### Main List (`42:23`)
| 요소 | nodeId | 설명 |
|------|--------|------|
| Header BG | `42:24` | 상단 헤더 배경 |
| App Title | `42:26` | "Todoly" |
| Search Button | `42:27` | 🔍 버튼 |
| Quick Add Bar | `42:31` | 빠른 추가 입력 바 |
| List Card - 보고서 | `58:2` | 태스크 카드 (우선순위바 `58:3`, 체크박스 `58:4`) |
| List Card - 장보기 | `58:7` | 태스크 카드 |
| List Card - 책 읽기 | `58:12` | 태스크 카드 |
| Tab Bar | `53:12` | 하단 탭 바 |

#### Task Detail (`43:54`)
| 요소 | nodeId | 설명 |
|------|--------|------|
| Close Button | `43:56` | ✕ 닫기 |
| Save Button | `43:57` | 저장 버튼 영역 |
| Title | `43:59` | 제목 텍스트 |
| Memo Section | `43:60` | 메모 영역 |
| Due Date Section | `43:63` | 마감일 영역 |
| Priority Section | `43:66` | 우선순위 영역 |
| Reminder Section | `43:75` | 알림 영역 |
| Category Section | `43:79`~`43:86` | 카테고리 칩들 |
| Delete Button | `43:87` | 삭제 버튼 |

#### Alarm View (`85:2`)
| 요소 | nodeId | 설명 |
|------|--------|------|
| 알림 아이콘 | `85:4` | 🔔 아이콘 |
| 타이틀 | `85:5` | "Todoly 알림" |
| 할 일 제목 | `85:6` | 할 일 제목 텍스트 |
| 서브 메시지 | `85:7` | "마감 시간입니다!" |
| 끄기 버튼 | `85:8` | "알림 끄기" 버튼 |

### 참고: 별도 생성된 파일 (통합 전)
- **Todoly - Calendar View & Design System**: `x2ej6W1sHOYO1LyZcyd5Fe` (이 파일의 내용은 메인 파일로 통합됨)
