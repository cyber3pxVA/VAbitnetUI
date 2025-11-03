#!/usr/bin/env python3
"""
Mock BitNet server for testing the UI
Provides the same API as the real server but returns placeholder responses
"""

from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
import uvicorn

class CompletionRequest(BaseModel):
    prompt: str
    n_predict: Optional[int] = 128
    temperature: Optional[float] = 0.7
    top_p: Optional[float] = 0.9
    top_k: Optional[int] = 40
    repeat_penalty: Optional[float] = 1.1
    repeat_last_n: Optional[int] = 64
    stop: Optional[list[str]] = None
    stream: Optional[bool] = False

app = FastAPI(title="Mock BitNet Server")

@app.get("/health")
async def health():
    return {"status": "ok", "mode": "mock"}

@app.get("/")
async def root():
    return {"message": "Mock BitNet Server - For Testing Only"}

@app.post("/completion")
async def completion(request: CompletionRequest):
    # Generate a mock response based on the prompt
    mock_response = f"""Based on your input, here's a structured summary:

**Key Points:**
• Received transcript for processing
• System is in mock mode for testing
• Will provide actual AI responses once BitNet backend is built

**Next Steps:**
1. Build the BitNet backend properly
2. Fix OpenMP linking issues
3. Replace this mock server with the real one

This is a test response to verify the UI is working correctly."""
    
    return {
        "content": mock_response,
        "stop": False,
        "tokens_predicted": 100,
        "tokens_evaluated": 50
    }

def main():
    print("=" * 70)
    print("🚧 MOCK BitNet Server 🚧")
    print("=" * 70)
    print()
    print("This is a TESTING server that returns mock responses.")
    print("It allows you to test the UI without a working BitNet backend.")
    print()
    print("Server running on: http://127.0.0.1:8081")
    print("Endpoints:")
    print("  - http://127.0.0.1:8081/health")
    print("  - http://127.0.0.1:8081/completion")
    print()
    print("Press Ctrl+C to stop")
    print("=" * 70)
    print()
    
    uvicorn.run(app, host="127.0.0.1", port=8081, log_level="warning")

if __name__ == "__main__":
    main()

