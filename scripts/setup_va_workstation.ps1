# VAbitnetUI Setup Script for VA Workstations (Windows)
# This script automates the complete setup process for VA-compliant deployment

param(
    [switch]$SkipVSCheck = $false,
    [switch]$SkipModelDownload = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

# Colors for output
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Header { param($msg) Write-Host "`n========================================" -ForegroundColor Magenta; Write-Host $msg -ForegroundColor Magenta; Write-Host "========================================`n" -ForegroundColor Magenta }

Write-Header "VAbitnetUI Setup - VA Workstation Configuration"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

Write-Info "Installation directory: $RootDir"
Write-Info "Current user: $env:USERNAME"
Write-Info "Computer name: $env:COMPUTERNAME"

# Step 1: Check Python installation
Write-Header "Step 1: Checking Python Installation"

try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)") {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        if ($major -ge 3 -and $minor -ge 10) {
            Write-Success "Python $major.$minor found"
        } else {
            Write-Error "Python 3.10+ required. Found: $pythonVersion"
            Write-Warning "Please install Python 3.10 or later from https://www.python.org"
            exit 1
        }
    }
} catch {
    Write-Error "Python not found in PATH"
    Write-Warning "Please install Python 3.10+ from https://www.python.org"
    exit 1
}

# Step 2: Check Visual Studio 2022 and Clang
Write-Header "Step 2: Checking Visual Studio 2022 & Clang"

if (-not $SkipVSCheck) {
    try {
        $clangVersion = clang -v 2>&1
        if ($clangVersion -match "clang version") {
            Write-Success "Clang compiler found"
            if ($Verbose) { Write-Info "$clangVersion" }
        } else {
            throw "Clang not properly configured"
        }
    } catch {
        Write-Error "Visual Studio 2022 environment not initialized"
        Write-Warning @"
Please ensure Visual Studio 2022 is installed with:
  - Desktop development with C++
  - C++ CMake Tools for Windows
  - C++ Clang Compiler for Windows
  - MS-Build Support for LLVM-Toolset

Then run this script from 'Developer PowerShell for VS 2022'
Or initialize the environment manually:
  Import-Module "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
  Enter-VsDevShell -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"
"@
        exit 1
    }
} else {
    Write-Warning "Skipping Visual Studio check (--SkipVSCheck specified)"
}

# Step 3: Create Python virtual environment
Write-Header "Step 3: Creating Python Virtual Environment"

Set-Location $RootDir

if (Test-Path "venv") {
    Write-Info "Virtual environment already exists"
    $recreate = Read-Host "Recreate? (y/N)"
    if ($recreate -eq "y" -or $recreate -eq "Y") {
        Write-Info "Removing existing virtual environment..."
        Remove-Item -Recurse -Force venv
        python -m venv venv
        Write-Success "Virtual environment recreated"
    } else {
        Write-Success "Using existing virtual environment"
    }
} else {
    python -m venv venv
    Write-Success "Virtual environment created"
}

# Activate virtual environment
Write-Info "Activating virtual environment..."
& "$RootDir\venv\Scripts\Activate.ps1"
Write-Success "Virtual environment activated"

# Step 4: Install Python dependencies
Write-Header "Step 4: Installing Python Dependencies"

Write-Info "Upgrading pip..."
python -m pip install --upgrade pip --quiet

Write-Info "Installing requirements from requirements.txt..."
pip install -r "$RootDir\requirements.txt"
Write-Success "Python dependencies installed"

# Step 5: Download VOSK model
Write-Header "Step 5: Downloading VOSK Model (Offline Speech Recognition)"

$voskModelPath = "$RootDir\models\vosk-model-small-en-us-0.15"

if (Test-Path $voskModelPath) {
    Write-Success "VOSK model already exists at $voskModelPath"
} else {
    Write-Info "Downloading VOSK model (vosk-model-small-en-us-0.15)..."
    New-Item -ItemType Directory -Force -Path "$RootDir\models" | Out-Null
    
    $voskUrl = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip"
    $voskZip = "$RootDir\models\vosk-model-small-en-us-0.15.zip"
    
    try {
        Invoke-WebRequest -Uri $voskUrl -OutFile $voskZip -UseBasicParsing
        Write-Success "VOSK model downloaded"
        
        Write-Info "Extracting VOSK model..."
        Expand-Archive -Path $voskZip -DestinationPath "$RootDir\models" -Force
        Remove-Item $voskZip
        Write-Success "VOSK model extracted and ready"
    } catch {
        Write-Error "Failed to download VOSK model: $_"
        Write-Warning "You can download manually from: $voskUrl"
    }
}

# Step 6: Build BitNet backend
Write-Header "Step 6: Building BitNet Backend (This may take 5-10 minutes)"

Set-Location "$RootDir\bitnet_backend"

