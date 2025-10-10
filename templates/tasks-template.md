---
description: "기능 구현을 위한 작업 목록 템플릿"
---

# Tasks: [FEATURE NAME]

**입력**: `/specs/[###-feature-name]/`의 설계 문서
**전제조건**: plan.md (필수), spec.md (사용자 스토리용 필수), research.md, data-model.md, contracts/

**테스트**: 아래 예시에는 테스트 작업이 포함되어 있습니다. 테스트는 선택사항입니다 - 기능 명세에서 명시적으로 요청된 경우에만 포함하세요.

**구성**: 각 스토리의 독립적인 구현과 테스트를 가능하게 하기 위해 작업은 사용자 스토리별로 그룹화됩니다.

## 형식: `[ID] [P?] [Story] Description`
- **[P]**: 병렬 실행 가능 (다른 파일, 의존성 없음)
- **[Story]**: 이 작업이 속한 사용자 스토리 (예: US1, US2, US3)
- 설명에 정확한 파일 경로 포함

## 경로 규칙
- **단일 프로젝트**: 리포지토리 루트의 `src/`, `tests/`
- **웹 앱**: `backend/src/`, `frontend/src/`
- **모바일**: `api/src/`, `ios/src/` 또는 `android/src/`
- 아래 표시된 경로는 단일 프로젝트를 가정 - plan.md 구조에 따라 조정

<!-- 
  ============================================================================
  중요: 아래 작업들은 예시 목적으로만 제공되는 샘플 작업입니다.
  
  /speckit.tasks 명령어는 다음을 기반으로 실제 작업으로 교체해야 합니다:
  - spec.md의 사용자 스토리 (우선순위 P1, P2, P3...)
  - plan.md의 기능 요구사항
  - data-model.md의 엔티티
  - contracts/의 엔드포인트
  
  작업은 각 스토리가 다음을 가능하게 하도록 사용자 스토리별로 구성되어야 합니다:
  - 독립적으로 구현
  - 독립적으로 테스트
  - MVP 증분으로 전달
  
  생성된 tasks.md 파일에 이 샘플 작업들을 유지하지 마세요.
  ============================================================================
-->

## Phase 1: Setup (공유 인프라)

**목적**: 프로젝트 초기화 및 기본 구조

- [ ] T001 구현 계획에 따라 프로젝트 구조 생성
- [ ] T002 [framework] 의존성으로 [language] 프로젝트 초기화
- [ ] T003 [P] 린팅 및 포맷팅 도구 구성

---

## Phase 2: Foundational (필수 전제조건)

**목적**: 모든 사용자 스토리가 구현되기 전에 반드시 완료되어야 하는 핵심 인프라

**⚠️ 중요**: 이 페이즈가 완료될 때까지 사용자 스토리 작업을 시작할 수 없습니다

기초 작업의 예시 (프로젝트에 따라 조정):

- [ ] T004 데이터베이스 스키마 및 마이그레이션 프레임워크 설정
- [ ] T005 [P] 인증/권한 프레임워크 구현
- [ ] T006 [P] API 라우팅 및 미들웨어 구조 설정
- [ ] T007 모든 스토리가 의존하는 기본 모델/엔티티 생성
- [ ] T008 에러 핸들링 및 로깅 인프라 구성
- [ ] T009 환경 설정 관리 설정

**체크포인트**: 기초 준비 완료 - 이제 사용자 스토리 구현을 병렬로 시작할 수 있음

---

## Phase 3: User Story 1 - [Title] (우선순위: P1) 🎯 MVP

**목표**: [이 스토리가 전달하는 것에 대한 간략한 설명]

**독립 테스트**: [이 스토리가 독립적으로 작동하는지 검증하는 방법]

### User Story 1용 테스트 (선택사항 - 테스트 요청된 경우만) ⚠️

**참고: 이 테스트들을 먼저 작성하고, 구현 전에 실패하는지 확인하세요**

