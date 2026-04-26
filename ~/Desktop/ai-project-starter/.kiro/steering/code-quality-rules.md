---
inclusion: auto
---

# 🛡️ 코드 품질 필수 규칙

이 steering은 코드를 생성하거나 수정할 때 항상 자동으로 적용됩니다.
프로젝트의 기술 스택(언어, 프레임워크)에 맞게 아래 원칙을 적용합니다.

---

## 1. 순수 함수 (Pure Functions) — 필수

- 비즈니스 로직은 반드시 순수 함수로 작성
- 같은 입력 → 항상 같은 출력. 외부 상태 변경 금지
- Store/ViewModel은 순수 로직을 호출하고 결과를 적용하는 역할만 수행
- 부수 효과(알림, 네트워크, DB)는 순수 로직과 반드시 분리

```
✅ 좋은 예: 필터링 로직을 순수 함수로 분리
filterActiveTodos(todos) → 새 배열 반환

❌ 나쁜 예: 필터링하면서 외부 상태를 변경
filterActiveTodos() → self.filteredList 변경 + UI 업데이트
```

## 2. 단일 책임 원칙 (SRP) — 필수

- 하나의 파일 = 하나의 역할. 300줄 초과 시 분리 검토
- 하나의 함수 = 하나의 일. "and"가 들어가는 함수명은 분리 대상
- View는 렌더링만, Logic은 계산만, Store는 상태 관리만

```
✅ 좋은 예:
validateTitle(title) → Bool
saveTodo(todo) → void
sendNotification(todo) → void

❌ 나쁜 예:
validateAndSaveTodoAndNotify(title) → void
```

## 3. Protocol/Interface 기반 추상화 (DI) — 필수

- 서비스는 반드시 Protocol/Interface를 정의하고 구체 구현을 주입
- Store/ViewModel은 구체 타입이 아닌 추상에 의존
- 새 서비스 추가 시: 추상 정의 → 구현 → 주입

```
✅ 좋은 예:
interface NotificationService { schedule(todo): void }
class TodoStore { constructor(private notificationService: NotificationService) }

❌ 나쁜 예:
class TodoStore { private service = new FirebaseNotificationService() }
```

## 4. 모듈화 규칙

- 기능 단위로 파일/모듈을 분리한다
- 모듈 간 의존성은 최소화한다 (느슨한 결합)
- 공통 유틸리티는 별도 모듈로 추출한다

### 권장 폴더 구조 (레이어드 + Feature 기반)
```
src/ (또는 프로젝트 루트)
├── app/              # 앱 진입점, 라우팅
├── core/
│   ├── components/   # 공통 UI 컴포넌트
│   └── extensions/   # 유틸리티, 헬퍼
├── data/
│   ├── store/        # 상태 관리 (순수 로직 호출 → 결과 적용)
│   └── services/     # 외부 서비스 (Protocol/Interface 구현)
├── domain/
│   ├── models/       # 데이터 모델
│   ├── logic/        # 순수 함수 비즈니스 로직
│   └── protocols/    # 추상화 (Protocol/Interface)
└── features/
    ├── feature-a/    # 화면/기능별 모듈
    ├── feature-b/
    └── ...
```

### 의존성 방향 (위반 금지)
```
features ──→ domain ←── data
    │            ↑
    └──→ core ───┘

app ──→ 전체
```
- domain은 어디에도 의존하지 않는다 (순수 레이어)
- features끼리 직접 의존하지 않는다

## 5. 코드 생성 시 자체 체크리스트

| # | 체크 항목 |
|---|----------|
| 1 | 비즈니스 로직이 순수 함수로 분리되어 있는가? |
| 2 | 한 파일이 300줄을 넘지 않는가? |
| 3 | 각 함수가 하나의 일만 하는가? |
| 4 | 함수명만 보고 역할을 알 수 있는가? |
| 5 | 구체 구현이 아닌 추상(Protocol/Interface)에 의존하는가? |
| 6 | 새 파일이 올바른 폴더에 위치하는가? |
| 7 | 부수 효과가 순수 로직과 분리되어 있는가? |
| 8 | 새 기능 추가 시 기존 코드 수정 없이 확장 가능한가? |
