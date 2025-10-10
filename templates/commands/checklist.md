---
description: 사용자 요구사항을 기반으로 현재 기능에 대한 사용자 정의 체크리스트를 생성합니다.
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## 체크리스트 목적: "영어를 위한 단위 테스트"

**중요 개념**: 체크리스트는 **요구사항 작성을 위한 단위 테스트**입니다 - 주어진 도메인에서 요구사항의 품질, 명확성 및 완성도를 검증합니다.

**검증/테스팅용이 아님**:
- ❌ "버튼이 올바르게 클릭되는지 검증"이 아님
- ❌ "에러 핸들링이 작동하는지 테스트"가 아님
- ❌ "API가 200을 반환하는지 확인"이 아님
- ❌ 코드/구현이 명세와 일치하는지 확인하는 것이 아님

**요구사항 품질 검증용**:
- ✅ "모든 카드 타입에 대해 시각적 계층 요구사항이 정의되어 있는가?" (완성도)
- ✅ "'눈에 띄는 표시'가 구체적인 크기/위치로 정량화되어 있는가?" (명확성)
- ✅ "모든 인터랙티브 요소에 걸쳐 호버 상태 요구사항이 일관되는가?" (일관성)
- ✅ "키보드 네비게이션에 대한 접근성 요구사항이 정의되어 있는가?" (커버리지)
- ✅ "로고 이미지 로드 실패 시 무엇이 발생하는지 명세가 정의하는가?" (엣지 케이스)

**비유**: 명세가 영어로 작성된 코드라면, 체크리스트는 그것의 단위 테스트 스위트입니다. 요구사항이 잘 작성되었는지, 완전한지, 모호하지 않은지, 구현 준비가 되었는지를 테스트하는 것입니다 - 구현이 작동하는지가 아닙니다.

## 사용자 입력

```text
$ARGUMENTS
```

비어있지 않은 경우 진행하기 전에 사용자 입력을 **반드시** 고려해야 합니다.

## 실행 단계

1. **설정**: 리포지토리 루트에서 `{SCRIPT}`를 실행하고 FEATURE_DIR 및 AVAILABLE_DOCS 목록에 대한 JSON을 파싱하세요.
   - 모든 파일 경로는 절대 경로여야 합니다.
   - "I'm Groot"와 같은 인자의 작은따옴표는 이스케이프 구문을 사용하세요: 예 'I'\''m Groot' (또는 가능하면 큰따옴표 사용: "I'm Groot").

2. **의도 명확화 (동적)**: spec/plan/tasks에서 추출된 신호 + 사용자 표현에서 생성된 최대 3개의 초기 컨텍스트 명확화 질문을 도출하세요. 다음을 **반드시** 충족:
   - 사용자의 표현 + spec/plan/tasks에서 추출된 신호에서 생성
   - 체크리스트 콘텐츠를 실질적으로 변경하는 정보에 대해서만 질문
   - `$ARGUMENTS`에서 이미 명확한 경우 개별적으로 건너뛰기
   - 폭보다 정밀도 선호

   생성 알고리즘:
   1. 신호 추출: 기능 도메인 키워드 (예: auth, latency, UX, API), 위험 지표 ("critical", "must", "compliance"), 이해관계자 힌트 ("QA", "review", "security team"), 명시적 결과물 ("a11y", "rollback", "contracts").
   2. 신호를 관련성별로 순위가 매겨진 후보 집중 영역(최대 4개)으로 클러스터링.
   3. 명시적이지 않은 경우 가능한 대상 & 타이밍 식별 (작성자, 리뷰어, QA, 릴리스).
   4. 누락된 차원 감지: 범위 폭, 깊이/엄격성, 위험 강조, 제외 경계, 측정 가능한 수락 기준.
   5. 다음 원형에서 선택된 질문 공식화:
      - 범위 개선 (예: "X 및 Y와의 통합 접점을 포함해야 하는가 아니면 로컬 모듈 정확성으로 제한되어야 하는가?")
      - 위험 우선순위 지정 (예: "어떤 잠재적 위험 영역이 필수 게이팅 체크를 받아야 하는가?")
      - 깊이 보정 (예: "가벼운 사전 커밋 정상 목록인가 아니면 공식 릴리스 게이트인가?")
      - 대상 프레이밍 (예: "작성자만 사용하는가 아니면 PR 리뷰 중 동료가 사용하는가?")
      - 경계 제외 (예: "이번 라운드에서 성능 튜닝 항목을 명시적으로 제외해야 하는가?")
      - 시나리오 클래스 갭 (예: "복구 플로우가 감지되지 않음—롤백 / 부분 실패 경로가 범위 내에 있는가?")

   질문 형식 규칙:
   - 옵션을 제시하는 경우 열이 있는 간결한 테이블 생성: 옵션 | 후보 | 중요한 이유
   - 최대 A–E 옵션으로 제한; 자유형 답변이 더 명확한 경우 테이블 생략
   - 사용자가 이미 말한 것을 다시 말하도록 요청하지 않기
   - 추측 카테고리 피하기 (환각 금지). 불확실한 경우 명시적으로 질문: "X가 범위에 속하는지 확인."

   상호작용이 불가능할 때 기본값:
   - 깊이: 표준
   - 대상: 코드 관련인 경우 리뷰어 (PR); 그렇지 않으면 작성자
   - 집중: 상위 2개 관련성 클러스터

   질문 출력 (Q1/Q2/Q3 레이블). 답변 후: ≥2개의 시나리오 클래스 (대안 / 예외 / 복구 / 비기능 도메인)가 불명확한 경우, 각각 한 줄 정당화가 있는 최대 2개의 추가 타겟 후속 조치(Q4/Q5)를 **할 수 있습니다** (예: "미해결 복구 경로 위험"). 총 5개 질문을 초과하지 마세요. 사용자가 명시적으로 더 거부하면 에스컬레이션 건너뛰기.

