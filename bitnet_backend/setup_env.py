#!/usr/bin/env python3
"""
BitNet Environment Setup Script
Builds the BitNet inference engine and prepares models for deployment
"""

import os
import sys
import argparse
import subprocess
import shutil
import platform
from pathlib import Path
import urllib.request
import json

# Model configurations
MODEL_CONFIGS = {
    "1bitLLM/bitnet_b1_58-large": {
        "local_path": "models/bitnet_b1_58-large",
        "gguf_file": "ggml-model-i2_s.gguf",
        "description": "BitNet 1.58-bit 2.4B parameter model"
    },
    "1bitLLM/bitnet_b1_58-3B": {
        "local_path": "models/bitnet_b1_58-3B", 
        "gguf_file": "ggml-model-i2_s.gguf",
        "description": "BitNet 1.58-bit 3B parameter model"
    }
}

QUANT_TYPES = ["i2_s", "tl1"]

def print_colored(message, color="white"):
    """Print colored output for better visibility"""
    colors = {
        "red": "\033[91m",
        "green": "\033[92m", 
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "cyan": "\033[96m",
        "white": "\033[97m",
        "reset": "\033[0m"
    }
    
    if platform.system() == "Windows":
        # Windows console may not support colors
        print(f"[{color.upper()}] {message}")
    else:
        print(f"{colors.get(color, colors['white'])}{message}{colors['reset']}")

def run_command(cmd, cwd=None, check=True, capture_output=False):
    """Run shell command with proper error handling"""
    print_colored(f"Running: {' '.join(cmd) if isinstance(cmd, list) else cmd}", "cyan")
    
    try:
        if isinstance(cmd, str):
            result = subprocess.run(cmd, shell=True, cwd=cwd, check=check, 
                                  capture_output=capture_output, text=True)
        else:
            result = subprocess.run(cmd, cwd=cwd, check=check,
                                  capture_output=capture_output, text=True)
        
        if capture_output:
            return result.stdout.strip()
        return result.returncode == 0
    except subprocess.CalledProcessError as e:
        print_colored(f"Command failed: {e}", "red")
        if capture_output and e.stdout:
            print_colored(f"Output: {e.stdout}", "yellow")
        if capture_output and e.stderr:
            print_colored(f"Error: {e.stderr}", "red")
        if check:
            raise
        return False

def check_dependencies():
    """Check for required build dependencies"""
    print_colored("Checking build dependencies...", "blue")
    
    dependencies = {
        "cmake": ["cmake", "--version"],
        "git": ["git", "--version"],
        "python": ["python", "--version"]
    }
    
    missing = []
    for name, cmd in dependencies.items():
        try:
            version = run_command(cmd, capture_output=True)
            print_colored(f"✓ {name}: {version.split()[0] if version else 'found'}", "green")
        except:
            missing.append(name)
            print_colored(f"✗ {name}: not found", "red")
    
    if missing:
        print_colored(f"Missing dependencies: {', '.join(missing)}", "red")
        print_colored("Please install missing dependencies and run again", "yellow")
        return False
    
    return True

def detect_compiler():
    """Detect available C++ compiler"""
    compilers = [
        ("clang++", ["clang++", "--version"]),
        ("g++", ["g++", "--version"]),
        ("cl", ["cl"])  # MSVC
    ]
    
    for name, cmd in compilers:
        try:
            run_command(cmd, capture_output=True)
            print_colored(f"✓ Using compiler: {name}", "green")
            return name
        except:
            continue
    
    print_colored("No C++ compiler found!", "red")
    return None

def create_build_directory(build_dir="build"):
    """Create and prepare build directory"""
    build_path = Path(build_dir)
    
    if build_path.exists():
        print_colored(f"Removing existing build directory: {build_path}", "yellow")
        shutil.rmtree(build_path)
    
    build_path.mkdir(parents=True)
    print_colored(f"Created build directory: {build_path}", "green")
    return build_path

def configure_cmake(build_dir, model_dir, quant_type):
    """Configure CMake build"""
    print_colored("Configuring CMake...", "blue")
    
    cmake_args = [
        "cmake",
        "..",
        "-DCMAKE_BUILD_TYPE=Release"
    ]
    
    # Add quantization type flags
    if quant_type == "i2_s":
        cmake_args.append("-DBITNET_X86_TL2=ON")
    elif quant_type == "tl1":
        cmake_args.append("-DBITNET_ARM_TL1=ON")
    
    # Platform-specific configurations
    if platform.system() == "Windows":
        cmake_args.extend([
            "-G", "Visual Studio 17 2022",
            "-A", "x64"
        ])
    
    return run_command(cmake_args, cwd=build_dir)

