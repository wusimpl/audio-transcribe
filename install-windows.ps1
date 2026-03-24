# Windows Installation Script for Audio Transcribe
# Run this in PowerShell

param(
    [switch]$SkipModelDownload
)

$ErrorActionPreference = 'Stop'

# Fix encoding for Windows PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "Audio Transcribe - Windows Setup" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "Note: Not running as Administrator. User-level install will be used." -ForegroundColor Yellow
}

$installDir = Join-Path $env:USERPROFILE 'tools'
$modelDir = Join-Path $env:USERPROFILE '.openclaw\models'
$whisperInstallDir = Join-Path $installDir 'whisper'

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
New-Item -ItemType Directory -Force -Path $modelDir | Out-Null
New-Item -ItemType Directory -Force -Path $whisperInstallDir | Out-Null

Write-Host "Install directory: $installDir" -ForegroundColor Gray
Write-Host "Model directory: $modelDir" -ForegroundColor Gray
Write-Host ""

function Add-ToPath {
    param([string]$Dir)

    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ([string]::IsNullOrWhiteSpace($currentPath)) {
        $newPath = $Dir
    } elseif (($currentPath -split ';') -contains $Dir) {
        Write-Host "$Dir already in PATH" -ForegroundColor Green
        return
    } else {
        $newPath = "$currentPath;$Dir"
    }

    [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')
    $env:PATH = "$Dir;$env:PATH"
    Write-Host "Added $Dir to PATH" -ForegroundColor Green
}

function Download-File {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$OutFile,
        [int]$TimeoutSec = 180
    )

    Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec $TimeoutSec
    if (-not (Test-Path $OutFile)) {
        throw "Download failed: $Url"
    }
}

function Get-ExistingCommand {
    param([string[]]$Names)

    foreach ($name in $Names) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) {
            return $cmd
        }
    }

    return $null
}

function Install-WhisperCli {
    Write-Host 'Checking whisper-cli...' -ForegroundColor Yellow

    $existing = Get-ExistingCommand -Names @('whisper-cli', 'whisper-cli.exe')
    if ($existing) {
        Write-Host "whisper-cli found: $($existing.Source)" -ForegroundColor Green
        return
    }

    Write-Host 'Downloading whisper-cli...' -ForegroundColor Cyan

    $urls = @(
        'https://github.com/ggml-org/whisper.cpp/releases/download/v1.7.6/whisper-bin-x64.zip',
        'https://github.com/ggml-org/whisper.cpp/releases/download/v1.7.5/whisper-bin-x64.zip',
        'https://github.com/ggml-org/whisper.cpp/releases/download/v1.7.4/whisper-bin-x64.zip',
        'https://github.com/ggerganov/whisper.cpp/releases/download/v1.7.4/whisper-blas-bin-x64.zip'
    )

    foreach ($url in $urls) {
        $zipFile = Join-Path $env:TEMP ("whisper_{0}.zip" -f ([guid]::NewGuid().ToString('N')))
        $extractDir = Join-Path $env:TEMP ("whisper_extract_{0}" -f ([guid]::NewGuid().ToString('N')))

        try {
            Write-Host "Trying $url..." -ForegroundColor Gray
            Download-File -Url $url -OutFile $zipFile -TimeoutSec 180
            Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force

            $whisperExe = Get-ChildItem $extractDir -Recurse -Filter 'whisper-cli.exe' | Select-Object -First 1
            if (-not $whisperExe) {
                throw 'whisper-cli.exe not found in archive'
            }

            Copy-Item (Join-Path $whisperExe.Directory.FullName '*') $whisperInstallDir -Recurse -Force
            Add-ToPath $whisperInstallDir
            Write-Host "whisper-cli installed to $whisperInstallDir" -ForegroundColor Green
            return
        } catch {
            Write-Host "Failed from $url : $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            if (Test-Path $zipFile) { Remove-Item $zipFile -Force -ErrorAction SilentlyContinue }
            if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue }
        }
    }

    throw 'Failed to download whisper-cli. Please install manually from the whisper.cpp releases page.'
}

function Install-Ffmpeg {
    Write-Host 'Checking ffmpeg...' -ForegroundColor Yellow

    $existing = Get-ExistingCommand -Names @('ffmpeg', 'ffmpeg.exe')
    if ($existing) {
        Write-Host "ffmpeg found: $($existing.Source)" -ForegroundColor Green
        return
    }

    Write-Host 'Downloading ffmpeg...' -ForegroundColor Cyan

    $ffmpegUrl = 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip'
    $zipFile = Join-Path $env:TEMP ("ffmpeg_{0}.zip" -f ([guid]::NewGuid().ToString('N')))
    $extractDir = Join-Path $env:TEMP ("ffmpeg_extract_{0}" -f ([guid]::NewGuid().ToString('N')))

    try {
        Download-File -Url $ffmpegUrl -OutFile $zipFile -TimeoutSec 240
        Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force

        $ffmpegExe = Get-ChildItem $extractDir -Recurse -Filter 'ffmpeg.exe' | Select-Object -First 1
        if (-not $ffmpegExe) {
            throw 'ffmpeg.exe not found in archive'
        }

        Copy-Item (Join-Path $ffmpegExe.Directory.FullName '*') $installDir -Force
        Add-ToPath $installDir
        Write-Host "ffmpeg installed to $installDir" -ForegroundColor Green
    } finally {
        if (Test-Path $zipFile) { Remove-Item $zipFile -Force -ErrorAction SilentlyContinue }
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Install-Model {
    if ($SkipModelDownload) {
        return
    }

    Write-Host 'Checking model file...' -ForegroundColor Yellow
    $modelFile = Join-Path $modelDir 'ggml-large-v3-turbo.bin'
    if (Test-Path $modelFile) {
        Write-Host "Model file already exists: $modelFile" -ForegroundColor Green
        return
    }

    Write-Host 'Downloading whisper model (this may take a while)...' -ForegroundColor Cyan

    $modelUrls = @(
        'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin',
        'https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin'
    )

    foreach ($url in $modelUrls) {
        try {
            Write-Host "Trying $url..." -ForegroundColor Gray
            Download-File -Url $url -OutFile $modelFile -TimeoutSec 600
            Write-Host "Model downloaded to $modelFile" -ForegroundColor Green
            return
        } catch {
            Write-Host "Failed from $url : $($_.Exception.Message)" -ForegroundColor Red
            if (Test-Path $modelFile) { Remove-Item $modelFile -Force -ErrorAction SilentlyContinue }
        }
    }

    throw 'Failed to download model. Please download it manually from the whisper.cpp model repository.'
}

Install-WhisperCli
Write-Host ''
Install-Ffmpeg
Write-Host ''
Install-Model
Write-Host ''
Write-Host 'Setup complete!' -ForegroundColor Green
Write-Host ''
Write-Host 'Usage:' -ForegroundColor Cyan
Write-Host "  .\transcribe.ps1 -File 'C:\path\to\audio.ogg' -Language zh"
Write-Host ''
Write-Host 'If PATH was updated, a new terminal window will also pick it up automatically.'
