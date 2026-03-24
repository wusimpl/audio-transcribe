# Windows Installation Script for Audio Transcribe
# Run this in PowerShell as Administrator

param(
    [switch]$SkipModelDownload
)

Write-Host "🎙️  Audio Transcribe - Windows Setup" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "Not running as Administrator. Some operations may fail."
}

# Create directories
$installDir = "$env:USERPROFILE\tools"
$modelDir = "$env:USERPROFILE\.openclaw\models"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
New-Item -ItemType Directory -Force -Path $modelDir | Out-Null

# Function to add to PATH
function Add-ToPath {
    param([string]$dir)
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$dir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$dir", "User")
        Write-Host "✅ Added $dir to PATH (restart terminal to apply)" -ForegroundColor Green
    } else {
        Write-Host "✅ $dir already in PATH" -ForegroundColor Green
    }
}

# Check/Download whisper-cli
Write-Host "Checking whisper-cli..." -ForegroundColor Yellow
$whisperCli = Get-Command whisper-cli.exe -ErrorAction SilentlyContinue
if (-not $whisperCli) {
    Write-Host "📥 Downloading whisper-cli..." -ForegroundColor Cyan
    $whisperUrl = "https://github.com/ggerganov/whisper.cpp/releases/download/v1.7.4/whisper-blas-clblast-bin-x64.zip"
    $zipFile = "$env:TEMP\whisper.zip"
    
    try {
        Invoke-WebRequest -Uri $whisperUrl -OutFile $zipFile -UseBasicParsing
        Expand-Archive -Path $zipFile -DestinationPath "$installDir\whisper" -Force
        Remove-Item $zipFile
        Add-ToPath "$installDir\whisper"
        Write-Host "✅ whisper-cli installed to $installDir\whisper" -ForegroundColor Green
    } catch {
        Write-Error "Failed to download whisper-cli. Please install manually from: https://github.com/ggerganov/whisper.cpp/releases"
    }
} else {
    Write-Host "✅ whisper-cli found: $($whisperCli.Source)" -ForegroundColor Green
}

# Check/Download ffmpeg
Write-Host ""
Write-Host "Checking ffmpeg..." -ForegroundColor Yellow
$ffmpeg = Get-Command ffmpeg.exe -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
    Write-Host "📥 Downloading ffmpeg..." -ForegroundColor Cyan
    $ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    $zipFile = "$env:TEMP\ffmpeg.zip"
    
    try {
        Invoke-WebRequest -Uri $ffmpegUrl -OutFile $zipFile -UseBasicParsing
        Expand-Archive -Path $zipFile -DestinationPath "$env:TEMP\ffmpeg" -Force
        $ffmpegDir = Get-ChildItem "$env:TEMP\ffmpeg" -Directory | Select-Object -First 1
        Copy-Item "$($ffmpegDir.FullName)\bin\*" $installDir -Recurse -Force
        Remove-Item $zipFile
        Remove-Item "$env:TEMP\ffmpeg" -Recurse -Force
        Add-ToPath $installDir
        Write-Host "✅ ffmpeg installed to $installDir" -ForegroundColor Green
    } catch {
        Write-Error "Failed to download ffmpeg. Please install manually from: https://ffmpeg.org/download.html"
    }
} else {
    Write-Host "✅ ffmpeg found: $($ffmpeg.Source)" -ForegroundColor Green
}

# Download model
if (-not $SkipModelDownload) {
    Write-Host ""
    Write-Host "Checking model file..." -ForegroundColor Yellow
    $modelFile = "$modelDir\ggml-large-v3-turbo.bin"
    if (-not (Test-Path $modelFile)) {
        Write-Host "📥 Downloading whisper model (this may take a while)..." -ForegroundColor Cyan
        $modelUrl = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
        try {
            Invoke-WebRequest -Uri $modelUrl -OutFile $modelFile -UseBasicParsing
            Write-Host "✅ Model downloaded to $modelFile" -ForegroundColor Green
        } catch {
            Write-Error "Failed to download model. Please download manually from: $modelUrl"
        }
    } else {
        Write-Host "✅ Model file already exists: $modelFile" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  .\transcribe.ps1 -File `"C:\path\to\audio.ogg`" -Language zh"
Write-Host ""
Write-Host "Note: You may need to restart your terminal for PATH changes to take effect."
