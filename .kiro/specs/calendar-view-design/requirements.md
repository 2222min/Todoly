# 요구사항 문서: 캘린더 뷰 & 디자인 개선

## 소개

Todoly 앱에 캘린더 기반 할 일 조회 기능을 추가하고, 전체 앱 디자인을 귀엽고 아기자기하며 가독성 높은 스타일로 개선한다. 캘린더 뷰는 기존 탭 구조(MainTabView)에 새 탭으로 추가되며, 날짜별 할 일을 시각적으로 확인할 수 있다. 디자인 개선은 타이포그래피, 컬러 팔레트, 아이콘, 카드 스타일 등 앱 전반에 걸쳐 적용된다.

## 용어 정의

- **Calendar_View**: 월간 캘린더 형태로 할 일을 날짜별로 조회할 수 있는 화면
- **Date_Cell**: 캘린더 그리드 내 개별 날짜를 표시하는 셀
- **Dot_Indicator**: 해당 날짜에 할 일이 존재함을 나타내는 작은 점 표시
- **Day_Task_List**: 캘린더에서 특정 날짜를 선택했을 때 표시되는 해당 날짜의 할 일 목록
- **TodoStore**: 앱의 중앙 상태 관리 객체 (할 일 데이터 CRUD 담당)
- **MainTabView**: 앱 하단 탭 네비게이션 구조
- **TaskCardView**: 할 일 항목을 카드 형태로 표시하는 뷰 컴포넌트
- **Design_System**: 앱 전반에 적용되는 색상, 타이포그래피, 간격, 모서리 반경 등의 시각적 규칙 체계
- **Pastel_Palette**: 부드럽고 따뜻한 파스텔 톤 색상 체계
- **Rounded_Typography**: .rounded 디자인의 둥근 서체 스타일

## 요구사항

### 요구사항 1: 캘린더 탭 추가

**사용자 스토리:** 사용자로서, 하단 탭에서 캘린더 탭을 선택하여 캘린더 화면에 진입하고 싶다. 그래야 날짜 기반으로 할 일을 관리할 수 있다.

#### 수용 기준

1. WHEN 사용자가 하단 탭 바에서 캘린더 탭을 탭하면, THE MainTabView SHALL Calendar_View 화면을 표시한다
2. THE MainTabView SHALL 기존 Tasks, Categories, Trash 탭과 함께 Calendar 탭을 두 번째 위치(Tasks 다음)에 배치한다
3. THE Calendar 탭 SHALL 캘린더 아이콘(calendar)과 "Calendar" 라벨을 표시한다
4. WHEN 앱이 실행되면, THE MainTabView SHALL Tasks 탭을 기본 선택 상태로 표시한다

### 요구사항 2: 월간 캘린더 표시

**사용자 스토리:** 사용자로서, 월간 캘린더를 보고 어떤 날짜에 할 일이 있는지 한눈에 파악하고 싶다. 그래야 일정을 효율적으로 관리할 수 있다.

#### 수용 기준

1. THE Calendar_View SHALL 현재 월의 캘린더 그리드를 7열(일~토) 형태로 표시한다
2. THE Calendar_View SHALL 캘린더 상단에 현재 연도와 월을 "yyyy년 M월" 형식으로 표시한다
3. WHEN 사용자가 좌측 화살표를 탭하면, THE Calendar_View SHALL 이전 월의 캘린더를 표시한다
4. WHEN 사용자가 우측 화살표를 탭하면, THE Calendar_View SHALL 다음 월의 캘린더를 표시한다
5. THE Date_Cell SHALL 오늘 날짜를 강조 표시(accent 색상 원형 배경)로 구분한다
6. WHEN 할 일의 dueDate가 특정 날짜에 해당하면, THE Date_Cell SHALL 해당 날짜 아래에 Dot_Indicator를 표시한다
7. THE Dot_Indicator SHALL 할 일의 우선순위 색상(high: 빨강, medium: 주황, low: 파랑)을 반영하여 최대 3개까지 표시한다
8. WHEN 해당 날짜에 완료된 할 일만 존재하면, THE Dot_Indicator SHALL 회색으로 표시한다

### 요구사항 3: 날짜 선택 및 할 일 목록 표시

**사용자 스토리:** 사용자로서, 캘린더에서 특정 날짜를 탭하여 해당 날짜의 할 일 목록을 확인하고 싶다. 그래야 날짜별 할 일을 상세히 볼 수 있다.

#### 수용 기준

