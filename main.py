"""
Application entry point.
Lean orchestration - configuration and initialization only.
"""

import sys
from pathlib import Path

from PyQt6.QtWidgets import QApplication, QMessageBox

from src.core.config import Config
from src.ui import MainWindow
from src.core.download_vosk import download_file, extract_zip, VOSK_MODEL_URL, VOSK_MODEL_NAME


def ensure_vosk_model() -> bool:
    """
    Check if VOSK model exists, download if missing.
    Returns True if model is ready, False on failure.
    """
    root_dir = Path(__file__).parent
    models_dir = root_dir / "models"
    model_path = models_dir / VOSK_MODEL_NAME
    
    # Check if model already exists
    if model_path.exists() and model_path.is_dir():
        required_files = ['am', 'conf', 'graph']
        if all((model_path / f).exists() for f in required_files):
            return True
    
    # Model missing or incomplete - download it
    print(f"\n{'='*50}")
    print("VOSK model not found - downloading...")
    print(f"{'='*50}")
    
    models_dir.mkdir(exist_ok=True)
    zip_path = models_dir / f"{VOSK_MODEL_NAME}.zip"
    
    # Download
    if not download_file(VOSK_MODEL_URL, zip_path):
        return False
    
    # Extract
    if not extract_zip(zip_path, models_dir):
        return False
    
    # Verify
    if not model_path.exists():
        return False
    
    # Clean up
    try:
        zip_path.unlink()
    except:
        pass
    
    print(f"\n{'='*50}")
    print("✓ VOSK model ready")
    print(f"{'='*50}\n")
    
    return True


def main() -> int:
    """
    Application entry point.
    Returns exit code.
    """
    # Check/download VOSK model before starting GUI
    if not ensure_vosk_model():
        print("\n✗ Failed to download VOSK model")
        print("Please check your internet connection and try again.")
        return 1
    
    # Create Qt application
    app = QApplication(sys.argv)
    app.setApplicationName("VOSK BitNet Scribe")
    app.setOrganizationName("VoskBitnetScribe")
    
    # Load configuration
    config = Config.from_environment()
    
    # Validate configuration
    is_valid, errors = config.validate()
    if not is_valid:
        error_msg = "Configuration errors:\n\n" + "\n".join(f"• {e}" for e in errors)
        QMessageBox.critical(None, "Configuration Error", error_msg)
        return 1
    
    # Create and show main window
    window = MainWindow(config)
    window.show()
    
    # Run application event loop
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
