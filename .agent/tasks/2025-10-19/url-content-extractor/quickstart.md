# Quickstart Guide: URL Content Extractor

**Feature**: URL Content Extractor
**Tech Stack**: Kotlin + Spring Boot 3.4 + Gradle 8.11 + JDK 25
**Date**: 2025-10-19

## Overview

This quickstart guide provides step-by-step instructions for running the URL Content Extractor application locally, testing the API, and validating functionality against the acceptance criteria.

## Prerequisites

- **JDK 25+** installed and configured
- **Gradle 8.11+** (or use included Gradle wrapper)
- **Internet connectivity** (to fetch web pages)
- **curl** or **Postman** (for API testing)
- **Web browser** (for UI testing)

## Quick Start

### 1. Build the Application

```bash
# Clone or navigate to project directory
cd url-content-extractor

# Build with Gradle
./gradlew clean build

# Run tests
./gradlew test
```

### 2. Run the Application

```bash
# Start the Spring Boot application
./gradlew bootRun

# Or run the built JAR
java -jar build/libs/url-content-extractor-1.0.0.jar
```

**Expected Output**:
```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v3.4.0)

2025-10-19 10:30:00.123  INFO ... : Started ApplicationKt in 2.5 seconds
2025-10-19 10:30:00.234  INFO ... : Application started on port 8080
```

### 3. Verify Application is Running

```bash
# Health check
curl http://localhost:8080/actuator/health

# Expected response
{"status":"UP"}
```

### 4. Open the Web UI

Navigate to: **http://localhost:8080/**

You should see:
- URL input form
- Submit button
- Example URLs (optional)

## Integration Test Scenarios

### Scenario 1: Basic Content Extraction (P1 - User Story 1)

**Test**: Extract content from a blog article

#### Via API

```bash
curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/blog/sample-article"
  }'
```

**Expected Response** (200 OK):
```json
{
  "success": true,
  "requestedUrl": "https://example.com/blog/sample-article",
  "processingTimeMs": 1250,
  "content": {
    "title": "Sample Article Title",
    "text": "This is the main article content...",
    "structuredContent": [
      {
        "type": "HEADING",
        "content": "Introduction",
        "level": 1
      },
      {
        "type": "PARAGRAPH",
        "content": "This is the main article content..."
      }
    ],
    "sourceUrl": "https://example.com/blog/sample-article",
    "extractedAt": "2025-10-19T10:30:00Z",
    "contentLength": 1523,
    "language": "en"
  }
}
```

**Acceptance Criteria**:
- ✅ **SC-001**: Response received in <5 seconds
- ✅ **FR-003**: Main body content extracted
- ✅ **FR-004**: No navigation/ads in content
- ✅ **FR-005**: Headings and paragraphs preserved

#### Via Web UI

1. Open http://localhost:8080/
2. Enter URL: `https://example.com/blog/sample-article`
3. Click "Extract Content"
4. **Expected**:
   - Loading indicator appears (FR-007)
   - Main article text displays without navigation/ads
   - Headings and paragraph structure preserved

---

### Scenario 2: URL Validation (P2 - User Story 2)

**Test**: Handle invalid URL format

#### Via API

```bash
curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{
    "url": "not-a-valid-url"
  }'
```

**Expected Response** (400 Bad Request):
```json
{
  "success": false,
  "requestedUrl": "not-a-valid-url",
  "processingTimeMs": 5,
  "error": {
    "errorCode": "INVALID_URL",
    "message": "The provided URL format is invalid. Please enter a valid HTTP or HTTPS URL.",
    "details": "URL must start with http:// or https://"
  }
}
```

**Acceptance Criteria**:
- ✅ **FR-002**: URL validated before extraction
- ✅ **FR-009**: Clear error message provided
- ✅ **SC-005**: 100% of failures have error messages

#### Via Web UI

1. Enter invalid URL: `not-a-url`
2. Click "Extract Content"
3. **Expected**: Error message displays: "The provided URL format is invalid..."

---

### Scenario 3: Unreachable URL (P2 - User Story 2)

**Test**: Handle network errors gracefully

#### Via API

```bash
curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://nonexistent-site-12345.com/article"
  }'
```

