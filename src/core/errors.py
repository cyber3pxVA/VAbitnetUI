"""
Structured error types for API contract enforcement.
Eliminates string-based error handling.
"""

from dataclasses import dataclass
from enum import Enum
from typing import Optional


class ErrorCode(Enum):
    """Machine-readable error classification."""
    
    NETWORK_ERROR = "network_error"
    TIMEOUT = "timeout"
    INVALID_RESPONSE = "invalid_response"
    VALIDATION_ERROR = "validation_error"
    CANCELLED = "cancelled"
    SERVER_ERROR = "server_error"
    UNKNOWN = "unknown"


@dataclass(frozen=True)
class APIError:
    """
    Structured error with classification.
    Prevents vibe-coded error handling.
    """
    
    code: ErrorCode
    message: str
    details: Optional[dict] = None
    
    def to_dict(self) -> dict:
        """JSON-serializable representation."""
        return {
            "code": self.code.value,
            "message": self.message,
            "details": self.details or {}
        }
    
    def __str__(self) -> str:
        """Human-readable representation."""
        if self.details:
            return f"[{self.code.value}] {self.message} | {self.details}"
        return f"[{self.code.value}] {self.message}"
