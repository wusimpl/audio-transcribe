#!/bin/bash
# Audio transcription script using whisper-cli
# Handles OGG/Opus to WAV conversion automatically
# Cross-platform: macOS, Linux, Windows (Git Bash/WSL)

set -e

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    PLATFORM="windows"
    DEFAULT_MODEL="$USERPROFILE/.openclaw/models/ggml-large-v3-turbo.bin"
    DEFAULT_TEMP="${TEMP:-/tmp}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    DEFAULT_MODEL="$HOME/.openclaw/models/ggml-large-v3-turbo.bin"
    DEFAULT_TEMP="/tmp"
else
    PLATFORM="macos"
    DEFAULT_MODEL="$HOME/.openclaw/models/ggml-large-v3-turbo.bin"
    DEFAULT_TEMP="/tmp"
fi

WHISPER_MODEL="${WHISPER_MODEL:-$DEFAULT_MODEL}"
LANGUAGE="${LANGUAGE:-zh}"
TEMP_DIR="${TEMP_DIR:-$DEFAULT_TEMP}"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <audio-file> [language]" >&2
    echo "Example: $0 voice.ogg zh" >&2
    exit 1
fi

INPUT_FILE="$1"
LANG="${2:-$LANGUAGE}"

if [[ "$PLATFORM" == "windows" && "$INPUT_FILE" =~ ^[A-Za-z]:\\ ]]; then
    INPUT_FILE=$(printf '%s' "$INPUT_FILE" | sed 's#\\#/#g' | sed 's#^\([A-Za-z]\):#/'"'"'\L\1'"'"'#')
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found: $INPUT_FILE" >&2
    exit 1
fi

if ! command -v whisper-cli >/dev/null 2>&1; then
    echo "Error: whisper-cli not found in PATH" >&2
    echo "Please install whisper.cpp first" >&2
    exit 1
fi

if [ ! -f "$WHISPER_MODEL" ]; then
    echo "Error: Whisper model not found: $WHISPER_MODEL" >&2
    exit 1
fi

FILE_EXT="${INPUT_FILE##*.}"
FILE_EXT_LOWER=$(echo "$FILE_EXT" | tr '[:upper:]' '[:lower:]')

if [ "$FILE_EXT_LOWER" = "wav" ]; then
    AUDIO_FILE="$INPUT_FILE"
    CLEANUP=false
else
    if ! command -v ffmpeg >/dev/null 2>&1; then
        echo "Error: ffmpeg not found. Required for converting $FILE_EXT_LOWER to WAV" >&2
        exit 1
    fi

    TEMP_WAV="$TEMP_DIR/whisper-$(basename "$INPUT_FILE" ".${FILE_EXT}")-$$.wav"
    ffmpeg -i "$INPUT_FILE" -ar 16000 -ac 1 -c:a pcm_s16le "$TEMP_WAV" -y 2>/dev/null
    AUDIO_FILE="$TEMP_WAV"
    CLEANUP=true
fi

TRANSCRIPT=$(whisper-cli --model "$WHISPER_MODEL" --language "$LANG" "$AUDIO_FILE" 2>/dev/null | \
    grep -E '^\[' | \
    sed 's/^\[[^]]*\] *//' | \
    tr '\n' ' ' | \
    sed 's/  */ /g' | \
    sed 's/^ *//;s/ *$//')

if [ "$CLEANUP" = true ] && [ -f "$TEMP_WAV" ]; then
    rm -f "$TEMP_WAV"
fi

if [ -n "$TRANSCRIPT" ]; then
    echo "$TRANSCRIPT"
    exit 0
fi

echo "Error: Transcription failed or returned empty result" >&2
exit 1
