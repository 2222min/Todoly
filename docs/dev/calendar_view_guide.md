# 📅 캘린더 뷰 개발 가이드

## 1. 애니메이션 파라미터 가이드

모든 애니메이션은 `AnimationConstants` enum에서 중앙 관리한다.

| 전환 | 애니메이션 | response | dampingFraction | 비고 |
|------|----------|----------|-----------------|------|
| 월 이동 | .asymmetric(insertion/removal) | 0.4 | 0.8 | 방향 추적 필요 |
| 날짜 선택 | .scaleEffect + .opacity | 0.35 | 0.7 | 원형 배경 |
| 할 일 목록 등장 | .move(edge: .bottom) + .opacity | 0.45 | 0.8 | 날짜 선택 시 |
| 항목 개별 등장 | staggered delay | 0.4 | 0.75 | delay: index * 0.06 |
| 탭 전환 | .spring | 0.35 | 0.7 | 기존 유지 |

### Reduce Motion 대응
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// 사용 예시
.animation(reduceMotion ? .none : AnimationConstants.dateSelection, value: selectedDate)
```

## 2. 컬러/폰트 가이드 (캘린더 뷰 전용)

### 날짜 셀 상태별 스타일

| 상태 | 배경 | 텍스트 색상 | 폰트 |
|------|------|-----------|------|
| 일반 | 없음 | txt1 (#2D2D2D) | 14pt Medium .rounded |
| 오늘 | accent1 opacity 0.15 원형 | accent1 (#FF8A65) | 14pt Bold .rounded |
| 선택됨 | 코랄→레드 그라데이션 원형 | white (#FFFFFF) | 14pt Bold .rounded |
| 일요일 | 없음 | priorityHigh (#FF6B6B) | 12pt Medium .rounded |
| 토요일 | 없음 | priorityLow (#5B9BF5) | 12pt Medium .rounded |

### Dot Indicator 색상

| 우선순위 | 색상 | 크기 |
|----------|------|------|
| high | #FF6B6B | 4px |
| medium | #FFAB5E | 4px |
| low | #5B9BF5 | 4px |
| 완료만 | #B0B0B0 (txt3) | 4px |

최대 3개, 간격 2px.

### 할 일 카드 스타일

| 요소 | 스타일 |
|------|--------|
| 카드 | 350x72, cornerRadius 20, white bg, shadow(0.06, blur 16) |
| 우선순위 바 | 3x48, cornerRadius 2 |
| 제목 | 14pt Bold .rounded, txt1 |
| 메타 (카테고리 · 시간) | 10pt Medium .rounded, 카테고리색 + txt3 + accent1 |

## 3. 터치 타겟 가이드

| 요소 | 최소 크기 | 구현 방식 |
|------|----------|----------|
| 월 이동 ◀ ▶ | 44x44pt | 투명 버튼 프레임 |
| 날짜 셀 | 50x48pt | 셀 전체 탭 영역 |
| 할 일 카드 | 350x72pt | 카드 전체 탭 |
| 탭 바 아이템 | 85x47pt | 탭 프레임 전체 |

## 4. 접근성 라벨 가이드

| 요소 | 라벨 형식 | 예시 |
|------|----------|------|
| 날짜 셀 | "\(month)월 \(day)일, 할 일 \(count)개" | "4월 10일, 할 일 3개" |
| 이전 달 버튼 | "이전 달" | — |
| 다음 달 버튼 | "다음 달" | — |
| 할 일 항목 | "\(title), 우선순위 \(priority)" | "보고서 작성, 우선순위 높음" |
| 월 표시 | "\(year)년 \(month)월" | "2026년 4월" |

## 5. 탭 바 통일 가이드

기존 3탭 → 4탭으로 변경. 모든 화면에 동일 적용.

```
탭 순서: 할 일 | 캘린더 | 카테고리 | 휴지통
아이콘: list.bullet | calendar | square.grid.2x2 | trash
```

### 활성 탭 스타일
- 42px 원형 그라데이션 배경 (accent1 → FF6B6B)
- 아이콘 16pt, 흰색
- 라벨 10pt Medium .rounded, accent1 색상

### 비활성 탭 스타일
- 42px 원형 투명 배경
- 아이콘 16pt, txt3 색상
- 라벨 10pt Medium .rounded, txt3 색상
