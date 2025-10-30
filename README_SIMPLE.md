# VAbitnetUI - Simple Guide

## What Is This?

A desktop application that lets you:
1. **Speak** into your microphone → Get text transcription (using VOSK)
2. **Process** that text → Get cleaned-up notes (using BitNet AI)
3. **Chat** with an AI assistant (also using BitNet)

**Built for**: VA Windows workstations (works offline after setup)

---

## Quick Start (5 Minutes)

### What You Need
- Windows 10 or 11
- Python 3.10 or newer
- A microphone (for speech-to-text)
- About 5GB of free disk space

### Installation

1. **Clone this repository**
```bash
git clone https://github.com/cyber3pxVA/VAbitnetUI.git
cd VAbitnetUI
```

2. **Install Python packages**
```bash
pip install -r requirements.txt
```

3. **Download VOSK speech model** (for voice recognition)
```bash
python src/core/download_vosk.py
```

4. **Start BitNet server** (in a separate terminal)
```bash
# Follow instructions in the bitnet_backend folder
cd bitnet_backend
# Run the BitNet server (see their docs)
```

5. **Run the application**
```bash
python main.py
```

---

## How It Works

### The Application Has 3 Parts:

#### 1. Voice Transcription
- Click "Start Recording"
- Speak into your microphone
- See your words appear as text
- Click "Stop Recording" when done

#### 2. Note Processing
- Copy text into the text box
- Click "Process with BitNet"
- AI cleans up your notes (removes filler words, organizes info)
- Get a clean, professional note

#### 3. AI Chat
- Type questions in the chat box
- Get responses from the BitNet AI
- Have a conversation (it remembers context)

---

## File Structure (What's Where)

```
VAbitnetUI/
├── main.py                          # Start the app here
├── requirements.txt                 # Python packages needed
│
├── src/                             # Main code
│   ├── core/                        # Core settings and data structures
│   │   ├── config.py               # All settings in one place
│   │   ├── models.py               # Data structures (requests/responses)
│   │   └── errors.py               # Error handling (NEW!)
│   │
│   ├── infrastructure/              # External connections (NEW!)
│   │   └── http_client.py          # Talks to BitNet server
│   │
│   ├── services/                    # Business logic
│   │   ├── audio_service.py        # Microphone recording
│   │   ├── chat_service.py         # Chat functionality
│   │   ├── inference_service.py    # BitNet processing
│   │   └── clipboard_service.py    # Copy/paste helpers
│   │
│   └── ui/                          # User interface
│       ├── main_window.py          # Main application window
│       └── styles.py               # Colors and fonts
│
├── bitnet_backend/                  # BitNet AI model files
│   └── models/                      # The actual AI model
│
└── docs/                            # Documentation
```

---

## Common Tasks

### Change the AI's Behavior
Edit `src/core/config.py`:
```python
# Make responses more creative (0.0 = boring, 2.0 = wild)
temperature: float = 0.7

# Limit response length
max_tokens: int = 2048

# Change what the AI does
system_prompt: str = "Your custom instructions here"
```

### Use a Different Microphone
The app uses your system's default microphone. Change it in Windows Settings → Sound.

### Fix "Can't Connect to BitNet" Error
1. Make sure BitNet server is running: `http://localhost:8081`
2. Check the endpoint in `.env` file or `src/core/config.py`
3. Try: `curl http://localhost:8081` to test connection

### Clear Chat History
Click "Clear History" button in the UI, or restart the app.

---

## What We Just Fixed (Recent Improvements)

### 1. No More "Vibe-Coded" Errors ✅
**Before**: App would crash with confusing errors
**Now**: Clear error messages tell you exactly what went wrong

### 2. One HTTP Client Instead of Three ✅
**Before**: Three different places making web requests (messy!)
**Now**: One clean HTTP client that everyone uses

### 3. Structured Error Handling ✅
**Before**: Errors were just text strings
**Now**: Errors have codes (like `TIMEOUT`, `NETWORK_ERROR`) so the app can handle them intelligently

---

## Troubleshooting

### "VOSK model not found"
Run: `python src/core/download_vosk.py`

### "Cannot connect to BitNet server"
1. Check if BitNet is running: `http://localhost:8081`
2. Start BitNet server (see `bitnet_backend/` folder)

### "Import requests could not be resolved"
Run: `pip install -r requirements.txt`

### "No microphone detected"
1. Plug in your microphone
2. Go to Windows Settings → Sound → Input
3. Test your microphone there first

### App is slow
1. Close other programs
2. Check BitNet server logs for issues
3. Reduce `max_tokens` in config (fewer words = faster)

---

## For Developers

See `DEVELOPER_GUIDE.md` for:
- Code architecture details
- How to add new features
- Testing instructions
- Contributing guidelines

---

## Need Help?

1. Check the `docs/` folder for detailed guides
2. Look at `ARCHITECTURAL_REFACTORING.md` for technical details
3. Open an issue on GitHub
4. Read the original project docs: [VAbitnet_i2](https://github.com/cyber3pxVA/VAbitnet_i2)

---

## License

See `LICENSE` file

---

## Credits

- BitNet inference engine: Microsoft Research
- VOSK speech recognition: Alpha Cephei
- Built for: VA workstation environments
