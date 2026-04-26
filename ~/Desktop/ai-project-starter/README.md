# 🚀 AI Project Starter Template

> Kiro, Claude, Codex 세 가지 AI 도구 모두에서 사용할 수 있는 범용 프로젝트 초기 세팅 템플릿

## 사용법

### 1. 새 프로젝트 시작
```bash
cp -r ~/Desktop/ai-project-starter ~/Desktop/내프로젝트이름
```

### 2. AI 도구별 설정

| AI 도구 | 설정 파일 | 자동 적용 |
|---------|----------|----------|
| **Kiro** | `.kiro/steering/*.md` | ✅ 자동 (steering) |
| **Claude** | `CLAUDE.md` | ✅ 자동 (Project Instructions) |
| **Codex** | `AGENTS.md` | ✅ 자동 (Agent Instructions) |
| **Cursor** | `.cursorrules` | ✅ 자동 |
| **Copilot** | `.github/copilot-instructions.md` | ✅ 자동 |

### 3. 프로젝트 시작하기
아무 AI 도구에서 아이디어만 말하면 9단계 플로우가 자동 실행됩니다:
```
직장인을 위한 심플한 TODO 앱 만들고 싶어
```

## 폴더 구조
```
ai-project-starter/
├── .kiro/                          # Kiro 전용 설정
│   ├── steering/
│   │   ├── app-development-flow.md # 9단계 개발 플로우 (핵심)
│   │   └── code-quality-rules.md   # 코드 품질 규칙
│   └── settings/
│       └── mcp.json                # MCP 서버 설정 (필요시)
├── CLAUDE.md                       # Claude 전용 (= steering 요약)
├── AGENTS.md                       # Codex 전용 (= steering 요약)
├── .cursorrules                    # Cursor 전용
├── .github/
│   └── copilot-instructions.md     # Copilot 전용
├── docs/                           # 산출물 폴더 (자동 생성됨)
│   ├── planning/                   # 기획 문서
│   ├── design/                     # 디자인 문서
│   └── dev/                        # 개발 문서
└── README.md                       # 이 파일
```

## 핵심 철학
- 🪶 가볍게 시작 — 최소 기능으로 빠르게
- 💰 비용 최소화 — 서버 비용 월 $0 목표
- 🔄 반복 리뷰 — AI 멀티 페르소나 리뷰
- 📄 문서 기반 — 문서 품질 = 코드 품질
- 🎭 역할 부여 — AI에게 전문가 역할을 줘서 품질 향상
