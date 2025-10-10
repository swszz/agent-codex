---
description: 사용 가능한 설계 아티팩트를 기반으로 기능에 대한 실행 가능하고 의존성이 정렬된 tasks.md를 생성합니다.
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## 사용자 입력

```text
$ARGUMENTS
```

비어있지 않은 경우 진행하기 전에 사용자 입력을 **반드시** 고려해야 합니다.

## 개요

1. **설정**: 리포지토리 루트에서 `{SCRIPT}`를 실행하고 FEATURE_DIR과 AVAILABLE_DOCS 목록을 파싱하세요. 모든 경로는 절대 경로여야 합니다. "I'm Groot"와 같은 인자의 작은따옴표는 이스케이프 구문을 사용하세요: 예 'I'\''m Groot' (또는 가능하면 큰따옴표 사용: "I'm Groot").

2. **설계 문서 로드**: FEATURE_DIR에서 읽기:
   - **필수**: plan.md (기술 스택, 라이브러리, 구조), spec.md (우선순위가 있는 사용자 스토리)
   - **선택**: data-model.md (엔티티), contracts/ (API 엔드포인트), research.md (결정사항), quickstart.md (테스트 시나리오)
   - 참고: 모든 프로젝트가 모든 문서를 가지고 있지 않습니다. 사용 가능한 것을 기반으로 작업을 생성하세요.

3. **작업 생성 워크플로우 실행** (템플릿 구조를 따름):
   - plan.md를 로드하고 기술 스택, 라이브러리, 프로젝트 구조 추출
   - **spec.md를 로드하고 우선순위(P1, P2, P3 등)와 함께 사용자 스토리 추출**
   - data-model.md가 있으면: 엔티티 추출 → 사용자 스토리에 매핑
   - contracts/가 있으면: 각 파일 → 엔드포인트를 사용자 스토리에 매핑
   - research.md가 있으면: 결정사항 추출 → 설정 작업 생성
   - **사용자 스토리별로 구성된 작업 생성**:
     - 설정 작업 (모든 스토리에 필요한 공유 인프라)
     - **기초 작업 (모든 사용자 스토리가 시작되기 전에 완료되어야 하는 전제조건)**
     - 각 사용자 스토리에 대해 (우선순위 순서 P1, P2, P3...):
       - 해당 스토리만 완료하는 데 필요한 모든 작업 그룹화
       - 해당 스토리에 특정한 모델, 서비스, 엔드포인트, UI 컴포넌트 포함
       - 어떤 작업이 [P] 병렬화 가능한지 표시
       - 테스트가 요청되면: 해당 스토리에 특정한 테스트 포함
     - 마무리/통합 작업 (범용 관심사)
   - **테스트는 선택사항**: 기능 명세에서 명시적으로 요청되거나 사용자가 TDD 접근법을 요청한 경우에만 테스트 작업 생성
   - 작업 규칙 적용:
     - 다른 파일 = 병렬로 [P] 표시
     - 같은 파일 = 순차적 ([P] 없음)
     - 테스트가 요청되면: 구현 전 테스트 (TDD 순서)
   - 작업에 순차적으로 번호 매김 (T001, T002...)
   - 사용자 스토리 완료 순서를 보여주는 의존성 그래프 생성
   - 사용자 스토리별 병렬 실행 예시 생성
   - 작업 완성도 검증 (각 사용자 스토리가 필요한 모든 작업을 가지고 있고, 독립적으로 테스트 가능)

4. **tasks.md 생성**: `.specify/templates/tasks-template.md`를 구조로 사용하여 다음으로 채움:
   - plan.md의 올바른 기능 이름
   - Phase 1: 설정 작업 (프로젝트 초기화)
   - Phase 2: 기초 작업 (모든 사용자 스토리를 위한 필수 전제조건)
   - Phase 3+: 사용자 스토리당 하나의 페이즈 (spec.md의 우선순위 순서)
     - 각 페이즈 포함: 스토리 목표, 독립 테스트 기준, 테스트 (요청된 경우), 구현 작업
     - 각 작업에 대한 명확한 [Story] 레이블 (US1, US2, US3...)
     - 각 스토리 내 병렬화 가능한 작업에 대한 [P] 마커
     - 각 스토리 페이즈 후 체크포인트 마커
   - 최종 Phase: 마무리 & 범용 관심사
   - 실행 순서대로 번호가 매겨진 작업 (T001, T002...)
   - 각 작업에 대한 명확한 파일 경로
   - 스토리 완료 순서를 보여주는 의존성 섹션
   - 스토리별 병렬 실행 예시
   - 구현 전략 섹션 (MVP 우선, 점진적 전달)

5. **보고**: 생성된 tasks.md 경로와 요약 출력:
   - 총 작업 수
   - 사용자 스토리별 작업 수
   - 식별된 병렬 실행 기회
   - 각 스토리에 대한 독립 테스트 기준
   - 제안된 MVP 범위 (일반적으로 User Story 1만)

작업 생성을 위한 컨텍스트: {ARGS}

tasks.md는 즉시 실행 가능해야 합니다 - 각 작업은 추가 컨텍스트 없이 LLM이 완료할 수 있을 만큼 구체적이어야 합니다.

## 작업 생성 규칙

**중요**: 테스트는 선택사항입니다. 사용자가 기능 명세에서 테스팅 또는 TDD 접근법을 명시적으로 요청한 경우에만 테스트 작업을 생성하세요.

**CRITICAL**: Tasks MUST be organized by user story to enable independent implementation and testing.

1. **From User Stories (spec.md)** - PRIMARY ORGANIZATION:
   - Each user story (P1, P2, P3...) gets its own phase
   - Map all related components to their story:
     - Models needed for that story
     - Services needed for that story
     - Endpoints/UI needed for that story
     - If tests requested: Tests specific to that story
   - Mark story dependencies (most stories should be independent)
   
2. **From Contracts**:
   - Map each contract/endpoint → to the user story it serves
   - If tests requested: Each contract → contract test task [P] before implementation in that story's phase
   
3. **From Data Model**:
   - Map each entity → to the user story(ies) that need it
   - If entity serves multiple stories: Put in earliest story or Setup phase
   - Relationships → service layer tasks in appropriate story phase
   
4. **From Setup/Infrastructure**:
   - Shared infrastructure → Setup phase (Phase 1)
   - Foundational/blocking tasks → Foundational phase (Phase 2)
     - Examples: Database schema setup, authentication framework, core libraries, base configurations
     - These MUST complete before any user story can be implemented
   - Story-specific setup → within that story's phase

5. **Ordering**:
   - Phase 1: Setup (project initialization)
   - Phase 2: Foundational (blocking prerequisites - must complete before user stories)
   - Phase 3+: User Stories in priority order (P1, P2, P3...)
     - Within each story: Tests (if requested) → Models → Services → Endpoints → Integration
   - Final Phase: Polish & Cross-Cutting Concerns
   - Each user story phase should be a complete, independently testable increment
