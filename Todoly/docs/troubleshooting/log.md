# Troubleshooting Log

## 2026-04-28: watchOS 타겟 Tuist 설정

### 문제
Tuist 3.42.0에서 `watch2App` product 타입은 소스 파일을 직접 포함할 수 없음.
```
Target TodolyWatch cannot contain sources. watch 2 application targets doesn't support source files
```

### 원인
Tuist 3.x는 watchOS 단일 타겟 앱(watchOS 9+)을 직접 지원하지 않음. `watch2App`은 빈 컨테이너 역할만 하고, 소스는 `watch2Extension`에 포함해야 함.

### 해결
`watch2App` + `watch2Extension` 듀얼 타겟 구조 사용:
- `TodolyWatchApp` (watch2App): 빈 컨테이너, `TodolyWatchExtension` 의존
- `TodolyWatchExtension` (watch2Extension): 실제 소스 코드 포함

### 참고
Tuist 4.x에서는 `supportedDestinations`로 단일 타겟 watchOS 앱 지원 예정.
