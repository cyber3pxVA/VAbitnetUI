# VA Workstation Setup Guide

## Overview

This guide provides step-by-step instructions for deploying VAbitnetUI on VHA-compliant Windows workstations. The setup uses only approved portable tools and requires no system-level modifications.

## ⚠️ Important VA Requirements

- **Network Access**: Required ONLY for initial setup (git clone, model download)
- **After Setup**: Fully offline operation - no internet required
- **System Modifications**: NONE - all tools run from user directory
- **Toolchain**: VHA-compliant portable MinGW/MSVC via Visual Studio 2022
- **Security**: Local inference only - no cloud services, no data transmission

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Windows 10/11** (VA standard issue laptop)
- [ ] **Visual Studio 2022** installed with required components
- [ ] **Python 3.10+** installed (portable installation acceptable)
- [ ] **Git** for Windows (included with VS 2022)
- [ ] **Network access** (temporary - for initial clone and downloads)
- [ ] **8GB RAM minimum** (16GB recommended)
- [ ] **5GB free disk space**

## Visual Studio 2022 Required Components

When installing or modifying Visual Studio 2022, ensure these workloads/components are selected:

### Required Workloads:
1. **Desktop development with C++**

### Required Individual Components:
1. **C++ CMake tools for Windows**
2. **Git for Windows**
3. **C++ Clang Compiler for Windows** (v18.0 or later)
4. **MSBuild support for LLVM (Clang-cl) toolset**

### Verification:
After installation, verify from a **regular** PowerShell/Command Prompt:
```powershell
# Check if Visual Studio is installed
dir "C:\Program Files\Microsoft Visual Studio\2022"

# Should show: Community, Professional, or Enterprise folder
```

## Installation Steps

### Step 1: Open Developer Environment

⚠️ **CRITICAL**: You must use Developer tools from Visual Studio

**Option A: Developer PowerShell** (Recommended)
1. Press Windows key
2. Type "Developer PowerShell for VS 2022"
3. Run as your user (admin not required)

**Option B: Developer Command Prompt**
1. Press Windows key
2. Type "Developer Command Prompt for VS 2022"
3. Run as your user (admin not required)

**Option C: Initialize Regular PowerShell**
```powershell
Import-Module "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
Enter-VsDevShell -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"
```

### Step 2: Verify Environment

In your Developer PowerShell/Command Prompt:

```powershell
# Test Python
python --version
# Should show: Python 3.10.x or later

# Test Clang
clang -v
# Should show: clang version 18.x.x

# Test CMake
cmake --version
# Should show: cmake version 3.22 or later

# Test Git
git --version
# Should show: git version 2.x.x
```

If any command fails, Visual Studio components may not be properly installed.

### Step 3: Clone Repository

Navigate to your preferred installation location (e.g., Documents, Desktop):

```powershell
# Example: Install to Documents
cd $env:USERPROFILE\Documents

# Clone with submodules (downloads everything)
git clone --recursive https://github.com/cyber3pxVA/VAbitnetUI.git

# Enter directory
cd VAbitnetUI
```

**Note**: This will download:
- Application code (~50MB)
- BitNet inference engine source (~100MB)
- BitNet 2.4B model via Git LFS (~1.2GB)

Total download: ~1.4GB

### Step 4: Run Automated Setup

From the VAbitnetUI directory in Developer PowerShell:

```powershell
# Run setup script
.\scripts\setup_va_workstation.ps1
```

The script will:
1. ✅ Verify Python 3.10+ is installed
2. ✅ Verify Visual Studio and Clang are available
3. ✅ Create Python virtual environment (isolated, no system changes)
4. ✅ Install Python dependencies (tkinter, vosk, requests, etc.)
5. ✅ Download VOSK speech model (~40MB)
6. ✅ Build BitNet C++ inference engine (5-10 minutes)
7. ✅ Download/verify BitNet 2.4B model
8. ✅ Create configuration file (.env)

**Expected time**: 15-30 minutes depending on network speed and CPU

### Step 5: First-Time Configuration (Optional)

The setup creates a `.env` file with defaults. You can customize:

```ini
# Edit .env file in root directory

# Number of CPU threads for inference (0 = auto-detect all cores)
BITNET_THREADS=0

# Context window size (higher = more memory, better context)
BITNET_CTX_SIZE=2048

# Generation temperature (0.0-1.0, higher = more creative)
BITNET_TEMPERATURE=0.7

# Server port (change if 8081 is in use)
BITNET_SERVER_PORT=8081
```

