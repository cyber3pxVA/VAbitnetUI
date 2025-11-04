# VAbitnetUI - Local AI Chat for VA Workstations

**⚠️ PROTOTYPE**: This is a proof-of-concept. It works, but it's early stage. If something breaks, let us know!

Run a 2.4B parameter AI language model **100% offline** on your VA laptop. No internet needed after setup, no cloud services, no data leaving your machine.

**What you get:**
- Local AI chatbot in your web browser
- Runs on CPU (no GPU needed)
- Works on standard VA i5/i7 laptops
- Completely offline after initial download

---

## 🚀 Setup (Takes 5 minutes)

### What You Need
- Windows 10/11 VA workstation
- Git installed (check by typing `git --version` in terminal)
- Internet connection (only for initial setup)
- ~2GB free disk space

### Step-by-Step

**1. Download the code**

Open Git Bash (or PowerShell) and copy-paste this:

```bash
git clone https://github.com/cyber3pxVA/VAbitnetUI.git
cd VAbitnetUI
```

**What's happening:** Downloads all the files including a 1.2GB AI model. Takes 3-5 minutes on VA network.

---

**2. Verify everything downloaded**

```bash
SETUP.bat
```

**What's happening:** Just checks the files are there. Takes 30 seconds. You should see:
- ✓ Git LFS is configured
- ✓ Server binaries found
- ✓ Model file found (1.2GB)

**If you see errors here:** Stop and report what it says - something didn't download right.

---

**3. Start the AI server**

```bash
START.bat
```

**What's happening:** 
- Launches `llama-server.exe` in background
- Loads the 1.2GB model into memory (takes 15-20 seconds)
- Opens your web browser to http://127.0.0.1:8081

**You should see:** A chat interface in your browser after ~20 seconds.

---

**4. Test it out**

Type something like:
```
What is the capital of France?
```

Press Enter. You should get a response in 2-3 seconds.

**Normal behavior:**
- First response takes longer (model is "warming up")
- Speed: 5-15 words per second
- Responses might be short or generic - this is a small model

**If nothing happens:** See troubleshooting below.

---

## 🤔 If Something Doesn't Work

**This is a prototype.** Here's what to check:

### Server won't start
- Check if `bitnet_backend/build_mingw/bin/llama-server.exe` exists
- If missing, the binaries didn't download from Git
- Let us know and we'll fix the repo

### Model not found
- Check if `bitnet_backend/models/bitnet_b1_58-large/ggml-model-i2_s.gguf` exists (should be 1.2GB)
- If missing, run: `git lfs pull`
- Git LFS might not be installed - run: `git lfs install`

### Browser doesn't open
- Manually go to: http://127.0.0.1:8081
- Server might be running but browser didn't auto-open

### Responses are slow or weird
- This is a 2.4B parameter model - it's small and fast but not GPT-4
- Expected speed: 5-15 words per second on i5/i7
- Responses may be basic or repetitive - that's normal for this size model

### Something else broke
- **Give us feedback!** Open an issue on GitHub with:
  - What you tried to do
  - What error you got
  - Your Windows version and CPU type (i5/i7)

---

## 📝 What This Actually Is

**Technical Details:**
- **Model**: Microsoft BitNet b1.58 (2.4B parameters, 1.58-bit quantized)
- **Interface**: Web UI built into llama-server
- **Backend**: C++ inference engine (llama.cpp with BitNet extensions)
- **Speed**: ~7-15 tokens/sec on VA i7-1265U CPU
- **Memory**: Uses ~1.4GB RAM

**Optional Python GUI:**
- There's also a Python GUI with voice transcription (VOSK)
- Run `python main.py` if you want voice input
- Requires Python 3.10+ and `pip install -r requirements.txt`
- **Not needed for basic chat** - web UI is simpler

---

## 💡 Feedback & Issues

**This is a prototype to prove VA workstations can run local AI.**

If you try this and:
- ✅ It works - tell us! We want to know what laptops it runs on
- ❌ It breaks - tell us! We'll fix it
- 🤔 You want different features - tell us! What would make this useful?

**Open an issue on GitHub** with your feedback. Be specific:
- "Worked great on i7 laptop"
- "Setup failed at step X with error Y"
- "Would be better if it could Z"

---

## 📚 For Developers

**How it works:**
- `SETUP.bat` - Verifies Git LFS pulled binaries and model
- `START.bat` - Runs `llama-server.exe` with BitNet model
- Server provides web UI at port 8081
- Everything runs locally, no external connections

**Key files:**
- `bitnet_backend/build_mingw/bin/llama-server.exe` - Pre-built server (4.6MB)
- `bitnet_backend/build_mingw/bin/libgomp-1.dll` - OpenMP library (280KB)
- `bitnet_backend/models/bitnet_b1_58-large/ggml-model-i2_s.gguf` - Model (1.2GB)

