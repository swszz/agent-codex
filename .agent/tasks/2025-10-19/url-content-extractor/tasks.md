# Tasks: URL Content Extractor

**Input**: Design documents from `.agent/tasks/2025-10-19/url-content-extractor/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/openapi.yaml, research.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Project root**: `url-content-extractor/`
- **Main source**: `src/main/kotlin/com/example/extractor/`
- **Resources**: `src/main/resources/`
- **Tests**: `src/test/kotlin/com/example/extractor/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic Kotlin + Spring Boot structure

- [ ] T001 Create project root directory `url-content-extractor/` and initialize Git repository
- [ ] T002 Create Gradle project structure with Kotlin DSL in `build.gradle.kts` and `settings.gradle.kts`
- [ ] T003 Configure Gradle dependencies (Spring Boot 3.4.0, Kotlin 2.1.0, Jsoup 1.18.1, Bucket4j, MockK) in `build.gradle.kts`
- [ ] T004 Configure Gradle plugins (kotlin-jvm, kotlin-spring, spring-boot) in `build.gradle.kts`
- [ ] T005 Set JDK 25+ as target in `build.gradle.kts` Kotlin compiler options
- [ ] T006 Create package structure `src/main/kotlin/com/example/extractor/` with subdirectories (config, controller, service, model, exception)
- [ ] T007 Create test package structure `src/test/kotlin/com/example/extractor/` with subdirectories (controller, service, integration)
- [ ] T008 Create Spring Boot main application class in `src/main/kotlin/com/example/extractor/Application.kt`
- [ ] T009 [P] Create base `application.yml` configuration file in `src/main/resources/application.yml` with server port, virtual threads, and extraction settings
- [ ] T010 [P] Create resources directories `src/main/resources/templates/`, `src/main/resources/static/css/`, `src/main/resources/static/js/`
- [ ] T011 [P] Create `.gitignore` file for Gradle, Kotlin, and IDE files

**Checkpoint**: Project structure ready, Gradle build successful

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core domain models and configuration that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T012 [P] Create `ErrorCode` enum in `src/main/kotlin/com/example/extractor/model/ErrorCode.kt` with 8 error types and HTTP status codes
- [ ] T013 [P] Create `ContentBlockType` enum in `src/main/kotlin/com/example/extractor/model/ContentBlockType.kt` (HEADING, PARAGRAPH, LIST_ITEM, QUOTE, CODE)
- [ ] T014 [P] Create `ContentBlock` data class in `src/main/kotlin/com/example/extractor/model/ContentBlock.kt` with type, content, level validation
- [ ] T015 Create `ExtractionRequest` data class in `src/main/kotlin/com/example/extractor/model/ExtractionRequest.kt` with URL validation annotations
- [ ] T016 Create `ExtractedContent` data class in `src/main/kotlin/com/example/extractor/model/ExtractedContent.kt` with all attributes from data-model.md
- [ ] T017 Create `ExtractionError` data class in `src/main/kotlin/com/example/extractor/model/ExtractionError.kt` with errorCode, message, details
- [ ] T018 Create `ExtractionResult` sealed class in `src/main/kotlin/com/example/extractor/model/ExtractionResult.kt` with Success and Failure subclasses
- [ ] T019 [P] Create custom exception `InvalidUrlException` in `src/main/kotlin/com/example/extractor/exception/InvalidUrlException.kt`
- [ ] T020 [P] Create custom exception `UnreachableUrlException` in `src/main/kotlin/com/example/extractor/exception/UnreachableUrlException.kt`
- [ ] T021 [P] Create custom exception `NoContentException` in `src/main/kotlin/com/example/extractor/exception/NoContentException.kt`
- [ ] T022 [P] Create custom exception `BlockedUrlException` in `src/main/kotlin/com/example/extractor/exception/BlockedUrlException.kt`
- [ ] T023 Create `ExtractionProperties` configuration class in `src/main/kotlin/com/example/extractor/config/ExtractionProperties.kt` with @ConfigurationProperties
- [ ] T024 Create `WebClientConfig` bean configuration in `src/main/kotlin/com/example/extractor/config/WebClientConfig.kt` for HTTP client setup

**Checkpoint**: Foundation ready - all domain models and configs complete, user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Basic Content Extraction (Priority: P1) 🎯 MVP

**Goal**: Core functionality to extract and display clean content from URLs