**Expected Response** (404 Not Found):
```json
{
  "success": false,
  "requestedUrl": "https://nonexistent-site-12345.com/article",
  "processingTimeMs": 3000,
  "error": {
    "errorCode": "UNREACHABLE",
    "message": "The website could not be reached. Please check the URL and try again.",
    "details": "UnknownHostException: nonexistent-site-12345.com"
  }
}
```

**Acceptance Criteria**:
- ✅ **FR-008**: Network errors handled gracefully
- ✅ **FR-009**: Clear, actionable error message

---

### Scenario 4: SSRF Prevention (Security)

**Test**: Block private IP addresses

#### Via API

```bash
curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{
    "url": "http://192.168.1.1/admin"
  }'
```

**Expected Response** (403 Forbidden):
```json
{
  "success": false,
  "requestedUrl": "http://192.168.1.1/admin",
  "processingTimeMs": 3,
  "error": {
    "errorCode": "BLOCKED_URL",
    "message": "This URL cannot be accessed for security reasons.",
    "details": "Private IP addresses and localhost are not allowed"
  }
}
```

**Test Cases**:
- `http://localhost:8080/admin` → Blocked
- `http://127.0.0.1/` → Blocked
- `http://10.0.0.1/` → Blocked
- `http://172.16.0.1/` → Blocked
- `http://192.168.0.1/` → Blocked
- `http://169.254.169.254/latest/meta-data/` → Blocked (AWS metadata)

---

### Scenario 5: Redirect Handling (Edge Case)

**Test**: Follow redirects transparently

#### Via API

```bash
curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{
    "url": "http://example.com/old-url"
  }'
```

**Expected Response** (200 OK):
- `requestedUrl`: `http://example.com/old-url`
- `sourceUrl`: `http://example.com/new-url` (after redirect)
- Content extracted successfully

**Acceptance Criteria**:
- ✅ **FR-012**: URL redirects handled transparently
- ✅ Source URL reflects final destination

---

### Scenario 6: No Content Found (Edge Case)

**Test**: Handle pages with no extractable content

#### Via API

```bash
curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/empty-page"
  }'
```

**Expected Response** (422 Unprocessable Entity):
```json
{
  "success": false,
  "requestedUrl": "https://example.com/empty-page",
  "processingTimeMs": 800,
  "error": {
    "errorCode": "NO_CONTENT",
    "message": "No main content could be extracted from this page.",
    "details": "Page contains only navigation and boilerplate elements"
  }
}
```

---

### Scenario 7: Content Export (P3 - User Story 3)

**Test**: Copy and download extracted content

#### Via Web UI

1. Extract content from any URL
2. Click "Copy to Clipboard" button
3. **Expected**:
   - Content copied to clipboard (FR-010)
   - Success notification appears
   - Can paste content elsewhere

4. Click "Download as Text" button
5. **Expected**:
   - Text file downloads with article title as filename
   - File contains extracted plain text

---

### Scenario 8: Large Content (Edge Case)

**Test**: Handle large articles

#### Via API

```bash
curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/very-long-article"
  }'
```

**Expected**:
- If content <5MB: Extract successfully
- If content >5MB: Return 413 Content Too Large error

**Acceptance Criteria**:
- ✅ Processing completes within timeout (10s max)
- ✅ Large pages handled without memory issues

---

### Scenario 9: Concurrent Requests (Performance - SC-006)

**Test**: Handle 100 concurrent extraction requests

#### Load Test Script

```bash
# Using Apache Bench (ab)
ab -n 100 -c 100 -T "application/json" -p request.json \
   http://localhost:8080/api/extract
```

**request.json**:
```json
{
  "url": "https://example.com/test-article"
}
```

**Expected Results**:
- All 100 requests complete successfully
- No 500 errors or timeouts
- Average response time <5 seconds
- No performance degradation

**Alternative (Artillery.io)**:
```yaml
config:
  target: "http://localhost:8080"
  phases:
    - duration: 60
      arrivalRate: 10
scenarios:
  - flow:
      - post:
          url: "/api/extract"
          json:
            url: "https://example.com/article"
```

---

### Scenario 10: Non-HTML Content (Edge Case)

**Test**: Reject PDF and other non-HTML content

#### Via API

```bash
curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/document.pdf"
  }'
```