**Rebuilding from source:**
- See `bitnet_backend/README.md` for build instructions
- Requires MinGW-w64 + CMake
- Takes 10-15 minutes to compile

**Python GUI (optional):**
- `main.py` - PyQt6 GUI with VOSK speech recognition
- `requirements.txt` - Python dependencies
- Not needed for basic functionality

---

## ⚠️ Limitations (Prototype)

**This is proof-of-concept. Known issues:**
- Model is small (2.4B) - responses are basic
- No conversation history - each message is independent
- No fine-tuning - generic responses, not VA-specific
- No document search (RAG) - can't reference VA docs
- Web UI is basic - no advanced features

**What we'd need for production:**
- Larger model (7B-13B parameters)
- Fine-tuning on VA-specific data
- RAG for searching VA documents
- Better web interface
- Evaluation and testing framework

**But it proves the concept works!** VA laptops CAN run local AI offline.

---

## 🛠️ Quick Commands

```bash
# First time setup
git clone https://github.com/cyber3pxVA/VAbitnetUI.git
cd VAbitnetUI
SETUP.bat
START.bat

# Every time after that
START.bat

# Stop the server
# Just close the terminal window or press Ctrl+C

# Optional Python GUI with voice
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

---

## 📞 Contact & Contribution

This is a VA proof-of-concept. Feedback welcome!

**GitHub Issues**: https://github.com/cyber3pxVA/VAbitnetUI/issues

**What helps us improve:**
- Which VA laptop model you tested on
- What worked / what didn't
- What features would make this actually useful
- Any security or compliance concerns

Thanks for testing!

## ⚠️ VA Workstation Requirements

**Critical**: This is designed for **VHA-compliant Windows workstations** with:
- Windows 10/11 (VA standard issue laptops)
- Portable toolchain (MinGW/MSVC) - no system modifications required
- Offline operation after initial setup
- CPU-only inference (no GPU required)
- Self-contained deployment approach

## ✨ Features

- � **Built-in Web UI**: Access via browser at http://127.0.0.1:8081 (primary interface)
- 💬 **Text Chat**: Interactive conversation with BitNet LLM
- 🎤 **Optional Voice Transcription**: VOSK-based speech recognition (via Python GUI)
- 🖥️ **Optional Python GUI**: Clean interface for voice and text (see `main.py`)
- 🔒 **Offline Operation**: No cloud services required after initial setup
- ⚡ **CPU Optimized**: Runs on standard laptops without GPU
- 🧩 **Modular Architecture**: Multiple interface options for flexibility

## 📋 Requirements

### VA Workstation Software (VHA-Compliant)
- **Windows**: Windows 10/11 (VA standard issue)
- **Python**: 3.10+ (portable installation recommended)
- **Visual Studio 2022**: Required components:
  - Desktop development with C++
  - C++ CMake Tools for Windows
  - Git for Windows
  - C++ Clang Compiler for Windows
  - MS-Build Support for LLVM-Toolset (clang)
- **Portable Toolchain**: MinGW-w64 (included in repo for offline operation)

### Hardware (VA Laptop Specifications)
- **CPU**: x86-64 (Intel/AMD, standard VA laptop processors)
- **RAM**: 8GB minimum (16GB recommended for optimal performance)
- **Disk**: ~5GB free space for models and dependencies
- **Microphone**: Built-in or USB microphone for voice transcription
- **Network**: Required only for initial setup/clone (then fully offline)

## 🚀 Quick Start (VA Workstation)

### For New VA Workstation (First Time Setup)

**Prerequisites**: Git with Git LFS installed (standard on most VA workstations)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/cyber3pxVA/VAbitnetUI.git
   cd VAbitnetUI
   ```

2. **Run one-time setup**:
   ```bash
   SETUP.bat
   ```
   
   This downloads:
   - Pre-built binaries (llama-server.exe - 4.6MB)
   - BitNet model file (1.2GB via Git LFS)
   - Takes 2-5 minutes depending on internet speed

3. **Start the application**:
   ```bash
   START.bat
   ```
   
   - Launches BitNet server
   - Opens web browser to http://127.0.0.1:8081
   - Start chatting immediately!

**That's it!** No Python needed, no Visual Studio, no build tools, no bullshit.

**⚠️ Important**: After initial setup, **NO internet connection is required**. Everything runs 100% offline.

## 📖 Manual Installation (VA Workstation)

If you need to set up manually or troubleshoot the automated setup:

### Step 1: Verify Visual Studio 2022 (VA Required)

Open **Developer Command Prompt for VS 2022** or **Developer PowerShell for VS 2022**:

```powershell
# Verify Clang is available
clang -v

# Should show: clang version 18.x.x or later
# If not, run Visual Studio Installer and add required components
```