**Independent Test**: Enter a valid article URL and verify main text is displayed without navigation/ads

### Implementation for User Story 1

- [ ] T025 [P] [US1] Create `UrlValidationService` in `src/main/kotlin/com/example/extractor/service/UrlValidationService.kt` with URL format validation and SSRF prevention (FR-002, FR-011)
- [ ] T026 [P] [US1] Create `ContentFetchService` in `src/main/kotlin/com/example/extractor/service/ContentFetchService.kt` with WebClient HTTP fetching, redirect handling, timeout (FR-011, FR-012)
- [ ] T027 [P] [US1] Create `ContentParserService` in `src/main/kotlin/com/example/extractor/service/ContentParserService.kt` with Jsoup extraction logic (FR-003, FR-004, FR-005)
- [ ] T028 [US1] Create `ExtractionService` orchestrator in `src/main/kotlin/com/example/extractor/service/ExtractionService.kt` that coordinates validation, fetch, and parsing
- [ ] T029 [US1] Create `ExtractionApiController` REST controller in `src/main/kotlin/com/example/extractor/controller/ExtractionApiController.kt` with POST /api/extract endpoint
- [ ] T030 [P] [US1] Create basic home page template `index.html` in `src/main/resources/templates/` with URL input form (FR-001)
- [ ] T031 [P] [US1] Create result display template `result.html` in `src/main/resources/templates/` with extracted content display (FR-006)
- [ ] T032 [P] [US1] Create `WebController` UI controller in `src/main/kotlin/com/example/extractor/controller/WebController.kt` with GET / and GET /result endpoints
- [ ] T033 [P] [US1] Add loading indicator support in `index.html` using HTMX (FR-007)
- [ ] T034 [P] [US1] Create basic CSS styles in `src/main/resources/static/css/styles.css` for readable content display
- [ ] T035 [P] [US1] Download and add HTMX library to `src/main/resources/static/js/htmx.min.js`
- [ ] T036 [US1] Implement URL validation unit tests in `src/test/kotlin/com/example/extractor/service/UrlValidationServiceTest.kt`
- [ ] T037 [US1] Implement content parser unit tests in `src/test/kotlin/com/example/extractor/service/ContentParserServiceTest.kt`
- [ ] T038 [US1] Implement extraction service integration tests in `src/test/kotlin/com/example/extractor/integration/ExtractionIntegrationTest.kt`
- [ ] T039 [US1] Test basic extraction flow end-to-end per quickstart.md Scenario 1 (valid article URL → extracted content)

**Checkpoint**: User Story 1 complete - MVP functional! Can extract and display content from URLs independently

---

## Phase 4: User Story 2 - URL Validation and Error Handling (Priority: P2)

**Goal**: Comprehensive error handling with clear, actionable error messages for all failure scenarios

**Independent Test**: Enter invalid URLs (malformed, unreachable, no content) and verify clear error messages

### Implementation for User Story 2

- [ ] T040 [US2] Create `GlobalExceptionHandler` with @ControllerAdvice in `src/main/kotlin/com/example/extractor/exception/GlobalExceptionHandler.kt`
- [ ] T041 [US2] Add exception mapping for `InvalidUrlException` → 400 Bad Request with clear message in GlobalExceptionHandler
- [ ] T042 [US2] Add exception mapping for `BlockedUrlException` → 403 Forbidden with SSRF prevention message in GlobalExceptionHandler
- [ ] T043 [US2] Add exception mapping for `UnreachableUrlException` → 404 Not Found with network error message in GlobalExceptionHandler
- [ ] T044 [US2] Add exception mapping for `NoContentException` → 422 Unprocessable Entity with no content message in GlobalExceptionHandler
- [ ] T045 [US2] Add exception mapping for timeout → 504 Gateway Timeout in GlobalExceptionHandler
- [ ] T046 [US2] Add exception mapping for content too large → 413 Payload Too Large in GlobalExceptionHandler
- [ ] T047 [US2] Add exception mapping for unsupported content type → 415 Unsupported Media Type in GlobalExceptionHandler
- [ ] T048 [US2] Add exception mapping for generic errors → 500 Internal Server Error in GlobalExceptionHandler
- [ ] T049 [P] [US2] Create error page template `error.html` in `src/main/resources/templates/` for UI error display (FR-009)
- [ ] T050 [US2] Update `ExtractionService` to throw appropriate exceptions for all error scenarios (FR-008, FR-009)
- [ ] T051 [US2] Update `UrlValidationService` to throw `InvalidUrlException` for malformed URLs and `BlockedUrlException` for SSRF attempts
- [ ] T052 [US2] Update `ContentFetchService` to throw `UnreachableUrlException` for network failures and handle timeout
- [ ] T053 [US2] Update `ContentParserService` to throw `NoContentException` when no main content found
- [ ] T054 [US2] Test error handling for invalid URL per quickstart.md Scenario 2 (malformed URL → 400 error)
- [ ] T055 [US2] Test error handling for unreachable URL per quickstart.md Scenario 3 (non-existent site → 404 error)
- [ ] T056 [US2] Test SSRF prevention per quickstart.md Scenario 4 (private IP → 403 blocked)
- [ ] T057 [US2] Test redirect handling per quickstart.md Scenario 5 (redirect → follow transparently)
- [ ] T058 [US2] Test no content scenario per quickstart.md Scenario 6 (empty page → 422 error)
- [ ] T059 [US2] Test non-HTML content per quickstart.md Scenario 10 (PDF URL → 415 error)

