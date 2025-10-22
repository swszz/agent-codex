# Claude Code 핵심 개념 가이드

Claude Code의 확장 메커니즘과 커스터마이징 옵션에 대한 종합 가이드입니다.

## 목차

1. [개념 비교표](#개념-비교표)
2. [Slash Commands (슬래시 커맨드)](#slash-commands-슬래시-커맨드)
3. [Sub-Agents (서브 에이전트)](#sub-agents-서브-에이전트)
4. [Agent Skills (에이전트 스킬)](#agent-skills-에이전트-스킬)
5. [Hooks (훅)](#hooks-훅)
6. [Output Styles (출력 스타일)](#output-styles-출력-스타일)
7. [Plugins (플러그인)](#plugins-플러그인)

---

## 개념 비교표

| 구분 | Slash Commands | Sub-Agents | Agent Skills | Hooks | Output Styles | Plugins |
|------|----------------|------------|--------------|-------|---------------|---------|
| **목적** | 자주 사용하는 프롬프트 단축 | 특정 작업을 위한 전문 AI | Claude의 기능 확장 | 이벤트 기반 자동화 | 시스템 프롬프트 커스터마이징 | 기능 번들 배포 |
| **실행 방식** | 사용자 명시적 호출 | Claude 자동/명시적 위임 | Claude 자동 활성화 | 이벤트 발생 시 자동 | 지속적 적용 | 설치 후 컴포넌트별 작동 |
| **저장 위치** | `.claude/commands/`<br>`~/.claude/commands/` | `.claude/agents/`<br>`~/.claude/agents/` | `.claude/skills/`<br>`~/.claude/skills/` | `.claude/settings.json` | `.claude/output-styles/`<br>`~/.claude/output-styles/` | 마켓플레이스 경로 |
| **파일 형식** | Markdown (`.md`) | Markdown with YAML | Markdown with YAML | JSON 설정 | Markdown with YAML | 디렉토리 구조 + JSON |
| **컨텍스트** | 메인 대화 공유 | 독립된 컨텍스트 창 | 메인 대화 공유 | 세션/이벤트 데이터 | 메인 대화 영향 | 컴포넌트별 다름 |
| **도구 접근** | `allowed-tools` 지정 | YAML에서 `tools` 지정 | `allowed-tools` 지정 | 쉘 커맨드 실행 | 영향 없음 | 컴포넌트별 다름 |
| **사용 예시** | `/commit`, `/review-pr` | `code-reviewer`, `test-writer` | PDF 추출, Excel 처리 | Pre-commit 검사, 자동 포매팅 | 교육용, 설명형 | 팀 워크플로우 패키지 |
| **베스트 유스케이스** | 빠른 반복 작업 | 복잡한 전문 작업 | 특정 파일 타입/도메인 | 품질 게이트, 자동화 | 학습/설명 모드 | 팀 표준화 |
| **공유 방법** | Git 커밋 | Git 커밋 | Git 커밋 또는 플러그인 | Git 커밋 | Git 커밋 | 마켓플레이스 |
| **인자 지원** | ✅ (`$1`, `$2`, `$ARGUMENTS`) | ✅ (프롬프트에 포함) | ✅ (스킬 내부 로직) | ✅ (JSON stdin) | ❌ | 컴포넌트별 다름 |
| **Bash 실행** | ✅ (`!` prefix) | ✅ (Bash 도구 사용) | ✅ (도구 권한 내) | ✅ (직접 실행) | ❌ | 컴포넌트별 다름 |

---

## Slash Commands (슬래시 커맨드)

### 개요

Slash Commands는 자주 사용하는 프롬프트를 재사용 가능한 명령어로 저장하는 기능입니다. `/` 기호로 시작하며, 단일 Markdown 파일로 정의됩니다.

### 주요 특징

- **명시적 호출**: 사용자가 직접 `/command-name` 형태로 입력
- **인자 전달**: `$1`, `$2` 또는 `$ARGUMENTS`로 동적 값 전달
- **Bash 실행**: `!` prefix로 쉘 커맨드 실행 가능
- **파일 참조**: `@` prefix로 파일 경로 참조

### 저장 위치

```
프로젝트 레벨 (우선순위 높음):
.claude/commands/
  ├── commit.md
  ├── review-pr.md
  └── subdirectory/
      └── analyze.md

개인 레벨 (모든 프로젝트에서 사용):
~/.claude/commands/
  └── personal-command.md
```

### 파일 구조

```markdown
---
description: 간단한 설명
allowed-tools: Bash(git status:*), Bash(git commit:*)
model: claude-3-5-haiku-20241022
argument-hint: [arg1] [arg2]
---

커맨드가 실행할 프롬프트 내용

인자 사용 예시: $1, $2, $ARGUMENTS
```

### 사용 예시

**정의 (`.claude/commands/review-pr.md`)**:
```markdown
---
description: PR 코드 리뷰 수행
argument-hint: [pr-number]
---

PR #$1을 리뷰하고 다음을 확인하세요:
1. 코드 품질
2. 테스트 커버리지
3. 문서화
```

**호출**:
```
/review-pr 123
```

### 언제 사용하나?

- ✅ 자주 반복하는 작업 (커밋, 리뷰, 포맷팅)
- ✅ 간단한 프롬프트 템플릿
- ✅ 빠른 작업 실행
- ❌ 복잡한 다단계 워크플로우 (→ Sub-Agents 사용)
- ❌ 조건부 자동 실행 (→ Hooks 사용)

---

## Sub-Agents (서브 에이전트)

### 개요

Sub-Agents는 특정 작업에 특화된 독립적인 AI 어시스턴트입니다. 각자 고유한 컨텍스트 창, 시스템 프롬프트, 도구 권한을 가집니다.

### 주요 특징

- **컨텍스트 격리**: 메인 대화와 독립된 컨텍스트
- **전문화**: 특정 도메인에 최적화된 상세 지침
- **재사용성**: 여러 프로젝트에서 사용 가능
- **세밀한 권한 제어**: 에이전트별 도구 접근 제한

### 저장 위치

```
프로젝트 레벨 (우선순위 높음):
.claude/agents/
  ├── code-reviewer/
  │   └── AGENT.md
  └── test-writer/
      └── AGENT.md

사용자 레벨:
~/.claude/agents/
  └── personal-agent/
      └── AGENT.md
```

### 파일 구조

```markdown
---
name: code-reviewer
description: 코드 품질, 보안, 성능을 검토하는 전문 리뷰어
tools: Read, Grep, Bash
model: sonnet
---

당신은 시니어 코드 리뷰어입니다. 다음을 중점적으로 검토하세요:

1. **보안**: SQL 인젝션, XSS, 인증/인가 이슈
2. **성능**: N+1 쿼리, 메모리 누수, 비효율적 알고리즘
3. **가독성**: 명명 규칙, 주석, 코드 구조

각 이슈에 대해 구체적인 개선안을 제시하세요.
```

### 사용 방법

**자동 위임** (Claude가 자동 선택):
```
User: 최근 변경사항을 리뷰해주세요
Claude: [자동으로 code-reviewer 에이전트 사용]
```

**명시적 호출**:
```
User: code-reviewer 에이전트를 사용해서 이 PR을 검토해주세요
```

### 관리 명령어

```bash
/agents          # 모든 에이전트 보기
/agents new      # 새 에이전트 생성
/agents edit     # 기존 에이전트 편집
/agents delete   # 에이전트 삭제
```

### 언제 사용하나?

- ✅ 복잡한 전문 작업 (코드 리뷰, 테스트 작성, 리팩토링)
- ✅ 독립된 컨텍스트가 필요한 경우
- ✅ 특정 도구만 허용해야 하는 경우
- ✅ 여러 단계의 분석이 필요한 작업
- ❌ 단순 반복 작업 (→ Slash Commands 사용)

---

## Agent Skills (에이전트 스킬)

### 개요

Agent Skills는 Claude의 기능을 확장하는 모듈형 역량입니다. Claude가 요청 내용에 따라 자동으로 활성화합니다.

### 주요 특징

- **자동 활성화**: 사용자 요청과 연관성이 있으면 Claude가 자동 사용
- **모듈형 구조**: `SKILL.md` + 스크립트/템플릿 등 지원 파일
- **도구 제한**: `allowed-tools`로 권한 제어
- **점진적 공개**: 필요한 파일만 컨텍스트에 로드

### 저장 위치

```
프로젝트 레벨:
.claude/skills/
  └── pdf-extractor/
      ├── SKILL.md
      ├── examples/
      └── scripts/

개인 레벨:
~/.claude/skills/
  └── excel-processor/
      └── SKILL.md

플러그인 레벨:
[plugin-path]/skills/
  └── formatter/
      └── SKILL.md
```

### 파일 구조

```markdown
---
name: PDF 텍스트 추출기
description: PDF 파일에서 텍스트와 테이블을 추출합니다. PDF 분석이나 문서 처리 작업 시 사용하세요.
allowed-tools: Read, Bash, Write
---

# PDF 텍스트 추출 스킬

이 스킬은 PDF 파일에서 내용을 추출합니다.

## 사용 가능한 도구

- `pdftotext`: 텍스트 추출
- `pdftohtml`: HTML 변환
- `tabula-py`: 테이블 추출

## 사용 지침

1. PDF 파일 경로 확인
2. 적절한 도구 선택
3. 추출 및 후처리

## 지원 파일

- `examples/sample-output.txt`: 예상 출력 형식
- `scripts/extract.sh`: 추출 스크립트
```

### 베스트 프랙티스

1. **집중된 스킬**: 하나의 스킬은 하나의 역량만 담당
2. **구체적인 설명**: "문서 처리" ❌ → "PDF에서 텍스트와 테이블 추출" ✅
3. **트리거 포함**: "Excel 파일 작업 시 사용" 명시
4. **팀 테스트**: 스킬이 예상대로 활성화되는지 검증

### 언제 사용하나?

- ✅ 특정 파일 타입 처리 (PDF, Excel, 이미지)
- ✅ 도메인 특화 기능 (데이터 분석, 포맷 변환)
- ✅ 자동 활성화가 필요한 역량
- ❌ 명시적 호출이 필요한 경우 (→ Slash Commands)
- ❌ 독립 컨텍스트가 필요한 경우 (→ Sub-Agents)

---

## Hooks (훅)

### 개요

Hooks는 특정 이벤트 발생 시 자동으로 실행되는 커맨드입니다. 이벤트 기반 자동화 시스템입니다.

### 주요 특징

- **이벤트 기반**: 특정 조건에서 자동 실행
- **쉘 접근**: 임의의 쉘 커맨드 실행 가능
- **차단 가능**: Exit 2로 작업 중단 가능
- **보안 중요**: 자동 실행되므로 신중한 설정 필요

### 설정 위치

```
사용자 레벨:
~/.claude/settings.json

프로젝트 레벨:
.claude/settings.json

로컬 (Git 제외):
.claude/settings.local.json
```

### 설정 구조

```json
{
  "hooks": {
    "EventName": [{
      "matcher": "ToolPattern",
      "hooks": [{
        "type": "command",
        "command": "your-command-here"
      }]
    }]
  }
}
```

### 사용 가능한 이벤트

#### 도구 관련 (matcher 지원)

- **PreToolUse**: 도구 실행 전
- **PostToolUse**: 도구 실행 후

matcher 예시: `"Edit|Write"`, `"Bash:git.*"`

#### 워크플로우 (matcher 불필요)

- **UserPromptSubmit**: 사용자 프롬프트 제출 시
- **Notification**: 시스템 알림 발생 시
- **Stop**: 에이전트 응답 완료 시
- **SubagentStop**: 서브 에이전트 완료 시
- **SessionStart**: 세션 시작 시
- **SessionEnd**: 세션 종료 시
- **PreCompact**: 컨텍스트 압축 전

### Exit Code 동작

```
Exit 0: 성공 (stdout이 트랜스크립트에 표시)
Exit 2: 차단 (stderr이 Claude에 전달, 작업 중단)
기타: 비차단 에러 (경고만 표시)
```

### 예시: Pre-commit Hook

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash:git commit.*",
      "hooks": [{
        "type": "command",
        "command": "npm run lint && npm test"
      }]
    }]
  }
}
```

### 예시: 자동 포매팅

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "prettier --write \"$FILE_PATH\""
      }]
    }]
  }
}
```

### 보안 고려사항

⚠️ **중요**: Hooks는 자동으로 쉘 커맨드를 실행합니다!

```bash
# ✅ 안전한 사용
"command": "git status"
"command": "npm run lint"

# ⚠️ 위험한 사용 (절대 하지 마세요)
"command": "rm -rf /"
"command": "curl unknown-site | bash"

# 변수 사용 시 반드시 따옴표로 감싸기
"command": "echo \"$FILE_PATH\""  # ✅
"command": "echo $FILE_PATH"       # ❌ (인젝션 위험)
```

### 언제 사용하나?

- ✅ 자동 품질 검사 (lint, test)
- ✅ 자동 포매팅
- ✅ Pre-commit 검증
- ✅ 알림 및 로깅
- ❌ 복잡한 로직 (→ Sub-Agents나 Skills 사용)
- ❌ 파괴적 작업 (보안 위험)

---

## Output Styles (출력 스타일)

### 개요

Output Styles는 Claude의 시스템 프롬프트를 커스터마이징하여 응답 방식을 변경합니다.

### 내장 스타일

1. **Default**: 표준 소프트웨어 엔지니어링 모드
2. **Explanatory**: 교육적 "Insights" 섹션 포함
3. **Learning**: 협업 학습 모드, `TODO(human)` 마커 사용

### 주요 특징

- **시스템 프롬프트 대체**: 기본 지침을 완전히 교체
- **지속적 적용**: 세션 전체에 영향
- **로컬 저장**: `.claude/settings.local.json`에 저장
- **프로젝트/사용자 레벨**: 모두 지원

### 저장 위치

```
사용자 레벨:
~/.claude/output-styles/
  └── educational.md

프로젝트 레벨:
.claude/output-styles/
  └── team-style.md
```

### 파일 구조

```markdown
---
name: 교육용 스타일
description: 각 단계를 자세히 설명하며 학습 중심으로 작업합니다
---

당신은 교육자입니다. 모든 코드 변경 시:

1. **왜** 이 방식을 선택했는지 설명
2. 대안들과 **장단점** 비교
3. 핵심 개념 강조
4. 학습 포인트 요약

코드보다 이해를 우선하세요.
```

### 사용 방법

```bash
/output-style                    # 메뉴 표시
/output-style explanatory        # 직접 전환
/output-style:new 내가 원하는...  # 커스텀 생성
/config                          # 설정에서 변경
```

### 다른 개념과의 차이

| 비교 대상 | Output Styles | 다른 개념 |
|----------|---------------|-----------|
| **CLAUDE.md** | 시스템 프롬프트 **대체** | 시스템 프롬프트 **추가** |
| **Sub-Agents** | 메인 루프 영향 | 독립 작업 실행 |
| **Slash Commands** | "저장된 시스템 프롬프트" | "저장된 프롬프트" |

### 언제 사용하나?

- ✅ 학습/교육 모드
- ✅ 팀별 응답 스타일 표준화
- ✅ 특정 프로젝트 톤 설정
- ❌ 작업별 동작 변경 (→ Slash Commands/Sub-Agents)
- ❌ 조건부 동작 (→ Hooks)

---

## Plugins (플러그인)

### 개요

Plugins는 커스텀 기능을 번들로 묶어 배포하는 메커니즘입니다. 여러 컴포넌트(Commands, Agents, Skills, Hooks)를 하나의 패키지로 제공합니다.

### 플러그인 구조

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # 메타데이터
├── commands/                # Slash Commands
│   ├── format.md
│   └── analyze.md
├── agents/                  # Sub-Agents
│   └── code-reviewer/
│       └── AGENT.md
├── skills/                  # Agent Skills
│   └── pdf-processor/
│       └── SKILL.md
└── hooks/
    └── hooks.json           # Hooks 설정
```

### plugin.json 예시

```json
{
  "name": "my-team-plugin",
  "version": "1.0.0",
  "description": "팀 개발 워크플로우 자동화",
  "author": "Your Team",
  "commands": ["format", "analyze"],
  "agents": ["code-reviewer"],
  "skills": ["pdf-processor"],
  "hooks": true
}
```

### 설치 및 관리

```bash
/plugin                        # 플러그인 메뉴
/plugin install formatter@org  # 설치
/plugin list                   # 목록 보기
/plugin enable formatter       # 활성화
/plugin disable formatter      # 비활성화
/plugin uninstall formatter    # 제거
```

### 팀 배포

**프로젝트 레벨 설정** (`.claude/settings.json`):
```json
{
  "marketplaces": ["https://your-org/marketplace"],
  "plugins": ["team-workflow@1.0.0"]
}
```

팀원이 프로젝트를 신뢰하면 자동으로 플러그인이 설치됩니다.

### MCP 통합

플러그인은 MCP(Model Context Protocol) 서버를 포함할 수 있어 외부 도구 및 서비스와 통합됩니다.

MCP 슬래시 커맨드 형식:
```
/mcp__<server-name>__<prompt-name> [arguments]
```

### 언제 사용하나?

- ✅ 팀 워크플로우 표준화
- ✅ 여러 컴포넌트 묶어 배포
- ✅ 조직 전체 도구 배포
- ✅ 외부 서비스 통합 (MCP)
- ❌ 개인용 단순 커맨드 (→ Slash Commands)
- ❌ 프로젝트 특화 설정 (→ 직접 `.claude/` 사용)

---

## 사용 시나리오별 선택 가이드

### 시나리오 1: 코드 리뷰 자동화

```
상황: PR 생성 시마다 코드 리뷰를 자동 실행하고 싶습니다.

솔루션 조합:
1. Sub-Agent (code-reviewer) - 리뷰 로직 담당
2. Slash Command (/review-pr) - 수동 실행용
3. Hook (PreToolUse) - git push 전 자동 리뷰
```

### 시나리오 2: 문서 처리 파이프라인

```
상황: PDF, Excel, Markdown 등 여러 포맷을 자동 처리하고 싶습니다.

솔루션 조합:
1. Agent Skills (pdf-extractor, excel-processor) - 파일 타입별 처리
2. Slash Command (/process-docs) - 파이프라인 시작
```

### 시나리오 3: 학습 중심 페어 프로그래밍

```
상황: 주니어 개발자와 페어 프로그래밍하며 설명을 곁들이고 싶습니다.

솔루션:
1. Output Style (learning 또는 커스텀) - 설명 중심 응답
```

### 시나리오 4: 팀 표준 도구 배포

```
상황: 팀 전체에 통일된 워크플로우를 배포하고 싶습니다.

솔루션:
1. Plugin - 모든 컴포넌트 번들링 (Commands, Agents, Skills, Hooks)
2. 팀 마켓플레이스에 배포
```

---

## 파일 우선순위 규칙

같은 이름의 컴포넌트가 여러 레벨에 존재할 때:

```
프로젝트 레벨 (.claude/)
  ↓ 우선순위 높음
플러그인 레벨
  ↓
사용자 레벨 (~/.claude/)
  ↓ 우선순위 낮음
내장 컴포넌트
```

프로젝트 레벨이 항상 우선하므로 프로젝트별 커스터마이징이 가능합니다.

---

## 추가 리소스

### 공식 문서

- Sub-Agents: https://docs.claude.com/en/docs/claude-code/sub-agents
- Slash Commands: https://docs.claude.com/en/docs/claude-code/slash-commands
- Plugins: https://docs.claude.com/en/docs/claude-code/plugins
- Skills: https://docs.claude.com/en/docs/claude-code/skills
- Hooks: https://docs.claude.com/en/docs/claude-code/hooks
- Output Styles: https://docs.claude.com/en/docs/claude-code/output-styles

### 관련 명령어

```bash
/help              # 전체 도움말
/config            # 설정 메뉴
/agents            # 에이전트 관리
/plugin            # 플러그인 관리
/output-style      # 출력 스타일 선택
/memory            # CLAUDE.md 편집
```

---

## 마무리

Claude Code의 확장 시스템은 다음 원칙을 따릅니다:

1. **계층화**: 개인 → 프로젝트 → 플러그인
2. **모듈화**: 각 컴포넌트는 명확한 책임
3. **조합성**: 여러 메커니즘을 함께 사용 가능
4. **팀 협업**: Git으로 공유 가능

필요에 따라 적절한 메커니즘을 선택하고 조합하여 최적의 워크플로우를 구축하세요.
