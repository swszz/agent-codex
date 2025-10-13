# [PROJECT_NAME] Constitution
## Core Principles
<!-- 핵심 원칙: 프로젝트에서 절대 타협할 수 없는 기본 원칙들 -->

### I. Test code is required (NON-NEGOTIABLE)
- Write at least one test that handles both success and failure.
<!-- 최소한 성공과 실패를 담당하는 테스트를 한 개 이상 작성하세요. -->
- All tests must pass before PR merge (no exceptions)
<!-- PR 머지 전 모든 테스트 통과 필수 (예외 없음) -->

### II. Clarity Before Code
- Never start coding with ambiguous requirements
<!-- 모호한 요구사항으로 코딩 시작 금지 -->
- Ask questions and clarify uncertainties before implementation
<!-- 구현 전 질문하고 불확실성 제거 -->
- Define user stories and acceptance criteria first
<!-- 사용자 스토리와 인수 기준을 먼저 정의 -->
- No implementation that starts with "probably" or "I think"
<!-- "아마도", "~인 것 같다"로 시작하는 구현 금지 -->

### III. Simplicity First
- Choose simple solutions over complex ones
<!-- 복잡한 것보다 단순한 솔루션 선택 -->
- YAGNI principle: Don't build what you don't need now
<!-- YAGNI 원칙: 지금 필요하지 않으면 만들지 않음 -->
- Abstraction only after identifying pattern 3+ times
<!-- 추상화는 패턴이 3번 이상 발견된 후에만 -->
- Complexity increases require documented justification
<!-- 복잡도 증가는 문서화된 정당화 필요 -->

### IV. Security by Default
- Never hardcode sensitive information (use environment variables/secrets manager)
<!-- 민감 정보 하드코딩 금지 (환경변수/시크릿 관리자 사용) -->
- Validate all user inputs (never trust client data)
<!-- 모든 사용자 입력 검증 (클라이언트 데이터 신뢰 금지) -->

### V. Observability Required
- Structured logging (JSON format with correlation IDs)
<!-- 구조화된 로깅 (JSON 형식, correlation ID 포함) -->
- Meaningful error messages (include debuggable context)
<!-- 의미 있는 에러 메시지 (디버깅 가능한 컨텍스트 포함) -->

### VI. Documentation Alongside Code
- Complex logic requires comments explaining "why"
<!-- 복잡한 로직은 "왜"를 설명하는 주석 필수 -->
- README.md must include local setup instructions (< 10 min setup)
<!-- README.md에 로컬 실행 방법 명시 (10분 이내 셋업) -->

### VII. Backward Compatibility
- Breaking changes require minimum 1 version deprecation period
<!-- Breaking change는 최소 1개 버전 deprecation 기간 필요 -->
- Database migrations are forward-only
<!-- 데이터베이스 마이그레이션은 forward-only -->
- Use feature flags for gradual rollout
<!-- 점진적 롤아웃을 위한 feature flag 사용 -->

## Technical Constraints
<!-- 기술 제약사항: 사용 가능한 기술 스택과 금지된 기술을 정의 -->

### Required Tech Stack
<!-- 필수 기술 스택: 프로젝트에서 사용해야 하는 기술들 -->

**Preferred Languages & Frameworks**
- Type safety required (TypeScript, Java, Go, Rust, etc.)
<!-- 타입 안정성 필수 (TypeScript, Java, Go, Rust 등) -->
- Proven frameworks preferred (Spring Boot, Express, FastAPI, etc.)
<!-- 검증된 프레임워크 우선 (Spring Boot, Express, FastAPI 등) -->
- Use latest LTS versions
<!-- 최신 LTS 버전 사용 -->

**Database**
- Production: PostgreSQL/MySQL (proven RDBMS)
<!-- 프로덕션: PostgreSQL/MySQL (검증된 RDBMS) -->
- Use ORM/Query Builder/SQL Tempalte
<!-- ORM/Query Builder/SQL Tempalte 사용 -->

