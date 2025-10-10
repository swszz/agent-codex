# 구현 계획: [FEATURE]

**브랜치**: `[###-feature-name]` | **날짜**: [DATE] | **명세**: [link]
**입력**: `/specs/[###-feature-name]/spec.md`의 기능 명세

**참고**: 이 템플릿은 `/speckit.plan` 명령어로 작성됩니다. 실행 워크플로우는 `.specify/templates/commands/plan.md`를 참조하세요.

## 요약

[기능 명세에서 추출: 주요 요구사항 + 연구를 통한 기술적 접근방법]

## 기술 컨텍스트

<!--
  작업 필요: 이 섹션의 내용을 프로젝트의 기술 세부사항으로 교체하세요.
  여기 구조는 반복 프로세스를 안내하기 위한 자문 용도로 제공됩니다.
-->

**언어/버전**: [예: Python 3.11, Swift 5.9, Rust 1.75 또는 명확화 필요]  
**주요 의존성**: [예: FastAPI, UIKit, LLVM 또는 명확화 필요]  
**저장소**: [해당되는 경우, 예: PostgreSQL, CoreData, files 또는 N/A]  
**테스팅**: [예: pytest, XCTest, cargo test 또는 명확화 필요]  
**대상 플랫폼**: [예: Linux server, iOS 15+, WASM 또는 명확화 필요]
**프로젝트 타입**: [single/web/mobile - 소스 구조 결정]  
**성능 목표**: [도메인별, 예: 1000 req/s, 10k lines/sec, 60 fps 또는 명확화 필요]  
**제약사항**: [도메인별, 예: <200ms p95, <100MB memory, offline-capable 또는 명확화 필요]  
**규모/범위**: [도메인별, 예: 10k users, 1M LOC, 50 screens 또는 명확화 필요]

## 헌장 체크

*게이트: Phase 0 연구 전에 통과해야 함. Phase 1 설계 후 재확인.*

[헌장 파일을 기반으로 결정된 게이트]

## 프로젝트 구조

### 문서 (이 기능)

```
specs/[###-feature]/
├── plan.md              # 이 파일 (/speckit.plan 명령어 출력)
├── research.md          # Phase 0 출력 (/speckit.plan 명령어)
├── data-model.md        # Phase 1 출력 (/speckit.plan 명령어)
├── quickstart.md        # Phase 1 출력 (/speckit.plan 명령어)
├── contracts/           # Phase 1 출력 (/speckit.plan 명령어)
└── tasks.md             # Phase 2 출력 (/speckit.tasks 명령어 - /speckit.plan으로 생성되지 않음)
```

### 소스 코드 (리포지토리 루트)
<!--
  작업 필요: 아래 플레이스홀더 트리를 이 기능의 구체적인 레이아웃으로 교체하세요.
  사용하지 않는 옵션은 삭제하고 선택한 구조를 실제 경로로 확장하세요
  (예: apps/admin, packages/something). 전달된 계획에는 옵션 레이블이 포함되지 않아야 합니다.
-->

```
# [미사용시 제거] 옵션 1: 단일 프로젝트 (기본값)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [미사용시 제거] 옵션 2: 웹 애플리케이션 ("frontend" + "backend" 감지시)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [미사용시 제거] 옵션 3: 모바일 + API ("iOS/Android" 감지시)
api/
└── [위 백엔드와 동일]

ios/ or android/
└── [플랫폼별 구조: 기능 모듈, UI 플로우, 플랫폼 테스트]
```

**구조 결정**: [선택된 구조를 문서화하고 위에서 캡처한 실제 디렉토리를 참조]

## 복잡도 추적

*헌장 체크에 정당화가 필요한 위반사항이 있을 때만 작성*

| 위반사항 | 필요한 이유 | 거부된 더 간단한 대안과 그 이유 |
|-----------|------------|-------------------------------------|
| [예: 4번째 프로젝트] | [현재 필요성] | [3개 프로젝트가 불충분한 이유] |
| [예: Repository 패턴] | [구체적인 문제] | [직접 DB 접근이 불충분한 이유] |
