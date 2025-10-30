# Developer Guide - VAbitnetUI

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Setting Up Development Environment](#setting-up-development-environment)
3. [Code Organization](#code-organization)
4. [How to Add Features](#how-to-add-features)
5. [Testing](#testing)
6. [Common Patterns](#common-patterns)
7. [Best Practices](#best-practices)

---

## Architecture Overview

### The Big Picture

```
┌─────────────┐
│    USER     │
│   (You!)    │
└──────┬──────┘
       │
       ↓
┌─────────────────────────────────┐
│     UI Layer (PyQt6)            │
│  main_window.py, styles.py      │
└────────┬────────────────────────┘
         │
         ↓
┌─────────────────────────────────┐
│   Services Layer                │
│  - ChatService                  │
│  - InferenceService             │
│  - AudioService                 │
└────────┬────────────────────────┘
         │
         ↓
┌─────────────────────────────────┐
│  Infrastructure Layer (NEW!)    │
│  - BitNetHTTPClient             │
│  (Talks to external APIs)       │
└────────┬────────────────────────┘
         │
         ↓
┌─────────────────────────────────┐
│   Core Layer                    │
│  - Config (settings)            │
│  - Models (data structures)     │
│  - Errors (error types)         │
└─────────────────────────────────┘
```

### Design Philosophy: "Braun Aesthetic"

Like the German company Braun (famous for clean design):
- **Simple**: Each piece does one thing well
- **Clear**: Code reads like English
- **No Waste**: Every line has a purpose

---

## Setting Up Development Environment

### 1. Clone and Install

```bash
git clone https://github.com/cyber3pxVA/VAbitnetUI.git
cd VAbitnetUI
pip install -r requirements.txt
```

### 2. Install Development Tools

```bash
# Code formatter
pip install black

# Linter (finds bugs)
pip install pylint

# Type checker
pip install mypy
```

### 3. Configure Your IDE

**VS Code** (recommended):
```json
// .vscode/settings.json
{
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "editor.formatOnSave": true
}
```

### 4. Run the App

```bash
# Terminal 1: Start BitNet server
cd bitnet_backend
# (follow BitNet startup instructions)

# Terminal 2: Run the app
python main.py
```

---

## Code Organization

### Layer Rules (IMPORTANT!)

```python
# ✅ GOOD: Layers can call DOWN
# UI → Services → Infrastructure → Core

# ❌ BAD: Layers CANNOT call UP
# Core should NOT import from Services
# Services should NOT import from UI
```

### Core Layer (`src/core/`)

**What goes here**: Pure data structures, no I/O, no external calls

```python
# config.py - All settings
@dataclass(frozen=True)  # Immutable!
class BitNetConfig:
    endpoint_url: str = "http://localhost:8081/completion"
    max_tokens: int = 2048

# models.py - Data structures
@dataclass(frozen=True)
class ProcessingRequest:
    transcript: str
    custom_prompt: Optional[str] = None

# errors.py - Error types
class ErrorCode(Enum):
    NETWORK_ERROR = "network_error"
    TIMEOUT = "timeout"
```

### Infrastructure Layer (`src/infrastructure/`)

**What goes here**: External system connections (HTTP, databases, files)

```python
# http_client.py - Talks to BitNet API
class BitNetHTTPClient:
    def post_completion(self, payload: dict) -> APIResponse:
        # Makes HTTP request
        # Handles all errors
        # Returns structured response
```

### Services Layer (`src/services/`)

**What goes here**: Business logic, orchestration

```python
# inference_service.py
class InferenceService:
    def __init__(self, config: BitNetConfig):
        self._http_client = BitNetHTTPClient(config)  # Use infrastructure
    
    def process(self, request: ProcessingRequest) -> ProcessingResult:
        # Validate request
        # Build prompt
        # Call HTTP client
        # Return structured result
```

### UI Layer (`src/ui/`)

**What goes here**: User interface, display logic only

```python
# main_window.py
class MainWindow:
    def __init__(self, config: Config):
        self._inference_service = InferenceService(config.bitnet)
    
    def on_process_clicked(self):
        # Get text from UI
        # Call service
        # Display result
```

---

## How to Add Features

### Example: Add a "Summarize" Button

#### Step 1: Add to Core (if needed)

If you need new settings:

```python
# src/core/config.py
@dataclass(frozen=True)
class BitNetConfig:
    # ... existing fields ...
    summary_max_length: int = 500  # NEW!
```

#### Step 2: Update Service

```python
# src/services/inference_service.py
class InferenceService:
    def summarize(self, text: str) -> ProcessingResult:
        """
        Summarize long text into brief points.
        """
        request = ProcessingRequest(
            transcript=text,
            custom_prompt="Summarize this in 3-5 bullet points:",
            max_tokens=self._config.summary_max_length
        )
        return self.process(request)
```

#### Step 3: Add to UI

```python
# src/ui/main_window.py
def _create_buttons(self):
    # ... existing buttons ...
    
    self.summarize_btn = QPushButton("Summarize")
    self.summarize_btn.clicked.connect(self._on_summarize_clicked)
    
def _on_summarize_clicked(self):
    text = self.input_text.toPlainText()
    if not text:
        return
    
    # Run in background thread (don't freeze UI)
    result = self._inference_service.summarize(text)
    
    if result.is_success:
        self.output_text.setPlainText(result.processed_text)
    else:
        self._show_error(result.error_message)
```

---

## Testing

### Manual Testing

```bash
# Run the app
python main.py

# Test each feature:
# 1. Record audio → Check transcription
# 2. Process text → Check AI output
# 3. Chat → Check responses
# 4. Clear history → Check it clears
```

### Unit Testing (Coming Soon)

```python
# tests/test_inference_service.py
def test_process_valid_request():
    # Mock the HTTP client
    mock_client = MockBitNetHTTPClient()
    service = InferenceService(test_config)
    service._http_client = mock_client
    
    # Test
    request = ProcessingRequest(transcript="Hello world")
    result = service.process(request)
    
    # Verify
    assert result.is_success
    assert result.processed_text == "Expected output"
```

---

## Common Patterns

### Pattern 1: Structured Errors (Always Use This!)

```python
# ❌ BAD: String errors
def do_something():
    return "Error: something failed"

# ✅ GOOD: Structured errors
def do_something():
    return ProcessingResult.failure(
        error=APIError(
            code=ErrorCode.VALIDATION_ERROR,
            message="Input too long",
            details={"length": 5000, "max": 2048}
        )
    )
```

### Pattern 2: Immutable Data

```python
# ✅ GOOD: Can't be changed after creation
@dataclass(frozen=True)
class Config:
    timeout: int = 30

# ❌ BAD: Can be changed anywhere
class Config:
    def __init__(self):
        self.timeout = 30  # Can be modified!
```

### Pattern 3: Factory Methods

```python
# ✅ GOOD: Clear intent
result = ProcessingResult.success(
    processed_text="Clean output",
    processing_time_ms=123.45
)

# ❌ BAD: Unclear what fields mean
result = ProcessingResult(
    status=ProcessingStatus.COMPLETED,
    processed_text="Clean output",
    error=None,
    processing_time_ms=123.45
)
```

### Pattern 4: Optional Callbacks

```python
# ✅ GOOD: Caller can provide progress updates
def process(
    self,
    request: ProcessingRequest,
    callback_status: Optional[Callable[[str], None]] = None
) -> ProcessingResult:
    if callback_status:
        callback_status("Starting...")
    
    # ... do work ...
    
    if callback_status:
        callback_status("Complete!")
```

---

## Best Practices

### 1. Type Hints EVERYWHERE

```python
# ✅ GOOD
def process_text(text: str, max_length: int) -> str:
    return text[:max_length]

# ❌ BAD
def process_text(text, max_length):
    return text[:max_length]
```

### 2. Docstrings for Public Methods

```python
def send_message(self, message: str) -> ChatResponse:
    """
    Send a chat message and get AI response.
    
    Args:
        message: User's message text
        
    Returns:
        ChatResponse with success status and message/error
    """
```

### 3. Constants, Not Magic Strings

```python
# ✅ GOOD
CONVERSATION_STOP_TOKENS = ("\nUser:", "\n\n", "\nYou:")

# ❌ BAD
stop_tokens = ["\nUser:", "\n\n", "\nYou:"]  # Scattered everywhere
```

### 4. Early Returns

```python
# ✅ GOOD: Easy to read
def process(self, request: ProcessingRequest):
    if not request.transcript:
        return ProcessingResult.failure(...)
    
    if self._cancelled:
        return ProcessingResult.cancelled()
    
    # ... happy path ...

# ❌ BAD: Nested hell
def process(self, request: ProcessingRequest):
    if request.transcript:
        if not self._cancelled:
            # ... deep nesting ...
```

### 5. Small Functions

```python
# ✅ GOOD: Each does one thing
def process(self, request):
    self._validate(request)
    prompt = self._build_prompt(request)
    response = self._call_api(prompt)
    return self._parse_response(response)

# ❌ BAD: 200-line monster function
def process(self, request):
    # ... validation code ...
    # ... prompt building ...
    # ... HTTP call ...
    # ... parsing ...
    # ... error handling ...
```

---

## Adding New Services

### Template

```python
# src/services/my_new_service.py
"""
My new service - does something cool.
"""

from typing import Optional
from ..core.config import MyConfig
from ..core.models import MyRequest, MyResult
from ..core.errors import APIError, ErrorCode


class MyNewService:
    """
    Does something cool with external API.
    """
    
    def __init__(self, config: MyConfig):
        self._config = config
        # Add any clients you need
    
    def do_something(self, request: MyRequest) -> MyResult:
        """
        Do the main thing this service does.
        
        Args:
            request: Input data
            
        Returns:
            MyResult with success/error
        """
        # 1. Validate
        is_valid, error = request.validate()
        if not is_valid:
            return MyResult.failure(
                error=APIError(ErrorCode.VALIDATION_ERROR, error)
            )
        
        # 2. Do work
        try:
            result = self._do_the_work(request)
            return MyResult.success(result)
        except Exception as e:
            return MyResult.failure(
                error=APIError(ErrorCode.UNKNOWN, str(e))
            )
    
    def _do_the_work(self, request: MyRequest):
        """Private helper method."""
        # Implementation here
        pass
```

---

## Debugging Tips

### 1. Use Print Statements (It's OK!)

```python
def process(self, request):
    print(f"DEBUG: Processing request: {request.transcript[:50]}...")
    result = self._call_api(...)
    print(f"DEBUG: Got response: {result.success}")
    return result
```

### 2. Check Error Codes

```python
result = service.process(request)
if not result.is_success:
    print(f"Error code: {result.error.code}")
    print(f"Error message: {result.error.message}")
    print(f"Error details: {result.error.details}")
```

### 3. Test Individual Layers

```python
# Test HTTP client alone
client = BitNetHTTPClient(config)
response = client.post_completion({"prompt": "test"})
print(response)

# Test service without UI
service = InferenceService(config)
result = service.process(test_request)
print(result)
```

---

## Performance Tips

### 1. Reuse HTTP Sessions

```python
# ✅ GOOD: One session for all requests
class BitNetHTTPClient:
    def __init__(self):
        self._session = requests.Session()  # Reused!

# ❌ BAD: New session every time
def make_request():
    response = requests.post(...)  # Creates new connection!
```

### 2. Use Threading for Long Operations

```python
# UI thread - don't block!
def on_button_clicked(self):
    thread = threading.Thread(target=self._do_long_task)
    thread.start()

def _do_long_task(self):
    # This runs in background
    result = self._service.process(request)
    # Update UI when done
```

### 3. Cache Expensive Operations

```python
class MyService:
    def __init__(self):
        self._cache = {}
    
    def get_result(self, key: str):
        if key in self._cache:
            return self._cache[key]  # Fast!
        
        result = self._expensive_operation(key)
        self._cache[key] = result
        return result
```

---

## Contributing

### Before Submitting Code

1. **Format**: `black src/`
2. **Lint**: `pylint src/`
3. **Test**: Run the app, test your changes
4. **Document**: Add docstrings, update this guide if needed

### Pull Request Checklist

- [ ] Code follows the layer architecture
- [ ] All public methods have type hints
- [ ] Errors use `APIError` (not strings)
- [ ] No duplicate code (use existing utilities)
- [ ] Tested manually
- [ ] Updated documentation if needed

---

## Questions?

- Read `ARCHITECTURAL_REFACTORING.md` for technical details
- Check existing code for examples
- Open an issue on GitHub

---

## Quick Reference

### Import Paths
```python
# Core
from ..core.config import Config, BitNetConfig
from ..core.models import ProcessingRequest, ProcessingResult
from ..core.errors import APIError, ErrorCode

# Infrastructure
from ..infrastructure.http_client import BitNetHTTPClient, APIResponse

# Services
from ..services.inference_service import InferenceService
from ..services.chat_service import ChatService, ChatMessage
```

### Common Error Codes
- `ErrorCode.NETWORK_ERROR` - Can't connect
- `ErrorCode.TIMEOUT` - Request took too long
- `ErrorCode.INVALID_RESPONSE` - API returned bad data
- `ErrorCode.VALIDATION_ERROR` - Input is invalid
- `ErrorCode.CANCELLED` - User cancelled
- `ErrorCode.SERVER_ERROR` - Server returned error
- `ErrorCode.UNKNOWN` - Something unexpected

---

**Remember**: Keep it simple, keep it clean, keep it testable. Every line should have a purpose!
