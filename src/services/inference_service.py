"""
BitNet inference service for text processing.
Abstracts model inference from UI and business logic.
"""

import time
from typing import Optional
import threading

from ..core.config import BitNetConfig
from ..core.models import ProcessingRequest, ProcessingResult, ProcessingStatus
from ..core.errors import APIError, ErrorCode
from ..infrastructure.http_client import BitNetHTTPClient


class InferenceService:
    """
    Local BitNet inference service.
    Uses centralized HTTP client for all API communication.
    """

    def __init__(self, config: BitNetConfig):
        self._config = config
        self._http_client = BitNetHTTPClient(config)
        self._lock = threading.Lock()
        self._cancelled = False

    def process(
        self,
        request: ProcessingRequest,
        callback_status: Optional[callable] = None
    ) -> ProcessingResult:
        """
        Process text with BitNet model.
        Blocking call - run in separate thread for async operation.
        
        Returns structured ProcessingResult (never throws for API errors).
        """
        start_time = time.time()
        
        # Validate request
        is_valid, error_msg = request.validate()
        if not is_valid:
            return ProcessingResult.failure(
                error=APIError(
                    code=ErrorCode.VALIDATION_ERROR,
                    message=f"Invalid request: {error_msg}"
                ),
                processing_time_ms=0
            )
        
        # Build prompt
        system_prompt = self._config.system_prompt
        user_prompt = request.custom_prompt or "Convert this transcript into clear notes:"
        full_prompt = f"{system_prompt}\n\n{user_prompt}\n\nTranscript:\n{request.transcript}"
        
        try:
            if callback_status:
                callback_status("Initializing BitNet inference...")
            
            # Build payload
            payload = {
                "prompt": full_prompt,
                "n_predict": request.max_tokens or self._config.max_tokens,
                "temperature": request.temperature or self._config.temperature,
                "repeat_penalty": self._config.repeat_penalty,
                "repeat_last_n": self._config.repeat_last_n,
                "top_p": self._config.top_p,
                "top_k": self._config.top_k,
                "stop": ["\n\nYou:", "\nUser:", "\nQuestion:"],
                "stream": False
            }
            
            # Check if cancelled
            with self._lock:
                if self._cancelled:
                    self._cancelled = False
                    return ProcessingResult.cancelled()
            
            if callback_status:
                callback_status("Sending request to BitNet...")
            
            # Execute via centralized HTTP client
            response = self._http_client.post_completion(payload)
            
            # Check if cancelled during request
            with self._lock:
                if self._cancelled:
                    self._cancelled = False
                    return ProcessingResult.cancelled()
            
            processing_time = (time.time() - start_time) * 1000
            
            # Handle response
            if not response.success:
                return ProcessingResult.failure(
                    error=response.error,
                    processing_time_ms=processing_time
                )
            
            # Extract text with strict validation
            try:
                result_text = response.get_text()
            except ValueError as e:
                return ProcessingResult.failure(
                    error=APIError(
                        code=ErrorCode.INVALID_RESPONSE,
                        message=str(e),
                        details={"response_keys": list(response.data.keys()) if response.data else []}
                    ),
                    processing_time_ms=processing_time
                )
            
            if callback_status:
                callback_status("Processing complete")
            
            return ProcessingResult.success(
                processed_text=result_text,
                processing_time_ms=processing_time
            )
            
        except Exception as e:
            processing_time = (time.time() - start_time) * 1000
            return ProcessingResult.failure(
                error=APIError(
                    code=ErrorCode.UNKNOWN,
                    message=f"Unexpected error: {str(e)}",
                    details={"exception_type": type(e).__name__}
                ),
                processing_time_ms=processing_time
            )
    
    def cancel(self) -> None:
        """Cancel current inference operation."""
        with self._lock:
            self._cancelled = True
    
    @staticmethod
    def check_availability(endpoint_url: str = "http://localhost:8081") -> tuple[bool, Optional[str]]:
        """
        Check if BitNet HTTP API is available.
        Returns (is_available, error_message).
        """
        # Create temporary client for health check
        from ..core.config import BitNetConfig
        temp_config = BitNetConfig(endpoint_url=endpoint_url)
        temp_client = BitNetHTTPClient(temp_config)
        
        is_available, error = temp_client.check_health()
        temp_client.close()
        
        return is_available, error
