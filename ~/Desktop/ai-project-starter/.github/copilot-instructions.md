# Copilot Instructions

이 프로젝트는 AI 기반 9단계 앱 개발 방법론을 따릅니다.

## 코드 품질 4원칙 (코드 생성 시 필수)

1. **순수 함수**: 비즈니스 로직은 순수 함수로. 부수 효과 분리
2. **모듈화**: 기능별 파일 분리. 300줄 이하. 느슨한 결합
3. **단일 책임**: 함수 하나 = 일 하나. "and" 금지
4. **SOLID**: Protocol/Interface에 의존. 구체 구현 주입

## 폴더 구조 (권장)

```
src/
├── app/              # 앱 진입점
├── core/components/  # 공통 UI
├── core/extensions/  # 유틸리티
├── data/store/       # 상태 관리
├── data/services/    # 외부 서비스
├── domain/models/    # 데이터 모델
├── domain/logic/     # 순수 비즈니스 로직
├── domain/protocols/ # 추상화
└── features/         # 화면별 모듈
```

## 변경 관리

코드를 직접 수정하지 않는다. 반드시 문서부터 업데이트한다.

## 상세 규칙

`.kiro/steering/` 폴더의 steering 파일 참조
