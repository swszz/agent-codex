# Implementation Plan: URL Content Extractor

**Branch**: `url-content-extractor`
**Date**: 2025-10-19
**Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `.agent/tasks/2025-10-19/url-content-extractor/spec.md`

## Summary

A web content extraction application built with Kotlin and Spring Boot that accepts URLs as input and returns clean, readable main body content. The system extracts text from web pages while filtering out navigation elements, advertisements, sidebars, and other non-essential page elements. The application provides both a REST API and server-side rendered web UI, handles concurrent requests efficiently using JDK 25 virtual threads, and includes comprehensive error handling for invalid URLs, unreachable sites, and extraction failures.

**Core Technologies**: Kotlin + Spring Boot 3.4 + Gradle 8.11 + JDK 25 + Jsoup + WebClient + Thymeleaf + HTMX

## Technical Context

**Language/Version**: Kotlin 2.1.0 with JDK 25+
**Primary Dependencies**:
- Spring Boot 3.4.0 (Web, WebFlux for WebClient, Thymeleaf, Actuator)
- Jsoup 1.18.1 (HTML parsing and content extraction)
- Bucket4j (rate limiting)
- Kotlin coroutines 1.9.0 (async operations)

**Storage**: N/A (stateless application, no persistence)
**Testing**: JUnit 5 + MockK + AssertJ + Spring Boot Test + WireMock
**Target Platform**: JVM (Spring Boot embedded Tomcat), deployable as standalone JAR or Docker container
**Project Type**: Web application (REST API + server-side rendered UI)
**Performance Goals**:
- <5 seconds extraction time for typical web pages (SC-001)
- 100 concurrent requests without degradation (SC-006)
- 90%+ success rate on standard article/blog pages (SC-002)

**Constraints**:
- 10-second timeout per extraction request
- 5MB maximum content size
- SSRF prevention (block private IPs, localhost)
- Rate limiting: 10 requests/min per IP, 100 requests/hour per IP

**Scale/Scope**:
- Stateless, horizontally scalable
- Single web application module
- ~15 source files (controllers, services, models, config)
- ~10 test files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: ✅ PASSED (no constitution file exists, no gates to validate)

No `.agent/constitution.md` file found. Proceeding with industry best practices:
- Layered architecture (separation of concerns)
- Dependency injection (Spring Boot default)
- Stateless design (no session management)
- Single responsibility principle
- Minimal complexity (no over-engineering)

## Project Structure

### Documentation (this feature)

```
.agent/tasks/2025-10-19/url-content-extractor/
├── spec.md                    # Feature specification
├── plan.md                    # This file (/plan command output)
├── research.md                # Phase 0: Technical research and decisions
├── data-model.md              # Phase 1: Domain models and entities
├── quickstart.md              # Phase 1: Integration test scenarios
├── contracts/                 # Phase 1: API contracts
│   └── openapi.yaml          # OpenAPI 3.0 specification
├── checklists/               # Quality validation
│   └── requirements.md       # Requirements quality checklist
└── tasks.md                  # Phase 2: Implementation tasks (/tasks command - NOT created by /plan)
```

### Source Code (repository root)

