#!/bin/bash
# Optimized inference script for VA workstation

export PATH="/c/Users/VHAWRJDRESCF/OneDrive - Department of Veterans Affairs/Documents/GitHub/VAbitnet/tools/mingw64/bin:$PATH"

MODEL="models/bitnet_b1_58-large/ggml-model-tl2.gguf"
LLAMA_CLI="./build_mingw/bin/llama-cli.exe"

# ADJUSTABLE PARAMETERS:
THREADS=4              # CPU threads (4 is optimal for this machine)
BATCH=512              # Batch size
CONTEXT=1024           # Context window
TEMPERATURE=0.7        # 0.0=deterministic, 1.0=creative, 2.0=very random
REPEAT_PENALTY=1.1     # Penalty for repeating tokens (1.0=none, 1.2=strong)
TOP_P=0.95             # Nucleus sampling (0.9-0.95 recommended)
TOP_K=40               # Top-K sampling (20-100 typical)

if [ -z "$1" ]; then
    echo "Usage: $0 \"Your prompt here\" [num_tokens]"
    echo ""
    echo "Example:"
    echo "  $0 \"What is the Department of Veterans Affairs?\" 100"
    echo ""
    echo "Optimized for VA workstation (Intel i7-1265U)"
    echo "Performance: ~7 tokens/second"
    exit 1
fi

PROMPT="$1"
TOKENS="${2:-100}"

echo "Running optimized inference..."
echo "Prompt: $PROMPT"
echo "Tokens: $TOKENS"
echo "Temperature: $TEMPERATURE | Repeat Penalty: $REPEAT_PENALTY"
echo "---"

$LLAMA_CLI \
    -m "$MODEL" \
    -p "$PROMPT" \
    -n "$TOKENS" \
    -t "$THREADS" \
    -b "$BATCH" \
    -c "$CONTEXT" \
    --temp "$TEMPERATURE" \
    --repeat_penalty "$REPEAT_PENALTY" \
    --top_p "$TOP_P" \
    --top_k "$TOP_K"

echo ""
echo "---"
echo "Performance optimized for VA workstation"
