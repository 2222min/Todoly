# Todoly v2 — 위젯 + Apple Watch 기획 리뷰

> 원본: `v2_widget_watch_plan.md`
> 리뷰어: Usability Expert, Visibility Expert, Readability Expert

---

## 🔴 Red (반드시 수정)

### R1. Shared 모듈 — 모델 이동 대신 공유 참조 방식 권장
- **리뷰어**: Usability Expert
- **문제**: 기존 `Domain/Models/`에서 `Shared/Models/`로 파일을 물리적으로 이동하면, 기존 앱 코드의 import 경로가 모두 변경되어 regression 리스크가 높음
- **제안**: 파일을 이동하지 않고, Tuist `sources`에서 동일 파일을 여러 타겟에 포함시키는 방식 사용. 기존 Project.swift의 Widget 타겟이 이미 `TodoAlarmAttributes.swift`를 이 방식으로 공유 중
- **수정**: `Shared/` 폴더 신설 대신, 기존 `Domain/Models/`, `Domain/Logic/` 파일을 Widget/Watch 타겟의 sources에 직접 포함

### R2. Watch 데이터 동기화 — WatchConnectivity만으로는 불안정
- **리뷰어**: Visibility Expert
- **문제**: WatchConnectivity의 `sendMessage`는 iPhone이 근처에 있고 앱이 reachable할 때만 동작. 백그라운드에서는 `transferUserInfo`만 가능하며 즉시성이 없음
- **제안**: watchOS 10+에서는 App Group을 통한 직접 UserDefaults 접근이 가능 (동일 App Group). WatchConnectivity는 실시간 동기화 보조 수단으로만 사용
- **수정**: Watch 앱도 App Group UserDefaults에서 직접 읽기. 완료 토글은 Watch에서 직접 App Group에 쓰고, iPhone 앱이 foreground 될 때 동기화

### R3. Interactive Widget — iOS 17 AppIntent 구현 누락
- **리뷰어**: Usability Expert
- **문제**: 기획서에 "Intent로 완료 토글"이라고만 되어 있고, 구체적인 AppIntent 구조가 없음. iOS 17+ Interactive Widget은 `AppIntent` + `Button` 조합이 필수
- **제안**: `ToggleTodoIntent: AppIntent` 정의 필요. 이 Intent가 App Group UserDefaults에 직접 쓰고 → WidgetCenter reload
- **수정**: AppIntent 구조를 기획서에 명시

---

## 🟡 Yellow (개선 권장)

### Y1. 위젯 디자인 — 기존 브랜드 컬러 활용 명시
- **리뷰어**: Readability Expert
- **문제**: 위젯 UI 설명에 색상/폰트 가이드가 없음
- **제안**: 기존 `Color+Brand.swift`의 `brandBg`, `txt1`, `priHigh/Med/Low` 등을 위젯에서도 동일하게 사용. 단, 위젯은 별도 타겟이므로 Color extension을 공유하거나 위젯 전용으로 복제 필요

### Y2. Watch UI — 최소 기능에 집중
- **리뷰어**: Usability Expert
- **문제**: Watch에서 Complication까지 v1에 포함하면 범위가 넓음
- **제안**: v1에서는 오늘 할 일 리스트 + 완료 토글만. Complication은 v2로 연기

### Y3. 위젯 Large — 카테고리 필터는 과도
- **리뷰어**: Visibility Expert
- **문제**: Large Widget에 Configurable 카테고리 필터는 복잡도 대비 사용 빈도가 낮음
- **제안**: v1에서는 전체 할 일만 표시. 카테고리 필터는 추후 추가

### Y4. 마이그레이션 — 기존 데이터 자동 이전 필수
- **리뷰어**: Usability Expert
- **문제**: App Group으로 전환 시 기존 `UserDefaults.standard` 데이터가 사라지면 사용자 경험 치명적
- **제안**: 앱 시작 시 standard → App Group 자동 마이그레이션 + 마이그레이션 완료 플래그

### Y5. 위젯 갱신 전략 구체화
- **리뷰어**: Visibility Expert
- **문제**: "15분 간격 + 수동 reload"만 언급. 구체적 TimelinePolicy 미정의
- **제안**: `.atEnd` 정책 + 자정 기준 타임라인 생성 (오늘 할 일 기준). 앱에서 데이터 변경 시 `WidgetCenter.shared.reloadAllTimelines()` 호출

---

## 리뷰 요약

| 등급 | 항목 | 조치 |
|------|------|------|
| 🔴 | R1. Shared 모듈 방식 | 파일 이동 대신 타겟 sources 공유 |
| 🔴 | R2. Watch 데이터 동기화 | App Group 직접 접근 + WC 보조 |
| 🔴 | R3. AppIntent 구조 명시 | ToggleTodoIntent 정의 추가 |
| 🟡 | Y1. 브랜드 컬러 공유 | Color extension 위젯 타겟에 포함 |
| 🟡 | Y2. Watch Complication 연기 | v1 범위에서 제외 |
| 🟡 | Y3. 카테고리 필터 연기 | v1 범위에서 제외 |
| 🟡 | Y4. 데이터 마이그레이션 | 자동 이전 로직 필수 |
| 🟡 | Y5. 타임라인 정책 | `.atEnd` + 자정 기준 + 수동 reload |