**Checkpoint**: User Stories 1 AND 2 complete - error handling fully implemented, both stories work independently

---

## Phase 5: User Story 3 - Content Export and Sharing (Priority: P3)

**Goal**: Enable users to copy extracted content to clipboard or download as text file

**Independent Test**: Extract content and verify copy/download functionality works

### Implementation for User Story 3

- [ ] T060 [P] [US3] Add "Copy to Clipboard" button in `result.html` template with HTMX attributes (FR-010)
- [ ] T061 [P] [US3] Add "Download as Text" button in `result.html` template with download link
- [ ] T062 [US3] Implement copy functionality using JavaScript/HTMX in `result.html` (copy extracted text to clipboard)
- [ ] T063 [US3] Add download endpoint GET /api/download in `ExtractionApiController` that returns plain text file
- [ ] T064 [US3] Implement download logic to format content as .txt file with page title as filename
- [ ] T065 [US3] Update CSS in `styles.css` to style copy/download buttons
- [ ] T066 [US3] Test copy to clipboard functionality per quickstart.md Scenario 7
- [ ] T067 [US3] Test download as text file functionality per quickstart.md Scenario 7
- [ ] T068 [US3] Verify manual text selection and copy still works (acceptance scenario 2)

**Checkpoint**: All user stories complete - full feature set implemented

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and production readiness

- [ ] T069 [P] Create `RateLimitConfig` in `src/main/kotlin/com/example/extractor/config/RateLimitConfig.kt` with Bucket4j setup (10 req/min, 100 req/hr per IP)
- [ ] T070 [P] Add rate limiting interceptor to controllers
- [ ] T071 [P] Add Spring Boot Actuator health check endpoint configuration in `application.yml`
- [ ] T072 [P] Add logging configuration with SLF4J in `application.yml` (INFO level for application, DEBUG for development)
- [ ] T073 [P] Add Micrometer metrics for extraction success rate, latency, and error counts
- [ ] T074 [P] Create comprehensive `README.md` in project root with setup instructions, tech stack, and usage examples
- [ ] T075 [P] Add unit tests for all models in `src/test/kotlin/com/example/extractor/model/` directory
- [ ] T076 [P] Add unit tests for `ContentFetchService` with WireMock in `src/test/kotlin/com/example/extractor/service/ContentFetchServiceTest.kt`
- [ ] T077 [P] Add integration tests for API controller in `src/test/kotlin/com/example/extractor/controller/ExtractionApiControllerTest.kt`
- [ ] T078 [P] Test large content handling per quickstart.md Scenario 8 (verify 5MB limit)
- [ ] T079 Test concurrent requests per quickstart.md Scenario 9 (100 concurrent → no degradation, validates SC-006)
- [ ] T080 Validate all success criteria (SC-001 through SC-006) against quickstart.md test scenarios
- [ ] T081 [P] Code cleanup: Remove unused imports, format code consistently
- [ ] T082 [P] Security review: Verify SSRF prevention, rate limiting, input validation
- [ ] T083 Build production JAR with `./gradlew bootJar` and verify executable
- [ ] T084 Run full test suite with `./gradlew test` and ensure all tests pass

**Checkpoint**: Production-ready application with all polish items complete

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Enhances US1 but independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Enhances US1 but independently testable

### Within Each User Story

