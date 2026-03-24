---
name: audio-transcribe
description: Transcribe audio messages and voice notes to text using local whisper-cli. Use when receiving audio/voice messages from Telegram, WhatsApp, or other channels that need to be converted to text for processing. Automatically handles OGG/Opus, MP3, M4A, and other audio formats by converting to WAV first.
---

# Audio Transcription Skill

Transcribe audio messages to text using local whisper-cli with automatic format conversion.

## Quick Start

When you receive an audio message that needs transcription:

```bash
scripts/transcribe.sh <audio-file-path> [language]
```

Example:

```bash
scripts/transcribe.sh /path/to/voice.ogg zh
scripts/transcribe.sh /path/to/audio.mp3 en
```

## How It Works

1. **Format Detection**: Checks if the input is already WAV
2. **Conversion**: If not WAV, uses ffmpeg to convert to 16kHz mono WAV
3. **Transcription**: Runs whisper-cli with the configured model
4. **Cleanup**: Removes temporary files
5. **Output**: Returns clean transcript text

## Configuration

The script uses environment variables for configuration:

- `WHISPER_MODEL`: Path to whisper model (default: `~/.openclaw/models/ggml-large-v3-turbo.bin`)
- `LANGUAGE`: Default language code (default: `zh`)
- `TEMP_DIR`: Temporary directory for conversions (default: `/tmp`)

Override when calling:

```bash
LANGUAGE=en scripts/transcribe.sh audio.ogg
WHISPER_MODEL=/path/to/model.bin scripts/transcribe.sh audio.ogg
```

## Supported Formats

- **Direct**: WAV (16kHz mono PCM)
- **Auto-converted**: OGG/Opus, MP3, M4A, AAC, FLAC, and any format ffmpeg supports

## Requirements

- `whisper-cli` in PATH (from whisper.cpp)
- `ffmpeg` in PATH (for format conversion)
- Whisper model file at configured path

## Installation

```bash
# Clone and setup
git clone git@github.com:wusimpl/audio-transcribe.git
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
```

## Error Handling

The script exits with non-zero status and error message on stderr if:

- Input file not found
- whisper-cli not in PATH
- Model file not found
- ffmpeg not available (when conversion needed)
- Transcription fails or returns empty

## Language Codes

Common language codes for `--language` parameter:

- `zh`: Chinese (Mandarin)
- `en`: English
- `ja`: Japanese
- `ko`: Korean
- `es`: Spanish
- `fr`: French
- `de`: German
- `ru`: Russian

For full list, see whisper.cpp documentation.
