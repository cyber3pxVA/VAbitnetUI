#!/bin/bash
# Silent build script for BitNet with MinGW

export PATH="/c/Users/VHAWRJDRESCF/OneDrive - Department of Veterans Affairs/Documents/GitHub/VAbitnet/tools/mingw64/bin:/c/Users/VHAWRJDRESCF/OneDrive - Department of Veterans Affairs/Documents/GitHub/VAbitnet/tools/cmake-3.30.0-windows-x86_64/bin:$PATH"

echo "Starting BitNet build... This will take 5-10 minutes."
echo "Building quietly to avoid terminal issues..."

# Build with output redirected to file
cmake --build build_mingw --config Release -j 2 > build_output.log 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Build completed successfully!"
    echo "✓ Binaries are in: build_mingw/bin/"
    echo ""
    echo "To test inference, run:"
    echo "  ./build_mingw/bin/llama-cli.exe -m models/bitnet_b1_58-large/ggml-model-tl2.gguf -p 'Hello' -n 20"
else
    echo ""
    echo "✗ Build failed. Check build_output.log for details"
    echo "Last 30 lines of build log:"
    tail -30 build_output.log
fi
