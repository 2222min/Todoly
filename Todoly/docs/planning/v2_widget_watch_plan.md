# Todoly v2 — 위젯 + Apple Watch 기획서 (Planning Draft)

## 1. 개요

Todoly 앱의 할 일 데이터를 홈 화면 위젯과 Apple Watch에서 빠르게 확인하고 조작할 수 있도록 확장한다.

### 목표
- 앱을 열지 않고도 오늘의 할 일을 한눈에 파악
- Apple Watch에서 간단한 완료 토글 가능
- 기존 아키텍처(Layered + Feature-based)를 유지하면서 데이터 공유

### 범위 (v1 Core Only)
- iOS 홈 화면 위젯 (Small / Medium / Large)
- Apple Watch 앱 (watchOS 10+)
- App Group 기반 데이터 공유

---

## 2. 현재 상태 분석

### 기존 구조
| 항목 | 현재 |
|------|------|
| 데이터 저장 | `UserDefaults.standard` + Codable |
| 위젯 | Live Activity만 존재 (TodolyAlarmLiveActivity) |
| Watch | 없음 |
| 공유 모델 | `TodoAlarmAttributes`만 위젯 타겟에 공유 |
| 빌드 | Tuist (Project.swift) |

### 변경이 필요한 부분
1. **데이터 공유**: `UserDefaults.standard` → `UserDefaults(suiteName: "group.com.todoly.app")` (App Group)
2. **모델 공유**: `Todo`, `TodoCategory`, `Priority` 모델을 Shared 모듈로 분리
3. **위젯 타겟 확장**: Live Activity + Static Widget
4. **Watch 타겟 추가**: watchOS 앱 타겟

---

## 3. 기능 정의

### 3.1 iOS 위젯

#### Small Widget (할 일 요약)
- 오늘 미완료 할 일 개수
- 가장 높은 우선순위 할 일 1개 표시
- 탭 → 앱 열기

#### Medium Widget (오늘 할 일 리스트)
- 오늘 미완료 할 일 최대 3개 표시 (우선순위 순)
- 각 항목: 체크박스 아이콘 + 제목 + 우선순위 색상 dot
- 탭 → 앱 열기
- Intent로 완료 토글 (iOS 17+ Interactive Widget)

#### Large Widget (오늘 할 일 + 완료)
- 미완료 할 일 최대 5개
- 완료된 할 일 최대 2개 (취소선)
- 카테고리 필터 옵션 (Configurable Widget)
- Intent로 완료 토글

### 3.2 Apple Watch 앱

#### 메인 화면 (오늘 할 일)
- 오늘 미완료 할 일 리스트
- 각 항목: 제목 + 우선순위 색상 + 완료 토글 버튼
- 완료 시 햅틱 피드백

#### 완료 화면
- 오늘 완료한 할 일 리스트
- 간단한 카운트 표시

#### Complication
- 오늘 미완료 할 일 개수 표시

---

## 4. 데이터 공유 아키텍처

### App Group
```
group.com.todoly.app
```

### 공유 데이터 흐름
```
iOS App (TodoStore)
  ├── save() → App Group UserDefaults
  ├── WidgetCenter.shared.reloadAllTimelines()
  └── WCSession.transferCurrentComplicationUserInfo()
  
Widget Extension
  └── read from App Group UserDefaults (read-only)

Watch App
  ├── read from App Group UserDefaults (via WatchConnectivity)
  ├── 완료 토글 → WCSession.sendMessage()
  └── iOS App receives → TodoStore.toggleComplete() → save() → reload widget
```

### Shared 모듈 구조
```
Todoly/Shared/
  Models/
    Todo.swift          (기존 Domain/Models에서 이동)
    TodoCategory.swift
    Priority.swift
  SharedStore/
    SharedDefaults.swift  (App Group UserDefaults 래퍼)
  Logic/
    TodoFilterLogic.swift (위젯/워치에서도 필터링 필요)
```

---

## 5. 프로젝트 구조 변경

### 새로운 타겟 구성

