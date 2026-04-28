# Todoly v2 — 위젯 + Apple Watch 디자인 브리프

## UI 디자인 가이드

### 공통 디자인 시스템
- 배경: `brandBg` (#FFF8F2) — 따뜻한 크림색
- 카드: `cardBg` (#FFFFFF)
- 텍스트: `txt1` (#2D2D2D), `txt2` (#6B6B6B), `txt3` (#B0B0B0)
- 우선순위: `priHigh` (#FF6B6B), `priMed` (#FFAB5E), `priLow` (#5B9BF5)
- 폰트: `.system(design: .rounded)` 일관 사용
- 모서리: 16pt radius (위젯 내부 카드)

### 위젯 디자인

#### Small (170×170 pt)
- 상단: "📋 오늘 할 일" 라벨 (13pt, txt2)
- 중앙: 미완료 개수 (40pt bold, txt1)
- 하단: 최우선 할 일 제목 (13pt, txt1) + 우선순위 dot (8pt circle)
- 배경: brandBg → 살짝 그라데이션 (warmGrad1)

#### Medium (364×170 pt)
- 좌측 상단: "📋 오늘 할 일" (15pt semibold)
- 우측 상단: "N개" 배지 (accent1 배경, white 텍스트)
- 리스트: 최대 3행, 각 행 높이 40pt
  - 좌: 체크 원형 버튼 (22pt, Interactive)
  - 중: 제목 (15pt, txt1)
  - 우: 우선순위 dot (8pt)
- 빈 상태: "오늘 할 일이 없어요 🎉" (txt3)

#### Large (364×382 pt)
- 미완료 섹션: 최대 5행
- 구분선: 1pt, txt3 opacity 0.3
- 완료 섹션: "✅ 완료 N개" 헤더 + 최대 2행
  - 완료 항목: 취소선 + txt3 색상
- 연속 할일: "Day N" 배지 (accent2 배경, 작은 캡슐)

### Watch 디자인

#### 메인 화면
- NavigationStack 제목: "오늘 할 일"
- 각 행: 
  - 좌: 원형 체크 버튼 (탭 → 완료 토글 + 햅틱)
  - 중: 제목 (16pt) + 우선순위 라벨 (12pt, 색상)
- 빈 상태: "모두 완료! 🎉"

#### 완료 화면
- TabView의 두 번째 탭
- 체크마크 + 제목 (취소선)
- 상단: "완료 N개"