If you see "'clang' is not recognized", you need to initialize the VS environment:

```powershell
# For PowerShell
Import-Module "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
Enter-VsDevShell -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"

# For Command Prompt
"C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat" -startdir=none -arch=x64 -host_arch=x64
```

### Step 2: BitNet Backend Setup (One-time Build)

The BitNet backend provides the AI inference engine. This step builds the C++ inference engine and downloads the model.

```powershell
cd bitnet_backend

# Build and setup (uses VHA-compliant portable toolchain)
python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

This will:
- ✅ Build the BitNet C++ inference engine with MinGW/MSVC
- ✅ Download the 2.4B parameter model (1.19 GB) via Git LFS
- ✅ Configure optimized i2_s kernels for x86 CPUs
- ✅ Create all necessary binaries in `build/bin/Release/`

**Note**: This build step requires network access **once**. After completion, everything runs offline.

### Step 3: GUI Frontend Setup (Python Environment)

Create an isolated Python environment (VHA-compliant, no system modifications):

```powershell
# Create virtual environment
python -m venv venv

# Activate it
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Step 4: Download VOSK Model (Offline Speech Recognition)

```powershell
# Automatic download (recommended)
python src\core\download_vosk.py

# This downloads vosk-model-small-en-us-0.15 (~40MB)
# Model is stored in models/ directory for offline use
```

### Step 5: Configuration (Optional Customization)

Create a `.env` file in the root directory for custom settings:

```ini
# Optional: Custom VOSK model location
VOSK_MODEL_PATH=.\models\vosk-model-small-en-us-0.15

# Optional: Custom BitNet endpoint (if using different port)
BITNET_ENDPOINT=http://localhost:8081/completion

# BitNet model path (auto-detected, but can override)
BITNET_MODEL_PATH=.\bitnet_backend\models\BitNet-b1.58-2B-4T\ggml-model-i2_s.gguf

# Number of CPU threads (default: auto-detect)
BITNET_THREADS=4

# Context window size
BITNET_CTX_SIZE=2048
```

## 🎮 Usage

### Starting the BitNet Server

Start the BitNet backend server:

```bash
cd bitnet_backend
./build_mingw/bin/llama-server.exe -m models/bitnet_b1_58-large/ggml-model-i2_s.gguf --port 8081 --host 127.0.0.1 -c 2048 -t 4
```

**The server provides a built-in web interface:**
- Open your browser to: http://127.0.0.1:8081
- Chat directly in the browser - no additional setup needed!

### Optional: Python GUI Application

For voice transcription and desktop interface:

```bash
python main.py
```

The Python GUI provides:
- Voice transcription via VOSK
- Text chat interface
- Settings management

**Note**: The web UI is recommended for most users. The Python GUI is optional and primarily useful if you need voice transcription capabilities.

1. Click **"Start Recording"** to begin capturing audio
2. Speak clearly into your microphone
3. Click **"Stop Recording"** when finished
4. Click **"Generate Notes"** to process with BitNet AI
5. Use **"Copy to Clipboard"** to save results

### Chat Mode

1. Click the **"Chat"** tab at the top
2. Type your message in the input field
3. Press **Enter** or click **"Send"**
4. The AI responds with context from conversation history
5. Use **"Clear History"** to start fresh

## 🏗️ Architecture

```
VAbitnetUI/
├── src/                          # GUI application source
│   ├── core/                     # Domain models and configuration
│   │   ├── config.py            # Centralized configuration
│   │   ├── models.py            # Data contracts
│   │   └── download_vosk.py     # VOSK model downloader
│   ├── services/                 # Business logic layer
│   │   ├── audio_service.py     # VOSK speech recognition
│   │   ├── inference_service.py # BitNet integration
│   │   └── clipboard_service.py # System clipboard
│   └── ui/                       # Presentation layer
│       ├── styles.py            # Braun aesthetic styling
│       └── main_window.py       # Main UI orchestration
├── bitnet_backend/               # BitNet inference engine
│   ├── 3rdparty/                # Third-party dependencies
│   ├── src/                     # C++ source code
│   ├── models/                  # Model storage
│   ├── setup_env.py             # Build and setup script
│   ├── run_server.py            # HTTP API server
│   └── run_inference.py         # CLI inference
├── scripts/                      # Setup and start scripts
│   ├── setup_windows.ps1        # Windows automated setup
│   ├── setup_linux.sh           # Linux automated setup
│   ├── start_windows.ps1        # Windows start script
│   └── start_linux.sh           # Linux start script
├── docs/                         # Documentation
│   ├── ARCHITECTURE.md          # Architecture details
│   ├── API.md                   # API documentation
│   └── TROUBLESHOOTING.md       # Common issues
├── main.py                       # Application entry point
├── requirements.txt              # Python dependencies
├── .env.example                 # Environment configuration template
└── README.md                    # This file
```

