# [PROJECT_NAME] Constitution
<!-- 예시: TaskFlow Constitution, AI 챗봇 플랫폼 Constitution 등 -->

## Core Principles

### I. 테스트 우선 개발 (NON-NEGOTIABLE)
- 구현 전 반드시 테스트 작성: 테스트 작성 → 사용자 승인 → 테스트 실패 확인 → 구현
- Red-Green-Refactor 사이클 엄격히 준수
- 최소 커버리지 80% 필수 (CI에서 자동 검증)
- PR 머지 시 모든 테스트 통과 필수 (예외 없음)

### II. 명확한 요구사항 우선
- 모호한 요구사항으로 코딩 시작 금지
- 불확실한 부분은 구현 전 반드시 질문하고 명확화
- 사용자 스토리와 인수 기준을 먼저 정의
- "아마도", "~인 것 같다"로 시작하는 구현 금지

### III. 단순함이 최우선
- 복잡한 솔루션보다 단순한 솔루션 선택
- YAGNI 원칙: 지금 필요하지 않으면 구현하지 않음
- 추상화는 최소 3번의 반복 패턴 발견 후
- 복잡도 증가는 반드시 문서화된 정당화 필요

### IV. 시큐리티 기본 탑재
- 모든 엔드포인트는 기본적으로 인증 필요 (public은 명시적 표시)
- 민감 정보는 절대 하드코딩 금지 (환경변수/시크릿 관리자 사용)
- 사용자 입력은 모두 검증 (클라이언트 데이터 신뢰 금지)
- SQL 인젝션, XSS 방어 기본 적용

### V. 관찰 가능성 필수
- 구조화된 로깅 (JSON 형식, correlation ID 포함)
- 의미 있는 에러 메시지 (디버깅 가능한 컨텍스트 포함)
- 주요 로직에 메트릭 추가 (응답 시간, 에러율)
- Health check 엔드포인트 필수 (liveness, readiness)

### VI. 문서화는 코드와 함께
- Public API는 모두 문서화 (JSDoc, Javadoc 등)
- 복잡한 로직은 "왜" 설명하는 주석 필수
- README.md에 로컬 실행 방법 명시 (< 10분 셋업)
- API 변경 시 문서 동시 업데이트

### VII. 하위 호환성 유지
- API 버전 관리 필수 (/v1/, /v2/ 등)
- Breaking change는 최소 1개 버전 deprecation 기간
- 데이터베이스 마이그레이션은 forward-only
- 기능 플래그로 점진적 롤아웃

## 기술 제약사항

### 필수 기술 스택
**선호 언어 및 프레임워크**
- 타입 안정성 필수 (TypeScript, Java, Go, Rust 등)
- 검증된 프레임워크 우선 (Spring Boot, Express, FastAPI 등)
- 최신 LTS 버전 사용

**데이터베이스**
- 프로덕션은 PostgreSQL/MySQL (검증된 RDBMS)
- 로컬 개발은 Docker로 동일 환경 구성
- ORM/Query Builder 사용 (Raw SQL 최소화)

**API 설계**
- RESTful 원칙 준수 (명사형 리소스, HTTP 메소드 의미 일치)
- 에러 응답 표준화 (상태 코드, 메시지, 상세 정보)
- 요청/응답 예시 문서화

### 금지 기술
❌ 타입 없는 언어 (순수 JavaScript, Python without type hints)
❌ 검증되지 않은 신기술 (production에서)
❌ 동기식 blocking call 남발 (비동기 처리 우선)
❌ 공유 mutable 상태 (불변성 원칙)

### 코드 품질 기준
**구조**
- 함수 길이: 최대 50줄
- 파일 길이: 최대 300줄
- 중첩 깊이: 최대 3단계
- 순환 복잡도: 최대 10

**네이밍**
- 약어 금지 (user 대신 usr 같은 것)
- 발음 가능한 이름 (genYmdhms 같은 것 금지)
- 검색 가능한 이름 (상수에 7 같은 magic number 금지)

**의존성 관리**
- 외부 라이브러리 추가 시 정당화 문서 필요
- 보안 취약점 있는 의존성 사용 금지
- 라이선스 확인 (GPL 등 제한적 라이선스 주의)

## 개발 워크플로우

### Git 전략
**브랜치 모델**
- `main`: 프로덕션 배포 가능 상태 (보호됨)
- `feature/*`: 새 기능 개발
- `fix/*`: 버그 수정
- `hotfix/*`: 긴급 프로덕션 수정

**커밋 메시지**
```
<타입>: <제목> (50자 이내)

<본문> (선택사항, 72자마다 줄바꿈)
- 무엇을, 왜 변경했는지 설명
- 어떻게는 코드가 설명

<푸터> (선택사항)
Fixes #123
Breaking Change: API v1 endpoint 제거됨
```

타입: feat, fix, docs, test, refactor, chore

### PR 필수 요구사항
**자동 검증 (CI)**
- ✅ 모든 테스트 통과
- ✅ 코드 커버리지 80% 이상
- ✅ Linting 통과
- ✅ 빌드 성공

**수동 검증 (리뷰어)**
- ✅ 최소 1명 승인 (복잡한 변경은 2명)
- ✅ 요구사항과 일치 확인
- ✅ 보안 이슈 없음 확인
- ✅ 성능 영향 검토

**PR 설명 필수 항목**
```markdown
## 변경 내용
- 무엇을 변경했는지

## 변경 이유
- 왜 이 변경이 필요한지

## 테스트 방법
- 어떻게 검증했는지

## 스크린샷 (UI 변경 시)
- Before/After

## 체크리스트
- [ ] 테스트 추가/업데이트
- [ ] 문서 업데이트
- [ ] Breaking change 체크
```

