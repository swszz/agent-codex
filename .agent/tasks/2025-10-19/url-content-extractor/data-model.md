# Data Model: URL Content Extractor

**Feature**: URL Content Extractor
**Date**: 2025-10-19
**Tech Stack**: Kotlin + Spring Boot

## Overview

This document defines the domain models for the URL content extraction application. Since the application is stateless (no database), these models represent runtime data structures used during request processing.

## Core Entities

### 1. ExtractionRequest

Represents a user's request to extract content from a URL.

**Purpose**: Input validation and request processing

**Attributes**:
- `url: String` - The target URL to extract content from (required)
- `timestamp: Instant` - When the request was received (auto-generated)

**Validation Rules**:
- `url` must not be blank
- `url` must be valid URL format (http:// or https://)
- `url` must not point to private IP ranges (SSRF prevention)
- `url` must not exceed 2048 characters

**Example**:
```kotlin
data class ExtractionRequest(
    @field:NotBlank(message = "URL is required")
    @field:URL(message = "Invalid URL format")
    val url: String
) {
    val timestamp: Instant = Instant.now()
}
```

**Relationships**:
- Creates one `ExtractionResult` upon processing

---

### 2. ExtractedContent

Represents the successfully extracted and parsed content from a web page.

**Purpose**: Structured representation of extracted main content

**Attributes**:
- `title: String?` - Page title (nullable if not found)
- `text: String` - Main body text content (required)
- `structuredContent: List<ContentBlock>` - Hierarchical content with formatting preserved
- `sourceUrl: String` - Original URL (may differ from request URL due to redirects)
- `extractedAt: Instant` - When extraction was performed
- `contentLength: Int` - Character count of extracted text
- `language: String?` - Detected language code (nullable, e.g., "en", "ko")

**Validation Rules**:
- `text` must not be blank (if blank, extraction failed)
- `contentLength` must be > 0
- `structuredContent` must not be empty

**Example**:
```kotlin
data class ExtractedContent(
    val title: String?,
    val text: String,
    val structuredContent: List<ContentBlock>,
    val sourceUrl: String,
    val extractedAt: Instant = Instant.now(),
    val language: String? = null
) {
    val contentLength: Int get() = text.length
}
```

**Relationships**:
- Contained within `ExtractionResult` (success case)
- Composed of multiple `ContentBlock` elements

---

### 3. ContentBlock

Represents a single block of structured content (heading, paragraph, list, etc.)

**Purpose**: Preserve content structure and formatting

**Attributes**:
- `type: ContentBlockType` - Type of content block (enum)
- `content: String` - The actual text content
- `level: Int?` - Heading level (1-6) for heading blocks, null otherwise

**Content Block Types** (enum):
```kotlin
enum class ContentBlockType {
    HEADING,    // h1-h6
    PARAGRAPH,  // p
    LIST_ITEM,  // li
    QUOTE,      // blockquote
    CODE        // code blocks (if needed)
}
```

**Validation Rules**:
- `content` must not be blank
- `level` must be 1-6 if type is HEADING, null otherwise

**Example**:
```kotlin
data class ContentBlock(
    val type: ContentBlockType,
    val content: String,
    val level: Int? = null
) {
    init {
        require(content.isNotBlank()) { "Content must not be blank" }
        if (type == ContentBlockType.HEADING) {
            require(level in 1..6) { "Heading level must be 1-6" }
        } else {
            require(level == null) { "Only headings have level attribute" }
        }
    }
}
```

**Relationships**:
- Multiple blocks compose `ExtractedContent.structuredContent`

---

### 4. ExtractionResult

Represents the complete outcome of an extraction attempt (success or failure).

**Purpose**: Unified response model for API and UI

**Attributes**:
- `success: Boolean` - Whether extraction succeeded
- `content: ExtractedContent?` - Extracted content (present only if success = true)
- `error: ExtractionError?` - Error details (present only if success = false)
- `processingTimeMs: Long` - Time taken to process request in milliseconds
- `requestedUrl: String` - Original URL from request

**Validation Rules**:
- If `success = true`, `content` must be non-null and `error` must be null
- If `success = false`, `error` must be non-null and `content` must be null

**Example**:
```kotlin
sealed class ExtractionResult {
    abstract val requestedUrl: String
    abstract val processingTimeMs: Long

    data class Success(
        override val requestedUrl: String,
        override val processingTimeMs: Long,
        val content: ExtractedContent
    ) : ExtractionResult()

    data class Failure(
        override val requestedUrl: String,
        override val processingTimeMs: Long,
        val error: ExtractionError
    ) : ExtractionResult()
}
```

**Relationships**:
- Created from `ExtractionRequest`
- Contains either `ExtractedContent` or `ExtractionError`

---

### 5. ExtractionError

Represents error details when extraction fails.

**Purpose**: Provide clear, actionable error messages to users

**Attributes**:
- `errorCode: ErrorCode` - Machine-readable error code (enum)
- `message: String` - Human-readable error message
- `details: String?` - Additional technical details (optional)

**Error Codes** (enum):
```kotlin
enum class ErrorCode(val httpStatus: Int) {
    INVALID_URL(400),           // Malformed URL format
    UNREACHABLE(404),           // Cannot connect to target URL
    NO_CONTENT(422),            // Page found but no extractable content
    TIMEOUT(504),               // Request timed out
    BLOCKED_URL(403),           // URL blocked (private IP, localhost)
    CONTENT_TOO_LARGE(413),     // Response exceeds size limit
    UNSUPPORTED_CONTENT(415),   // Non-HTML content type
    INTERNAL_ERROR(500)         // Unexpected server error
}
```

**Example**:
```kotlin
data class ExtractionError(
    val errorCode: ErrorCode,
    val message: String,
    val details: String? = null
)
```

**Relationships**:
- Contained within `ExtractionResult.Failure`

---

## Entity Relationships Diagram

```
ExtractionRequest (1) ---creates---> (1) ExtractionResult
                                           |
                                           +--- Success (1) ---contains---> (1) ExtractedContent
                                           |                                      |
                                           |                                      +--composed-of--> (*) ContentBlock
                                           |
                                           +--- Failure (1) ---contains---> (1) ExtractionError
```

## State Transitions

### Extraction Request Lifecycle

```
[ExtractionRequest received]
        |
        v
[Validate URL format] --invalid--> [ExtractionResult.Failure: INVALID_URL]
        |
        | valid
        v
[Check URL safety] --blocked--> [ExtractionResult.Failure: BLOCKED_URL]
        |
        | safe
        v
[Fetch HTML] --timeout--> [ExtractionResult.Failure: TIMEOUT]
        |        |
        |        +--connection error--> [ExtractionResult.Failure: UNREACHABLE]
        |        |
        |        +--too large--> [ExtractionResult.Failure: CONTENT_TOO_LARGE]
        |
        | success
        v
[Parse HTML]
        |
        v
[Extract content] --no content--> [ExtractionResult.Failure: NO_CONTENT]
        |
        | content found
        v
[Build ContentBlocks]
        |
        v
[ExtractionResult.Success with ExtractedContent]
```

## Validation Summary

### Request Validation (FR-002)
- URL format validation
- URL length validation (max 2048 chars)
- Protocol validation (http/https only)
- SSRF protection (block private IPs, localhost)

### Content Validation
- Extracted text not empty
- At least one ContentBlock present
- Content length within reasonable bounds

### Error Handling (FR-008, FR-009)
- All failure paths produce ExtractionError with clear message
- HTTP status codes map to error codes
- Technical details available for debugging

## API Mapping

### Request → Domain
- `POST /api/extract` body → `ExtractionRequest`

### Domain → Response
- `ExtractionResult.Success` → `200 OK` with `ExtractedContent` JSON
- `ExtractionResult.Failure` → HTTP status from `ErrorCode` with `ExtractionError` JSON

### View Rendering
- `ExtractionResult.Success` → Thymeleaf template with formatted content
- `ExtractionResult.Failure` → Error page with user-friendly message

## Performance Considerations

### Memory Footprint
- **ExtractionRequest**: ~100 bytes
- **ExtractedContent**: ~10KB typical article (1000 words × 10 chars/word)
- **ContentBlock**: ~100 bytes per block
- **Total per request**: ~15-20KB

### Processing Time (SC-001: <5 seconds)
- URL validation: <1ms
- HTTP fetch: 100-3000ms (depends on target site)
- HTML parsing: 10-100ms (depends on page size)
- Content extraction: 10-50ms
- Total: typically 200-3500ms, max 10s (timeout)

### Concurrency (SC-006: 100 concurrent requests)
- Stateless models enable thread-safe concurrent processing
- No shared mutable state
- Virtual threads handle blocking I/O efficiently
- Memory: 100 requests × 20KB = 2MB (negligible)

## Testing Scenarios

### Valid Extraction
```kotlin
val request = ExtractionRequest(url = "https://example.com/article")
// Process request
val result = extractionService.extract(request)
// Assert
assertTrue(result is ExtractionResult.Success)
assertEquals("Example Article", result.content.title)
assertTrue(result.content.contentLength > 0)
```

### Invalid URL
```kotlin
val request = ExtractionRequest(url = "not-a-url")
// Process request
val result = extractionService.extract(request)
// Assert
assertTrue(result is ExtractionResult.Failure)
assertEquals(ErrorCode.INVALID_URL, result.error.errorCode)
```

### SSRF Prevention
```kotlin
val request = ExtractionRequest(url = "http://localhost:8080/admin")
// Process request
val result = extractionService.extract(request)
// Assert
assertTrue(result is ExtractionResult.Failure)
assertEquals(ErrorCode.BLOCKED_URL, result.error.errorCode)
```

### No Content Found
```kotlin
val request = ExtractionRequest(url = "https://example.com/empty")
// Mock HTML with no main content
val result = extractionService.extract(request)
// Assert
assertTrue(result is ExtractionResult.Failure)
assertEquals(ErrorCode.NO_CONTENT, result.error.errorCode)
```

## Extension Points

### Future Enhancements (Out of MVP Scope)

**Extraction History** (if needed later):
```kotlin
data class ExtractionHistory(
    val id: UUID,
    val request: ExtractionRequest,
    val result: ExtractionResult,
    val userId: String?
)
```

**Caching** (if performance optimization needed):
```kotlin
// Cache key: hash(url)
// Cache value: ExtractedContent
// TTL: 1 hour
```

**Batch Processing** (currently out of scope):
```kotlin
data class BatchExtractionRequest(
    val urls: List<String>
)

data class BatchExtractionResult(
    val results: List<ExtractionResult>
)
```

## Summary

**Core Models**: 5 entities
- ExtractionRequest (input)
- ExtractedContent (success output)
- ContentBlock (content structure)
- ExtractionResult (unified response)
- ExtractionError (failure details)

**Design Principles**:
- Immutable data classes (Kotlin best practice)
- Sealed classes for type-safe result handling
- Clear validation rules
- Separation of concerns (request, content, error, result)
- No database dependencies (stateless)

**Aligns with**:
- FR-001 to FR-012 (all functional requirements)
- SC-001 to SC-006 (performance and success criteria)
- Error handling requirements (FR-008, FR-009)
