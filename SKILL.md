---
name: audio-transcribe
description: Transcribe audio messages and voice notes to text using local whisper-cli. Use when receiving audio/voice messages from Telegram, WhatsApp, or other channels that need to be converted to text for processing. Automatically handles OGG/Opus, MP3, M4A, and other audio formats by converting to WAV first. Cross-platform: macOS, Linux, Windows.
---

# Audio Transcription Skill

Transcribe audio messages to text using local whisper-cli with automatic format conversion.

## Platform Support

- ✅ macOS (Bash)
- ✅ Linux (Bash)
- ✅ Windows (Git Bash / PowerShell)

## Quick Start

### macOS / Linux (Bash)

```bash
# Clone and setup
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

# Install dependencies if missing
command -v whisper-cli || echo "Install whisper.cpp first"
command -v ffmpeg || echo "Install ffmpeg first"

# Download model if not exists
MODEL_DIR="$HOME/.openclaw/models"
MODEL_FILE="$MODEL_DIR/ggml-large-v3-turbo.bin"
if [ ! -f "$MODEL_FILE" ]; then
    mkdir -p "$MODEL_DIR"
    curl -L -o "$MODEL_FILE" \
      "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
fi

# Transcribe
./transcribe.sh /path/to/audio.ogg zh
```

### Windows (PowerShell - Recommended)

```powershell
# Clone and setup
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

# Install dependencies and model (requires Administrator)
.\install-windows.ps1

# Transcribe
.\transcribe.ps1 -File "C:\path\to\audio.ogg" -Language "zh"
```

### Windows (Git Bash)

```bash
# Clone and setup
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

# Install whisper-cli and ffmpeg manually, add to PATH
# Then download model
MODEL_DIR="$USERPROFILE/.openclaw/models"
MODEL_FILE="$MODEL_DIR/ggml-large-v3-turbo.bin"
if [ ! -f "$MODEL_FILE" ]; then
    mkdir -p "$MODEL_DIR"
    curl -L -o "$MODEL_FILE" \
      "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
fi

# Transcribe
./transcribe.sh /c/path/to/audio.ogg zh
```

## Usage

### Bash (macOS/Linux/Windows Git Bash)

```bash
./transcribe.sh <audio-file-path> [language-code]
```

Examples:
```bash
./transcribe.sh voice.ogg zh      # Chinese
./transcribe.sh meeting.mp3 en    # English
./transcribe.sh podcast.m4a ja    # Japanese
```

### PowerShell (Windows)

```powershell
.\transcribe.ps1 -File <path> [-Language <code>]
```

Examples:
```powershell
.\transcribe.ps1 -File "voice.ogg" -Language "zh"
.\transcribe.ps1 -File "C:\Users\name\Downloads\meeting.mp3" -Language "en"
```

## How It Works

1. **Format Detection**: Checks if the input is already WAV
2. **Conversion**: If not WAV, uses ffmpeg to convert to 16kHz mono WAV
3. **Transcription**: Runs whisper-cli with the configured model
4. **Cleanup**: Removes temporary files
5. **Output**: Returns clean transcript text

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WHISPER_MODEL` | `~/.openclaw/models/ggml-large-v3-turbo.bin` | Path to model file |
| `LANGUAGE` | `zh` | Default language code |
| `TEMP_DIR` | `/tmp` (Unix)<br>`$TEMP` (Windows) | Temporary directory |

### Override Examples

Bash:
```bash
LANGUAGE=en ./transcribe.sh audio.ogg
WHISPER_MODEL=/path/to/model.bin ./transcribe.sh audio.ogg
```

PowerShell:
```powershell
$env:LANGUAGE = "en"; .\transcribe.ps1 -File "audio.ogg"
$env:WHISPER_MODEL = "C:\models\model.bin"; .\transcribe.ps1 -File "audio.ogg"
```

## Supported Formats

- **Direct**: WAV (16kHz mono PCM)
- **Auto-converted**: OGG/Opus, MP3, M4A, AAC, FLAC, and any format ffmpeg supports

## Requirements

| Platform | Requirements |
|----------|--------------|
| macOS | `whisper-cli`, `ffmpeg` |
| Linux | `whisper-cli`, `ffmpeg` |
| Windows | `whisper-cli.exe`, `ffmpeg.exe` (auto-installed by `install-windows.ps1`) |

### Installing whisper.cpp

**macOS:**
```bash
brew install whisper-cpp
```

**Linux:**
```bash
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
make
sudo cp main /usr/local/bin/whisper-cli
```

**Windows:**
Download from [releases](https://github.com/ggerganov/whisper.cpp/releases) and add to PATH, or run `install-windows.ps1` which auto-downloads.

## Error Handling

The script exits with non-zero status and error message on stderr if:

- Input file not found
- whisper-cli not in PATH
- Model file not found
- ffmpeg not available (when conversion needed)
- Transcription fails or returns empty

## Language Codes

Common language codes:

| Code | Language |
|------|----------|
| `zh` | Chinese (Mandarin) |
| `en` | English |
| `ja` | Japanese |
| `ko` | Korean |
| `es` | Spanish |
| `fr` | French |
| `de` | German |
| `ru` | Russian |

For full list, see whisper.cpp documentation.

## Windows-Specific Notes

1. **PowerShell is recommended** over Git Bash on Windows for better compatibility
2. **install-windows.ps1** auto-downloads whisper-cli, ffmpeg, and the model
3. **PATH changes** require terminal restart to take effect
4. **File paths** with spaces should be quoted: `"C:\My Folder\audio.ogg"`
