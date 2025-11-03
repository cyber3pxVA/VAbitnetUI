# VA Workstation Deployment Guide

## Prerequisites

**Required (must be installed by VA IT):**
- Git (with Git LFS support)
- CMake 3.22 or higher
- C++ compiler (MinGW-w64 or MSVC with Clang)
- Python 3.9+ (for optional utilities)

**No admin rights required for:**
- Cloning this repository
- Running inference with included model
- Building from source (if compiler is available)

## Quick Start - Offline Deployment

### Step 1: Clone Repository (ONE TIME - requires internet)

```bash
git clone --recursive https://github.com/cyber3pxVA/VAbitnet_i2.git
cd VAbitnet_i2
```

**This automatically downloads:**
- All source code
- Pre-built model file (1.19 GB via Git LFS)
- Tokenizer files
- Build scripts
- Documentation

### Step 2: Build BitNet Binaries

```bash
# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build (use -j4 for 4 parallel jobs)
cmake --build . --config Release -j4

cd ..
```

**After build completes, binaries are in:** `build/bin/`

### Step 3: Test Installation

```bash
# Quick test (generates 10 tokens)
./build/bin/llama-cli.exe \
    -m models/bitnet_b1_58-large/ggml-model-i2_s.gguf \
    -p "Hello, world" \
    -n 10
```

### Step 4: Run Inference

```bash
# Interactive mode
./run_optimized.sh "What is the Department of Veterans Affairs?" 100

# Or direct command
./build/bin/llama-cli.exe \
    -m models/bitnet_b1_58-large/ggml-model-i2_s.gguf \
    -p "Your prompt here" \
    -n 100 \
    -t 4
```

## Offline Operation

**After initial clone, NO internet required:**
- ✅ Model file is local (1.19 GB in `models/bitnet_b1_58-large/`)
- ✅ All tokenizer files included
- ✅ All source code and binaries available
- ✅ No HuggingFace API calls
- ✅ No cloud dependencies

## File Structure

```
VAbitnet_i2/
├── models/
│   └── bitnet_b1_58-large/
│       ├── ggml-model-i2_s.gguf        # 1.19 GB model (Git LFS)
│       ├── tokenizer.model              # 489 KB tokenizer
│       ├── tokenizer.json               # 1.8 MB tokenizer data
│       └── config.json                  # Model configuration
├── build/
│   └── bin/
│       ├── llama-cli.exe                # Main inference binary
│       ├── llama-quantize.exe           # Quantization tool
│       └── llama-embedding.exe          # Embedding extractor
├── src/                                 # BitNet source code
├── utils/                               # Python utilities (optional)
└── run_optimized.sh                     # Convenience script
```

## Performance Expectations

**VA Workstation (Intel i7-1265U):**
- Speed: ~7-15 tokens/second
- Memory: ~1.5 GB RAM usage
- CPU: Uses 4-8 cores efficiently
- Context: Supports up to 2048 token context

**Larger Servers:**
- Speed: 20-50 tokens/second on modern Xeon
- Memory: Scales with context window
- Multi-threading: Excellent scaling on 16+ cores

## Troubleshooting

### Model file not found
```bash
# Check Git LFS is working
git lfs ls-files

# Should show: ggml-model-i2_s.gguf
# If not, pull LFS files manually:
git lfs pull
```

### Build errors
```bash
# Ensure CMake and compiler are in PATH
cmake --version
gcc --version  # or clang --version

# Clean and rebuild
rm -rf build
mkdir build && cd build
cmake ..
cmake --build . --config Release
```

### Slow inference
```bash
# Increase thread count (adjust for your CPU)
./build/bin/llama-cli.exe \
    -m models/bitnet_b1_58-large/ggml-model-i2_s.gguf \
    -p "Test" \
    -n 10 \
    -t 8  # Use 8 threads instead of 4
```

## Security Notes

**Approved for VA deployment:**
- ✅ No internet connectivity required after clone
- ✅ No external API calls or cloud services
- ✅ Runs entirely on local hardware
- ✅ No data leaves the workstation
- ✅ Model weights are fixed (no updates without explicit git pull)

**Data handling:**
- All inference happens in RAM
- No logging of prompts or outputs by default
- Model is read-only after clone
- No telemetry or usage tracking

## Advanced Usage

### Custom Inference Parameters

```bash
./build/bin/llama-cli.exe \
    -m models/bitnet_b1_58-large/ggml-model-i2_s.gguf \
    -p "Your prompt" \
    -n 200              # Generate 200 tokens
    -t 8                # Use 8 threads
    -c 2048             # Context window size
    --temp 0.7          # Temperature (creativity)
    --repeat_penalty 1.1 # Reduce repetition
    --top_p 0.95        # Nucleus sampling
    --top_k 40          # Top-K sampling
```

### Batch Processing

```bash
# Process multiple prompts from file
while IFS= read -r prompt; do
    ./build/bin/llama-cli.exe \
        -m models/bitnet_b1_58-large/ggml-model-i2_s.gguf \
        -p "$prompt" \
        -n 50 \
        >> output.txt
done < prompts.txt
```

## Model Information

**Microsoft BitNet-b1.58-2B-4T:**
- Architecture: BitNet b1.58 (ternary quantization)
- Parameters: 2.4 billion
- Training: 4 trillion tokens
- Quantization: i2_s (1.58-bit weights)
- Context: 2048 tokens
- Vocabulary: 32,000 tokens (SentencePiece)

**License:** MIT (see LICENSE file)

## Support

For issues specific to VA deployment:
1. Check this document first
2. Review `README.md` for technical details
3. See `DEVLOG.md` for development history
4. Contact repository maintainer

For BitNet framework issues:
- Upstream: https://github.com/microsoft/BitNet
- Documentation: https://arxiv.org/abs/2410.16144