- [ ] T010 [P] [US1] tests/contract/test_[name].py의 [endpoint]에 대한 계약 테스트
- [ ] T011 [P] [US1] tests/integration/test_[name].py의 [user journey]에 대한 통합 테스트

### User Story 1 구현

- [ ] T012 [P] [US1] src/models/[entity1].py에 [Entity1] 모델 생성
- [ ] T013 [P] [US1] src/models/[entity2].py에 [Entity2] 모델 생성
- [ ] T014 [US1] src/services/[service].py에 [Service] 구현 (T012, T013에 의존)
- [ ] T015 [US1] src/[location]/[file].py에 [endpoint/feature] 구현
- [ ] T016 [US1] 검증 및 에러 핸들링 추가
- [ ] T017 [US1] 사용자 스토리 1 작업을 위한 로깅 추가

**체크포인트**: 이 시점에서 User Story 1은 완전히 기능하며 독립적으로 테스트 가능해야 함

---

## Phase 4: User Story 2 - [Title] (우선순위: P2)

**목표**: [이 스토리가 전달하는 것에 대한 간략한 설명]

**독립 테스트**: [이 스토리가 독립적으로 작동하는지 검증하는 방법]

### User Story 2용 테스트 (선택사항 - 테스트 요청된 경우만) ⚠️

- [ ] T018 [P] [US2] tests/contract/test_[name].py의 [endpoint]에 대한 계약 테스트
- [ ] T019 [P] [US2] tests/integration/test_[name].py의 [user journey]에 대한 통합 테스트

### User Story 2 구현

- [ ] T020 [P] [US2] src/models/[entity].py에 [Entity] 모델 생성
- [ ] T021 [US2] src/services/[service].py에 [Service] 구현
- [ ] T022 [US2] src/[location]/[file].py에 [endpoint/feature] 구현
- [ ] T023 [US2] User Story 1 컴포넌트와 통합 (필요한 경우)

**체크포인트**: 이 시점에서 User Stories 1과 2 모두 독립적으로 작동해야 함

---

## Phase 5: User Story 3 - [Title] (우선순위: P3)

**목표**: [이 스토리가 전달하는 것에 대한 간략한 설명]

**독립 테스트**: [이 스토리가 독립적으로 작동하는지 검증하는 방법]

### User Story 3용 테스트 (선택사항 - 테스트 요청된 경우만) ⚠️

- [ ] T024 [P] [US3] tests/contract/test_[name].py의 [endpoint]에 대한 계약 테스트
- [ ] T025 [P] [US3] tests/integration/test_[name].py의 [user journey]에 대한 통합 테스트

### User Story 3 구현

- [ ] T026 [P] [US3] src/models/[entity].py에 [Entity] 모델 생성
- [ ] T027 [US3] src/services/[service].py에 [Service] 구현
- [ ] T028 [US3] src/[location]/[file].py에 [endpoint/feature] 구현

**체크포인트**: 모든 사용자 스토리가 이제 독립적으로 기능해야 함

---

[필요에 따라 동일한 패턴으로 더 많은 사용자 스토리 페이즈 추가]

---

## Phase N: 마무리 & 범용 관심사

**목적**: 여러 사용자 스토리에 영향을 주는 개선사항

- [ ] TXXX [P] docs/의 문서 업데이트
- [ ] TXXX 코드 정리 및 리팩토링
- [ ] TXXX 모든 스토리에 걸친 성능 최적화
- [ ] TXXX [P] tests/unit/의 추가 유닛 테스트 (요청된 경우)
- [ ] TXXX 보안 강화
- [ ] TXXX quickstart.md 검증 실행

---

## 의존성 & 실행 순서

### 페이즈 의존성

- **Setup (Phase 1)**: 의존성 없음 - 즉시 시작 가능
- **Foundational (Phase 2)**: Setup 완료에 의존 - 모든 사용자 스토리를 차단
- **User Stories (Phase 3+)**: 모두 Foundational 페이즈 완료에 의존
  - 사용자 스토리는 병렬로 진행 가능 (인력이 있는 경우)
  - 또는 우선순위 순으로 순차적으로 (P1 → P2 → P3)