```
url-content-extractor/
├── build.gradle.kts          # Gradle build configuration (Kotlin DSL)
├── settings.gradle.kts       # Gradle settings
├── gradle/                   # Gradle wrapper files
├── src/
│   ├── main/
│   │   ├── kotlin/
│   │   │   └── com/example/extractor/
│   │   │       ├── Application.kt                    # Spring Boot main application
│   │   │       ├── config/
│   │   │       │   ├── WebClientConfig.kt           # WebClient bean configuration
│   │   │       │   ├── ExtractionProperties.kt      # @ConfigurationProperties
│   │   │       │   └── RateLimitConfig.kt           # Bucket4j rate limiting setup
│   │   │       ├── controller/
│   │   │       │   ├── ExtractionApiController.kt   # REST API endpoints
│   │   │       │   └── WebController.kt             # Thymeleaf UI controllers
│   │   │       ├── service/
│   │   │       │   ├── ExtractionService.kt         # Main extraction orchestration
│   │   │       │   ├── UrlValidationService.kt      # URL validation + SSRF prevention
│   │   │       │   ├── ContentFetchService.kt       # HTTP client wrapper
│   │   │       │   └── ContentParserService.kt      # Jsoup HTML parsing logic
│   │   │       ├── model/
│   │   │       │   ├── ExtractionRequest.kt         # Input model
│   │   │       │   ├── ExtractionResult.kt          # Sealed class (Success/Failure)
│   │   │       │   ├── ExtractedContent.kt          # Success response model
│   │   │       │   ├── ContentBlock.kt              # Structured content element
│   │   │       │   ├── ExtractionError.kt           # Error details
│   │   │       │   └── ErrorCode.kt                 # Error code enum
│   │   │       └── exception/
│   │   │           ├── GlobalExceptionHandler.kt    # @ControllerAdvice
│   │   │           ├── InvalidUrlException.kt       # Custom exceptions
│   │   │           ├── UnreachableUrlException.kt
│   │   │           ├── NoContentException.kt
│   │   │           └── BlockedUrlException.kt
│   │   └── resources/
│   │       ├── application.yml                       # Spring Boot configuration
│   │       ├── templates/
│   │       │   ├── index.html                       # Home page (Thymeleaf)
│   │       │   ├── result.html                      # Result display page
│   │       │   └── error.html                       # Error page
│   │       └── static/
│   │           ├── css/
│   │           │   └── styles.css                   # Basic styling
│   │           └── js/
│   │               └── htmx.min.js                  # HTMX library
│   └── test/
│       └── kotlin/
│           └── com/example/extractor/
│               ├── controller/
│               │   └── ExtractionApiControllerTest.kt
│               ├── service/
│               │   ├── ExtractionServiceTest.kt
│               │   ├── UrlValidationServiceTest.kt
│               │   ├── ContentFetchServiceTest.kt
│               │   └── ContentParserServiceTest.kt
│               ├── integration/
│               │   ├── ExtractionIntegrationTest.kt  # Full API integration tests
│               │   └── WireMockExtension.kt          # WireMock test setup
│               └── ApplicationTests.kt               # Spring Boot context load test
└── README.md                                          # Project README
```

**Structure Decision**: Selected **Option 1: Single project** structure because:
- Application is a single web service (no separate frontend/backend needed)
- Server-side rendering (Thymeleaf) eliminates need for separate frontend build
- Simplifies deployment (single JAR)
- Appropriate for the feature scope (~15 source files)
- HTMX integration doesn't require complex JavaScript build pipeline

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

No violations - N/A

## Architecture Overview

### Layered Architecture

```
┌─────────────────────────────────────────────┐
│          Presentation Layer                 │
│  ┌─────────────────┬───────────────────┐   │
│  │ REST Controllers│  Web Controllers  │   │
│  │  (JSON API)     │   (Thymeleaf)     │   │
│  └────────┬────────┴────────┬──────────┘   │
└───────────┼─────────────────┼──────────────┘
            │                 │
┌───────────┼─────────────────┼──────────────┐
│           │  Service Layer  │              │
│  ┌────────▼─────────────────▼──────────┐   │
│  │    ExtractionService (orchestrator) │   │
│  │  ┌──────────┬──────────┬──────────┐ │   │
│  │  │   URL    │ Content  │ Content  │ │   │
│  │  │Validation│  Fetch   │  Parser  │ │   │
│  │  └──────────┴──────────┴──────────┘ │   │
│  └─────────────────────────────────────┘   │
└───────────┼─────────────────┼──────────────┘
            │                 │
┌───────────┼─────────────────┼──────────────┐
│           │  Client Layer   │              │
│  ┌────────▼─────────┐  ┌───▼──────────┐   │
│  │   WebClient      │  │    Jsoup     │   │
│  │ (HTTP fetching)  │  │(HTML parsing)│   │
│  └──────────────────┘  └──────────────┘   │
└─────────────────────────────────────────────┘
            │
            ▼
      External Websites
```

