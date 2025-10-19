# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **agent-codex** repository, an AI-based Spec-Driven Development framework.

## Documentation Structure

All important documentation lives in the `.agent` folder with the following structure:

- **tasks/**: PRD & implementation plans for each feature
  - Each feature has its own directory: `.agent/tasks/[feature-name]/`
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

### /specify - Create Feature Specification

Creates a comprehensive feature specification from natural language requirements.

**Usage**:
```
/specify [feature description]
```

**Example**:
```
/specify I want to add user authentication with OAuth2 support
```

**What it does**:
1. Analyzes your feature description
2. Generates a concise short name (e.g., "oauth2-user-auth")
3. Creates directory structure: `.agent/tasks/[short-name]/`
4. Writes a complete specification at `.agent/tasks/[short-name]/spec.md`
5. Creates a validation checklist at `.agent/tasks/[short-name]/checklists/requirements.md`
6. Validates the specification quality
7. Asks clarifying questions if needed (max 3)

**Key principles**:
- Focus on WHAT and WHY, never HOW
- No implementation details (frameworks, languages, APIs)
- Written for non-technical stakeholders
- Every requirement must be testable
- Success criteria must be measurable and technology-agnostic

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
