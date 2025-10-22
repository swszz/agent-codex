# Technical Research: URL Content Extractor

**Feature**: URL Content Extractor
**Date**: 2025-10-19
**Status**: Complete

## Overview

This document captures technical decisions and research findings for implementing a web content extraction application using Kotlin, Spring Boot, Gradle, and JDK 25+.

## Technology Stack Decisions

### Core Platform

**Decision**: Kotlin + Spring Boot 3.4+ with JDK 25+

**Rationale**:
- Kotlin provides null safety, coroutines for async operations, and concise syntax ideal for web services
- Spring Boot 3.4+ supports JDK 25 and provides mature ecosystem for REST APIs
- JDK 25 includes latest performance improvements and virtual threads (Project Loom) for handling concurrent requests efficiently
- Gradle with Kotlin DSL provides type-safe build configuration

**Alternatives Considered**:
- **Plain Kotlin with Ktor**: More lightweight but less mature ecosystem for enterprise features
- **Java with Spring Boot**: Verbose compared to Kotlin, lacks modern language features
- **Quarkus**: Better startup time but smaller ecosystem and less Spring Boot familiarity

### Build Tool

**Decision**: Gradle 8.11+ with Kotlin DSL

**Rationale**:
- Native Kotlin support with type-safe build scripts
- Better performance than Maven for incremental builds
- Rich plugin ecosystem for Spring Boot, Kotlin compilation, and testing
- User explicitly requested Gradle

**Alternatives Considered**:
- **Maven**: XML-based, more verbose, slower builds
- **Gradle with Groovy DSL**: Less type-safe than Kotlin DSL

### Web Content Extraction Library

**Decision**: Jsoup 1.18.1

**Rationale**:
- Industry-standard HTML parser for Java/Kotlin
- Excellent CSS selector support for DOM traversal
- Built-in HTML cleaner for removing unwanted elements
- Active maintenance and extensive documentation
- Can handle malformed HTML gracefully
- Lightweight with no heavy dependencies

**Alternatives Considered**:
- **HtmlUnit**: Full browser simulation, too heavy for simple content extraction
- **Selenium/WebDriver**: Overkill for static content, requires browser binaries
- **Custom regex parsing**: Fragile, unreliable for real-world HTML
- **Readability4J**: Port of Mozilla Readability algorithm, good but less flexible than Jsoup

### HTTP Client

**Decision**: Spring WebClient (from Spring WebFlux)

**Rationale**:
- Non-blocking reactive HTTP client perfect for I/O-bound content fetching
- Built into Spring Boot, no additional dependencies
- Supports timeout configuration, redirects, and error handling
- Works well with Kotlin coroutines
- Handles various response types and character encodings

**Alternatives Considered**:
- **RestTemplate**: Blocking, deprecated in Spring 5+
- **OkHttp**: Excellent library but Spring WebClient provides same features with Spring integration
- **Apache HttpClient**: Mature but verbose API compared to WebClient

### Frontend Technology

**Decision**: Thymeleaf with HTMX

**Rationale**:
- Thymeleaf is Spring Boot's default template engine, minimal configuration
- HTMX provides modern interactive UX without complex JavaScript frameworks
- Allows progressive enhancement: works without JS, better with it
- Simple copy-to-clipboard functionality via HTMX attributes
- Lightweight, no build step required for frontend
- Server-side rendering aligns with Spring Boot architecture

**Alternatives Considered**:
- **React/Vue SPA**: Overkill for simple form + content display, requires separate build process
- **Plain HTML + vanilla JS**: More manual DOM manipulation, less elegant
- **Vaadin**: Full Java framework, steeper learning curve, heavier than needed

### API Design

**Decision**: REST API with JSON responses + Server-Side Rendering

**Rationale**:
- REST endpoints allow programmatic access (future API clients)
- JSON responses enable easy testing and potential mobile apps
- Thymeleaf views provide immediate user interface
- Hybrid approach: UI calls REST API via HTMX, external clients can use API directly

**API Endpoints**:
- `POST /api/extract` - Extract content from URL
- `GET /` - Home page with input form
- `GET /result` - Display extracted content (server-rendered)

### Error Handling Strategy

**Decision**: Spring Boot Exception Handling with @ControllerAdvice

**Rationale**:
- Centralized error handling across all controllers
- Consistent error response format (JSON for API, error pages for UI)
- Proper HTTP status codes for different error types
- Spring's exception hierarchy maps well to our error scenarios