**API Design**
- Follow RESTful principles (noun resources, meaningful HTTP methods)
<!-- RESTful 원칙 준수 (명사형 리소스, 의미 있는 HTTP 메소드) -->
- Standardized error responses (status code, message, details)
<!-- 표준화된 에러 응답 (상태 코드, 메시지, 상세 정보) -->
- Document request/response examples
<!-- 요청/응답 예시 문서화 -->

### Prohibited Technologies
❌ Unproven new technologies (in production)
<!-- 검증되지 않은 신기술 (프로덕션에서) -->
❌ Excessive synchronous blocking calls (prefer async)
<!-- 과도한 동기식 blocking 호출 (비동기 선호) -->
❌ Shared mutable state (follow immutability principles)
<!-- 공유 가변 상태 (불변성 원칙 따르기) -->

### Code Quality Standards
<!-- 코드 품질 기준: 코드 구조와 네이밍 규칙 -->

**Structure**
<!-- 구조 -->
- Function length: max 50 lines
<!-- 함수 길이: 최대 50줄 -->
- File length: max 300 lines
<!-- 파일 길이: 최대 300줄 -->
- Nesting depth: max 3 levels
<!-- 중첩 깊이: 최대 3단계 -->
- Cyclomatic complexity: max 10
<!-- 순환 복잡도: 최대 10 -->

**Naming**
- No abbreviations (avoid `usr` instead of `user`)
<!-- 약어 금지 (user 대신 usr 같은 것 피하기) -->
- Pronounceable names (avoid `genYmdhms`)
<!-- 발음 가능한 이름 (genYmdhms 같은 것 피하기) -->
- Searchable names (avoid magic numbers like 7)
<!-- 검색 가능한 이름 (7 같은 매직 넘버 피하기) -->

**Dependency Management**
- External library additions require documented justification
<!-- 외부 라이브러리 추가 시 문서화된 정당화 필요 -->
- No dependencies with known security vulnerabilities
<!-- 알려진 보안 취약점 있는 의존성 금지 -->
- Verify licenses (be cautious with restrictive licenses like GPL)
<!-- 라이선스 확인 (GPL 같은 제한적 라이선스 주의) -->

## Development Workflow
<!-- 개발 워크플로우: Git 전략, PR 요구사항, 코드 리뷰 프로세스 -->

### Git Strategy
<!-- Git 전략: 브랜치 모델과 커밋 메시지 규칙 -->