**Expected Response** (415 Unsupported Media Type):
```json
{
  "success": false,
  "requestedUrl": "https://example.com/document.pdf",
  "processingTimeMs": 500,
  "error": {
    "errorCode": "UNSUPPORTED_CONTENT",
    "message": "This content type is not supported. Only HTML pages can be extracted.",
    "details": "Content-Type: application/pdf"
  }
}
```

---

## Success Criteria Validation

### SC-001: Extraction time <5 seconds

**Test**:
```bash
time curl -X POST http://localhost:8080/api/extract \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/article"}'
```

**Pass Criteria**: Total time <5 seconds, `processingTimeMs` <5000

---

### SC-002: 90% success rate on standard articles

**Test**: Extract from 20 different blog/news sites
- Expected: ≥18 successful extractions (90%)

**Sample URLs**:
- https://medium.com/@author/article
- https://dev.to/author/article
- https://techcrunch.com/2025/10/19/article
- (17 more diverse article URLs)

---

### SC-003: Complete workflow <30 seconds

**Test** (Manual UI):
1. Start timer
2. Enter URL
3. Click extract
4. View content
5. Copy to clipboard
6. Stop timer

**Pass Criteria**: <30 seconds total

---

### SC-004: 95% ad-free content

**Test**: Visual inspection of extracted content
- Expected: No navigation menus, no ads, no sidebars in ≥19/20 samples

---

### SC-005: 100% error messages

**Test**: Trigger all 8 error types
- Expected: All return clear, actionable error messages

---

### SC-006: 100 concurrent requests

**Test**: Load test (Scenario 9)
- Expected: All complete without degradation

---

## Configuration

### Environment Variables

```bash
# Server port (default: 8080)
export SERVER_PORT=8080

# Enable virtual threads
export SPRING_THREADS_VIRTUAL_ENABLED=true

# Extraction timeout (milliseconds, default: 10000)
export EXTRACTION_TIMEOUT=10000

# Max content length (bytes, default: 5MB)
export EXTRACTION_MAX_CONTENT_LENGTH=5242880

# User agent string
export EXTRACTION_USER_AGENT="Mozilla/5.0 (compatible; URLContentExtractor/1.0)"
```

### Application Properties

Edit `src/main/resources/application.yml`:

```yaml
server:
  port: ${SERVER_PORT:8080}

spring:
  threads:
    virtual:
      enabled: ${SPRING_THREADS_VIRTUAL_ENABLED:true}

extraction:
  timeout: ${EXTRACTION_TIMEOUT:10000}
  max-content-length: ${EXTRACTION_MAX_CONTENT_LENGTH:5242880}
  user-agent: ${EXTRACTION_USER_AGENT:Mozilla/5.0 (compatible; URLContentExtractor/1.0)}

logging:
  level:
    com.example.extractor: DEBUG
```

---

## Troubleshooting

### Issue: Application won't start

**Solution**: Verify JDK 25+ is installed
```bash
java -version
# Should show: openjdk version "25" or higher
```

### Issue: Extraction always times out

**Solution**: Increase timeout
```bash
export EXTRACTION_TIMEOUT=20000
./gradlew bootRun
```

### Issue: Tests failing

**Solution**: Check internet connectivity, or use WireMock for deterministic tests

### Issue: Out of memory with many requests

**Solution**: Increase heap size
```bash
JAVA_OPTS="-Xmx2g" ./gradlew bootRun
```

---

## Next Steps

After validating all scenarios:

1. ✅ All P1 scenarios pass → **MVP Complete**
2. ✅ All P2 scenarios pass → **Error Handling Complete**
3. ✅ All P3 scenarios pass → **Full Feature Complete**
4. Run `/tasks` to generate implementation task list
5. Run `/implement` to execute implementation

---

## Summary

**Total Scenarios**: 10
- **P1 (Critical)**: 1, 8, 9
- **P2 (Important)**: 2, 3, 4, 5, 6, 10
- **P3 (Nice-to-have)**: 7

**Success Criteria**: All 6 (SC-001 through SC-006)

**API Endpoints**:
- `POST /api/extract` - Main extraction endpoint
- `GET /` - Web UI home
- `GET /result` - Web UI result display
- `GET /actuator/health` - Health check

**Run all tests**:
```bash
./gradlew test integrationTest
```

Ready to proceed with implementation!