### Request Flow

#### API Request Flow
```
POST /api/extract
   │
   ▼
ExtractionApiController.extractContent()
   │
   ├─> Validate request (@Valid annotation)
   │
   ▼
ExtractionService.extract(request)
   │
   ├─> UrlValidationService.validate(url)
   │   ├─> Check URL format
   │   ├─> Check SSRF (private IPs, localhost)
   │   └─> Return ValidationResult
   │
   ├─> ContentFetchService.fetchHtml(url)
   │   ├─> WebClient.get(url)
   │   ├─> Handle redirects
   │   ├─> Check content type (HTML only)
   │   ├─> Check content size (<5MB)
   │   └─> Return HTML string
   │
   ├─> ContentParserService.extractContent(html, sourceUrl)
   │   ├─> Jsoup.parse(html)
   │   ├─> Remove boilerplate (nav, footer, ads)
   │   ├─> Find main content container
   │   ├─> Extract structured blocks (headings, paragraphs)
   │   └─> Return ExtractedContent
   │
   └─> Build ExtractionResult.Success
       │
       ▼
   Return JSON response (200 OK)

Error at any step:
   │
   ├─> Throw custom exception
   │
   ▼
GlobalExceptionHandler
   │
   ├─> Map exception to ErrorCode
   ├─> Build ExtractionResult.Failure
   └─> Return JSON response (4xx/5xx)
```

#### UI Request Flow
```
GET /
   │
   ▼
WebController.home()
   └─> Render index.html (Thymeleaf)

User submits URL via HTMX
   │
   ▼
POST /api/extract (HTMX request)
   │
   ├─> (Same flow as API above)
   │
   ▼
HTMX receives JSON response
   │
   ├─> Injects result into #result div
   │
   └─> Displays extracted content or error
```

## Phase 0: Technical Research

**Document**: [research.md](./research.md)

**Status**: ✅ COMPLETED

**Key Decisions Made**:
1. **HTML Parsing Library**: Jsoup (industry standard, robust, lightweight)
2. **HTTP Client**: Spring WebClient (reactive, non-blocking, Spring-native)
3. **Frontend**: Thymeleaf + HTMX (server-side rendering, progressive enhancement)
4. **Concurrency**: JDK 25 virtual threads + Kotlin coroutines
5. **Content Extraction Algorithm**: Heuristic-based (remove known boilerplate tags/classes, find largest text block)
6. **Security**: SSRF prevention via URL validation, rate limiting with Bucket4j
7. **Error Handling**: Spring @ControllerAdvice with custom exception hierarchy
8. **Testing**: JUnit 5 + MockK (Kotlin-native mocking)

All "NEEDS CLARIFICATION" items resolved. See research.md for detailed rationale.

## Phase 1: Design & Contracts

### Data Model

**Document**: [data-model.md](./data-model.md)

**Status**: ✅ COMPLETED

**Core Entities**:
1. **ExtractionRequest**: Input validation model
2. **ExtractionResult**: Sealed class (Success | Failure)
3. **ExtractedContent**: Success payload with structured content
4. **ContentBlock**: Single element of structured content (heading, paragraph, etc.)
5. **ExtractionError**: Failure payload with error code and message
6. **ErrorCode**: Enum of 8 error types

**Key Design Patterns**:
- Sealed classes for type-safe result handling
- Immutable data classes (Kotlin best practice)
- Validation rules in data classes (fail-fast)
- No persistence (stateless, no JPA entities)

### API Contracts

**Document**: [contracts/openapi.yaml](./contracts/openapi.yaml)

**Status**: ✅ COMPLETED

**Endpoints**:
- `POST /api/extract` - Main extraction endpoint (JSON API)
- `GET /` - Home page (Thymeleaf UI)
- `GET /result` - Result display (Thymeleaf UI)

**Response Schemas**:
- `ExtractionSuccessResponse` (200 OK)
- `ExtractionErrorResponse` (4xx/5xx with error details)