### 코드 리뷰 원칙
**리뷰어 책임**
- 24시간 이내 첫 리뷰 (긴급 시 4시간)
- 건설적 피드백 (구체적 개선 방안 제시)
- 칭찬도 피드백 ("이 부분 좋네요" 등)

**작성자 책임**
- 셀프 리뷰 먼저 (PR 올리기 전 본인이 먼저 체크)
- 피드백에 대한 응답 (수정 또는 반론)
- 리뷰어의 시간 존중 (작은 PR 선호)

**리뷰 체크리스트**
- [ ] 요구사항 충족
- [ ] 엣지 케이스 처리
- [ ] 에러 핸들링 적절
- [ ] 테스트 충분
- [ ] 네이밍 명확
- [ ] 중복 코드 없음
- [ ] 보안 이슈 없음
- [ ] 성능 문제 없음

### 배포 프로세스
**환경 구성**
- Development → Staging → Production
- 각 환경은 독립적 (상호 의존 금지)
- 환경별 설정은 환경변수로 관리

**배포 절차**
1. Staging 배포 → 자동 테스트 실행
2. Staging 수동 검증 (QA)
3. Production 배포 (승인 필요)
4. Production 모니터링 (24시간)

**롤백 준비**
- 모든 배포는 롤백 가능해야 함
- 데이터베이스 마이그레이션은 별도 관리
- 롤백 시나리오 사전 문서화

## 성능 요구사항

### 응답 시간 목표
- API 평균: < 200ms
- API 95 percentile: < 500ms
- API 99 percentile: < 1000ms
- 페이지 로드: < 3초 (3G 네트워크)

### 확장성
- 수평 확장 가능한 아키텍처 (Stateless 서비스)
- 데이터베이스: Read Replica 활용
- 캐싱 전략: Redis (TTL 명시 필수)
- Rate Limiting: 사용자당 분당 1000 요청

### 리소스 효율
- 메모리 누수 금지 (프로파일링 필수)
- N+1 쿼리 금지 (Eager Loading 또는 배치 처리)
- 불필요한 재렌더링 최소화 (Frontend)
- 이미지 최적화 (WebP, lazy loading)

## 보안 요구사항

### 인증/인가
- JWT 토큰 기반 인증
- Refresh Token 구현 (Access Token 만료 대비)
- Role-Based Access Control (RBAC)
- 비밀번호: BCrypt (cost factor 12 이상)

### 데이터 보호
- 전송 중: HTTPS 필수 (TLS 1.3)
- 저장 시: 민감 데이터 암호화 (AES-256)
- 개인정보: 최소 수집, 명시적 동의
- 로그: PII 마스킹 필수

### 취약점 방어
- SQL Injection: Prepared Statement 사용
- XSS: 입력 검증 + 출력 이스케이핑
- CSRF: CSRF 토큰 구현
- Dependency Scan: 주간 보안 취약점 검사

## Governance

### 권한 구조
이 Constitution은 프로젝트의 최상위 규칙입니다:
1. Constitution > 다른 모든 가이드라인
2. 해석 충돌 시 Tech Lead가 최종 결정
3. 예외 처리는 문서화된 정당화 필요

### 수정 프로세스
**변경 제안**
1. GitHub Issue 생성 (`constitution-amendment` 라벨)
2. 변경 이유와 영향 범위 문서화
3. 구체적인 문구 수정안 제시

**승인 요구사항**
- 사소한 수정 (오타, 명확화): Tech Lead 1명 승인
- 원칙 변경: 팀원 2/3 찬성
- 대규모 개편: 전체 이해관계자 + CTO 승인

**마이그레이션 계획 필수**
수정이 기존 코드에 영향을 주는 경우:
- 마이그레이션 단계 문서화
- 타임라인 제시 (보통 1 스프린트)
- 영향받는 컴포넌트 추적 이슈 생성

### 적용 규칙
**PR 리뷰**
- 모든 PR은 Constitution 준수 여부 확인
- 리뷰어가 체크: 아키텍처, 테스팅, 보안, 품질
- 미준수 시 PR 거부 (예외 없음)

**회고**
- 월간 리뷰: Constitution이 잘 지켜지고 있는가?
- 분기별 리뷰: Constitution 업데이트 필요한가?
- 교훈 문서화

**예외 처리**
긴급 예외 허용 상황:
- 프로덕션 장애 대응 (포스트모템에 문서화)
- 치명적 보안 취약점 수정 (기술 부채 티켓 생성)
- 스파이크/POC 작업 (PR에 명시)

모든 예외는 반드시:
1. `CONSTITUTION_EXCEPTIONS.md`에 문서화
2. 기술 부채 티켓 생성
3. 해결 기한 설정

### 살아있는 문서
이 Constitution은 프로젝트와 함께 진화합니다:
- **정기 업데이트**: 분기마다
- **버전 관리**: Git으로 추적 (의미 있는 커밋 메시지)
- **변경 이력**: CHANGELOG.md에 모든 수정 기록
- **히스토리 보존**: 이전 버전 삭제 금지 (아카이브)

### 관련 문서
- `DEVELOPMENT_GUIDE.md`: 일상적 개발 실무
- `ARCHITECTURE.md`: 시스템 설계 결정사항
- `SECURITY_POLICY.md`: 보안 절차
- `CONTRIBUTING.md`: 외부 기여 가이드라인

충돌 시 우선순위:
Constitution > Security Policy > Architecture > Development Guide

---

**Version**: 1.0.0 | **Ratified**: 2025-10-13 | **Last Amended**: 2025-10-13
