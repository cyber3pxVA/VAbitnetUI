# VAbitnetUI Performance Benchmarks

## Test Environment
- **CPU**: Intel/AMD x86_64 (4 threads)
- **RAM**: 8GB minimum
- **Model**: BitNet 1.58-bit 2.4B parameters (1.1GB)
- **Backend**: llama.cpp BitNet fork (MinGW build)
- **OS**: Windows 10/11
- **Date**: November 2025

## BitNet Inference Performance

### Token Generation Speed
- **Prompt Processing**: ~50 tokens/sec (initial processing)
- **Generation**: ~12 tokens/sec (actual output)
- **Context Window**: 2048 tokens
- **KV Cache**: 150MB CPU memory

### Response Time by Token Count

| Tokens | Time (seconds) | Use Case |
|--------|---------------|----------|
| 10     | 1.0           | Quick yes/no answers |
| 20     | 3.5           | Short responses |
| 50     | 6.7           | Brief explanations |
| **100**    | **13.4**          | **Chat responses (default)** |
| 200    | 27.7          | Detailed answers |
| 500    | 68            | Long explanations |
| 2048   | 240           | Maximum context (not recommended) |

### Real-World Measurements
```bash
# Tested with: curl -X POST http://127.0.0.1:8081/completion

Test 1 (20 tokens):
real    0m3.496s
user    0m0.061s
sys     0m0.435s

Test 2 (50 tokens):
real    0m6.743s
user    0m0.046s
sys     0m0.295s

Test 3 (100 tokens):
real    0m13.390s
user    0m0.062s
sys     0m0.342s

Test 4 (200 tokens):
real    0m27.704s
user    0m0.123s
sys     0m0.328s
```

## Component Performance

### VOSK Speech Recognition
- **Model Size**: 39.3MB (vosk-model-small-en-us-0.15)
- **Accuracy**: ~85% for clear speech
- **Latency**: Real-time (< 100ms)
- **Language**: English only
- **CPU Usage**: ~10-15%

### UI Response Times
- **Startup**: ~2 seconds (PyQt6 initialization)
- **Health Check**: ~100ms (HTTP GET /health)
- **Chat Message**: 13-14 seconds (100 tokens)
- **Voice Transcription**: Real-time (VOSK)
- **Note Generation**: 15-25 seconds (varies by prompt complexity)

### Memory Usage
| Component | RAM Usage |
|-----------|-----------|
| BitNet Model | 1.1GB (loaded) |
| KV Cache | 150MB |
| VOSK Model | 50MB |
| UI Application | 80MB |
| **Total** | **~1.4GB** |

## Configuration Recommendations

### Fast Responses (6-7 seconds)
```python
# src/services/chat_service.py
n_predict = 50
temperature = 0.7
```

### Balanced (13-14 seconds) - DEFAULT
```python
n_predict = 100
temperature = 0.7
```

### Detailed (27-30 seconds)
```python
n_predict = 200
temperature = 0.7
```

## Performance Tuning

### For Faster Inference
1. **Reduce n_predict**: Lower token count = faster responses
2. **Increase temperature**: Less deterministic = slightly faster
3. **Reduce context**: Shorter conversation history = faster processing
4. **Use more threads**: Increase `-t` parameter (default: 4)

### For Better Quality
1. **Increase n_predict**: More tokens for complete thoughts
2. **Lower temperature**: More focused responses (0.3-0.5)
3. **Higher repeat_penalty**: Reduce repetition (1.15-1.3)
4. **Adjust Top-K/Top-P**: Fine-tune randomness

## Server Configuration
```bash
# Current settings (bitnet_backend/build_mingw/bin/llama-server.exe)
--host 127.0.0.1      # Localhost only
--port 8081           # HTTP API port
-c 2048               # Context window
-t 4                  # CPU threads
-m model.gguf         # Model file
```

## Known Limitations
- **CPU Only**: No GPU acceleration (BitNet design)
- **Single Request**: No concurrent requests (1 slot)
- **Context Limit**: 2048 tokens max
- **Language**: English only (VOSK model)
- **Platform**: Windows only (MinGW build)

## Optimization History
| Date | Change | Impact |
|------|--------|--------|
| 2025-11-02 | Reduced chat n_predict from 2048→100 | 10x faster chat (240s→13s) |
| 2025-11-02 | Increased timeout 30s→60s | Prevents premature failures |
| 2025-11-02 | Fixed KV cache handling | Eliminated server hangs |

## Future Improvements
- [ ] Streaming responses (token-by-token)
- [ ] Multiple chat slots (concurrent users)
- [ ] GPU acceleration (if BitNet supports)
- [ ] Larger context window (4096+)
- [ ] Additional language support (VOSK models)

---

**Benchmark Version**: 1.0  
**Last Updated**: November 2, 2025  
**Tested By**: Frank Drescher, VA
