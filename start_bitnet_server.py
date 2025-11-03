#!/usr/bin/env python3
"""
Start BitNet server using llama-cpp-python
Custom server to match the UI's expected /completion endpoint
"""

from pathlib import Path
from llama_cpp import Llama
from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
import uvicorn

# Model path
MODEL_PATH = Path(__file__).parent / "bitnet_backend" / "models" / "bitnet_b1_58-large" / "ggml-model-i2_s.gguf"

# Global model instance
llm = None

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

def main():
    global llm
    
    print("=" * 60)
    print("Starting BitNet Server")
    print("=" * 60)
    print(f"Model: {MODEL_PATH}")
    print(f"Port: 8081")
    print(f"Host: 127.0.0.1")
    print("=" * 60)
    print()
    
    if not MODEL_PATH.exists():
        print(f"❌ ERROR: Model file not found at {MODEL_PATH}")
        print()
        return 1
    
    print("Loading model... (this may take 30-60 seconds)")
    
    # Create llama model instance
    llm = Llama(
        model_path=str(MODEL_PATH),
        n_ctx=2048,
        n_threads=4,
        verbose=False
    )
    
    print("✓ Model loaded successfully!")
    print()
    print("Server starting on http://127.0.0.1:8081")
    print("API endpoints:")
    print("  - http://127.0.0.1:8081/completion")
    print("  - http://127.0.0.1:8081/health")
    print()
    print("Press Ctrl+C to stop the server")
    print("=" * 60)
    print()
    
    # Create FastAPI app
    app = FastAPI(title="BitNet Server")
    
    @app.get("/health")
    async def health():
        return {"status": "ok", "model_loaded": llm is not None}
    
    @app.post("/completion")
    async def completion(request: CompletionRequest):
        if llm is None:
            return {"error": "Model not loaded"}, 500
        
        try:
            # Generate completion
            result = llm(
                prompt=request.prompt,
                max_tokens=request.n_predict,
                temperature=request.temperature,
                top_p=request.top_p,
                top_k=request.top_k,
                repeat_penalty=request.repeat_penalty,
                stop=request.stop or [],
                echo=False
            )
            
            # Extract generated text
            text = result["choices"][0]["text"]
            
            return {
                "content": text,
                "stop": result.get("stop", False),
                "tokens_predicted": result["usage"]["completion_tokens"],
                "tokens_evaluated": result["usage"]["prompt_tokens"]
            }
        except Exception as e:
            return {"error": str(e)}, 500
    
    # Run server
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8081,
        log_level="info"
    )
    
    return 0

if __name__ == "__main__":
    exit(main())

