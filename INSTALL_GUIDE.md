# VA Workstation Installation Guide

## For Non-Technical Users - Super Simple!

### What You Need
- Windows 10 or 11 (your VA laptop)
- Internet connection (just for initial setup)
- 10 minutes

---

## Installation Steps (Just 3 Clicks!)

### Step 1: Get Python (One-Time Setup)
If you don't have Python installed:

1. Go to: https://www.python.org/downloads/
2. Click the big yellow "Download Python" button
3. Run the installer
4. **IMPORTANT**: Check the box that says "Add Python to PATH"
5. Click "Install Now"
6. Wait for it to finish

### Step 2: Get the Application
1. Download this entire folder to your computer
2. Put it somewhere easy to find (like `C:\VAbitnetUI`)

### Step 3: Install Everything
1. Open the `VAbitnetUI` folder
2. **Double-click `INSTALL.bat`**
3. Press any key when it asks
4. Wait (this takes 5-10 minutes)
5. Done!

---

## Running the Application

**Every time you want to use it:**
1. Double-click `RUN_APP.bat`
2. That's it!

---

## Testing Your Installation

Want to make sure it installed correctly?
1. Double-click `TEST.bat`
2. If you see "All Tests Passed ✓" you're good!

---

## What If Something Goes Wrong?

### "Python is not installed"
- Go back to Step 1 above
- Make sure you checked "Add Python to PATH"

### "Could not install required packages"
- Check your internet connection
- Try running `INSTALL.bat` again

### "Virtual environment not found"
- You need to run `INSTALL.bat` first
- Don't run `RUN_APP.bat` until installation is complete

### Application won't start
1. Run `TEST.bat` to see what's broken
2. Try running `INSTALL.bat` again
3. Restart your computer and try again

---

## Files You'll See

- **INSTALL.bat** - Click this ONCE to set everything up
- **RUN_APP.bat** - Click this EVERY TIME to run the app
- **TEST.bat** - Click this to check if installation worked
- **venv/** - This folder appears after installation (don't touch it!)

---

## Transferring to Another VA Workstation

Want to install this on another computer?

### Method 1: Fresh Install (Recommended)
1. Copy the entire `VAbitnetUI` folder to the new computer
2. Delete the `venv` folder if it exists
3. Run `INSTALL.bat` on the new computer

### Method 2: Package Everything
1. On working computer, copy the entire folder including `venv`
2. Put it on a USB drive
3. Copy to new computer
4. Just run `RUN_APP.bat` (no install needed!)

**Note**: Method 2 only works if both computers have the same Python version!

---

## For IT Staff: Technical Details

### What INSTALL.bat Does
1. Checks Python installation
2. Creates isolated venv: `python -m venv venv`
3. Activates venv: `venv\Scripts\activate.bat`
4. Updates pip: `python -m pip install --upgrade pip`
5. Installs dependencies: `pip install -r requirements.txt`
6. Downloads VOSK model: `python src/core/download_vosk.py`

### Security & Compliance
- All packages installed in isolated venv (no system-wide changes)
- No admin rights required
- No registry modifications
- No system PATH changes
- Completely portable - can be deleted without cleanup

### Requirements
- Python 3.10+
- ~500MB disk space
- Internet for initial download only
- Works offline after installation

### Troubleshooting Commands
```cmd
# Check Python version
python --version

# Check if venv is activated (should show venv path)
where python

# Manual venv activation
venv\Scripts\activate.bat

# Test imports
python -c "import PyQt6; print('PyQt6 OK')"
```

---

## Quick Reference

| File | Purpose | When to Use |
|------|---------|-------------|
| `INSTALL.bat` | Setup everything | Once per computer |
| `RUN_APP.bat` | Start application | Every time |
| `TEST.bat` | Verify installation | After INSTALL.bat |
| `requirements.txt` | Package list | (automatic) |
| `venv/` | Python environment | (automatic) |

---

## Still Need Help?

1. Run `TEST.bat` and screenshot any errors
2. Check the terminal output for error messages
3. Contact your IT support with the screenshots

---

## Uninstalling

To completely remove:
1. Just delete the entire `VAbitnetUI` folder
2. That's it! Nothing else to clean up.

The venv keeps everything isolated, so deleting the folder removes everything.
