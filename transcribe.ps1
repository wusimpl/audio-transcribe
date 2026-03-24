# Audio Transcription Script for Windows PowerShell
# Requires: whisper-cli.exe and ffmpeg.exe in PATH

param(
    [Parameter(Mandatory=$true, HelpMessage='Path to audio file')]
    [string]$File,

    [Parameter(HelpMessage='Language code (default: zh)')]
    [string]$Language = 'zh',

    [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Host 'Usage: .\transcribe.ps1 -File <audio-file> [-Language <lang>]'
    Write-Host 'Example: .\transcribe.ps1 -File voice.ogg -Language zh'
    exit 0
}

$whisperModel = if ($env:WHISPER_MODEL) { $env:WHISPER_MODEL } else { "$env:USERPROFILE\.openclaw\models\ggml-large-v3-turbo.bin" }
$tempDir = if ($env:TEMP_DIR) { $env:TEMP_DIR } else { $env:TEMP }

if (-not (Test-Path $File)) {
    Write-Error "Input file not found: $File"
    exit 1
}

$whisperCli = Get-Command whisper-cli -ErrorAction SilentlyContinue
if (-not $whisperCli) {
    $whisperCli = Get-Command whisper-cli.exe -ErrorAction SilentlyContinue
    if (-not $whisperCli) {
        Write-Error 'whisper-cli not found in PATH. Please install whisper.cpp.'
        exit 1
    }
}

if (-not (Test-Path $whisperModel)) {
    Write-Error "Whisper model not found: $whisperModel"
    exit 1
}

$fileExt = [System.IO.Path]::GetExtension($File).ToLower().TrimStart('.')

if ($fileExt -eq 'wav') {
    $audioFile = $File
    $cleanup = $false
} else {
    $ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if (-not $ffmpeg) {
        $ffmpeg = Get-Command ffmpeg.exe -ErrorAction SilentlyContinue
        if (-not $ffmpeg) {
            Write-Error "ffmpeg not found. Required for converting $fileExt to WAV."
            exit 1
        }
    }

    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $tempWav = Join-Path $tempDir ("whisper-{0}-{1}.wav" -f $fileName, [guid]::NewGuid().ToString('N'))

    & $ffmpeg.Source -i $File -ar 16000 -ac 1 -c:a pcm_s16le $tempWav -y 2>$null

    if (-not (Test-Path $tempWav)) {
        Write-Error 'Failed to convert audio to WAV format.'
        exit 1
    }

    $audioFile = $tempWav
    $cleanup = $true
}

$output = & $whisperCli.Source --model $whisperModel --language $Language $audioFile 2>$null

$transcriptLines = @()
foreach ($line in $output) {
    if ($line -match '^\[.*\]\s*(.+)$') {
        $transcriptLines += $matches[1]
    }
}
$transcript = ($transcriptLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join ' '

if ($cleanup -and (Test-Path $tempWav)) {
    Remove-Item $tempWav -Force
}

if (-not [string]::IsNullOrWhiteSpace($transcript)) {
    Write-Output $transcript.Trim()
    exit 0
}

Write-Error 'Transcription failed or returned empty result.'
exit 1