```
Project.swift targets:
  ├── Todoly (iOS App) — depends on Shared
  ├── TodolyTests
  ├── TodolyWidget (Widget Extension) — depends on Shared
  ├── TodolyWatch (watchOS App) — depends on Shared
  └── TodolyWatchExtension — depends on Shared
```

### 파일 구조 추가
```
Todoly/
  Shared/                          ← NEW: 공유 모듈
    Models/
      Todo.swift
      TodoCategory.swift
      Priority.swift
      TodoAlarmAttributes.swift
    Store/
      SharedDefaults.swift         ← App Group UserDefaults 래퍼
    Logic/
      TodoFilterLogic.swift
  
  TodolyWidget/                    ← EXTEND: 기존 위젯 확장
    TodolyWidgetBundle.swift       (수정: Static Widget 추가)
    TodolyAlarmLiveActivity.swift  (기존 유지)
    TodayWidget/
      TodayWidgetProvider.swift
      TodayWidgetEntryView.swift
      TodaySmallView.swift
      TodayMediumView.swift
      TodayLargeView.swift
  
  TodolyWatch/                     ← NEW: Watch 앱
    TodolyWatchApp.swift
    ContentView.swift
    TodayListView.swift
    CompletedListView.swift
    WatchTodoRow.swift
    WatchConnectivityManager.swift
```

---

## 6. 기술 스택 & 제약

| 항목 | 선택 |
|------|------|
| iOS 위젯 | WidgetKit + SwiftUI (iOS 17+ Interactive) |
| Watch 앱 | SwiftUI (watchOS 10+) |
| 데이터 공유 | App Group + UserDefaults |
| Watch 통신 | WatchConnectivity (WCSession) |
| 위젯 갱신 | TimelineProvider (15분 간격 + 앱 변경 시 수동 reload) |
| 위젯 인터랙션 | AppIntent (iOS 17+) |

### 제약 사항
- 위젯에서 직접 데이터 쓰기 불가 → AppIntent로 앱 프로세스에서 처리
- Watch에서 직접 UserDefaults 접근 불가 → WatchConnectivity 사용
- 위젯 타임라인 갱신 빈도 시스템 제한 있음
- 서버 비용 $0 유지 (로컬 데이터만 사용)

---

## 7. 마이그레이션 계획

### Phase 1: 데이터 공유 기반 (Breaking Change 최소화)
1. App Group entitlement 추가
2. `SharedDefaults` 래퍼 생성
3. `TodoStore.save()` → App Group UserDefaults로 이중 저장
4. 기존 `UserDefaults.standard` 데이터 마이그레이션 로직

### Phase 2: iOS 위젯
1. `TodayWidgetProvider` + Entry 구현
2. Small / Medium / Large 뷰 구현
3. Interactive Widget (완료 토글) AppIntent 구현
4. Widget Bundle에 등록

### Phase 3: Apple Watch
1. watchOS 타겟 추가 (Project.swift)
2. WatchConnectivity 매니저 구현
3. Watch UI 구현
4. Complication 구현

---

## 8. 리스크 & 대응

| 리스크 | 영향 | 대응 |
|--------|------|------|
| App Group 마이그레이션 시 기존 데이터 유실 | 높음 | 마이그레이션 로직에서 standard → group 복사 후 검증 |
| 위젯 타임라인 갱신 지연 | 중간 | 앱 foreground 시 강제 reload + relevance 활용 |
| Watch ↔ iPhone 연결 끊김 | 중간 | Watch에 로컬 캐시 유지, 연결 복구 시 동기화 |
| Shared 모듈 분리 시 빌드 에러 | 낮음 | 점진적 이동, 각 단계별 빌드 검증 |

---

## 9. 성공 지표

- 위젯에서 오늘 할 일 정확히 표시
- 위젯 탭 → 앱 정상 진입
- Interactive Widget으로 완료 토글 동작
- Watch에서 할 일 목록 표시 + 완료 토글
- 기존 앱 기능 regression 없음
