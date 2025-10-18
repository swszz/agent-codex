# [PROJECT_NAME] Constitution
## Core Principles
### I. Test code is required (NON-NEGOTIABLE)
- Write at least one test that handles both success and failure.
- All tests must pass before commit (no exceptions)
- If this principle cannot be followed, you MUST immediately report to the user and discuss a solution.

### II. Clarity Before Code
- Never start coding with ambiguous requirements
- Ask questions and clarify uncertainties before implementation
- Define user stories and acceptance criteria first
- No implementation that starts with "probably" or "I think"

### III. Simplicity First
- Choose simple solutions over complex ones
- YAGNI principle: Don't build what you don't need now
- Abstraction only after identifying pattern 3+ times
- Complexity increases require documented justification

### IV. Security by Default
- Never hardcode sensitive information (use environment variables/secrets manager)
- Validate all user inputs (never trust client data)

### V. Observability Required
- Structured logging (JSON format with correlation IDs)
- Meaningful error messages (include debuggable context)

### VI. Documentation Alongside Code
- Complex logic requires comments explaining "why"
- README.md must include local setup instructions (< 10 min setup)

### VII. Backward Compatibility
- Breaking changes require minimum 1 version deprecation period
- Database migrations are forward-only

### VIII. Variables from Memory
- Always load `.specify/memory/variables.json` first
- Use variables for project-wide configuration and template references
- Keep variables synchronized across all script templates

**Version**: 1.0.0 | **Ratified**: 2025-10-13