**Error Codes Defined**:
- 400: INVALID_URL
- 403: BLOCKED_URL
- 404: UNREACHABLE
- 413: CONTENT_TOO_LARGE
- 415: UNSUPPORTED_CONTENT
- 422: NO_CONTENT
- 500: INTERNAL_ERROR
- 504: TIMEOUT

### Integration Test Scenarios

**Document**: [quickstart.md](./quickstart.md)

**Status**: ✅ COMPLETED

**10 Test Scenarios Defined**:
1. Basic content extraction (P1)
2. URL validation (P2)
3. Unreachable URL (P2)
4. SSRF prevention (Security)
5. Redirect handling (Edge case)
6. No content found (Edge case)
7. Content export (P3)
8. Large content (Edge case)
9. Concurrent requests (Performance)
10. Non-HTML content (Edge case)

**Success Criteria Validation**:
- SC-001: <5s extraction time
- SC-002: 90%+ success rate
- SC-003: <30s complete workflow
- SC-004: 95% ad-free content
- SC-005: 100% error messages
- SC-006: 100 concurrent requests

### CLAUDE.md Update

**Status**: ✅ COMPLETED

Added **URL Content Extractor** project section to CLAUDE.md with:
- Project status, location, tech stack
- Key technologies and architecture overview
- Links to all documentation artifacts

## Re-evaluation: Constitution Check

*Re-check after Phase 1 design*

**Status**: ✅ PASSED

No constitution file exists. Design adheres to best practices:
- ✅ Layered architecture (clear separation)
- ✅ Single responsibility (each service has one job)
- ✅ Dependency injection (Spring Boot)
- ✅ Stateless design (horizontally scalable)
- ✅ Error handling strategy (centralized)
- ✅ Testing strategy (unit + integration)
- ✅ Security considerations (SSRF, rate limiting)

No complexity violations introduced.

## Implementation Phases (for /tasks command)

The `/tasks` command will generate detailed task lists based on user stories. Expected phases:

### Phase 1: Project Setup
- Initialize Gradle project with Kotlin DSL
- Configure dependencies (Spring Boot, Jsoup, MockK)
- Set up project structure
- Configure application.yml

### Phase 2: Foundational Components
- Domain models (all data classes)
- Exception hierarchy
- Configuration properties

### Phase 3: User Story P1 - Basic Content Extraction
- UrlValidationService (FR-002)
- ContentFetchService (FR-011, FR-012)
- ContentParserService (FR-003, FR-004, FR-005)
- ExtractionService (orchestrator)
- ExtractionApiController (FR-001, FR-006)
- Integration tests

### Phase 4: User Story P2 - Error Handling
- Custom exceptions
- GlobalExceptionHandler (FR-008, FR-009)
- Error response formatting
- Error scenario tests

### Phase 5: User Story P3 - Content Export
- WebController (UI pages)
- Thymeleaf templates (index.html, result.html)
- HTMX integration (FR-010)
- Copy/download functionality
- UI integration tests

### Phase 6: Polish & Cross-Cutting
- Rate limiting (Bucket4j)
- Actuator health checks
- Logging and metrics
- Performance testing (SC-006)
- Documentation (README.md)

## Dependencies

### build.gradle.kts (Expected)

```kotlin
plugins {
    kotlin("jvm") version "2.1.0"
    kotlin("plugin.spring") version "2.1.0"
    id("org.springframework.boot") version "3.4.0"
    id("io.spring.dependency-management") version "1.1.6"
}

group = "com.example"
version = "1.0.0"
java.sourceCompatibility = JavaVersion.VERSION_25

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-webflux") // WebClient
    implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-validation")

    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor:1.9.0")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")

    // HTML Parsing
    implementation("org.jsoup:jsoup:1.18.1")

    // Rate Limiting
    implementation("com.bucket4j:bucket4j-core:8.10.1")

    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("io.mockk:mockk:1.13.12")
    testImplementation("org.assertj:assertj-core:3.26.3")
    testImplementation("com.github.tomakehurst:wiremock-jre8:3.0.1")
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs = listOf("-Xjsr305=strict")
        jvmTarget = "25"
    }
}
```