1. WHEN 사용자가 Date_Cell을 탭하면, THE Calendar_View SHALL 해당 날짜를 선택 상태(accent 그라데이션 원형 배경)로 표시한다
2. WHEN 날짜가 선택되면, THE Day_Task_List SHALL 캘린더 하단에 해당 날짜의 미완료 및 완료 할 일 목록을 표시한다
3. THE Day_Task_List SHALL 각 할 일 항목을 TodoCheckbox(미완료: 빈 원 스트로크, 완료: 녹색 #34C759 filled + 체크마크, 히트 영역 44x44), 우선순위 컬러바, 제목, 카테고리, 마감 시간 정보와 함께 표시한다
4. WHEN 선택된 날짜에 할 일이 없으면, THE Day_Task_List SHALL "이 날은 할 일이 없어요 🎉" 빈 상태 메시지를 표시한다
5. WHEN 사용자가 Day_Task_List의 할 일 항목을 탭하면, THE Calendar_View SHALL TaskDetailView를 시트로 표시한다
6. WHEN Calendar_View가 처음 표시되면, THE Calendar_View SHALL 오늘 날짜를 기본 선택 상태로 설정한다
7. WHEN 사용자가 Day_Task_List의 할 일 항목의 체크박스를 탭하면, THE Calendar_View SHALL 해당 할 일의 완료/미완료 토글 처리를 수행한다 (스와이프 완료 제거, 체크박스만 사용)
8. THE Day_Task_List SHALL 완료된 항목을 미완료와 동일한 DayTaskRow 카드 UI로 표시하되, 체크박스 on 상태 + 색상 처리 + 투명도 0.55를 적용한다
9. THE Day_Task_List SHALL 완료된 항목에 completedAt 시간을 "오전/오후 H:mm 완료" 형식으로 표시한다

### 요구사항 4: 캘린더 뷰 데이터 연동

**사용자 스토리:** 사용자로서, 캘린더에서 보는 할 일 데이터가 메인 리스트와 동일하게 실시간 반영되길 원한다. 그래야 데이터 불일치 없이 앱을 사용할 수 있다.

#### 수용 기준

1. THE Calendar_View SHALL TodoStore의 incomplete 및 completed 배열에서 dueDate가 있는 할 일을 캘린더에 표시한다
2. WHEN TodoStore의 데이터가 변경되면(추가, 완료, 삭제), THE Calendar_View SHALL 변경 사항을 즉시 반영한다
3. WHEN 사용자가 Calendar_View에서 할 일을 완료 처리하면, THE TodoStore SHALL 해당 할 일의 isCompleted 상태를 true로 변경하고 completedAt을 현재 시각으로 설정한다
4. THE Calendar_View SHALL isDeleted가 true인 할 일을 표시하지 않는다
5. THE Calendar_View SHALL dueDate 있는 완료 할일을 dueDate 기준으로 표시한다
6. THE Calendar_View SHALL dueDate 없는 완료 할일을 completedAt 기준으로 표시한다

### 요구사항 5: 디자인 시스템 — 컬러 팔레트 개선

**사용자 스토리:** 사용자로서, 앱의 색상이 귀엽고 따뜻한 파스텔 톤으로 통일되길 원한다. 그래야 앱 사용 시 기분 좋은 경험을 할 수 있다.

#### 수용 기준

1. THE Design_System SHALL 배경색으로 따뜻한 크림 톤(FFF8F2 계열)을 유지한다
2. THE Design_System SHALL 주요 액센트 색상으로 코랄(FF8A65), 라벤더(A78BFA), 민트(6DD5C8) 파스텔 조합을 사용한다
3. THE Design_System SHALL 카드 배경에 순백(FFFFFF)을 사용하고 부드러운 그림자(opacity 0.06, radius 16)를 적용한다
4. THE Design_System SHALL 우선순위 색상을 부드러운 톤(high: FF6B6B, medium: FFAB5E, low: 5B9BF5)으로 유지한다
5. THE Design_System SHALL 텍스트 색상을 3단계 계층(primary: 2D2D2D, secondary: 6B6B6B, tertiary: B0B0B0)으로 구분한다

### 요구사항 6: 디자인 시스템 — 타이포그래피 및 카드 스타일 개선

**사용자 스토리:** 사용자로서, 앱의 글꼴과 카드 디자인이 둥글고 아기자기하며 가독성이 좋길 원한다. 그래야 할 일 내용을 편하게 읽을 수 있다.

#### 수용 기준

1. THE Design_System SHALL 모든 텍스트에 .rounded 디자인 서체를 적용한다
2. THE Design_System SHALL 제목 텍스트를 15pt Bold, 보조 텍스트를 11~12pt Medium, 라벨 텍스트를 9~10pt Medium으로 설정한다
3. THE TaskCardView SHALL 24pt 모서리 반경의 둥근 카드 형태를 유지한다
4. THE TaskCardView SHALL 카테고리 라벨, 마감일 배지, 제목, 메모를 명확한 계층 구조로 표시한다
5. THE Design_System SHALL 버튼과 인터랙티브 요소에 부드러운 스프링 애니메이션(response: 0.35, dampingFraction: 0.7)을 적용한다
6. THE Design_System SHALL 배지(마감일, 카테고리)에 Capsule 형태와 파스텔 배경색을 적용한다

### 요구사항 7: 하단 탭 바 디자인 개선

**사용자 스토리:** 사용자로서, 하단 탭 바가 귀엽고 직관적이며 현재 선택된 탭을 명확히 알 수 있길 원한다. 그래야 앱 내비게이션이 편리하다.

#### 수용 기준

1. THE MainTabView SHALL 선택된 탭에 그라데이션 원형 배경(accent1 → FF6B6B)과 흰색 아이콘을 표시한다
2. THE MainTabView SHALL 선택되지 않은 탭에 회색(txt3) 아이콘을 표시한다
3. THE MainTabView SHALL 탭 전환 시 부드러운 스프링 애니메이션을 적용한다
4. THE MainTabView SHALL 탭 라벨을 10pt .rounded 서체로 표시한다
5. THE MainTabView SHALL 하단 탭 바에 부드러운 상단 그림자(opacity 0.04, radius 16)를 적용한다

### 요구사항 8: 캘린더 뷰 빈 상태 및 접근성

**사용자 스토리:** 사용자로서, dueDate가 설정된 할 일이 하나도 없을 때 안내 메시지를 보고 싶다. 그래야 캘린더 기능의 사용법을 이해할 수 있다.

#### 수용 기준

1. WHEN dueDate가 설정된 할 일이 전체 데이터에 하나도 없으면, THE Calendar_View SHALL "마감일을 설정하면 캘린더에서 확인할 수 있어요 📅" 안내 메시지를 캘린더 하단에 표시한다
2. THE Calendar_View SHALL 모든 인터랙티브 요소에 VoiceOver 접근성 라벨을 제공한다
3. THE Calendar_View SHALL 날짜 셀에 "M월 d일, 할 일 N개" 형식의 접근성 라벨을 제공한다
4. THE Calendar_View SHALL 월 이동 버튼에 "이전 달", "다음 달" 접근성 라벨을 제공한다

### 요구사항 9: 캘린더 "날짜 미지정" 섹션 (변경: 2026-04-26)

**사용자 스토리:** 사용자로서, 마감일이 지정되지 않은 할 일도 캘린더 화면에서 확인하고 싶다. 그래야 모든 할 일을 한 곳에서 관리할 수 있다.

#### 수용 기준

1. THE Calendar_View SHALL 캘린더 하단에 "📌 날짜 미지정" 접이식 섹션을 표시한다
2. THE "날짜 미지정" 섹션 SHALL dueDate가 nil인 미완료 할일만 표시한다
3. THE "날짜 미지정" 섹션 SHALL 날짜 선택과 무관하게 항상 표시한다
4. THE "날짜 미지정" 섹션 SHALL 접기/펼치기가 가능하며 기본 상태는 펼침이다
5. WHEN 할 일에 날짜가 지정되면, THE "날짜 미지정" 섹션에서 해당 할 일이 제거되고 해당 날짜로 이동한다
6. WHEN "날짜 미지정" 할 일이 완료되면, THE Calendar_View SHALL completedAt 날짜의 완료됨 섹션에 해당 할 일을 표시한다
7. WHEN "날짜 미지정" 할 일이 삭제되면, THE Calendar_View SHALL 해당 할 일을 휴지통으로 이동한다

### 요구사항 10: 캘린더 완료 체크 및 완료 시간 표시 (변경: 2026-04-26)

**사용자 스토리:** 사용자로서, 캘린더에서 직접 할 일을 완료/미완료 처리하고 완료 시간을 확인하고 싶다. 그래야 별도 화면 이동 없이 빠르게 관리할 수 있다.

#### 수용 기준

1. THE Calendar_View SHALL 체크박스 탭으로 할 일 완료/미완료 토글을 지원한다 (스와이프 완료 제거)
2. THE Calendar_View SHALL TodoCheckbox 공통 컴포넌트를 사용한다 (할일 탭과 동일)
3. THE TodoCheckbox SHALL 미완료 시 빈 원 스트로크, 완료 시 녹색(#34C759) filled + 체크마크를 표시한다
4. THE TodoCheckbox SHALL 히트 영역 44x44를 보장한다
5. THE Calendar_View SHALL 완료 처리 시 completedAt 시간을 "오전/오후 H:mm 완료" 형식으로 표시한다
6. THE Calendar_View SHALL 완료 항목을 미완료와 동일한 DayTaskRow 카드 UI로 표시하되 투명도 0.55를 적용한다