User Story 1:
- T025, T026, T027 (services) can run in parallel
- T028 (ExtractionService) depends on T025, T026, T027 completion
- T029 (controller) depends on T028
- T030, T031, T032, T033, T034, T035 (UI) can run in parallel after T029
- T036, T037, T038 (tests) can run in parallel after implementation
- T039 (E2E test) runs after all implementation complete

User Story 2:
- T040-T048 (exception mappings) can be added incrementally in GlobalExceptionHandler
- T049 (error template) can run in parallel
- T050-T053 (service updates) depend on GlobalExceptionHandler
- T054-T059 (tests) can run in parallel after service updates

User Story 3:
- T060, T061 (UI buttons) can run in parallel
- T062, T063, T064 (functionality) can run in parallel
- T065 (CSS) can run in parallel
- T066-T068 (tests) run after implementation

### Parallel Opportunities

- **Setup (Phase 1)**: T009, T010, T011 can run in parallel
- **Foundational (Phase 2)**: T012, T013, T014 can run in parallel; T019-T022 can run in parallel
- **User Story 1**: T025, T026, T027 in parallel; T030-T035 in parallel; T036-T038 in parallel
- **User Story 2**: T040-T048 can be done incrementally; T049 in parallel with handler work; T054-T059 in parallel
- **User Story 3**: T060, T061 in parallel; T062-T064 in parallel; T066-T068 in parallel
- **Polish (Phase 6)**: T069-T078, T081-T082 can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all foundational services together:
Task: "Create UrlValidationService in src/main/kotlin/com/example/extractor/service/UrlValidationService.kt"
Task: "Create ContentFetchService in src/main/kotlin/com/example/extractor/service/ContentFetchService.kt"
Task: "Create ContentParserService in src/main/kotlin/com/example/extractor/service/ContentParserService.kt"

# Launch all UI components together (after controllers ready):
Task: "Create basic home page template index.html"
Task: "Create result display template result.html"
Task: "Create WebController UI controller"
Task: "Add loading indicator support using HTMX"
Task: "Create basic CSS styles"
Task: "Download and add HTMX library"

# Launch all tests together:
Task: "Implement URL validation unit tests"
Task: "Implement content parser unit tests"
Task: "Implement extraction service integration tests"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (**T001-T011**) → Project structure ready
2. Complete Phase 2: Foundational (**T012-T024**) → Domain models and config complete
3. Complete Phase 3: User Story 1 (**T025-T039**) → Core extraction working
4. **STOP and VALIDATE**: Test per quickstart.md Scenario 1
5. Deploy/demo MVP if ready

**Estimated MVP**: 39 tasks, provides complete basic content extraction

### Incremental Delivery

1. Complete Setup + Foundational (**Phases 1-2**) → Foundation ready
2. Add User Story 1 (**Phase 3**) → Test independently → **Deploy/Demo (MVP!)**
3. Add User Story 2 (**Phase 4**) → Test independently → Deploy/Demo
4. Add User Story 3 (**Phase 5**) → Test independently → Deploy/Demo
5. Add Polish (**Phase 6**) → Production ready
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (**Phases 1-2**)
2. Once Foundational is done:
   - Developer A: User Story 1 (**T025-T039**)
   - Developer B: User Story 2 (**T040-T059**, can start in parallel once T028-T029 complete)
   - Developer C: User Story 3 (**T060-T068**, can start once T031 complete)
3. Stories complete and integrate independently
4. Team completes Polish together (**Phase 6**)

---

## Success Criteria Validation

Each user story maps to success criteria from spec.md:

- **User Story 1** validates:
  - **SC-001**: Extraction time <5 seconds (test T039)
  - **SC-002**: 90%+ success rate (integration test T038)
  - **SC-003**: Complete workflow <30 seconds (test T039)
  - **SC-004**: 95% ad-free content (parser test T037)

- **User Story 2** validates:
  - **SC-005**: 100% error messages (tests T054-T059)

- **User Story 3** validates:
  - Copy/download functionality (tests T066-T068)

- **Polish Phase** validates:
  - **SC-006**: 100 concurrent requests (test T079)

---

## Notes

- [P] tasks = different files, no dependencies - can run in parallel
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Verify MVP (User Story 1) works before proceeding to P2/P3
- All file paths are relative to `url-content-extractor/` project root
- Tests are included because they validate success criteria (SC-001 through SC-006)
