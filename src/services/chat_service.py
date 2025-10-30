"""
Chat service - handles conversational interactions with BitNet.
"""

from typing import Optional, Callable
from dataclasses import dataclass

from ..core.config import BitNetConfig
from ..core.errors import APIError, ErrorCode
from ..infrastructure.http_client import BitNetHTTPClient


@dataclass
class ChatMessage:
    """Single chat message."""
    role: str  # "user" or "assistant"
    content: str


@dataclass
class ChatResponse:
    """Response from chat interaction."""
    success: bool
    message: str
    error: Optional[APIError] = None


class ChatService:
    """
    Handles chat-based interaction with BitNet.
    Maintains conversation history.
    """

    def __init__(self, config: BitNetConfig):
        self._config = config
        self._http_client = BitNetHTTPClient(config)
        self._history: list[ChatMessage] = []
        self._is_cancelled = False

    def send_message(
        self,
        message: str,
        callback_status: Optional[Callable[[str], None]] = None
    ) -> ChatResponse:
        """
        Send a chat message and get response.

        Args:
            message: User message to send
            callback_status: Optional status update callback

        Returns:
            ChatResponse with success status and message/error
        """
        if not message.strip():
            return ChatResponse(
                success=False,
                message="",
                error=APIError(
                    code=ErrorCode.VALIDATION_ERROR,
                    message="Empty message"
                )
            )
        
        # Add user message to history
        self._history.append(ChatMessage(role="user", content=message))
        
        try:
            if callback_status:
                callback_status("Sending message...")

            api_response = self._call_api(message)
            
            if self._is_cancelled:
                self._is_cancelled = False
                return ChatResponse(
                    success=False,
                    message="",
                    error=APIError(
                        code=ErrorCode.CANCELLED,
                        message="Cancelled by user"
                    )
                )
            
            if api_response.success:
                # Add assistant response to history
                self._history.append(
                    ChatMessage(role="assistant", content=api_response.message)
                )
            
            return api_response

        except Exception as e:
            return ChatResponse(
                success=False,
                message="",
                error=APIError(
                    code=ErrorCode.UNKNOWN,
                    message=f"Chat error: {str(e)}",
                    details={"exception_type": type(e).__name__}
                )
            )
    
    def _call_api(self, message: str) -> ChatResponse:
        """Call BitNet API with chat message via centralized HTTP client."""
        # Build context from conversation history
        context = self._build_context()
        
        # Construct prompt
        prompt = f"{context}\\n\\nUser: {message}\\nAssistant:"
        
        payload = {
            "prompt": prompt,
            "n_predict": self._config.max_tokens,
            "temperature": self._config.temperature,
            "repeat_penalty": self._config.repeat_penalty,
            "repeat_last_n": self._config.repeat_last_n,
            "top_p": self._config.top_p,
            "top_k": self._config.top_k,
            "stop": ["\\nUser:", "\\n\\n", "\\nYou:", "\\nQuestion:"],
            "stream": False
        }
        
        # Execute via centralized HTTP client
        response = self._http_client.post_completion(payload)
        
        if not response.success:
            return ChatResponse(
                success=False,
                message="",
                error=response.error
            )
        
        # Extract text with strict validation
        try:
            result_text = response.get_text()
            return ChatResponse(success=True, message=result_text)
        except ValueError as e:
            return ChatResponse(
                success=False,
                message="",
                error=APIError(
                    code=ErrorCode.INVALID_RESPONSE,
                    message=str(e),
                    details={"response_keys": list(response.data.keys()) if response.data else []}
                )
            )
    
    def _build_context(self) -> str:
        """Build conversation context from history."""
        if not self._history:
            return "You are a helpful AI assistant. Respond concisely and accurately."
        
        # Include last N messages for context (prevent token overflow)
        max_history = 10
        recent = self._history[-max_history:] if len(self._history) > max_history else self._history
        
        lines = ["Conversation history:"]
        for msg in recent:
            role = msg.role.capitalize()
            lines.append(f"{role}: {msg.content}")
        
        return "\\n".join(lines)
    
    def clear_history(self) -> None:
        """Clear conversation history."""
        self._history.clear()
    
    def get_history(self) -> list[ChatMessage]:
        """Get conversation history."""
        return self._history.copy()
    
    def cancel(self) -> None:
        """Cancel ongoing request."""
        self._is_cancelled = True
