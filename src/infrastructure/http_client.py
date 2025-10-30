"""
Centralized HTTP client for BitNet API communication.
Eliminates duplicate HTTP logic across services.
"""

import time
from dataclasses import dataclass
from typing import Optional

import requests

from ..core.config import BitNetConfig
from ..core.errors import APIError, ErrorCode


# API response field priority for parsing
RESPONSE_FIELD_PRIORITY = ("content", "text", "completion", "generated_text")


@dataclass(frozen=True)
class APIResponse:
    """
    Structured API response with strict type contract.
    Never returns raw strings - always structured data.
    """
    
    success: bool
    data: Optional[dict] = None
    error: Optional[APIError] = None
    latency_ms: Optional[float] = None
    
    @property
    def is_error(self) -> bool:
        """Whether response contains an error."""
        return not self.success
    
    def get_text(self) -> str:
        """
        Extract text from response data.
        Raises ValueError if data structure is invalid.
        """
        if not self.success or self.data is None:
            raise ValueError("Cannot extract text from failed response")
        
        # Try fields in priority order
        for field in RESPONSE_FIELD_PRIORITY:
            if field in self.data:
                text = str(self.data[field]).strip()
                if text:  # Validate non-empty
                    return text
        
        # Handle OpenAI-style choices array
        if "choices" in self.data and len(self.data["choices"]) > 0:
            choice = self.data["choices"][0]
            if "text" in choice:
                return str(choice["text"]).strip()
            if "message" in choice and "content" in choice["message"]:
                return str(choice["message"]["content"]).strip()
        
        # Strict failure - no silent coercion
        raise ValueError(
            f"API response missing expected fields: {RESPONSE_FIELD_PRIORITY}. "
            f"Received keys: {list(self.data.keys())}"
        )


class BitNetHTTPClient:
    """
    Unified HTTP client for all BitNet API communication.
    Single source of truth for request/response handling.
    """
    
    def __init__(self, config: BitNetConfig):
        self._config = config
        self._session = requests.Session()
        self._session.headers.update({"Content-Type": "application/json"})
    
    def post_completion(self, payload: dict) -> APIResponse:
        """
        Execute completion request with unified error handling.
        
        Args:
            payload: Request payload matching BitNet API schema
            
        Returns:
            APIResponse with success status and data/error
        """
        start = time.time()
        
        try:
            response = self._session.post(
                self._config.endpoint_url,
                json=payload,
                timeout=self._config.timeout_seconds
            )
            
            latency = (time.time() - start) * 1000
            
            # Check HTTP status
            if response.status_code != 200:
                return APIResponse(
                    success=False,
                    error=APIError(
                        code=ErrorCode.SERVER_ERROR,
                        message=f"HTTP {response.status_code}",
                        details={"response_text": response.text[:200]}
                    ),
                    latency_ms=latency
                )
            
            # Parse JSON
            try:
                data = response.json()
            except ValueError as e:
                return APIResponse(
                    success=False,
                    error=APIError(
                        code=ErrorCode.INVALID_RESPONSE,
                        message="Invalid JSON in response",
                        details={"parse_error": str(e)}
                    ),
                    latency_ms=latency
                )
            
            return APIResponse(
                success=True,
                data=data,
                latency_ms=latency
            )
            
        except requests.exceptions.Timeout:
            return APIResponse(
                success=False,
                error=APIError(
                    code=ErrorCode.TIMEOUT,
                    message=f"Request exceeded {self._config.timeout_seconds}s timeout",
                    details={"endpoint": self._config.endpoint_url}
                ),
                latency_ms=(time.time() - start) * 1000
            )
            
        except requests.exceptions.ConnectionError as e:
            return APIResponse(
                success=False,
                error=APIError(
                    code=ErrorCode.NETWORK_ERROR,
                    message="Cannot connect to BitNet server",
                    details={
                        "endpoint": self._config.endpoint_url,
                        "error": str(e)
                    }
                )
            )
            
        except Exception as e:
            return APIResponse(
                success=False,
                error=APIError(
                    code=ErrorCode.UNKNOWN,
                    message=f"Unexpected error: {str(e)}",
                    details={"exception_type": type(e).__name__}
                )
            )
    
    def check_health(self) -> tuple[bool, Optional[str]]:
        """
        Check if BitNet API is available.
        Returns (is_available, error_message).
        """
        try:
            # Try health endpoint first
            health_url = self._config.endpoint_url.replace("/completion", "/health")
            
            try:
                response = requests.get(health_url, timeout=5)
                if response.status_code == 200:
                    return True, None
            except:
                # Health endpoint might not exist, try root
                root_url = self._config.endpoint_url.split("/completion")[0]
                response = requests.get(root_url, timeout=5)
                if response.status_code in (200, 404):  # 404 means server responding
                    return True, None
            
            return False, f"Server unhealthy (status {response.status_code})"
            
        except requests.exceptions.ConnectionError:
            return False, f"Cannot connect to {self._config.endpoint_url}"
        except requests.exceptions.Timeout:
            return False, "Connection timeout"
        except Exception as e:
            return False, f"Health check error: {e}"
    
    def close(self) -> None:
        """Close HTTP session and release resources."""
        self._session.close()
