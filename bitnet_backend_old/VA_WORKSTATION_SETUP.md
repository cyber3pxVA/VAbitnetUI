# VA Workstation Setup Guide for BitNet Development

## Overview

This document outlines the **VHA-compliant software installation pathway** used to successfully build and run BitNet on Veterans Health Administration (VHA) workstations. All tools and methods documented here use approved software available through standard VHA channels or portable executables that run from user directories.

**Document Purpose:** Preserve institutional knowledge for VA developers working with AI/ML tools on standard VHA workstations. This file should not be deleted as it contains critical deployment strategies.

---

## VHA-Compliant Tool Selection

### Core Principles

1. **Portable Tools First**: Use tools that extract to user directories without system modifications
2. **Standard VHA Software**: Leverage tools available through VHA Software Center when possible
3. **Self-Contained Deployment**: All dependencies contained within project directory
4. **No System Modifications**: No changes to PATH, registry, or system directories

### Approved Tool Sources

#### Git for Windows
- **Source**: https://git-scm.com/download/win
- **Installation**: Standard installer or portable version
- **VHA Availability**: Available through VHA Software Center
- **Version Used**: 2.51.1
- **Components**: Git, Git Bash, Git LFS
- **User Directory**: Standard installation works on VHA workstations

#### Python
- **Source**: https://www.python.org/downloads/
- **Installation**: Via `winget install Python.Python.3.12`
- **VHA Availability**: Can be installed through winget on most VHA workstations
- **Version Used**: 3.12.10
- **Alternative**: Portable Python from python.org (no installation required)

#### MinGW-w64 (Portable GCC Compiler)
- **Source**: https://github.com/niXman/mingw-builds-binaries/releases
- **Type**: Portable - extract to user directory
- **Version Used**: 14.2.0 (x86_64-posix-seh-ucrt)
- **Size**: ~80 MB compressed
- **Installation**: Extract to `tools/mingw64/` in project directory
- **Key Advantage**: Does not require Visual Studio (which needs elevated permissions)

#### CMake (Portable Build System)
- **Source**: https://cmake.org/download/
- **Type**: Portable ZIP archive
- **Version Used**: 3.30.5
- **Size**: ~45 MB compressed
- **Installation**: Extract to `tools/cmake-3.30.5-windows-x86_64/`
- **Usage**: Direct execution from project directory

#### 7-Zip (Portable Archiver)
- **Source**: https://www.7-zip.org/download.html
- **Type**: Portable executable (7zr.exe - standalone)
- **Size**: ~600 KB
- **Purpose**: Extract .7z archives (MinGW distribution format)
- **Installation**: Download single executable to `tools/`

---

## Successful Build Strategy

### Why This Approach Works on VHA Workstations

**Challenge**: Traditional development tools (Visual Studio, system-wide CMake) require elevated installation permissions that may not be available on all VHA workstations.

**Solution**: Use portable toolchain that operates entirely from user directories:
1. Portable MinGW-w64 provides GCC compiler without Visual Studio
2. Portable CMake runs directly from extracted folder
3. All build outputs stay within project directory
4. No system PATH modifications required
5. Compatible with OneDrive-synced directories

### Directory Structure

```
VAbitnet_i2/
├── tools/                          # Portable tools (not committed to Git)
│   ├── mingw64/                    # MinGW-w64 compiler toolchain
│   │   └── bin/
│   │       ├── gcc.exe
│   │       ├── g++.exe
│   │       ├── mingw32-make.exe
│   │       └── [runtime DLLs]
│   ├── cmake-3.30.5-windows-x86_64/  # Portable CMake
│   │   └── bin/
│   │       └── cmake.exe
│   └── 7zr.exe                     # Portable 7-Zip
├── build_mingw/                    # Build output directory
│   └── bin/
│       ├── llama-cli.exe           # Main inference binary
│       └── [other executables]
└── models/                         # Model files (Git LFS)
    └── bitnet_b1_58-large/
        └── ggml-model-i2_s.gguf
```

---

## Step-by-Step Installation Process

### Phase 1: Prerequisites

**1. Install Git**
```bash
# If Git not available through VHA Software Center:
# Download portable Git from https://git-scm.com/download/win
# Extract to user directory
```

**2. Install Python (Optional for utilities)**
```bash
winget install Python.Python.3.12
# Or download portable Python from python.org
```

### Phase 2: Download Portable Tools

**3. Download MinGW-w64**
```powershell
# Download from: https://github.com/niXman/mingw-builds-binaries/releases
# File: x86_64-14.2.0-release-posix-seh-ucrt-rt_v12-rev0.7z (~80 MB)
# Extract to: tools/mingw64/
```

**4. Download CMake**
```powershell
# Download from: https://cmake.org/download/
# File: cmake-3.30.5-windows-x86_64.zip (~45 MB)
# Extract to: tools/cmake-3.30.5-windows-x86_64/
```

**5. Download 7-Zip (for extracting MinGW)**
```powershell
# Download from: https://www.7-zip.org/download.html
# File: 7zr.exe (~600 KB standalone)
# Place in: tools/7zr.exe
```

### Phase 3: Clone and Build

**6. Clone Repository**
```bash
git clone https://github.com/cyber3pxVA/VAbitnet_i2.git
cd VAbitnet_i2/VAbitnet_i2
git lfs pull  # Download model files
```

**7. Extract Portable Tools**
```bash
# Extract MinGW (if downloaded as .7z)
./tools/7zr.exe x x86_64-14.2.0-release-posix-seh-ucrt-rt_v12-rev0.7z -o./tools/mingw64/

# CMake extracts with standard Windows ZIP tools
```