3. **사용자 요청 이해**: `$ARGUMENTS` + 명확화 답변 결합:
   - 체크리스트 테마 도출 (예: 보안, 리뷰, 배포, ux)
   - 사용자가 언급한 명시적 필수 항목 통합
   - 집중 선택을 카테고리 스캐폴딩에 매핑
   - spec/plan/tasks에서 누락된 컨텍스트 추론 (환각 금지)

4. **기능 컨텍스트 로드**: FEATURE_DIR에서 읽기:
   - spec.md: 기능 요구사항 및 범위
   - plan.md (있는 경우): 기술 세부사항, 의존성
   - tasks.md (있는 경우): 구현 작업
   
   **컨텍스트 로딩 전략**:
   - 활성 집중 영역과 관련된 필요한 부분만 로드 (전체 파일 덤프 피하기)
   - 긴 섹션을 간결한 시나리오/요구사항 포인트로 요약 선호
   - 점진적 공개 사용: 갭이 감지된 경우에만 후속 검색 추가
   - 소스 문서가 큰 경우 원시 텍스트를 포함하는 대신 중간 요약 항목 생성

5. **체크리스트 생성** - "요구사항을 위한 단위 테스트" 생성:
   - 존재하지 않는 경우 `FEATURE_DIR/checklists/` 디렉토리 생성
   - 고유 체크리스트 파일명 생성:
     - 도메인을 기반으로 짧고 설명적인 이름 사용 (예: `ux.md`, `api.md`, `security.md`)
     - 형식: `[domain].md` 
     - 파일이 있으면 기존 파일에 추가
   - CHK001부터 순차적으로 항목 번호 매김
   - 각 `/speckit.checklist` 실행은 새 파일을 생성 (기존 체크리스트를 덮어쓰지 않음)

   **핵심 원칙 - 구현이 아닌 요구사항을 테스트**:
   모든 체크리스트 항목은 다음에 대해 요구사항 자체를 **반드시** 평가:
   - **완성도**: 모든 필요한 요구사항이 있는가?
   - **명확성**: 요구사항이 모호하지 않고 구체적인가?
   - **일관성**: 요구사항이 서로 정렬되는가?
   - **측정 가능성**: 요구사항을 객관적으로 검증할 수 있는가?
   - **커버리지**: 모든 시나리오/엣지 케이스가 다뤄지는가?
   
   **카테고리 구조** - 요구사항 품질 차원별로 항목 그룹화:
   - **요구사항 완성도** (모든 필요한 요구사항이 문서화되었는가?)
   - **요구사항 명확성** (요구사항이 구체적이고 모호하지 않은가?)
   - **요구사항 일관성** (요구사항이 충돌 없이 정렬되는가?)
   - **수락 기준 품질** (성공 기준이 측정 가능한가?)
   - **시나리오 커버리지** (모든 플로우/케이스가 다뤄지는가?)
   - **엣지 케이스 커버리지** (경계 조건이 정의되었는가?)
   - **비기능 요구사항** (성능, 보안, 접근성 등 - 명시되었는가?)
   - **의존성 & 가정** (문서화되고 검증되었는가?)
   - **모호성 & 충돌** (무엇이 명확화가 필요한가?)
   
   **HOW TO WRITE CHECKLIST ITEMS - "Unit Tests for English"**:
   
   ❌ **WRONG** (Testing implementation):
   - "Verify landing page displays 3 episode cards"
   - "Test hover states work on desktop"
   - "Confirm logo click navigates home"
   
   ✅ **CORRECT** (Testing requirements quality):
   - "Are the exact number and layout of featured episodes specified?" [Completeness]
   - "Is 'prominent display' quantified with specific sizing/positioning?" [Clarity]
   - "Are hover state requirements consistent across all interactive elements?" [Consistency]
   - "Are keyboard navigation requirements defined for all interactive UI?" [Coverage]
   - "Is the fallback behavior specified when logo image fails to load?" [Edge Cases]
   - "Are loading states defined for asynchronous episode data?" [Completeness]
   - "Does the spec define visual hierarchy for competing UI elements?" [Clarity]
   
   **ITEM STRUCTURE**:
   Each item should follow this pattern:
   - Question format asking about requirement quality
   - Focus on what's WRITTEN (or not written) in the spec/plan
   - Include quality dimension in brackets [Completeness/Clarity/Consistency/etc.]
   - Reference spec section `[Spec §X.Y]` when checking existing requirements
   - Use `[Gap]` marker when checking for missing requirements
   
   **EXAMPLES BY QUALITY DIMENSION**:
   
   Completeness:
   - "Are error handling requirements defined for all API failure modes? [Gap]"
   - "Are accessibility requirements specified for all interactive elements? [Completeness]"
   - "Are mobile breakpoint requirements defined for responsive layouts? [Gap]"
   
   Clarity:
   - "Is 'fast loading' quantified with specific timing thresholds? [Clarity, Spec §NFR-2]"
   - "Are 'related episodes' selection criteria explicitly defined? [Clarity, Spec §FR-5]"
   - "Is 'prominent' defined with measurable visual properties? [Ambiguity, Spec §FR-4]"
   
   Consistency:
   - "Do navigation requirements align across all pages? [Consistency, Spec §FR-10]"
   - "Are card component requirements consistent between landing and detail pages? [Consistency]"
   
   Coverage:
   - "Are requirements defined for zero-state scenarios (no episodes)? [Coverage, Edge Case]"
   - "Are concurrent user interaction scenarios addressed? [Coverage, Gap]"
   - "Are requirements specified for partial data loading failures? [Coverage, Exception Flow]"
   
   Measurability:
   - "Are visual hierarchy requirements measurable/testable? [Acceptance Criteria, Spec §FR-1]"
   - "Can 'balanced visual weight' be objectively verified? [Measurability, Spec §FR-2]"

   **Scenario Classification & Coverage** (Requirements Quality Focus):
   - Check if requirements exist for: Primary, Alternate, Exception/Error, Recovery, Non-Functional scenarios
   - For each scenario class, ask: "Are [scenario type] requirements complete, clear, and consistent?"
   - If scenario class missing: "Are [scenario type] requirements intentionally excluded or missing? [Gap]"
   - Include resilience/rollback when state mutation occurs: "Are rollback requirements defined for migration failures? [Gap]"

   **Traceability Requirements**:
   - MINIMUM: ≥80% of items MUST include at least one traceability reference
   - Each item should reference: spec section `[Spec §X.Y]`, or use markers: `[Gap]`, `[Ambiguity]`, `[Conflict]`, `[Assumption]`
   - If no ID system exists: "Is a requirement & acceptance criteria ID scheme established? [Traceability]"

   **Surface & Resolve Issues** (Requirements Quality Problems):
   Ask questions about the requirements themselves:
   - Ambiguities: "Is the term 'fast' quantified with specific metrics? [Ambiguity, Spec §NFR-1]"
   - Conflicts: "Do navigation requirements conflict between §FR-10 and §FR-10a? [Conflict]"
   - Assumptions: "Is the assumption of 'always available podcast API' validated? [Assumption]"
   - Dependencies: "Are external podcast API requirements documented? [Dependency, Gap]"
   - Missing definitions: "Is 'visual hierarchy' defined with measurable criteria? [Gap]"

   **Content Consolidation**:
   - Soft cap: If raw candidate items > 40, prioritize by risk/impact
   - Merge near-duplicates checking the same requirement aspect
   - If >5 low-impact edge cases, create one item: "Are edge cases X, Y, Z addressed in requirements? [Coverage]"

   **🚫 ABSOLUTELY PROHIBITED** - These make it an implementation test, not a requirements test:
   - ❌ Any item starting with "Verify", "Test", "Confirm", "Check" + implementation behavior
   - ❌ References to code execution, user actions, system behavior
   - ❌ "Displays correctly", "works properly", "functions as expected"
   - ❌ "Click", "navigate", "render", "load", "execute"
   - ❌ Test cases, test plans, QA procedures
   - ❌ Implementation details (frameworks, APIs, algorithms)
   
   **✅ REQUIRED PATTERNS** - These test requirements quality:
   - ✅ "Are [requirement type] defined/specified/documented for [scenario]?"
   - ✅ "Is [vague term] quantified/clarified with specific criteria?"
   - ✅ "Are requirements consistent between [section A] and [section B]?"
   - ✅ "Can [requirement] be objectively measured/verified?"
   - ✅ "Are [edge cases/scenarios] addressed in requirements?"
   - ✅ "Does the spec define [missing aspect]?"