### Step 6: Start Application

```powershell
# Start both server and GUI
.\scripts\start_va_workstation.ps1

# Optional: Start server only (for testing)
.\scripts\start_va_workstation.ps1 -ServerOnly

# Optional: Start GUI only (if server already running)
.\scripts\start_va_workstation.ps1 -GuiOnly
```

**First startup**: Allow 10-30 seconds for model loading into RAM.

## Usage Guide

### Voice Transcription Mode

1. Click **"Voice"** tab (default view)
2. Click **"Start Recording"** button
3. Speak clearly into microphone
4. Click **"Stop Recording"** when done
5. Review transcript in text area
6. Click **"Generate Notes"** to:
   - Summarize your transcript
   - Format into structured notes
   - Extract key points
7. Click **"Copy to Clipboard"** to paste elsewhere

### Chat Mode

1. Click **"Chat"** tab at top
2. Type message in input field at bottom
3. Press **Enter** or click **"Send"**
4. AI responds with context from conversation
5. Click **"Clear History"** to reset conversation

### Keyboard Shortcuts

- **Ctrl+Enter**: Send message (in Chat mode)
- **Ctrl+C**: Copy selected text
- **Ctrl+V**: Paste text
- **Escape**: Close application (with confirmation)

## Performance Optimization

### CPU Thread Configuration

By default, the application uses all available CPU cores. On VA laptops with 4-8 cores:

**Default (Auto)**: Best for most users
```ini
BITNET_THREADS=0
```

**Conservative (Half cores)**: Better for multitasking
```ini
BITNET_THREADS=2  # On 4-core laptop
BITNET_THREADS=4  # On 8-core laptop
```

**Aggressive (All cores)**: Fastest inference
```ini
BITNET_THREADS=4  # On 4-core laptop
BITNET_THREADS=8  # On 8-core laptop
```

### Expected Performance

On typical VA laptop (Intel i5/i7, 4-8 cores, 8-16GB RAM):

- **Model Loading**: 5-15 seconds
- **Voice Transcription**: Real-time (VOSK processes as you speak)
- **Text Generation**: 3-7 tokens/second
- **Response Time**: 5-15 seconds for typical chat response
- **Memory Usage**: 2-3GB during inference

## Offline Operation

### What Works Offline (After Setup)

✅ **Everything!**
- Voice transcription (VOSK is fully local)
- Text chat (BitNet runs locally)
- Note generation
- All AI features

### What Requires Network (One-Time)

❌ **Initial Setup Only**:
- Git clone repository
- Download models (BitNet, VOSK)
- Install Python packages

**After setup completes**: Disconnect from network if required by VA policy.

## Troubleshooting

### Issue: "clang is not recognized"

**Cause**: Not running from Developer environment

**Solution**:
```powershell
# Option 1: Use Developer PowerShell for VS 2022 (Start menu)

# Option 2: Initialize environment manually
Import-Module "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
Enter-VsDevShell -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"
```

### Issue: Port 8081 already in use

**Cause**: Another application using port, or previous instance still running

**Solution**:
```powershell
# Check what's using port 8081
netstat -ano | findstr :8081

# Kill the process (replace 1234 with actual PID from above)
Stop-Process -Id 1234 -Force

# Or use different port
$env:BITNET_SERVER_PORT=8082
.\scripts\start_va_workstation.ps1
```

### Issue: Model file not found

**Cause**: Git LFS didn't download model, or download incomplete

**Solution**:
```powershell
cd bitnet_backend\models\BitNet-b1.58-2B-4T

# Check if file is LFS pointer or actual model
dir ggml-model-i2_s.gguf
# Should be ~1.2GB, not 130 bytes

# If small (pointer file), download manually:
git lfs pull

# Or re-run setup
cd ..\..\..\
.\scripts\setup_va_workstation.ps1
```

### Issue: Build fails during setup

**Common causes**:
1. Missing Visual Studio components
2. Not in Developer environment
3. Disk space full