**Branch Model**
<!-- 브랜치 모델 -->
- `main`: production-ready state (protected)
<!-- main: 프로덕션 배포 가능 상태 (보호됨) -->
- `feature/*`: new feature development
<!-- feature/*: 새 기능 개발 -->
- `fix/*`: bug fixes
<!-- fix/*: 버그 수정 -->
- `hotfix/*`: urgent production fixes
<!-- hotfix/*: 긴급 프로덕션 수정 -->

**Commit Messages**
<!-- 커밋 메시지 -->
```
<type>: <subject> (50 chars or less)

<body> (optional, wrap at 72 chars)
- Explain what and why
- Code explains how

<footer> (optional)
Fixes #123
Breaking Change: Removed API v1 endpoint
```
<!-- 타입, 제목, 본문, 푸터 형식으로 작성 -->

Types: feat, fix, docs, test, refactor, chore
<!-- 타입: feat(기능), fix(수정), docs(문서), test(테스트), refactor(리팩토링), chore(잡무) -->

### PR Requirements
<!-- PR 요구사항: 머지 전 통과해야 하는 조건들 -->

**Automated Checks (CI)**
- ✅ All tests pass
<!-- 모든 테스트 통과 -->
- ✅ Linting passes
<!-- Linting 통과 -->
- ✅ Build succeeds
<!-- 빌드 성공 -->

**Manual Review**
- ✅ At least 1 approval (2 for complex changes)
<!-- 최소 1명 승인 (복잡한 변경은 2명) -->
- ✅ Requirements verified
<!-- 요구사항 확인 -->
- ✅ No security issues
<!-- 보안 이슈 없음 -->
- ✅ Performance impact reviewed
<!-- 성능 영향 검토 -->

**PR Description Template**
<!-- PR 설명 템플릿 -->
```markdown
## What Changed
- Describe the changes

## Why
- Explain the reason

## How to Test
- Testing instructions

## Screenshots (if UI changes)
- Before/After

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Breaking changes noted
```

### Code Review Principles
<!-- 코드 리뷰 원칙: 리뷰어와 작성자의 책임 -->

**Reviewer Responsibilities**
- First review within 24 hours (4 hours for urgent)
<!-- 24시간 이내 첫 리뷰 (긴급 시 4시간) -->
- Constructive feedback (suggest specific improvements)
<!-- 건설적 피드백 (구체적 개선안 제시) -->
- Praise good work ("This part is excellent")
<!-- 좋은 작업에 대한 칭찬 -->

**Author Responsibilities**
- Self-review first (check before submitting PR)
<!-- 셀프 리뷰 먼저 (PR 제출 전 본인이 먼저 체크) -->
- Respond to feedback (address or discuss)
<!-- 피드백에 응답 (수정 또는 토론) -->
- Respect reviewer's time (prefer small PRs)
<!-- 리뷰어의 시간 존중 (작은 PR 선호) -->

**Review Checklist**
- [ ] Requirements met
<!-- 요구사항 충족 -->
- [ ] Edge cases handled
<!-- 엣지 케이스 처리 -->
- [ ] Error handling appropriate
<!-- 에러 핸들링 적절 -->
- [ ] Tests sufficient
<!-- 테스트 충분 -->
- [ ] Naming clear
<!-- 네이밍 명확 -->
- [ ] No code duplication
<!-- 코드 중복 없음 -->
- [ ] No security issues
<!-- 보안 이슈 없음 -->
- [ ] No performance problems
<!-- 성능 문제 없음 -->

### Deployment Process
**Environment Setup**
<!-- 환경 구성 -->
- Development → Staging → Production
<!-- 개발 → 스테이징 → 프로덕션 -->
- Each environment is independent (no cross-dependencies)
<!-- 각 환경은 독립적 (상호 의존 금지) -->
- Environment-specific configurations via environment variables
<!-- 환경별 설정은 환경변수로 관리 -->

**Deployment Steps**
<!-- 배포 단계 -->
1. Deploy to Staging → Run automated tests
<!-- 스테이징 배포 → 자동 테스트 실행 -->
2. Manual validation in Staging (QA)
<!-- 스테이징 수동 검증 (QA) -->
3. Deploy to Production (approval required)
<!-- 프로덕션 배포 (승인 필요) -->
4. Monitor Production (24 hours)
<!-- 프로덕션 모니터링 (24시간) -->

**Rollback Readiness**
- All deployments must be rollback-capable
<!-- 모든 배포는 롤백 가능해야 함 -->
- Database migrations managed separately
<!-- 데이터베이스 마이그레이션은 별도 관리 -->
- Rollback scenarios documented in advance
<!-- 롤백 시나리오 사전 문서화 -->

## Performance Requirements
<!-- 성능 요구사항: 응답 시간, 확장성, 리소스 효율성 목표 -->

### Response Time Targets
<!-- 응답 시간 목표 -->
- API average: < 200ms
<!-- API 평균: 200ms 미만 -->
- API 95th percentile: < 500ms
<!-- API 95 percentile: 500ms 미만 -->
- API 99th percentile: < 1000ms
<!-- API 99 percentile: 1000ms 미만 -->

### Scalability
- Horizontally scalable architecture (stateless services)
<!-- 수평 확장 가능한 아키텍처 (Stateless 서비스) -->
- Database: Read replicas for queries
<!-- 데이터베이스: 쿼리용 Read Replica -->

### Resource Efficiency
- No memory leaks (profiling required)
<!-- 메모리 누수 금지 (프로파일링 필수) -->
- No N+1 queries (use eager loading or batch processing)
<!-- N+1 쿼리 금지 (Eager Loading 또는 배치 처리) -->

## Security Requirements
<!-- 보안 요구사항: 인증/인가, 데이터 보호, 취약점 방어 -->

### Authentication & Authorization

### Data Protection
- Logs: PII masking required

### Vulnerability Defense

## Governance
### Authority
This Constitution is the supreme governing document for this project:
<!-- 이 Constitution은 프로젝트의 최상위 규칙입니다 -->
1. Constitution supersedes all other guidelines
<!-- Constitution이 다른 모든 가이드라인보다 우선 -->
2. Tech Lead resolves interpretation disputes
<!-- 해석 충돌 시 Tech Lead가 결정 -->
3. Exceptions require documented justification
<!-- 예외는 문서화된 정당화 필요 -->

### Amendment Process
<!-- 수정 프로세스 -->

**Proposing Changes**
1. Create GitHub Issue with `constitution-amendment` label
<!-- constitution-amendment 라벨로 GitHub Issue 생성 -->
2. Document rationale and impact scope
<!-- 변경 이유와 영향 범위 문서화 -->
3. Propose specific wording changes
<!-- 구체적인 문구 수정안 제시 -->

**Approval Requirements**
- Minor changes (typos, clarifications): 1 Tech Lead approval
<!-- 사소한 변경 (오타, 명확화): Tech Lead 1명 승인 -->
- Principle modifications: 2/3 team vote
<!-- 원칙 변경: 팀원 2/3 찬성 -->
- Major overhaul: All stakeholders + CTO approval
<!-- 대규모 개편: 모든 이해관계자 + CTO 승인 -->

**Migration Plan Required**
If amendments affect existing code:
<!-- 수정이 기존 코드에 영향을 주는 경우 -->
- Document migration steps
<!-- 마이그레이션 단계 문서화 -->
- Provide timeline (typically 1 sprint)
<!-- 타임라인 제시 (보통 1 스프린트) -->

### Enforcement

**PR Review**
- Every PR must verify Constitution compliance
<!-- 모든 PR은 Constitution 준수 여부 확인 -->
- Reviewers check: architecture, testing, security, quality
<!-- 리뷰어가 체크: 아키텍처, 테스팅, 보안, 품질 -->
- Non-compliance results in PR rejection (no exceptions)
<!-- 미준수 시 PR 거부 (예외 없음) -->

**Retrospectives**
- Monthly review: Is Constitution being followed?
<!-- 월간 리뷰: Constitution이 잘 지켜지고 있는가? -->
- Quarterly review: Does Constitution need updates?
<!-- 분기별 리뷰: Constitution 업데이트 필요한가? -->
- Document lessons learned
<!-- 교훈 문서화 -->

**Exceptions**
<!-- 예외 -->
Emergency exceptions allowed for:
<!-- 긴급 예외 허용 상황 -->
- Production incidents (document in postmortem)
<!-- 프로덕션 장애 (포스트모템에 문서화) -->
- Critical security fixes (create tech debt ticket)
<!-- 치명적 보안 수정 (기술 부채 티켓 생성) -->
- Spike/POC work (mark clearly in PR)
<!-- 스파이크/POC 작업 (PR에 명시) -->

### Living Document
This Constitution evolves with the project:
<!-- 이 Constitution은 프로젝트와 함께 진화합니다 -->
- **Regular Updates**: Quarterly
<!-- 정기 업데이트: 분기마다 -->
- **Version Control**: Git tracked with meaningful commits
<!-- 버전 관리: 의미 있는 커밋으로 Git 추적 -->
- **Change Log**: Document all amendments in CHANGELOG.md
<!-- 변경 이력: CHANGELOG.md에 모든 수정 기록 -->
- **Historical Record**: Never delete old versions (archive)
<!-- 히스토리 보존: 이전 버전 삭제 금지 (아카이브) -->

Priority in case of conflicts:
<!-- 충돌 시 우선순위 -->
Constitution > Security Policy > Architecture > Development Guide

---

**Version**: 1.0.0 | **Ratified**: 2025-10-13 | **Last Amended**: 2025-10-13
<!-- 버전: 초기 버전 | 비준일: 최초 승인일 | 최종 수정일: 마지막 수정일 -->
