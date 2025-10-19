---
description: Create a feature specification from natural language requirements
---

You are tasked with creating a comprehensive feature specification based on user requirements.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding. If the input is empty, ask the user to provide a feature description.

## Process
### 1. **Generate a concise short name** (2-4 words) for the branch:
    - Analyze the feature description and extract the most meaningful keywords
    - Create a 2-4 word short name that captures the essence of the feature
    - Use action-noun format when possible (e.g., "add-user-auth", "fix-payment-bug")
    - Preserve technical terms and acronyms (OAuth2, API, JWT, etc.)
    - Keep it concise but descriptive enough to understand the feature at a glance
    - Examples:
        - "I want to add user authentication" → "user-auth"
        - "Implement OAuth2 integration for the API" → "oauth2-api-integration"
        - "Create a dashboard for analytics" → "analytics-dashboard"
        - "Fix payment processing timeout bug" → "fix-payment-timeout"

### 2. Create Feature Directory Structure
Create the following directory structure in `.agent/tasks/[yyyy-MM-dd]/[short-name]/`:
- `spec.md` - The feature specification
- `checklist/requirements.md` - Quality validation checklist

### 3. Load Specification Template
Read `.agent/templates/spec-template.md` to understand the required sections and structure.

### 4. Follow this execution flow:
    1. Parse user description from Input
       If empty: ERROR "No feature description provided"
    2. Extract key concepts from description
       Identify: actors, actions, data, constraints
    3. For unclear aspects:
       - Make informed guesses based on context and industry standards
       - Only mark with [NEEDS CLARIFICATION: specific question] if:
         - The choice significantly impacts feature scope or user experience
         - Multiple reasonable interpretations exist with different implications
         - No reasonable default exists
       - **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
       - Prioritize clarifications by impact: scope > security/privacy > user experience > technical details
    4. Fill User Scenarios & Testing section
       If no clear user flow: ERROR "Cannot determine user scenarios"
    5. Generate Functional Requirements
       Each requirement must be testable
       Use reasonable defaults for unspecified details (document assumptions in Assumptions section)
    6. Define Success Criteria
       Create measurable, technology-agnostic outcomes
       Include both quantitative metrics (time, performance, volume) and qualitative measures (user satisfaction, task completion)
       Each criterion must be verifiable without implementation details
    7. Identify Key Entities (if data involved)
    8. Return: SUCCESS (spec ready for planning)

### 5. Write the specification to SPEC_FILE using the template structure, replacing placeholders with concrete details derived from the feature description (arguments) while preserving section order and headings.

For unclear aspects:
- Make informed guesses based on context and industry standards
- Document assumptions in the Assumptions section
- Only use [NEEDS CLARIFICATION: specific question] for critical decisions where:
  - The choice significantly impacts scope or user experience
  - Multiple reasonable interpretations exist
  - No reasonable default exists
- **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
- Prioritize: scope > security/privacy > user experience > technical details

### 6. **Specification Quality Validation**: After writing the initial spec, validate it against quality criteria:

#### a. **Create Spec Quality Checklist**: Generate a checklist file at `checklists/requirements.md` using the checklist template structure with these validation items:

      ```markdown
      # Specification Quality Checklist: [FEATURE NAME]
      
      **Purpose**: Validate specification completeness and quality before proceeding to planning
      **Created**: [DATE]
      **Feature**: [Link to spec.md]
      
      ## Content Quality
      
      - [ ] No implementation details (languages, frameworks, APIs)
      - [ ] Focused on user value and business needs
      - [ ] Written for non-technical stakeholders
      - [ ] All mandatory sections completed
      
      ## Requirement Completeness
      
      - [ ] No [NEEDS CLARIFICATION] markers remain
      - [ ] Requirements are testable and unambiguous
      - [ ] Success criteria are measurable
      - [ ] Success criteria are technology-agnostic (no implementation details)
      - [ ] All acceptance scenarios are defined
      - [ ] Edge cases are identified
      - [ ] Scope is clearly bounded
      - [ ] Dependencies and assumptions identified
      
      ## Feature Readiness
      
      - [ ] All functional requirements have clear acceptance criteria
      - [ ] User scenarios cover primary flows
      - [ ] Feature meets measurable outcomes defined in Success Criteria
      - [ ] No implementation details leak into specification
      ```

#### b. **Run Validation Check**: Review the spec against each checklist item:
- For each item, determine if it passes or fails
- Document specific issues found (quote relevant spec sections)

c. **Handle Validation Results**:

      - **If all items pass**: Mark checklist complete and proceed to step 6
      
      - **If items fail (excluding [NEEDS CLARIFICATION])**:
        1. List the failing items and specific issues
        2. Update the spec to address each issue
        3. Re-run validation until all items pass (max 3 iterations)
        4. If still failing after 3 iterations, document remaining issues in checklist notes and warn user
      
      - **If [NEEDS CLARIFICATION] markers remain**:
        1. Extract all [NEEDS CLARIFICATION: ...] markers from the spec
        2. **LIMIT CHECK**: If more than 3 markers exist, keep only the 3 most critical (by scope/security/UX impact) and make informed guesses for the rest
        3. For each clarification needed (max 3), present options to user in this format:
        
           ```markdown
           ## Question [N]: [Topic]
           
           **Context**: [Quote relevant spec section]
           
           **What we need to know**: [Specific question from NEEDS CLARIFICATION marker]
           
           **Suggested Answers**:
           
           | Option | Answer | Implications |
           |--------|--------|--------------|
           | A      | [First suggested answer] | [What this means for the feature] |
           | B      | [Second suggested answer] | [What this means for the feature] |
           | C      | [Third suggested answer] | [What this means for the feature] |
           | Custom | Provide your own answer | [Explain how to provide custom input] |
           
           **Your choice**: _[Wait for user response]_
           ```
        
        4. **CRITICAL - Table Formatting**: Ensure markdown tables are properly formatted:
           - Use consistent spacing with pipes aligned
           - Each cell should have spaces around content: `| Content |` not `|Content|`
           - Header separator must have at least 3 dashes: `|--------|`
           - Test that the table renders correctly in markdown preview
        5. Number questions sequentially (Q1, Q2, Q3 - max 3 total)
        6. Present all questions together before waiting for responses
        7. Wait for user to respond with their choices for all questions (e.g., "Q1: A, Q2: Custom - [details], Q3: B")
        8. Update the spec by replacing each [NEEDS CLARIFICATION] marker with the user's selected or provided answer
        9. Re-run validation after all clarifications are resolved

d. **Update Checklist**: After each validation iteration, update the checklist file with current pass/fail status

### 7. Report completion with branch name, spec file path, checklist results, and readiness for the next phase (`/clarify` or `/plan`).

**NOTE:** The script creates and checks out the new branch and initializes the spec file before writing.