"""
VOSK Model Downloader
Downloads and extracts VOSK speech recognition model for offline use.
"""

import os
import sys
import urllib.request
import zipfile
from pathlib import Path

VOSK_MODEL_URL = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip"
VOSK_MODEL_NAME = "vosk-model-small-en-us-0.15"

def download_file(url, destination):
    """Download file with progress indicator."""
    print(f"Downloading from: {url}")
    print(f"Saving to: {destination}")
    
    def reporthook(block_num, block_size, total_size):
        if total_size > 0:
            percent = min(block_num * block_size * 100 / total_size, 100)
            downloaded = min(block_num * block_size, total_size)
            downloaded_mb = downloaded / (1024 * 1024)
            total_mb = total_size / (1024 * 1024)
            print(f"\rProgress: {percent:.1f}% ({downloaded_mb:.1f}/{total_mb:.1f} MB)", end='')
    
    try:
        urllib.request.urlretrieve(url, destination, reporthook)
        print("\n✓ Download complete!")
        return True
    except Exception as e:
        print(f"\n✗ Download failed: {e}")
        return False

def extract_zip(zip_path, extract_to):
    """Extract ZIP file."""
    print(f"\nExtracting to: {extract_to}")
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
        print("✓ Extraction complete!")
        return True
    except Exception as e:
        print(f"✗ Extraction failed: {e}")
        return False

def main():
    # Determine root directory
    script_dir = Path(__file__).parent
    root_dir = script_dir.parent.parent
    models_dir = root_dir / "models"
    
    print("=" * 50)
    print("VOSK Model Downloader for VAbitnetUI")
    print("=" * 50)
    print(f"\nRoot directory: {root_dir}")
    print(f"Models directory: {models_dir}")
    
    # Create models directory if it doesn't exist
    models_dir.mkdir(exist_ok=True)
    print(f"✓ Models directory ready")
    
    # Check if model already exists
    model_path = models_dir / VOSK_MODEL_NAME
    if model_path.exists() and model_path.is_dir():
        print(f"\n⚠ VOSK model already exists at: {model_path}")
        response = input("Re-download? (y/N): ").strip().lower()
        if response not in ['y', 'yes']:
            print("✓ Using existing model")
            return 0
        # Remove existing model
        import shutil
        shutil.rmtree(model_path)
        print("Removed existing model")
    
    # Download model
    zip_path = models_dir / f"{VOSK_MODEL_NAME}.zip"
    print(f"\nDownloading VOSK model...")
    print(f"Model: {VOSK_MODEL_NAME}")
    print(f"Size: ~40 MB")
    
    if not download_file(VOSK_MODEL_URL, zip_path):
        print("\n✗ Failed to download model")
        return 1
    
    # Extract model
    if not extract_zip(zip_path, models_dir):
        print("\n✗ Failed to extract model")
        return 1
    
    # Verify extraction
    if not model_path.exists():
        print(f"\n✗ Model directory not found after extraction: {model_path}")
        return 1
    
    # Check for required files
    required_files = ['am', 'conf', 'graph']
    missing_files = [f for f in required_files if not (model_path / f).exists()]
    
    if missing_files:
        print(f"\n✗ Model incomplete. Missing: {', '.join(missing_files)}")
        return 1
    
    # Clean up ZIP file
    try:
        zip_path.unlink()
        print(f"\n✓ Cleaned up ZIP file")
    except Exception as e:
        print(f"\n⚠ Could not remove ZIP file: {e}")
    
    print("\n" + "=" * 50)
    print("✓ VOSK model successfully installed!")
    print("=" * 50)
    print(f"\nModel location: {model_path}")
    print(f"Ready for offline speech recognition")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
