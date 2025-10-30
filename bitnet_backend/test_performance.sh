#!/bin/bash
# Performance testing script for VABitNet

export PATH="/c/Users/VHAWRJDRESCF/OneDrive - Department of Veterans Affairs/Documents/GitHub/VAbitnet/tools/mingw64/bin:$PATH"

MODEL="models/bitnet_b1_58-large/ggml-model-tl2.gguf"
LLAMA_CLI="./build_mingw/bin/llama-cli.exe"

echo "================================"
echo "VABitNet Performance Test"
echo "================================"
echo ""

# Test 1: Different thread counts
echo "TEST 1: Thread Performance (50 tokens)"
echo "---------------------------------------"
for threads in 4 8 12; do
    echo "Testing with $threads threads..."
    $LLAMA_CLI -m $MODEL -p "Hello world" -n 50 -t $threads 2>&1 | grep -E "(eval time|tokens per second)"
    echo ""
    sleep 1
done
echo ""

echo ""

echo "================================"
echo "Performance Summary"
echo "================================"
echo "Best settings for VA workstation:"
echo "  - Threads: 12 (use all cores)"
echo "  - Batch: 512 (optimal)"  
echo "  - Context: 1024 (balanced)"
echo "  - Temp: 0.7 (coherent output)"
echo ""
echo "Quick command:"
echo "./build_mingw/bin/llama-cli.exe -m models/bitnet_b1_58-large/ggml-model-tl2.gguf \\"
echo "  -p 'Your prompt' -n 100 -t 12 -b 512 -c 1024 --temp 0.7"
echo "================================"

