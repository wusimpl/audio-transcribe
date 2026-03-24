---
name: audio-transcribe
description: "Transcribe audio messages and voice notes to text using local whisper-cli. Choose the correct command by operating system: use Bash on macOS/Linux, PowerShell on Windows, and Git Bash only when PowerShell is unavailable."
---

# Audio Transcription Skill

Use the installed local tools to convert audio files into plain text.

## Choose By OS

### macOS / Linux

Use Bash:

```bash
./transcribe.sh <audio-file-path> [language]
```

Examples:

```bash
./transcribe.sh /path/to/voice.ogg zh
./transcribe.sh /path/to/audio.mp3 en
```

### Windows

Prefer PowerShell:

```powershell
.\transcribe.ps1 -File "C:\path\to\audio.ogg" -Language "zh"
```

Example:

```powershell
.\transcribe.ps1 -File "C:\Users\name\Downloads\voice.mp3" -Language "en"
```

If the environment is Git Bash and PowerShell is not being used, use:

```bash
./transcribe.sh /c/path/to/audio.ogg zh
```

## Decision Rules

- On **macOS**: use `./transcribe.sh`
- On **Linux**: use `./transcribe.sh`
- On **Windows PowerShell**: use `.\transcribe.ps1`
- On **Windows Git Bash**: use `./transcribe.sh` with `/c/...` style paths
- If a Windows path contains spaces, always quote it
- Do not use the Bash command on Windows PowerShell

## Configuration

Default settings can be overridden with environment variables:

- `WHISPER_MODEL`: model path
- `LANGUAGE`: default language code
- `TEMP_DIR`: temporary directory

Examples:

```bash
LANGUAGE=en ./transcribe.sh audio.ogg
WHISPER_MODEL=/path/to/model.bin ./transcribe.sh audio.ogg
```

```powershell
$env:LANGUAGE = 'en'; .\transcribe.ps1 -File 'audio.ogg'
$env:WHISPER_MODEL = 'C:\models\model.bin'; .\transcribe.ps1 -File 'audio.ogg'
```

## Requirements

Make sure these are already installed before calling the skill:

- `whisper-cli` or `whisper-cli.exe` in PATH
- `ffmpeg` or `ffmpeg.exe` in PATH
- Whisper model file exists

## Error Handling

The script fails with a clear error if:

- input file does not exist
- `whisper-cli` is missing
- model file is missing
- `ffmpeg` is missing when conversion is needed
- transcription returns empty

## Output

Successful execution returns plain transcript text only.