6. **Structure Reference**: Generate the checklist following the canonical template in `templates/checklist-template.md` for title, meta section, category headings, and ID formatting. If template is unavailable, use: H1 title, purpose/created meta lines, `##` category sections containing `- [ ] CHK### <requirement item>` lines with globally incrementing IDs starting at CHK001.

7. **Report**: Output full path to created checklist, item count, and remind user that each run creates a new file. Summarize:
   - Focus areas selected
   - Depth level
   - Actor/timing
   - Any explicit user-specified must-have items incorporated

**Important**: Each `/speckit.checklist` command invocation creates a checklist file using short, descriptive names unless file already exists. This allows:

- Multiple checklists of different types (e.g., `ux.md`, `test.md`, `security.md`)
- Simple, memorable filenames that indicate checklist purpose
- Easy identification and navigation in the `checklists/` folder

To avoid clutter, use descriptive types and clean up obsolete checklists when done.

## Example Checklist Types & Sample Items

**UX Requirements Quality:** `ux.md`

Sample items (testing the requirements, NOT the implementation):
- "Are visual hierarchy requirements defined with measurable criteria? [Clarity, Spec §FR-1]"
- "Is the number and positioning of UI elements explicitly specified? [Completeness, Spec §FR-1]"
- "Are interaction state requirements (hover, focus, active) consistently defined? [Consistency]"
- "Are accessibility requirements specified for all interactive elements? [Coverage, Gap]"
- "Is fallback behavior defined when images fail to load? [Edge Case, Gap]"
- "Can 'prominent display' be objectively measured? [Measurability, Spec §FR-4]"

