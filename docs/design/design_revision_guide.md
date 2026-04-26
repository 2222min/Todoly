# 🎨 Todoly 디자인 수정 가이드

## 리뷰 참여자
| 역할 | 인원 | 주요 관점 |
|------|------|----------|
| 시니어 디자이너 A | 1명 | UI/비주얼 |
| 시니어 디자이너 B | 1명 | UX/인터랙션 |
| 미들급 디자이너 C | 1명 | 일관성/접근성 |
| 미들급 디자이너 D | 1명 | 기획 정합성 |
| 대표 | 1명 | 종합 판단 |

---

## 🔴 Critical (반드시 수정 — 6건)

### 1. Main List — 헤더 추가
- Empty State와 동일한 TopAppBar 추가
- 좌측: 햄버거 메뉴 + "Todoly" 타이틀
- 우측: 🔍 검색 아이콘
- 검색 아이콘 탭 → 검색바 확장 애니메이션

### 2. Main List — Bottom Nav Bar 추가
- Empty State와 동일한 하단 탭바
- 아이콘 + 텍스트 라벨 필수 (Tasks / Categories / Trash)
- 현재 활성 탭: 검정 원형 배경 + 흰색 아이콘

### 3. Main List — 검색 기능 진입점
- 헤더 우측 검색 아이콘으로 해결 (1번과 함께)

### 4. Trash — 개별 영구 삭제 버튼
- 각 항목에 Restore 버튼 옆 "Delete" 버튼 추가
- 또는 스와이프 좌측 → 빨간 Delete 영역 노출

### 5. Main List — 모바일 카드 가독성
- 375px 기준 2열 카드 내 텍스트 최소 12px 유지
- 카드 최소 높이 160px 확보
- 메모 텍스트 2줄 초과 시 말줄임(...) 처리

### 6. Task Detail — Notes 영역 확장성
- 최소 높이 120px → 내용에 따라 자동 확장
- 또는 Notes를 별도 전체 너비 섹션으로 분리 (Bento Grid 밖으로)

---

## 🟡 Recommended (권장 수정 — 6건)

### 7. Empty State — 추가 진입점 통합
- Quick Add 바 + FAB + "Add First Task" 버튼 3개 중복
- Empty State에서는 "Add First Task" CTA만 남기고, Quick Add 바는 숨김 처리
- 또는 "Add First Task" 탭 시 Quick Add 입력 필드에 포커스

### 8. 전체 — Bottom Nav 텍스트 라벨
- 모든 화면의 Bottom Nav 아이콘 하단에 라벨 추가

### 9. 전체 — 타이틀 폰트 웨이트 통일
- 현재: Empty State = Inter Black, Main List = Inter Bold
- 통일안: 앱 타이틀 "Todoly" = Inter Black, 섹션 타이틀 = Inter Bold

### 10. Task Detail — 이미지 영역 제거
- "Visual Context: Project Focus" 이미지 영역은 기획안에 없음
- v1에서는 제거, 향후 v2에서 이미지 첨부 기능으로 검토

### 11. Task Detail — 우선순위 색상 통일
- 현재 High = #ba1a1a → 기획안 #FF3B30으로 변경
- Low = #00e → 기획안 #007AFF로 변경

### 12. Trash — 접근성 개선
- 삭제 날짜 텍스트 #afafaf → 최소 #767676 (WCAG AA 4.5:1)

---

## 📋 추가 필요 화면

| 화면 | 우선순위 | 비고 |
|------|---------|------|
| 카테고리 관리 | 높음 | 기획안 3.4에 정의됨 |
| 다크모드 전체 | 중간 | 비기능 요구사항 |

---

## Figma 수정 위치
각 프레임 상단에 노란색 리뷰 노트가 추가되어 있습니다.
- Figma 파일: KAtwxMVjOZVQmM5DOvrEev
- Empty State (18:2), Trash (18:47), Main List (18:92), Task Detail (18:228)

---

## 다음 단계
1. 디자이너팀이 위 수정사항 반영
2. Round 2 디자인 리뷰 진행
3. 승인 시 → 개발팀에 개발 의뢰 전달 (7단계)
