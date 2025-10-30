# Quick Start Guide - Windows VA Workstation

## TL;DR - Get Running in 3 Commands

```powershell
# 1. Clone (from Developer PowerShell for VS 2022)
git clone --recursive https://github.com/cyber3pxVA/VAbitnetUI.git
cd VAbitnetUI

# 2. Setup (one-time, 15-30 minutes)
.\scripts\setup_va_workstation.ps1

# 3. Run
.\scripts\start_va_workstation.ps1
```

## Prerequisites (One-Time Install)

### 1. Visual Studio 2022

**Download**: https://visualstudio.microsoft.com/downloads/

**Required Components** (select during installation):
- ✅ Desktop development with C++
- ✅ C++ CMake Tools for Windows
- ✅ C++ Clang Compiler for Windows
- ✅ MS-Build Support for LLVM-Toolset

### 2. Python 3.10+

**Download**: https://www.python.org/downloads/

**Installation Options**:
- ✅ Check "Add Python to PATH"
- ✅ Install for current user (admin not required)

### 3. Git for Windows

Included with Visual Studio 2022, or download from: https://git-scm.com/download/win

## Step-by-Step First Run

### Step 1: Open Developer PowerShell

**Important**: Must use Developer tools, not regular PowerShell!

1. Press **Windows Key**
2. Type: `Developer PowerShell for VS 2022`
3. Press **Enter**

### Step 2: Navigate and Clone

```powershell
# Go to where you want to install (e.g., Documents)
cd $env:USERPROFILE\Documents

# Clone repository with all components
git clone --recursive https://github.com/cyber3pxVA/VAbitnetUI.git

# Enter directory
cd VAbitnetUI
```

**What gets downloaded**:
- Application code (~50 MB)
- BitNet inference engine (~100 MB)  
- AI model via Git LFS (~1.2 GB)
- **Total**: ~1.4 GB

**Time**: 2-10 minutes depending on connection

### Step 3: Run Setup Script

```powershell
.\scripts\setup_va_workstation.ps1
```

**What it does**:
1. Verifies Python and Visual Studio
2. Creates Python virtual environment
3. Installs Python packages
4. Downloads VOSK speech model (~40 MB)
5. Builds BitNet C++ engine (5-10 minutes)
6. Configures for offline use

**Time**: 15-30 minutes total

**Watch for**:
- ✓ Green checkmarks = success
- ⚠ Yellow warnings = non-critical
- ✗ Red errors = needs attention

### Step 4: Start Application

```powershell
.\scripts\start_va_workstation.ps1
```

**What happens**:
1. BitNet server starts (10-30 seconds to load model)
2. GUI window opens
3. Ready to use!

## Using the Application

### Voice Mode (Transcription)

1. **Start Recording**: Click button or press `Ctrl+R`
2. **Speak**: Talk clearly into microphone
3. **Stop Recording**: Click button again
4. **Generate Notes**: AI processes and summarizes
5. **Copy**: Use "Copy to Clipboard" button

### Chat Mode

1. **Switch to Chat**: Click "Chat" tab
2. **Type Message**: Enter text in bottom field
3. **Send**: Press Enter or click "Send"
4. **Get Response**: AI replies in ~5-15 seconds

## Common Issues & Quick Fixes

### ❌ "clang is not recognized"

**Problem**: Not in Developer environment

**Fix**: Use "Developer PowerShell for VS 2022" from Start menu

---

### ❌ "Python not found"

**Problem**: Python not in PATH

**Fix**: 
```powershell
# Find Python
where.exe python

# If not found, reinstall Python with "Add to PATH" checked
```

---

### ❌ Port 8081 in use

**Problem**: Another app using port

**Fix**:
```powershell
# Kill process on port 8081
netstat -ano | findstr :8081
# Note the PID (last number)
Stop-Process -Id <PID> -Force

# Or use different port
$env:BITNET_SERVER_PORT=8082
.\scripts\start_va_workstation.ps1
```

---

### ❌ Model not found

**Problem**: Git LFS didn't download model

**Fix**:
```powershell
cd bitnet_backend\models\BitNet-b1.58-2B-4T

# Check file size
dir ggml-model-i2_s.gguf
# Should be ~1.2 GB, not 130 bytes

# If small, download:
git lfs pull
```

---

### ❌ Build fails

**Problem**: Missing Visual Studio components

**Fix**:
1. Open Visual Studio Installer
2. Click "Modify" on VS 2022
3. Verify all required components checked (see Prerequisites)
4. Apply and restart
5. Rerun setup script

## Performance Tips

### Faster Inference

Edit `.env` file:
```ini
# Use all CPU cores
BITNET_THREADS=0

# Or specify number
BITNET_THREADS=4
```

### Better Context

```ini
# Increase context window (uses more RAM)
BITNET_CTX_SIZE=4096
```

### More Creative Responses

```ini
# Higher temperature = more creative
BITNET_TEMPERATURE=0.9
```

## Offline Use

**After setup completes**: No internet required!

- All models downloaded
- All tools included
- Fully self-contained

Perfect for secure VA environments.

## What's Next?

### Learn More
- Full documentation: `docs/VA_WORKSTATION_SETUP.md`
- Architecture: `docs/ARCHITECTURE.md`
- Troubleshooting: `docs/TROUBLESHOOTING.md`

### Customize
- Edit `.env` for your preferences
- Adjust thread count for performance
- Configure audio settings

### Update
```powershell
# Pull latest changes
git pull

# Rebuild if needed
cd bitnet_backend
python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

## Need Help?

1. **Check**: `docs/TROUBLESHOOTING.md`
2. **Search**: GitHub issues
3. **Ask**: Create new issue with:
   - Error messages
   - System specs
   - Steps to reproduce

## System Requirements

**Minimum**:
- Windows 10/11
- 4-core CPU
- 8 GB RAM
- 5 GB disk space

**Recommended**:
- Windows 11
- 8-core CPU (Intel i7/AMD Ryzen 7)
- 16 GB RAM
- 10 GB disk space (SSD preferred)

## Security & Privacy

- ✅ All processing is local
- ✅ No data sent to cloud
- ✅ No telemetry
- ✅ Works offline
- ✅ VHA-compliant deployment

---

**Ready to start?** Open Developer PowerShell and run the 3 commands at the top! 🚀