**Error Categories**:
- **400 Bad Request**: Invalid URL format (FR-002, FR-009)
- **404 Not Found**: Target URL not reachable (FR-008, FR-009)
- **422 Unprocessable Entity**: Valid URL but no content extractable (FR-009)
- **500 Internal Server Error**: Unexpected failures (FR-008)
- **504 Gateway Timeout**: Target site too slow (FR-008)

### Content Extraction Algorithm

**Decision**: Jsoup-based extraction with custom filtering rules

**Algorithm**:
1. Fetch HTML via WebClient with user-agent header
2. Parse HTML with Jsoup
3. Remove script, style, nav, footer, aside, iframe elements (FR-004)
4. Remove elements with common ad/navigation classes (ad, advertisement, sidebar, menu, etc.)
5. Extract main content container (article, main, or largest text block)
6. Preserve structure: h1-h6, p, ul, ol, li, blockquote (FR-005)
7. Clean whitespace and normalize text
8. Return structured content model

**Rationale**:
- Balances simplicity with effectiveness for 90%+ of article pages (SC-002)
- Customizable rules without machine learning complexity
- Fast execution for <5 second requirement (SC-001)
- Deterministic and testable

**Alternatives Considered**:
- **Mozilla Readability algorithm**: More sophisticated but harder to customize
- **ML-based extraction**: Overkill, requires training data and model serving
- **XPath-based extraction**: Too brittle, site-specific

### Performance & Concurrency

**Decision**: Virtual Threads (Project Loom) + Kotlin Coroutines

**Rationale**:
- JDK 25 virtual threads handle 100+ concurrent requests efficiently (SC-006)
- Kotlin coroutines provide clean async/await syntax
- Non-blocking WebClient doesn't block threads during HTTP I/O
- Spring Boot 3.4 has native virtual thread support via `spring.threads.virtual.enabled=true`

**Configuration**:
- Request timeout: 10 seconds (prevents hanging on slow sites)
- Connection pool: 200 max connections
- Virtual threads for handling all requests

### Testing Strategy

**Decision**: Multi-layer testing with JUnit 5 + MockK + Spring Test

**Test Layers**:
1. **Unit Tests**: Service logic, URL validation, content parsing (JUnit 5 + MockK)
2. **Integration Tests**: API endpoints with test containers if needed (Spring Boot Test)
3. **Contract Tests**: API response schemas match OpenAPI spec
4. **E2E Tests**: Real URLs against live service (subset of known stable sites)

**Tools**:
- **JUnit 5**: Modern testing framework with Kotlin support
- **MockK**: Kotlin-native mocking library (better than Mockito for Kotlin)
- **AssertJ**: Fluent assertions
- **Spring MockMvc**: Test controllers without starting server
- **WireMock**: Mock external HTTP calls for deterministic tests

**Rationale**:
- MockK provides idiomatic Kotlin mocking (every, verify, etc.)
- Spring Boot Test provides excellent integration test support
- Layered approach ensures quality at each level

### Configuration Management

**Decision**: Spring Boot application.yml + Environment Variables

**Configuration**:
```yaml
server:
  port: 8080

spring:
  threads:
    virtual:
      enabled: true

extraction:
  timeout: 10000  # milliseconds
  max-content-length: 5242880  # 5MB
  user-agent: "Mozilla/5.0 (compatible; URLContentExtractor/1.0)"
```

**Rationale**:
- application.yml for defaults
- Environment variables for deployment-specific overrides
- Type-safe configuration with @ConfigurationProperties
- Easy to test with different profiles

### Logging & Monitoring

**Decision**: SLF4J with Logback + Micrometer

**Rationale**:
- SLF4J is Spring Boot default, industry standard
- Logback provides structured logging with MDC for request tracing
- Micrometer exposes metrics for monitoring extraction success rate, latency
- Ready for production observability

**Key Metrics**:
- Extraction success rate (target: 90%+, SC-002)
- Extraction latency (target: <5s, SC-001)
- Error rate by type (validation, network, parsing)
- Concurrent request count

### Deployment & Packaging

**Decision**: Executable JAR with embedded Tomcat

**Rationale**:
- Spring Boot default, simplest deployment model
- Single JAR contains all dependencies
- No external application server required
- Can run directly: `java -jar url-content-extractor.jar`
- Docker-friendly for containerized deployments

**Alternatives Considered**:
- **WAR deployment**: Legacy, requires external Tomcat
- **Native image (GraalVM)**: Faster startup but limits reflection, premature optimization

## Architecture Decisions

### Layered Architecture

**Decision**: Classic Spring Boot layered architecture