if (-not $SkipModelDownload) {
    Write-Info "Checking for BitNet model files..."
    $modelPath = "$RootDir\bitnet_backend\models\BitNet-b1.58-2B-4T"
    
    if (Test-Path "$modelPath\ggml-model-i2_s.gguf") {
        Write-Success "BitNet model already exists"
        $rebuild = Read-Host "Rebuild anyway? (y/N)"
        if ($rebuild -ne "y" -and $rebuild -ne "Y") {
            Write-Info "Skipping BitNet build"
            Set-Location $RootDir
            Write-Header "Setup Complete!"
            Write-Success "All components are ready"
            Write-Info "To start the application, run: .\scripts\start_va_workstation.ps1"
            exit 0
        }
    }
    
    Write-Info "Building BitNet inference engine and downloading model..."
    Write-Info "This will download ~1.2GB model file via Git LFS"
    Write-Warning "Ensure you have network connectivity for this step"
    
    try {
        # Check if Git LFS is installed
        $gitLfs = git lfs version 2>&1
        if ($gitLfs -notmatch "git-lfs") {
            Write-Warning "Git LFS not found. Installing..."
            git lfs install
        }
        
        # Run setup_env.py with model directory and quantization type
        python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
        Write-Success "BitNet backend built successfully"
    } catch {
        Write-Error "BitNet build failed: $_"
        Write-Warning @"
Build failed. Common solutions:
1. Ensure you're running from 'Developer PowerShell for VS 2022'
2. Check that all Visual Studio components are installed
3. Verify network connection for model download
4. Check logs in bitnet_backend/logs/ directory

Manual build command:
  cd bitnet_backend
  python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
"@
        exit 1
    }
} else {
    Write-Warning "Skipping model download (--SkipModelDownload specified)"
}

# Step 7: Create .env file
Write-Header "Step 7: Creating Configuration File"

Set-Location $RootDir

$envContent = @"
# VAbitnetUI Configuration for VA Workstation
# Generated by setup_va_workstation.ps1

# VOSK Model Path (offline speech recognition)
VOSK_MODEL_PATH=.\models\vosk-model-small-en-us-0.15

# BitNet API Endpoint (local server)
BITNET_ENDPOINT=http://localhost:8081/completion

# BitNet Model Path
BITNET_MODEL_PATH=.\bitnet_backend\models\BitNet-b1.58-2B-4T\ggml-model-i2_s.gguf

# Inference Settings (adjust based on your VA laptop specs)
BITNET_THREADS=0
BITNET_CTX_SIZE=2048
BITNET_TEMPERATURE=0.7

# Server Port
BITNET_SERVER_PORT=8081
"@

$envFile = "$RootDir\.env"

if (Test-Path $envFile) {
    Write-Info ".env file already exists"
    $overwrite = Read-Host "Overwrite? (y/N)"
    if ($overwrite -eq "y" -or $overwrite -eq "Y") {
        $envContent | Out-File -FilePath $envFile -Encoding UTF8
        Write-Success ".env file updated"
    }
} else {
    $envContent | Out-File -FilePath $envFile -Encoding UTF8
    Write-Success ".env file created"
}

# Step 8: Final verification
Write-Header "Step 8: Verifying Installation"

$allGood = $true

# Check Python packages
Write-Info "Checking Python packages..."
$packages = @("tkinter", "vosk", "requests", "sounddevice")
foreach ($pkg in $packages) {
    try {
        python -c "import $pkg" 2>&1 | Out-Null
        Write-Success "  $pkg installed"
    } catch {
        Write-Error "  $pkg missing"
        $allGood = $false
    }
}

# Check VOSK model
if (Test-Path $voskModelPath) {
    Write-Success "VOSK model present"
} else {
    Write-Error "VOSK model missing"
    $allGood = $false
}

# Check BitNet build
$bitnetBinary = "$RootDir\bitnet_backend\build\bin\Release\llama-cli.exe"
if (Test-Path $bitnetBinary) {
    Write-Success "BitNet binary built"
} else {
    Write-Warning "BitNet binary not found (build may be in different location)"
}

# Check BitNet model
$bitnetModel = "$RootDir\bitnet_backend\models\BitNet-b1.58-2B-4T\ggml-model-i2_s.gguf"
if (Test-Path $bitnetModel) {
    $modelSize = (Get-Item $bitnetModel).Length / 1GB
    Write-Success "BitNet model present ($([math]::Round($modelSize, 2)) GB)"
} else {
    Write-Warning "BitNet model not found"
}

# Final message
Write-Header "Setup Complete!"

if ($allGood) {
    Write-Success @"
✓ All components installed and verified
✓ System ready for offline operation
✓ No internet connection required from this point forward
"@
    Write-Info "`nTo start the application:"
    Write-Host "  .\scripts\start_va_workstation.ps1" -ForegroundColor Yellow
    Write-Info "`nFirst-time startup tips:"
    Write-Info "  - The BitNet server will start automatically"
    Write-Info "  - Allow ~10-30 seconds for model loading"
    Write-Info "  - Use 'Voice' tab for speech transcription"
    Write-Info "  - Use 'Chat' tab for text conversation"
} else {
    Write-Warning @"
Setup completed with warnings. Please review the messages above.
Some components may need manual installation or configuration.
"@
}

Write-Info "`nFor troubleshooting, see: docs\TROUBLESHOOTING.md"
Write-Info "VA Workstation guide: docs\VA_WORKSTATION_SETUP.md"