**Solution**:
```powershell
# 1. Verify VS components installed
# Go to Visual Studio Installer → Modify → Verify checkboxes

# 2. Verify environment
clang -v
cmake --version

# 3. Check disk space
Get-PSDrive C
# Ensure 5GB+ free

# 4. Try manual build
cd bitnet_backend
python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

### Issue: Python packages fail to install

**Cause**: Network issues or pip version

**Solution**:
```powershell
# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Upgrade pip
python -m pip install --upgrade pip

# Install requirements with verbose output
pip install -r requirements.txt -v

# If specific package fails (e.g., sounddevice):
pip install sounddevice --no-cache-dir
```

### Issue: VOSK model not found

**Cause**: Download failed or extracted to wrong location

**Solution**:
```powershell
# Download manually
Invoke-WebRequest -Uri "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip" -OutFile "vosk-model.zip"

# Extract
Expand-Archive -Path "vosk-model.zip" -DestinationPath "models\"

# Verify location
dir models\vosk-model-small-en-us-0.15
# Should contain: am/, conf/, graph/, ivector/
```

### Issue: Application starts but no audio input

**Cause**: Microphone permissions or wrong device

**Solution**:
1. Check Windows microphone permissions:
   - Settings → Privacy → Microphone
   - Enable for desktop apps
2. Test microphone in Sound Recorder
3. In application, check error messages for device info

### Issue: Slow inference (>30 seconds per response)

**Cause**: Too few threads or system resource constraints

**Solution**:
```ini
# Edit .env file
BITNET_THREADS=0  # Let system auto-detect

# Or explicitly set to number of cores
BITNET_THREADS=4

# Reduce context size if low RAM
BITNET_CTX_SIZE=1024
```

## Security Considerations

### Data Privacy
- ✅ **All processing is local** - no data leaves your machine
- ✅ **No telemetry** - no usage data collected
- ✅ **No network calls** - after setup, works fully offline

### File Locations
- Application: `%USERPROFILE%\Documents\VAbitnetUI`
- Models: `VAbitnetUI\models\` and `VAbitnetUI\bitnet_backend\models\`
- Logs: `VAbitnetUI\bitnet_backend\logs\`
- Configuration: `VAbitnetUI\.env`

### Sensitive Data Handling
- Conversation history stored in memory only
- No automatic saving of transcripts
- Clear history manually to remove sensitive content
- Application does not write transcripts to disk unless you explicitly save

## Uninstallation

To remove VAbitnetUI:

```powershell
# 1. Stop any running instances
Stop-Process -Name python -Force

# 2. Delete application directory
cd $env:USERPROFILE\Documents
Remove-Item -Recurse -Force VAbitnetUI

# 3. (Optional) Uninstall Visual Studio 2022 if not needed for other work
```

No system-level changes are made, so removal is clean.

## Support & Resources

### Documentation
- Main README: `README.md`
- Architecture: `docs/ARCHITECTURE.md`
- API Documentation: `docs/API.md`
- General Troubleshooting: `docs/TROUBLESHOOTING.md`

### Upstream Projects
- BitNet: https://github.com/microsoft/BitNet
- VOSK: https://alphacephei.com/vosk/
- Original VA BitNet: https://github.com/cyber3pxVA/VAbitnet_i2

### Getting Help
1. Check this guide first
2. Review troubleshooting section
3. Check GitHub issues: https://github.com/cyber3pxVA/VAbitnetUI/issues
4. Create new issue with:
   - Error messages
   - Steps to reproduce
   - System specifications
   - Logs from `bitnet_backend\logs\`

## VA-Specific Compliance Notes

### VHA IT Compliance
- ✅ Uses approved Visual Studio 2022 toolchain
- ✅ Portable installation (user directory only)
- ✅ No system-level modifications
- ✅ No elevated privileges required
- ✅ Fully offline after initial setup
- ✅ No cloud services or external APIs

### Recommended Deployment Workflow
1. **Setup station**: Computer with network access for initial clone
2. **Transfer**: Copy entire VAbitnetUI folder to target VA laptop
3. **Verify**: Run from target laptop (no network needed)
4. **Distribute**: Same process for multiple workstations

### Model Security
- BitNet model (1.2GB) is Microsoft's official release
- VOSK model (40MB) is open-source from Alpha Cephei
- Both models are downloaded from official sources
- SHA256 checksums available for verification
- No custom or unofficial models used

---

**For VA IT Staff**: If you need to verify compliance or have questions about the toolchain, please open an issue on GitHub or refer to the main BitNet VA repository documentation.