**API Requirements Quality:** `api.md`

Sample items:
- "Are error response formats specified for all failure scenarios? [Completeness]"
- "Are rate limiting requirements quantified with specific thresholds? [Clarity]"
- "Are authentication requirements consistent across all endpoints? [Consistency]"
- "Are retry/timeout requirements defined for external dependencies? [Coverage, Gap]"
- "Is versioning strategy documented in requirements? [Gap]"

**Performance Requirements Quality:** `performance.md`

Sample items:
- "Are performance requirements quantified with specific metrics? [Clarity]"
- "Are performance targets defined for all critical user journeys? [Coverage]"
- "Are performance requirements under different load conditions specified? [Completeness]"
- "Can performance requirements be objectively measured? [Measurability]"
- "Are degradation requirements defined for high-load scenarios? [Edge Case, Gap]"

**Security Requirements Quality:** `security.md`

Sample items:
- "Are authentication requirements specified for all protected resources? [Coverage]"
- "Are data protection requirements defined for sensitive information? [Completeness]"
- "Is the threat model documented and requirements aligned to it? [Traceability]"
- "Are security requirements consistent with compliance obligations? [Consistency]"
- "Are security failure/breach response requirements defined? [Gap, Exception Flow]"

## Anti-Examples: What NOT To Do

**❌ WRONG - These test implementation, not requirements:**

```markdown
- [ ] CHK001 - Verify landing page displays 3 episode cards [Spec §FR-001]
- [ ] CHK002 - Test hover states work correctly on desktop [Spec §FR-003]
- [ ] CHK003 - Confirm logo click navigates to home page [Spec §FR-010]
- [ ] CHK004 - Check that related episodes section shows 3-5 items [Spec §FR-005]
```

**✅ CORRECT - These test requirements quality:**

```markdown
- [ ] CHK001 - Are the number and layout of featured episodes explicitly specified? [Completeness, Spec §FR-001]
- [ ] CHK002 - Are hover state requirements consistently defined for all interactive elements? [Consistency, Spec §FR-003]
- [ ] CHK003 - Are navigation requirements clear for all clickable brand elements? [Clarity, Spec §FR-010]
- [ ] CHK004 - Is the selection criteria for related episodes documented? [Gap, Spec §FR-005]
- [ ] CHK005 - Are loading state requirements defined for asynchronous episode data? [Gap]
- [ ] CHK006 - Can "visual hierarchy" requirements be objectively measured? [Measurability, Spec §FR-001]
```

**Key Differences:**
- Wrong: Tests if the system works correctly
- Correct: Tests if the requirements are written correctly
- Wrong: Verification of behavior
- Correct: Validation of requirement quality
- Wrong: "Does it do X?" 
- Correct: "Is X clearly specified?"
