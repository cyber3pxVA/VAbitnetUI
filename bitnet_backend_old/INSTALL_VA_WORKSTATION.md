# Installing BitNet on VA Workstation

**What this is:** BitNet lets you run AI language models (like ChatGPT) directly on your VA laptop without needing cloud services or special permissions. It uses 1.58-bit models that are tiny and fast.

**Time needed:** 15-30 minutes  
**Internet required:** Yes (for initial download)  
**Admin rights needed:** NO

---

## Understanding the Model Files

This repo includes a **pre-converted model** ready to use:

### Two Model Formats:

1. **model.safetensors (2.8 GB)** - Original training format
   - Used by researchers and GPU training
   - NOT included in this repo (too big for GitHub)
   - You don't need this to run inference

2. **ggml-model-tl2.gguf (328 MB)** - Converted for CPU inference
   - This is what you actually use to run the model
   - Already optimized for your laptop
   - **This IS included in the repo**
   - Ready to use immediately

**Think of it like this:** 
- `.safetensors` = RAW uncooked ingredients (2.8 GB)
- `.gguf` = Ready-to-eat meal (328 MB)

You're getting the ready-to-eat version! The GGUF file is compressed and optimized for CPU inference. The original PyTorch weights (safetensors) are used for training or converting, but once converted to GGUF, you don't need them anymore.

---

## What You Need

- Windows 10/11 VA workstation
- About 2 GB free disk space
- Python 3.10 or newer installed

---

## Step-by-Step Setup

### 1. Clone This Repository

Open **Git Bash** (or PowerShell) and run:

```bash
cd ~/Documents/GitHub
git clone https://github.com/cyber3pxVA/VABitNet.git
cd VABitNet
```

### 2. Get the Submodules

This downloads the llama.cpp engine:

```bash
git submodule update --init --recursive
```

### 3. The Model is Already Included!

The model file (`ggml-model-tl2.gguf`, 328 MB) is already in the repo via Git LFS. When you cloned the repo, you got it automatically.

Check it's there:

```bash
ls -lh models/bitnet_b1_58-large/ggml-model-tl2.gguf
```

You should see a **328 MB file**. This is the converted, optimized model ready to use.

### 4. Set Up Python Environment

Create a virtual environment and install dependencies:

**In Git Bash:**
```bash
python -m venv .venv
source .venv/Scripts/activate
pip install --upgrade pip
pip install -r requirements.txt
```

**In PowerShell:**
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
```

### 5. Convert the Model

Convert the model to the efficient GGUF format:

```bash
python utils/convert-hf-to-gguf-bitnet.py models/bitnet_b1_58-large --outtype tl2 --outfile models/bitnet_b1_58-large/ggml-model-tl2.gguf
```

This creates a **343 MB file** that's much faster to use.

### 6. Build the Inference Engine

The pre-built binaries won't work on VA computers (missing DLLs), so we build from source.

Run the silent build script:

```bash
bash build_silent.sh
```

This takes **5-10 minutes** and builds 35 executables in `build_mingw/bin/`.

---

## Running Inference

Once built, you can run the model like this:

```bash
# Add MinGW tools to your path
export PATH="/c/Users/$USERNAME/OneDrive - Department of Veterans Affairs/Documents/GitHub/VAbitnet/tools/mingw64/bin:$PATH"

# Run inference
./build_mingw/bin/llama-cli.exe -m models/bitnet_b1_58-large/ggml-model-tl2.gguf -p "Your prompt here" -n 50 -t 10
```

### Example Commands

**Simple text generation:**
```bash
./build_mingw/bin/llama-cli.exe -m models/bitnet_b1_58-large/ggml-model-tl2.gguf -p "The Department of Veterans Affairs" -n 100
```

**Question answering:**
```bash
./build_mingw/bin/llama-cli.exe -m models/bitnet_b1_58-large/ggml-model-tl2.gguf -p "Q: What is the VA? A:" -n 200
```

**Run as a server** (for API access):
```bash
./build_mingw/bin/llama-server.exe -m models/bitnet_b1_58-large/ggml-model-tl2.gguf --host 127.0.0.1 --port 8080
```

---

## Common Parameters

- `-m` = Model file to use
- `-p` = Your prompt (put in quotes)
- `-n` = Number of tokens to generate (default: 128)
- `-t` = Number of CPU threads to use (default: 4, max: your CPU cores)
- `-c` = Context size (default: 2048)
- `--temp` = Creativity (0.1 = focused, 1.0 = creative, default: 0.8)

---

## Tools Used

All tools are **portable** (no installation required) and stored in the `tools/` folder:

1. **MinGW-w64 GCC 14.2.0** - C++ compiler for Windows
   - Location: `tools/mingw64/`
   - Used to compile BitNet from source

2. **CMake 3.30.0** - Build system
   - Location: `tools/cmake-3.30.0-windows-x86_64/`
   - Configures and manages the build process

3. **Python 3.10+** - Already on your system
   - Used for model conversion scripts

---

## File Structure

```
VAbitnet/
├── models/
│   └── bitnet_b1_58-large/
│       ├── model.safetensors      (2.7 GB - original model)
│       └── ggml-model-tl2.gguf    (343 MB - converted model)
├── build_mingw/
│   └── bin/
│       ├── llama-cli.exe          (Main inference tool)
│       ├── llama-server.exe       (API server)
│       └── ...                    (33 other tools)
├── tools/
│   ├── mingw64/                   (Portable GCC compiler)
│   └── cmake-3.30.0-windows-x86_64/  (Portable CMake)
├── .venv/                         (Python virtual environment)
└── build_silent.sh                (Build script)
```

---

## Performance

On a typical VA laptop (Intel i7-1265U):
- **Prompt processing:** ~40 tokens/second
- **Text generation:** ~3-4 tokens/second
- **Memory usage:** ~600 MB RAM
- **Model size on disk:** 343 MB

---

## Troubleshooting

### "Missing DLL" Error
Make sure MinGW bin is in your PATH:
```bash
export PATH="/c/Users/$USERNAME/OneDrive - Department of Veterans Affairs/Documents/GitHub/VAbitnet/tools/mingw64/bin:$PATH"
```

### Build Failed
Check the log file:
```bash
tail -50 build_output.log
```

### Model Not Found
Verify the model file exists:
```bash
ls -lh models/bitnet_b1_58-large/ggml-model-tl2.gguf
```

### Slow Performance
Reduce threads or tokens:
```bash
./build_mingw/bin/llama-cli.exe -m models/bitnet_b1_58-large/ggml-model-tl2.gguf -p "Test" -n 20 -t 4
```

---

## Network Notes

**VA network considerations:**
- GitHub downloads work fine
- HuggingFace direct downloads may be blocked (use Git LFS instead)
- SSL certificate warnings are normal (VA network inspection)
- If Git LFS fails, try: `git config http.sslVerify false` (in the model repo only)

---

## What BitNet Does

BitNet uses **1.58-bit quantization** to make AI models incredibly small and efficient:
- Traditional models: 16-bit or 8-bit precision
- BitNet models: 1.58-bit precision (just -1, 0, or +1)
- Result: 8-10x smaller, 3-5x faster, same quality

Perfect for running AI on regular laptops without GPUs.

---

## Credits

- **BitNet framework:** Microsoft Research
- **llama.cpp:** ggerganov
- **Model:** 1bitLLM/bitnet_b1_58-large from HuggingFace
- **VA Implementation:** cyber3pxVA

---

## License

See LICENSE file for details.