**Layers**:
1. **Controller Layer**: REST endpoints + Thymeleaf views
2. **Service Layer**: Business logic (URL validation, content extraction)
3. **Domain Layer**: Data models (ExtractionRequest, ExtractionResult, ExtractedContent)
4. **Client Layer**: HTTP client for fetching external content

**Rationale**:
- Clear separation of concerns
- Easy to test each layer independently
- Standard Spring Boot pattern, familiar to developers
- Matches project complexity (not over-engineered)

### Data Flow

```
User Request → Controller → Service → HTTP Client → External Site
                   ↓            ↓
              Thymeleaf    Content Parser (Jsoup)
                   ↓            ↓
              HTML Response  Extracted Content
```

### No Database Required

**Decision**: Stateless application, no persistence

**Rationale**:
- Spec explicitly excludes history storage (Out of Scope)
- Each request is independent
- Simpler deployment and operations
- Faster development
- Can add later if needed without architectural changes

## Security Considerations

### SSRF Prevention

**Decision**: URL validation and allowlist/blocklist

**Measures**:
- Validate URL format before fetching
- Block private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 127.0.0.0/8)
- Block localhost and metadata endpoints (169.254.169.254)
- Limit redirects to prevent redirect loops
- Set maximum response size (5MB)

**Rationale**:
- Prevents SSRF attacks where attackers probe internal networks
- Essential for any service that fetches user-provided URLs

### Input Sanitization

**Decision**: URL encoding validation + HTML sanitization

**Measures**:
- Validate URL encoding and format
- Jsoup.clean() to sanitize extracted HTML
- Escape all user input in Thymeleaf templates
- Content Security Policy headers

**Rationale**:
- Prevents XSS attacks from malicious extracted content
- Defense in depth

### Rate Limiting

**Decision**: Spring Boot Bucket4j for rate limiting

**Configuration**:
- 10 requests per minute per IP address
- 100 requests per hour per IP address

**Rationale**:
- Prevents abuse and DoS attacks
- Ensures fair resource usage (SC-006: 100 concurrent requests)
- Lightweight, in-memory implementation sufficient for MVP

## Open Questions Resolved

### Q1: How to handle JavaScript-rendered content?

**Answer**: Out of scope for MVP (spec: "Target web pages are primarily HTML-based content"). Static HTML extraction with Jsoup is sufficient for 90%+ of article sites. Can revisit with headless browser (Playwright) if needed.

### Q2: Should we cache extracted content?

**Answer**: No for MVP. Adds complexity (cache invalidation, storage). Each extraction is fresh. Can add Redis caching later if performance testing shows need.

### Q3: How to determine main content vs. boilerplate?

**Answer**: Heuristic-based approach:
1. Remove known boilerplate tags (nav, footer, aside)
2. Remove elements with common class names (sidebar, ad, menu)
3. Find largest text block in remaining content
4. Prefer semantic tags: article > main > div with most text

### Q4: Text-only vs. formatted output?

**Answer**: Preserve basic formatting (headings, paragraphs, lists) as structured text. No images or rich media (spec: "plain text content extraction"). Output as HTML for display, provide text-only for export.

### Q5: Character encoding handling?

**Answer**: Jsoup auto-detects encoding from Content-Type header and HTML meta tags. Fallback to UTF-8. Covers 99%+ of real-world cases.

## Implementation Priorities

Based on User Stories (P1 → P2 → P3):

1. **Phase 1 (P1)**: Core extraction
   - REST API endpoint
   - URL validation
   - HTTP client with WebClient
   - Jsoup content extraction
   - Basic Thymeleaf UI

2. **Phase 2 (P2)**: Error handling
   - Exception handling
   - Error messages
   - Timeout handling
   - Edge case coverage

3. **Phase 3 (P3)**: Export features
   - Copy to clipboard
   - Download as text file
   - HTMX interactivity

## Summary

**Tech Stack**: Kotlin + Spring Boot 3.4 + Gradle 8.11 + JDK 25
**Key Libraries**: Jsoup (HTML parsing), WebClient (HTTP), Thymeleaf + HTMX (UI)
**Architecture**: Layered REST API with server-side rendering
**Testing**: JUnit 5 + MockK + Spring Boot Test
**Deployment**: Executable JAR with embedded Tomcat

All technical decisions align with:
- User's specified tech stack (Gradle, Kotlin, Spring Boot, JDK 25+)
- Functional requirements (FR-001 through FR-012)
- Success criteria (SC-001 through SC-006)
- Out of scope boundaries (no auth, no JS-heavy sites, no persistence)

Ready to proceed to Phase 1: Data Model and API Contracts.
