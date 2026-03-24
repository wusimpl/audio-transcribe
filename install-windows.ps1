# Windows Installation Script for Audio Transcribe
# Run this in PowerShell

param(
    [switch]$SkipModelDownload
)

# Fix encoding for Windows PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "Audio Transcribe - Windows Setup" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "Note: Not running as Administrator. Some operations may fail." -ForegroundColor Yellow
}

# Create directories
$installDir = "$env:USERPROFILE\tools"
$modelDir = "$env:USERPROFILE\.openclaw\models"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
New-Item -ItemType Directory -Force -Path $modelDir | Out-Null

Write-Host "Install directory: $installDir" -ForegroundColor Gray
Write-Host "Model directory: $modelDir" -ForegroundColor Gray
Write-Host ""

# Function to add to PATH
function Add-ToPath {
    param([string]$dir)
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$dir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$dir", "User")
        Write-Host "Added $dir to PATH (restart terminal to apply)" -ForegroundColor Green
    } else {
        Write-Host "$dir already in PATH" -ForegroundColor Green
    }
}

# Check/Download whisper-cli
Write-Host "Checking whisper-cli..." -ForegroundColor Yellow
$whisperCli = Get-Command whisper-cli.exe -ErrorAction SilentlyContinue
if (-not $whisperCli) {
    Write-Host "Downloading whisper-cli..." -ForegroundColor Cyan
    
    # Try multiple URLs
    $urls = @(
        "https://github.com/ggerganov/whisper.cpp/releases/download/v1.7.4/whisper-blas-bin-x64.zip",
        "https://github.com/ggerganov/whisper.cpp/releases/download/v1.7.3/whisper-blas-bin-x64.zip",
        "https://github.com/ggerganov/whisper.cpp/releases/download/v1.7.2/whisper-blas-bin-x64.zip"
    )
    
    $downloaded = $false
    foreach ($url in $urls) {
        $zipFile = "$env:TEMP\whisper_$(Get-Random).zip"
        try {
            Write-Host "Trying $url..." -ForegroundColor Gray
            Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing -TimeoutSec 120
            
            if (Test-Path $zipFile) {
                Expand-Archive -Path $zipFile -DestinationPath "$installDir\whisper" -Force
                Remove-Item $zipFile
                Add-ToPath "$installDir\whisper"
                Write-Host "whisper-cli installed to $installDir\whisper" -ForegroundColor Green
                $downloaded = $true
                break
            }
        } catch {
            Write-Host "Failed to download from $url : $_" -ForegroundColor Red
            if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
        }
    }
    
    if (-not $downloaded) {
        Write-Error "Failed to download whisper-cli. Please install manually from: https://github.com/ggerganov/whisper.cpp/releases"
        exit 1
    }
} else {
    Write-Host "whisper-cli found: $($whisperCli.Source)" -ForegroundColor Green
}

Write-Host ""

# Check/Download ffmpeg
Write-Host "Checking ffmpeg..." -ForegroundColor Yellow
$ffmpeg = Get-Command ffmpeg.exe -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
    Write-Host "Downloading ffmpeg..." -ForegroundColor Cyan
    
    # Use a more reliable mirror
    $ffmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    $zipFile = "$env:TEMP\ffmpeg_$(Get-Random).zip"
    
    try {
        Invoke-WebRequest -Uri $ffmpegUrl -OutFile $zipFile -UseBasicParsing -TimeoutSec 180
        
        if (Test-Path $zipFile) {
            Expand-Archive -Path $zipFile -DestinationPath "$env:TEMP\ffmpeg_extract" -Force
            
            # Find the bin directory
            $ffmpegBin = Get-ChildItem "$env:TEMP\ffmpeg_extract" -Recurse -Filter "ffmpeg.exe" | Select-Object -First 1
            if ($ffmpegBin) {
                $binDir = $ffmpegBin.Directory.FullName
                Copy-Item "$binDir\*" $installDir -Force
                Add-ToPath $installDir
                Write-Host "ffmpeg installed to $installDir" -ForegroundColor Green
            } else {
                Write-Error "Could not find ffmpeg.exe in downloaded archive"
            }
            
            Remove-Item $zipFile -Force
            Remove-Item "$env:TEMP\ffmpeg_extract" -Recurse -Force
        }
    } catch {
        Write-Error "Failed to download ffmpeg: $_"
        Write-Host "Please install manually from: https://ffmpeg.org/download.html" -ForegroundColor Yellow
    }
} else {
    Write-Host "ffmpeg found: $($ffmpeg.Source)" -ForegroundColor Green
}

Write-Host ""

# Download model
if (-not $SkipModelDownload) {
    Write-Host "Checking model file..." -ForegroundColor Yellow
    $modelFile = "$modelDir\ggml-large-v3-turbo.bin"
    if (-not (Test-Path $modelFile)) {
        Write-Host "Downloading whisper model (this may take a while)..." -ForegroundColor Cyan
        
        # Try multiple sources
        $modelUrls = @(
            "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin",
            "https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
        )
        
        $downloaded = $false
        foreach ($url in $modelUrls) {
            try {
                Write-Host "Trying $url..." -ForegroundColor Gray
                Invoke-WebRequest -Uri $url -OutFile $modelFile -UseBasicParsing -TimeoutSec 300
                
                if (Test-Path $modelFile) {
                    Write-Host "Model downloaded to $modelFile" -ForegroundColor Green
                    $downloaded = $true
                    break
                }
            } catch {
                Write-Host "Failed from $url : $_" -ForegroundColor Red
            }
        }
        
        if (-not $downloaded) {
            Write-Error "Failed to download model. Please download manually from: https://huggingface.co/ggerganov/whisper.cpp"
        }
    } else {
        Write-Host "Model file already exists: $modelFile" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  .\transcribe.ps1 -File 'C:\path\to\audio.ogg' -Language zh"
Write-Host ""
Write-Host "Note: You may need to restart your terminal for PATH changes to take effect."
