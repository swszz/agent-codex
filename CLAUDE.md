# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **agent-codex** repository, an AI-based Spec-Driven Development framework.

## Documentation Structure

All important documentation lives in the `.agent` folder with the following structure:

- **tasks/**: PRD & implementation plans for each feature
  - Each feature has its own directory: `.agent/tasks/[date]/[feature-name]/`
  - Contains `spec.md` (specification) and `checklists/` (validation checklists)
- **system/**: Documents the current state of the system including:
  - Project structure
  - Tech stack
  - Integration points
  - Database schema
  - Core functionalities (agent architecture, LLM layer, etc.)
- **sop/**: Standard Operating Procedures - best practices for executing specific tasks
  - How to add a schema migration
  - How to add a new page route
  - Other common development tasks
- **templates/**: Templates for documentation
  - `spec-template.md`: Template for feature specifications
- **README.md**: Index of all available documentation

**IMPORTANT**: Always read `.agent/README.md` first before planning any implementation to get proper context.

After implementing any feature, update the relevant `.agent` documentation to ensure it reflects the current state of the system.

## Custom Commands

This repository includes a complete workflow for spec-driven development with the following commands:

### /feature.specify - Create Feature Specification

Creates a comprehensive feature specification from natural language requirements.

**Usage**: `/feature.specify [feature description]`

**Example**: `/feature.specify I want to add user authentication with OAuth2 support`

**What it does**:
1. Analyzes your feature description
2. Generates a concise short name (e.g., "oauth2-user-auth")
3. Creates directory structure: `.agent/tasks/[date]/[short-name]/`
4. Writes a complete specification at `.agent/tasks/[date]/[short-name]/spec.md`
5. Creates a validation checklist at `.agent/tasks/[date]/[short-name]/checklists/requirements.md`
6. Validates the specification quality
7. Asks clarifying questions if needed (max 3)

**Key principles**:
- Focus on WHAT and WHY, never HOW
- No implementation details (frameworks, languages, APIs)
- Written for non-technical stakeholders
- Every requirement must be testable
- Success criteria must be measurable and technology-agnostic

---

### /feature.clarify - Clarify Specification

Identifies underspecified areas in the feature specification and asks targeted clarification questions.

**Usage**: `/feature.clarify [optional context]`

**When to use**: After `/feature.specify` and before `/feature.plan` to reduce ambiguity

**What it does**:
1. Analyzes the current feature spec for ambiguities and gaps
2. Asks up to 5 highly targeted clarification questions
3. Provides recommended answers based on best practices
4. Updates the spec with answers directly

**Question types covered**:
- Functional scope and behavior
- Data model and entities
- Non-functional requirements (performance, security, scalability)
- Integration points and dependencies
- Edge cases and error handling

---

### /feature.checklist - Generate Custom Checklist

Creates a custom checklist to validate requirements quality (like "unit tests for requirements").

**Usage**: `/feature.checklist [checklist type or focus area]`

**Example**: `/feature.checklist UX requirements` or `/feature.checklist security`

**What it does**:
1. Asks clarifying questions about checklist focus and depth
2. Generates a requirements quality checklist in `.agent/tasks/[date]/[feature-name]/checklists/[type].md`
3. Creates items that test requirements quality, NOT implementation

**Checklist validates**:
- Completeness: Are all necessary requirements documented?
- Clarity: Are requirements specific and unambiguous?
- Consistency: Do requirements align without conflicts?
- Coverage: Are all scenarios and edge cases addressed?
- Measurability: Can requirements be objectively verified?

---

### /feature.plan - Create Implementation Plan

Generates technical design and implementation plan from the specification.

**Usage**: `/feature.plan [optional context]`

**Prerequisites**: Completed and clarified specification

**What it does**:
1. Reads spec.md and constitution.md (if exists)
2. Creates plan.md with technical context and architecture decisions
3. Phase 0: Generates research.md (technical decisions and unknowns)
4. Phase 1: Generates data-model.md, contracts/, quickstart.md
5. Updates CLAUDE.md with new technologies

**Outputs**:
- `plan.md` - Implementation plan with tech stack and structure
- `research.md` - Technical decisions and rationale
- `data-model.md` - Entity definitions and relationships
- `contracts/` - API contracts (REST/GraphQL schemas)
- `quickstart.md` - Integration test scenarios

---

### /feature.tasks - Generate Task List

Creates an actionable, dependency-ordered task list for implementation.

**Usage**: `/feature.tasks [optional context]`

**Prerequisites**: Completed plan.md with technical design

**What it does**:
1. Reads plan.md, spec.md, and optional design docs
2. Generates tasks.md organized by user story (P1, P2, P3...)
3. Each user story becomes independently implementable and testable
4. Marks parallelizable tasks with [P]
5. Includes file paths and clear descriptions

**Task organization**:
- Phase 1: Setup (project initialization)
- Phase 2: Foundational (blocking prerequisites)
- Phase 3+: User Stories (one phase per story, in priority order)
- Final Phase: Polish and cross-cutting concerns

**Format**: `[TaskID] [P?] [Story?] Description with file path`

---

### /feature.implement - Execute Implementation

Processes and executes all tasks defined in tasks.md.

**Usage**: `/feature.implement [optional context]`

**Prerequisites**: Completed tasks.md

**What it does**:
1. Checks all checklists are complete (or asks permission to proceed)
2. Loads tasks.md, plan.md, spec.md, and all design docs
3. Executes tasks phase-by-phase in dependency order
4. Respects parallelization markers [P]
5. Marks completed tasks with [X]
6. Reports progress after each task

**Execution rules**:
- Setup first: Initialize project structure, dependencies, configuration
- Tests before code: If TDD approach specified
- Respect dependencies: Sequential tasks in order, parallel tasks together
- Validation checkpoints: Verify each phase completion

---

### /feature.analyze - Cross-Artifact Analysis

Performs quality analysis across spec.md, plan.md, and tasks.md to identify inconsistencies.

**Usage**: `/feature.analyze [optional context]`

**Prerequisites**: Completed tasks.md (run after `/feature.tasks`)

**What it does**:
1. Loads spec.md, plan.md, tasks.md, and constitution.md
2. Detects duplications, ambiguities, gaps, and conflicts
3. Validates constitution alignment
4. Checks requirement coverage by tasks
5. Produces a detailed analysis report (read-only, no file modifications)

**Detection passes**:
- Duplication detection
- Ambiguity detection (vague terms, placeholders)
- Underspecification
- Constitution alignment
- Coverage gaps
- Inconsistencies

**Severity levels**: CRITICAL, HIGH, MEDIUM, LOW

---

### /feature.constitution - Manage Project Constitution

Creates or updates the project constitution with development principles.

**Usage**: `/feature.constitution [optional principle inputs]`

**What it does**:
1. Loads existing constitution template from `.agent/constitution.md`
2. Collects or derives values for placeholders
3. Updates constitution with principles and governance rules
4. Propagates changes to dependent templates
5. Versions constitution (semantic versioning: MAJOR.MINOR.PATCH)

**Constitution includes**:
- Project principles (non-negotiable rules)
- Governance procedures
- Amendment policies
- Compliance expectations

---

## Complete Workflow

The recommended workflow for spec-driven development:

```
1. /feature.specify [feature description]
   └─> Creates spec.md with user stories and requirements

2. /feature.clarify (optional but recommended)
   └─> Resolves ambiguities in specification

3. /feature.checklist [focus area] (optional, can create multiple)
   └─> Validates requirements quality

4. /feature.plan
   └─> Generates technical design (plan.md, research.md, data-model.md, contracts/)

5. /feature.tasks
   └─> Creates actionable task list organized by user story

6. /feature.analyze (optional)
   └─> Validates consistency across all artifacts

7. /feature.implement
   └─> Executes implementation phase-by-phase
```

**Quick start for simple features**:
```
/feature.specify [description] → /feature.plan → /feature.tasks → /feature.implement
```

**Full workflow for complex features**:
```
/feature.specify [description] → /feature.clarify → /feature.checklist → /feature.plan → /feature.tasks → /feature.analyze → /feature.implement
```

---

## Specification Writing Guidelines

### Mandatory Sections
- Feature Name
- Overview
- User Scenarios
- Functional Requirements
- Success Criteria
- Acceptance Scenarios

### Optional Sections (include only if relevant)
- Key Entities
- User Experience Considerations
- Dependencies
- Assumptions
- Out of Scope
- Open Questions (max 3)

### Success Criteria Rules

Success criteria MUST be:
1. **Measurable**: Include specific metrics (time, percentage, count)
2. **Technology-agnostic**: No frameworks, languages, or tools
3. **User-focused**: Outcomes from user/business perspective
4. **Verifiable**: Can be tested without knowing implementation

**Good examples**:
- "Users can complete checkout in under 3 minutes"
- "System supports 10,000 concurrent users"
- "95% of searches return results in under 1 second"

**Bad examples** (avoid):
- "API response time is under 200ms" → Use: "Users see results instantly"
- "Database handles 1000 TPS" → Use user-facing metric
- "React components render efficiently" → No framework mentions