### Configuration: application.yml (Expected)

```yaml
server:
  port: 8080

spring:
  application:
    name: url-content-extractor
  threads:
    virtual:
      enabled: true  # JDK 25 virtual threads

extraction:
  timeout: 10000  # 10 seconds
  max-content-length: 5242880  # 5MB
  user-agent: "Mozilla/5.0 (compatible; URLContentExtractor/1.0)"
  rate-limit:
    per-minute: 10
    per-hour: 100

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  metrics:
    export:
      simple:
        enabled: true

logging:
  level:
    com.example.extractor: INFO
    org.springframework.web: INFO
```

## Testing Strategy

### Unit Tests (MockK)
- **UrlValidationService**: Test all URL validation rules, SSRF checks
- **ContentParserService**: Test Jsoup extraction logic, edge cases
- **ContentFetchService**: Mock WebClient, test timeout/error handling
- **ExtractionService**: Mock all dependencies, test orchestration logic

### Integration Tests (Spring Boot Test)
- **ExtractionApiController**: Test full API endpoints with @SpringBootTest
- **WebController**: Test Thymeleaf rendering
- **End-to-end scenarios**: All 10 scenarios from quickstart.md

### Contract Tests
- Validate API responses match OpenAPI schema
- Use JSON Schema validation

### Performance Tests
- Concurrent request handling (SC-006: 100 concurrent)
- Response time validation (SC-001: <5 seconds)

## Deployment Considerations

### Packaging
- Executable JAR: `./gradlew bootJar`
- Run: `java -jar build/libs/url-content-extractor-1.0.0.jar`

### Docker (Future Enhancement)
```dockerfile
FROM eclipse-temurin:25-jre-alpine
COPY build/libs/url-content-extractor-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Environment Variables (Production)
- `SERVER_PORT`: Server port (default: 8080)
- `EXTRACTION_TIMEOUT`: Timeout in ms (default: 10000)
- `EXTRACTION_MAX_CONTENT_LENGTH`: Max size in bytes (default: 5242880)
- `SPRING_THREADS_VIRTUAL_ENABLED`: Enable virtual threads (default: true)

## Risk Assessment

### Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| JavaScript-heavy sites (SPA) fail extraction | Medium | Document limitation, out of scope per spec |
| SSRF bypass via DNS rebinding | High | Validate IP both before and after DNS resolution |
| Rate limit bypass via distributed IPs | Medium | Consider IP range blocking, CAPTCHA for future |
| Memory issues with large pages | Medium | 5MB content limit, streaming if needed |
| Jsoup parsing failures on malformed HTML | Low | Jsoup handles malformed HTML gracefully |

### Performance Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Slow target sites cause timeouts | Medium | 10s timeout, clear error messages |
| Too many concurrent requests | Low | Virtual threads + rate limiting |
| Memory leak in long-running server | Low | Stateless design, proper resource cleanup |

## Next Steps

1. ✅ **Phase 0 Complete**: Technical research finalized
2. ✅ **Phase 1 Complete**: Data model, API contracts, quickstart scenarios defined
3. ✅ **CLAUDE.md Updated**: Project documentation added
4. **Ready for /tasks**: Run `/tasks` to generate implementation task list
5. **Ready for /implement**: After tasks.md created, run `/implement` to execute

## Summary

**Planning Status**: ✅ COMPLETE

**Artifacts Generated**:
- ✅ plan.md (this file)
- ✅ research.md
- ✅ data-model.md
- ✅ contracts/openapi.yaml
- ✅ quickstart.md
- ✅ CLAUDE.md updated

**Tech Stack Confirmed**:
- Language: Kotlin 2.1.0
- Framework: Spring Boot 3.4.0
- Build: Gradle 8.11+ with Kotlin DSL
- Runtime: JDK 25+
- Libraries: Jsoup, WebClient, Thymeleaf, HTMX, Bucket4j

**Architecture**: Layered (Controller → Service → Client/Parser)

**Next Command**: `/tasks` to generate implementation task list