**8. Configure Build**
```bash
./tools/cmake-3.30.5-windows-x86_64/bin/cmake.exe -B build_mingw -G "MinGW Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBITNET_X86_TL2=ON \
  -DCMAKE_C_COMPILER="$(pwd)/tools/mingw64/bin/gcc.exe" \
  -DCMAKE_CXX_COMPILER="$(pwd)/tools/mingw64/bin/g++.exe" \
  -DCMAKE_MAKE_PROGRAM="$(pwd)/tools/mingw64/bin/mingw32-make.exe" \
  -DGGML_OPENMP=OFF
```

**9. Build Project**
```bash
./tools/cmake-3.30.5-windows-x86_64/bin/cmake.exe --build build_mingw --config Release -j 4
```

Build time: ~10-15 minutes on typical VHA workstation (Intel i7, 16GB RAM)

### Phase 4: Run Inference

**10. Test BitNet Model**
```bash
# Add MinGW DLLs to PATH for current session
PATH="$(pwd)/tools/mingw64/bin:$PATH"

# Run inference
./build_mingw/bin/llama-cli.exe \
  -m models/bitnet_b1_58-large/ggml-model-i2_s.gguf \
  -p "Your prompt here" \
  -n 50
```

---

## Technical Considerations

### OpenMP Configuration

**Issue**: MinGW's OpenMP library (libgomp) may not link correctly by default.

**Solution**: Disable OpenMP during CMake configuration with `-DGGML_OPENMP=OFF`. This has minimal performance impact for BitNet's specialized kernels which use AVX2/FMA SIMD instructions directly.

### Runtime Dependencies

The compiled `llama-cli.exe` requires MinGW runtime DLLs:
- `libgcc_s_seh-1.dll`
- `libstdc++-6.dll`
- `libwinpthread-1.dll`

**Solution**: Add `tools/mingw64/bin/` to PATH before running executables, or copy DLLs to same directory as executables.

### Performance Characteristics

**BitNet 1.58-bit Model (2.4B parameters):**
- Model Size: 1.1 GB
- Memory Usage: ~1.4 GB total (includes KV cache)
- Generation Speed: 15-20 tokens/sec on Intel i7 (CPU-only)
- Prompt Processing: 30-40 tokens/sec
- CPU Features Used: AVX2, FMA, F16C, SSE3

---

## Alternative Approaches Considered

### Visual Studio Build Tools
- **Size**: ~7 GB download
- **Installation**: Requires elevated permissions in some VHA environments
- **Conclusion**: MinGW provides equivalent functionality with smaller footprint

### System-Wide CMake
- **Issue**: Installer may require elevation
- **Solution**: Portable ZIP version works identically

### WSL (Windows Subsystem for Linux)
- **Status**: May not be enabled on all VHA workstations
- **Alternative**: MinGW provides native Windows compilation

---

## Troubleshooting

### Build Fails with "command not found"
- Verify tool paths in CMake command
- Use absolute paths: `$(pwd)/tools/mingw64/bin/gcc.exe`
- Check that tools were extracted correctly

### Runtime Error: Missing DLLs
- Add MinGW bin to PATH: `PATH="$(pwd)/tools/mingw64/bin:$PATH"`
- Or copy DLLs to executable directory

### Git LFS Files Not Downloaded
- Run `git lfs install` once
- Run `git lfs pull` to download model files
- Verify model file size: should be ~1.19 GB

### OpenMP Linking Errors
- Ensure `-DGGML_OPENMP=OFF` flag is set in CMake configuration
- Delete `build_mingw/` and reconfigure if changing flags

---

## Security and Compliance

### VHA Software Compliance

All tools used are:
- ✅ Open-source with verifiable sources
- ✅ Commonly used in government/enterprise environments
- ✅ Do not require system modifications
- ✅ Operate from user directories only
- ✅ No network communication required after download

### Data Handling

- Model runs entirely on local workstation
- No cloud API calls or external network requests
- All inference happens in-memory on local CPU
- Suitable for handling sensitive/PII data after proper security review

### Deployment Classification

This setup is appropriate for:
- Development and testing on VHA workstations
- Prototype AI applications
- Research and evaluation of BitNet technology

For production deployment, consult VHA IT Security for:
- Formal security assessment
- Network isolation requirements
- Audit logging needs
- Data handling procedures

---

## Success Metrics

This approach successfully achieved:
- ✅ Complete build from source on VHA workstation
- ✅ All tools portable and self-contained
- ✅ Functional BitNet 1.58-bit inference
- ✅ Performance: 15.57 tokens/sec generation
- ✅ Memory efficiency: 1.4 GB total usage
- ✅ No elevated permissions required
- ✅ Compatible with OneDrive-synced directories

---

## Version History

- **October 29, 2025**: Initial successful build and inference
  - MinGW-w64 14.2.0
  - CMake 3.30.5
  - BitNet 2.4B model (i2_s format)
  - OpenMP disabled for compatibility

---

## Maintenance Notes

**For Future Developers:**

This document preserves the exact toolchain and process that successfully built BitNet on VHA workstations. If updating tools:

1. **Test thoroughly** on VHA workstation before updating documentation
2. **Preserve working versions** in documentation even if updating
3. **Document any new issues** encountered and solutions found
4. **Maintain portable tool strategy** - do not assume system-wide installations

**Do Not Delete This File** - It contains institutional knowledge specific to VHA development environment constraints and approved tooling pathways.

---

**Document Classification**: Internal Development Documentation  
**Last Updated**: October 29, 2025  
**Maintained By**: VA BitNet Development Team  
**Contact**: cyber3pxVA (GitHub)
