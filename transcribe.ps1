# Audio Transcription Script for Windows PowerShell
# Requires: whisper-cli.exe and ffmpeg.exe in PATH

param(
    [Parameter(Mandatory=$true, HelpMessage="Path to audio file")]
    [string]$File,
    
    [Parameter(HelpMessage="Language code (default: zh)")]
    [string]$Language = "zh",
    
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\transcribe.ps1 -File <audio-file> [-Language <lang>]"
    Write-Host "Example: .\transcribe.ps1 -File voice.ogg -Language zh"
    exit 0
}

# Configuration
$whisperModel = if ($env:WHISPER_MODEL) { $env:WHISPER_MODEL } else { "$env:USERPROFILE\.openclaw\models\ggml-large-v3-turbo.bin" }
$tempDir = if ($env:TEMP_DIR) { $env:TEMP_DIR } else { $env:TEMP }

# Check if file exists
if (-not (Test-Path $File)) {
    Write-Error "Input file not found: $File"
    exit 1
}

# Check if whisper-cli is available
$whisperCli = Get-Command whisper-cli -ErrorAction SilentlyContinue
if (-not $whisperCli) {
    # Try whisper-cli.exe
    $whisperCli = Get-Command whisper-cli.exe -ErrorAction SilentlyContinue
    if (-not $whisperCli) {
        Write-Error "whisper-cli not found in PATH. Please install whisper.cpp."
        exit 1
    }
}

# Check if model file exists
if (-not (Test-Path $whisperModel)) {
    Write-Error "Whisper model not found: $whisperModel"
    exit 1
}

# Get file extension
$fileExt = [System.IO.Path]::GetExtension($File).ToLower().TrimStart('.')

# Convert to WAV if needed
if ($fileExt -eq "wav") {
    $audioFile = $File
    $cleanup = $false
} else {
    # Check ffmpeg
    $ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if (-not $ffmpeg) {
        $ffmpeg = Get-Command ffmpeg.exe -ErrorAction SilentlyContinue
        if (-not $ffmpeg) {
            Write-Error "ffmpeg not found. Required for converting $fileExt to WAV."
            exit 1
        }
    }
    
    # Generate temp WAV file
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $tempWav = Join-Path $tempDir "whisper-$fileName.wav"
    
    # Convert to 16kHz mono WAV
    & ffmpeg -i $File -ar 16000 -ac 1 -c:a pcm_s16le $tempWav -y 2>$null
    
    if (-not (Test-Path $tempWav)) {
        Write-Error "Failed to convert audio to WAV format."
        exit 1
    }
    
    $audioFile = $tempWav
    $cleanup = $true
}

# Run whisper-cli and capture output
$output = & whisper-cli --model $whisperModel --language $Language $audioFile 2>$null

# Extract transcript (remove timestamps)
$transcript = $output | ForEach-Object {
    if ($_ -match '^\[.*\]\s*(.+)$') {
        $matches[1]
    }
} | Where-Object { $_ } | Join-String -Separator " "

# Cleanup temp file
if ($cleanup -and (Test-Path $tempWav)) {
    Remove-Item $tempWav -Force
}

# Output transcript
if ($transcript) {
    Write-Output $transcript
    exit 0
} else {
    Write-Error "Transcription failed or returned empty result."
    exit 1
}
