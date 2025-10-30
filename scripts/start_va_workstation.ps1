# VAbitnetUI Startup Script for VA Workstations (Windows)
# This script starts both the BitNet backend server and the GUI application

param(
    [switch]$ServerOnly = $false,
    [switch]$GuiOnly = $false,
    [switch]$Verbose = $false,
    [int]$Port = 8081
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Header { param($msg) Write-Host "`n========================================" -ForegroundColor Magenta; Write-Host $msg -ForegroundColor Magenta; Write-Host "========================================`n" -ForegroundColor Magenta }

Write-Header "VAbitnetUI - Starting Application"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

Write-Info "Application directory: $RootDir"
Write-Info "Starting mode: $(if ($ServerOnly) { 'Server Only' } elseif ($GuiOnly) { 'GUI Only' } else { 'Full Application' })"

# Check if virtual environment exists
if (-not (Test-Path "$RootDir\venv")) {
    Write-Error "Virtual environment not found!"
    Write-Warning "Please run setup first: .\scripts\setup_va_workstation.ps1"
    exit 1
}

# Activate virtual environment
Write-Info "Activating Python virtual environment..."
& "$RootDir\venv\Scripts\Activate.ps1"

# Load .env file if it exists
if (Test-Path "$RootDir\.env") {
    Write-Info "Loading configuration from .env file..."
    Get-Content "$RootDir\.env" | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            if ($name -and -not $name.StartsWith('#')) {
                [Environment]::SetEnvironmentVariable($name, $value, 'Process')
                if ($Verbose) { Write-Info "  $name = $value" }
            }
        }
    }
    Write-Success "Configuration loaded"
}

# Set default environment variables if not set
if (-not $env:BITNET_MODEL_PATH) {
    $env:BITNET_MODEL_PATH = "$RootDir\bitnet_backend\models\BitNet-b1.58-2B-4T\ggml-model-i2_s.gguf"
}
if (-not $env:VOSK_MODEL_PATH) {
    $env:VOSK_MODEL_PATH = "$RootDir\models\vosk-model-small-en-us-0.15"
}
if (-not $env:BITNET_ENDPOINT) {
    $env:BITNET_ENDPOINT = "http://localhost:$Port/completion"
}

# Verify model files exist
Write-Info "Verifying model files..."

if (-not (Test-Path $env:BITNET_MODEL_PATH)) {
    Write-Error "BitNet model not found at: $env:BITNET_MODEL_PATH"
    Write-Warning "Please run setup script to download the model"
    exit 1
}
Write-Success "BitNet model found"

if (-not (Test-Path $env:VOSK_MODEL_PATH)) {
    Write-Error "VOSK model not found at: $env:VOSK_MODEL_PATH"
    Write-Warning "Please run setup script to download the model"
    exit 1
}
Write-Success "VOSK model found"

# Function to check if port is available
function Test-Port {
    param($Port)
    try {
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
        $listener.Start()
        $listener.Stop()
        return $true
    } catch {
        return $false
    }
}

# Function to start BitNet server
function Start-BitNetServer {
    param($Port)
    
    Write-Header "Starting BitNet Server"
    
    # Check if port is available
    if (-not (Test-Port $Port)) {
        Write-Warning "Port $Port is already in use"
        $choice = Read-Host "Kill existing process and restart? (y/N)"
        if ($choice -eq "y" -or $choice -eq "Y") {
            Write-Info "Finding process using port $Port..."
            $netstat = netstat -ano | Select-String ":$Port"
            if ($netstat) {
                $pid = ($netstat -split '\s+')[-1]
                Write-Info "Stopping process $pid..."
                Stop-Process -Id $pid -Force
                Start-Sleep -Seconds 2
            }
        } else {
            Write-Info "Using existing server on port $Port"
            return $null
        }
    }
    
    Set-Location "$RootDir\bitnet_backend"
    
    Write-Info "Starting BitNet inference server on port $Port..."
    Write-Info "Model: $env:BITNET_MODEL_PATH"
    Write-Warning "Please wait 10-30 seconds for model loading..."
    
    # Check if run_server.py exists, otherwise use run_inference.py with server wrapper
    $serverScript = "$RootDir\bitnet_backend\run_server.py"
    
    if (Test-Path $serverScript) {
        $serverProcess = Start-Process -FilePath "python" -ArgumentList "$serverScript -m `"$env:BITNET_MODEL_PATH`" -p $Port" -PassThru -NoNewWindow
    } else {
        # Create a simple HTTP server wrapper
        Write-Info "Creating server wrapper..."
        $wrapperScript = "$RootDir\bitnet_backend\server_wrapper.py"
        
        $wrapperContent = @'
import http.server
import socketserver
import json
import subprocess
import sys
import os

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
MODEL_PATH = os.environ.get('BITNET_MODEL_PATH', '')

class BitNetHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/completion':
            content_length = int(self.headers['Content-Length'])
            body = self.rfile.read(content_length)
            data = json.loads(body.decode('utf-8'))
            
            prompt = data.get('prompt', '')
            n_predict = data.get('n_predict', 512)
            temp = data.get('temperature', 0.7)
            
            # Run inference
            cmd = [
                'python', 'run_inference.py',
                '-m', MODEL_PATH,
                '-p', prompt,
                '-n', str(n_predict),
                '-temp', str(temp)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            response_text = result.stdout.strip()
            
            response = {'content': response_text}
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        print(f"[BitNet Server] {format % args}")

with socketserver.TCPServer(("", PORT), BitNetHandler) as httpd:
    print(f"BitNet server running on port {PORT}")
    httpd.serve_forever()
'@
        
        $wrapperContent | Out-File -FilePath $wrapperScript -Encoding UTF8
        $serverProcess = Start-Process -FilePath "python" -ArgumentList "$wrapperScript $Port" -PassThru -NoNewWindow
    }
    
    Write-Success "BitNet server starting (PID: $($serverProcess.Id))"
    Write-Info "Waiting for server to be ready..."
    
    # Wait for server to be ready
    $maxWait = 60
    $waited = 0
    while ($waited -lt $maxWait) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$Port/completion" -Method POST -Body '{"prompt":"test"}' -ContentType "application/json" -TimeoutSec 2 -UseBasicParsing 2>&1
            Write-Success "Server is ready!"
            break
        } catch {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 2
            $waited += 2
        }
    }
    
    if ($waited -ge $maxWait) {
        Write-Warning "Server may still be loading. Proceeding anyway..."
    }
    
    return $serverProcess
}

# Function to start GUI
function Start-Gui {
    Write-Header "Starting GUI Application"
    
    Set-Location $RootDir
    
    Write-Info "Launching VAbitnetUI..."
    Write-Info "VOSK Model: $env:VOSK_MODEL_PATH"
    Write-Info "BitNet Endpoint: $env:BITNET_ENDPOINT"
    
    python main.py
}

# Main execution flow
try {
    $serverProcess = $null
    
    if (-not $GuiOnly) {
        $serverProcess = Start-BitNetServer -Port $Port
        Set-Location $RootDir
    }
    
    if (-not $ServerOnly) {
        Start-Gui
    } else {
        Write-Info "`nServer is running. Press Ctrl+C to stop."
        while ($true) {
            Start-Sleep -Seconds 1
        }
    }
} catch {
    Write-Error "Error occurred: $_"
    exit 1
} finally {
    # Cleanup
    if ($serverProcess -and -not $serverProcess.HasExited) {
        Write-Info "`nStopping BitNet server..."
        Stop-Process -Id $serverProcess.Id -Force
        Write-Success "Server stopped"
    }
}

Write-Info "`nApplication closed"