### Design Principles

This project follows **Braun design principles**:
- **Separation of Concerns**: UI, business logic, and infrastructure are decoupled
- **Clear Contracts**: All service interactions use typed data models
- **Minimalism**: No unnecessary complexity
- **Testability**: Core logic can be tested independently

## 🔧 Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VOSK_MODEL_PATH` | `./models/vosk-model-small-en-us-0.15` | Path to VOSK model |
| `BITNET_ENDPOINT` | `http://localhost:8081/completion` | BitNet API endpoint |
| `BITNET_MODEL_PATH` | Auto-detected | Path to BitNet GGUF model |
| `BITNET_THREADS` | Auto (CPU cores) | Number of inference threads |
| `BITNET_CTX_SIZE` | `2048` | Context window size |

### BitNet Model Options

The default model is **BitNet-b1.58-2B-4T** (2.4B parameters, 1.19 GB):
- **Quantization**: i2_s (1.58-bit ternary weights)
- **Speed**: 5-7 tokens/second on modern CPUs
- **Memory**: ~2GB RAM during inference

You can use larger models by downloading them separately:
- **bitnet_b1_58-3B**: 3.3B parameters
- **Llama3-8B-1.58**: 8B parameters (requires more RAM)

## 📚 Documentation

- **[Architecture Guide](docs/ARCHITECTURE.md)**: Detailed architecture and design patterns
- **[API Documentation](docs/API.md)**: BitNet API and service interfaces
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)**: Common issues and solutions
- **[Development Guide](docs/DEVELOPMENT.md)**: Contributing and development setup

## 🐛 Troubleshooting

### Common Issues

**Issue**: BitNet server won't start
```bash
# Check if port 8081 is already in use
# Windows
netstat -ano | findstr :8081

# Linux
lsof -i :8081

# Use a different port
export BITNET_ENDPOINT=http://localhost:8082/completion
python bitnet_backend/run_server.py -p 8082
```

**Issue**: VOSK model not found
```bash
# Download manually
python src/core/download_vosk.py
```

**Issue**: GUI won't start (Windows PowerShell execution policy)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Issue**: Build fails (Windows - missing Visual Studio tools)
- Install Visual Studio 2022 with:
  - Desktop development with C++
  - C++ CMake Tools for Windows
  - C++ Clang Compiler for Windows
  - MS-Build Support for LLVM-Toolset

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more details.

## 🎯 Use Cases

### VA Workstation Deployment
- ✅ Offline operation after initial setup
- ✅ VHA-compliant portable toolchain
- ✅ CPU-only inference (no GPU required)
- ✅ Self-contained deployment

### General Desktop Usage
- ✅ Voice memo transcription and summarization
- ✅ Interactive AI assistant for research
- ✅ Offline AI chat for privacy-sensitive work
- ✅ Local document processing

## 🛠️ Development

### Running Tests
```bash
# Backend tests
cd bitnet_backend
python utils/e2e_benchmark.py -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf

# Frontend tests (unit tests)
pytest src/tests/
```

### Building for Distribution
```bash
# Create standalone executable (PyInstaller)
python scripts/build_executable.py
```

## 📝 License

MIT License - See [LICENSE](LICENSE) for details.

This project combines:
- **BitNet** (Microsoft) - MIT License
- **VOSK** (Alpha Cephei) - Apache 2.0 License
- **llama.cpp** (Georgi Gerganov) - MIT License

## 🙏 Acknowledgements

- **[Microsoft BitNet](https://github.com/microsoft/BitNet)**: 1.58-bit LLM inference engine
- **[llama.cpp](https://github.com/ggerganov/llama.cpp)**: Foundation for BitNet.cpp
- **[VOSK](https://alphacephei.com/vosk/)**: Offline speech recognition
- **[T-MAC](https://github.com/microsoft/T-MAC/)**: Lookup table methodologies

## 🚀 Roadmap

- [ ] Add support for larger models (7B, 13B parameters)
- [ ] Implement RAG (Retrieval Augmented Generation) for document Q&A
- [ ] Add model fine-tuning capabilities
- [ ] Create web interface option (Flask/FastAPI)
- [ ] Add speech synthesis (TTS) for voice responses
- [ ] Support for custom VOSK models and languages
- [ ] Docker containerization
- [ ] Model quantization utilities

## 📧 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/cyber3pxVA/VAbitnetUI/issues)
- **Discussions**: [GitHub Discussions](https://github.com/cyber3pxVA/VAbitnetUI/discussions)

## ⭐ Show Your Support

If you find this project useful, please consider giving it a star on GitHub!

---

**Note**: This is designed for Windows workstation deployment but works on any platform. The setup scripts handle platform-specific configurations automatically.