def build_project(build_dir, jobs=None):
    """Build the project"""
    print_colored("Building BitNet inference engine...", "blue")
    
    if jobs is None:
        jobs = os.cpu_count() or 4
    
    build_args = [
        "cmake",
        "--build", ".",
        "--config", "Release",
        "--parallel", str(jobs)
    ]
    
    return run_command(build_args, cwd=build_dir)

def verify_model_files(model_dir, quant_type):
    """Verify model files exist"""
    model_path = Path(model_dir)
    
    if not model_path.exists():
        print_colored(f"Model directory not found: {model_path}", "red")
        return False
    
    # Look for GGUF file
    gguf_files = list(model_path.glob("*.gguf"))
    if not gguf_files:
        print_colored(f"No GGUF model files found in {model_path}", "red")
        return False
    
    for gguf_file in gguf_files:
        size_mb = gguf_file.stat().st_size / (1024 * 1024)
        print_colored(f"✓ Model file: {gguf_file.name} ({size_mb:.1f} MB)", "green")
    
    return True

def create_server_executable(build_dir):
    """Create or find the server executable"""
    # Look for built executables
    possible_names = ["bitnet-server", "bitnet-server.exe", "server", "server.exe"]
    
    for name in possible_names:
        exe_path = Path(build_dir) / "bin" / name
        if exe_path.exists():
            print_colored(f"✓ Server executable: {exe_path}", "green")
            return exe_path
    
    # If not found, assume build created it somewhere
    print_colored("Server executable will be available after build", "yellow")
    return None

def main():
    parser = argparse.ArgumentParser(description="BitNet Environment Setup")
    parser.add_argument("-md", "--model-dir", 
                       default="models/bitnet_b1_58-large",
                       help="Model directory path")
    parser.add_argument("-q", "--quant-type",
                       choices=QUANT_TYPES,
                       default="i2_s", 
                       help="Quantization type")
    parser.add_argument("--hf-repo",
                       choices=list(MODEL_CONFIGS.keys()),
                       default="1bitLLM/bitnet_b1_58-large",
                       help="HuggingFace repository (for reference)")
    parser.add_argument("--log-dir",
                       default="logs",
                       help="Log directory")
    parser.add_argument("--quant-embd", 
                       action="store_true",
                       help="Enable embedding quantization")
    parser.add_argument("--build-dir",
                       default="build",
                       help="Build directory")
    parser.add_argument("-j", "--jobs",
                       type=int,
                       default=None,
                       help="Number of build jobs")
    
    args = parser.parse_args()
    
    print_colored("BitNet Environment Setup Starting...", "cyan")
    print_colored(f"Model directory: {args.model_dir}", "white")
    print_colored(f"Quantization type: {args.quant_type}", "white")
    print_colored(f"Build directory: {args.build_dir}", "white")
    
    # Create log directory
    Path(args.log_dir).mkdir(exist_ok=True)
    
    try:
        # Step 1: Check dependencies
        if not check_dependencies():
            sys.exit(1)
        
        # Step 2: Check compiler
        compiler = detect_compiler()
        if not compiler:
            sys.exit(1)
        
        # Step 3: Verify model files
        if not verify_model_files(args.model_dir, args.quant_type):
            print_colored("Model files not ready - this is expected for fresh installs", "yellow")
            print_colored("Model files should be available via Git LFS", "yellow")
        
        # Step 4: Create build directory
        build_dir = create_build_directory(args.build_dir)
        
        # Step 5: Configure CMake
        if not configure_cmake(build_dir, args.model_dir, args.quant_type):
            print_colored("CMake configuration failed", "red")
            sys.exit(1)
        
        # Step 6: Build project
        if not build_project(build_dir, args.jobs):
            print_colored("Build failed", "red")
            sys.exit(1)
        
        # Step 7: Verify results
        create_server_executable(build_dir)
        
        print_colored("BitNet setup completed successfully!", "green")
        print_colored(f"Build artifacts in: {build_dir}", "cyan")
        print_colored(f"Logs in: {args.log_dir}", "cyan")
        
    except KeyboardInterrupt:
        print_colored("Setup interrupted by user", "yellow")
        sys.exit(1)
    except Exception as e:
        print_colored(f"Setup failed with error: {e}", "red")
        sys.exit(1)

if __name__ == "__main__":
    main()