- **Polish (최종 Phase)**: 원하는 모든 사용자 스토리가 완료되어야 함

### 사용자 스토리 의존성

- **User Story 1 (P1)**: Foundational (Phase 2) 이후 시작 가능 - 다른 스토리에 대한 의존성 없음
- **User Story 2 (P2)**: Foundational (Phase 2) 이후 시작 가능 - US1과 통합될 수 있지만 독립적으로 테스트 가능해야 함
- **User Story 3 (P3)**: Foundational (Phase 2) 이후 시작 가능 - US1/US2와 통합될 수 있지만 독립적으로 테스트 가능해야 함

### 각 사용자 스토리 내

- 테스트(포함된 경우)는 구현 전에 작성되고 실패해야 함
- 서비스 전에 모델
- 엔드포인트 전에 서비스
- 통합 전에 핵심 구현
- 다음 우선순위로 이동하기 전에 스토리 완료

### 병렬 실행 기회

- [P]로 표시된 모든 Setup 작업은 병렬 실행 가능
- [P]로 표시된 모든 Foundational 작업은 병렬 실행 가능 (Phase 2 내에서)
- Foundational 페이즈 완료 후, 모든 사용자 스토리는 병렬로 시작 가능 (팀 역량이 허용하는 경우)
- [P]로 표시된 스토리의 모든 테스트는 병렬 실행 가능
- [P]로 표시된 스토리 내 모델은 병렬 실행 가능
- 다른 사용자 스토리는 다른 팀원이 병렬로 작업 가능

---

## 병렬 실행 예시: User Story 1

```bash
# User Story 1의 모든 테스트를 함께 실행 (테스트가 요청된 경우):
Task: "tests/contract/test_[name].py의 [endpoint]에 대한 계약 테스트"
Task: "tests/integration/test_[name].py의 [user journey]에 대한 통합 테스트"

# User Story 1의 모든 모델을 함께 실행:
Task: "src/models/[entity1].py에 [Entity1] 모델 생성"
Task: "src/models/[entity2].py에 [Entity2] 모델 생성"
```

---

## 구현 전략

### MVP 우선 (User Story 1만)

1. Phase 1 완료: Setup
2. Phase 2 완료: Foundational (중요 - 모든 스토리 차단)
3. Phase 3 완료: User Story 1
4. **중단 및 검증**: User Story 1을 독립적으로 테스트
5. 준비되면 배포/데모

### 점진적 전달

1. Setup + Foundational 완료 → 기초 준비 완료
2. User Story 1 추가 → 독립적으로 테스트 → 배포/데모 (MVP!)
3. User Story 2 추가 → 독립적으로 테스트 → 배포/데모
4. User Story 3 추가 → 독립적으로 테스트 → 배포/데모
5. 각 스토리는 이전 스토리를 깨지 않고 가치를 추가

### 병렬 팀 전략

여러 개발자가 있는 경우:

1. 팀이 Setup + Foundational을 함께 완료
2. Foundational 완료 후:
   - 개발자 A: User Story 1
   - 개발자 B: User Story 2
   - 개발자 C: User Story 3
3. 스토리들이 독립적으로 완료되고 통합됨

---

## 참고사항

- [P] 작업 = 다른 파일, 의존성 없음
- [Story] 레이블은 추적을 위해 작업을 특정 사용자 스토리에 매핑
- 각 사용자 스토리는 독립적으로 완료 및 테스트 가능해야 함
- 구현 전에 테스트가 실패하는지 확인
- 각 작업 또는 논리적 그룹 후 커밋
- 모든 체크포인트에서 중단하여 스토리를 독립적으로 검증
- 피해야 할 것: 모호한 작업, 동일 파일 충돌, 독립성을 깨는 스토리 간 의존성

