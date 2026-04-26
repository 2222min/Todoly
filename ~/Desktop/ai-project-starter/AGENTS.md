# Agent Instructions (Codex)

이 프로젝트는 AI 기반 9단계 앱 개발 방법론을 따릅니다.

## 개발 플로우 (9단계)

사용자가 앱 아이디어를 말하면 아래 플로우를 자동 실행합니다:

1. **기획 초안** → `docs/planning/v1_기획안.md`
2. **기획 리뷰** (AI 멀티 페르소나: 사용성/가시성/가독성) → `docs/planning/v1_리뷰.md`
3. **기획 확정** → `docs/planning/FINAL_기획안.md`
4. **디자인** (Figma / 코드 직행 / 전체 플로우 선택)
5. **디자인 리뷰** (UI/UX/일관성/기획정합성)
6. **디자인 확정** → `docs/dev/개발의뢰서.md`
7. **개발 스펙 논의** (비용 $0 목표) → `docs/dev/개발스펙_논의록.md`
8. **개발 가이드 작성** → `docs/dev/` 폴더
9. **구현** (문서 기반 코드 생성 + 자체 리뷰)

각 단계 완료 후 사용자 확인을 받고 다음 단계로 진행합니다.

## 코드 품질 4원칙 (코드 생성 시 필수)

1. **순수 함수**: 비즈니스 로직은 순수 함수로. 부수 효과 분리
2. **모듈화**: 기능별 파일 분리. 300줄 이하. 느슨한 결합
3. **단일 책임**: 함수 하나 = 일 하나. "and" 금지
4. **SOLID**: Protocol/Interface에 의존. 구체 구현 주입

## 변경 관리 (필수)

코드를 직접 수정하지 않는다. 반드시 문서부터 업데이트한다.
```
변경 요청 → 분석 → 문서 업데이트 → 코드 수정
```

## 비용 최소화 원칙

- 서버 비용 월 $0 목표 (Firebase Spark / Supabase Free 등)
- 직접 구현보다 매니지드 서비스/BaaS 우선
- v1은 핵심 기능만

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

## 산출물 폴더 구조

```
docs/
├── planning/          # 기획 문서 (v1, v2, FINAL)
├── design/            # 디자인 문서
└── dev/               # 개발 스펙, 가이드
```

## Codex 전용 참고사항

- 상세 steering 규칙은 `.kiro/steering/` 폴더 참조
- `app-development-flow.md`: 9단계 플로우 상세
- `code-quality-rules.md`: 코드 품질 규칙 상세
