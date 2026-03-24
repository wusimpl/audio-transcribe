#!/bin/bash
# Audio transcription script using whisper-cli
# Handles OGG/Opus to WAV conversion automatically
# Cross-platform: macOS, Linux, Windows (Git Bash/WSL)

set -e

# Detect OS and set platform-specific defaults
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    # Windows (Git Bash)
    PLATFORM="windows"
    DEFAULT_MODEL="$USERPROFILE/.openclaw/models/ggml-large-v3-turbo.bin"
    DEFAULT_TEMP="$TEMP"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    DEFAULT_MODEL="$HOME/.openclaw/models/ggml-large-v3-turbo.bin"
    DEFAULT_TEMP="/tmp"
else
    # macOS and others
    PLATFORM="macos"
    DEFAULT_MODEL="$HOME/.openclaw/models/ggml-large-v3-turbo.bin"
    DEFAULT_TEMP="/tmp"
fi

# Configuration
WHISPER_MODEL="${WHISPER_MODEL:-$DEFAULT_MODEL}"
LANGUAGE="${LANGUAGE:-zh}"
TEMP_DIR="${TEMP_DIR:-$DEFAULT_TEMP}"

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <audio-file> [language]" >&2
    echo "Example: $0 voice.ogg zh" >&2
    exit 1
fi

INPUT_FILE="$1"
LANG="${2:-$LANGUAGE}"

# Convert Windows path to Unix path if needed (for Git Bash)
if [[ "$PLATFORM" == "windows" && "$INPUT_FILE" =~ ^[A-Za-z]: ]]; then
    # Convert C:\path\to\file to /c/path/to/file
    INPUT_FILE=$(echo "$INPUT_FILE" | sed 's/\\/\//g' | sed 's/^\([A-Za-z]\):\/\//\1\//')
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found: $INPUT_FILE" >&2
    exit 1
fi

# Check if whisper-cli is available
if ! command -v whisper-cli &> /dev/null; then
    echo "Error: whisper-cli not found in PATH" >&2
    echo "Please install whisper.cpp first" >&2
    exit 1
fi

# Check if model file exists
if [ ! -f "$WHISPER_MODEL" ]; then
    echo "Error: Whisper model not found: $WHISPER_MODEL" >&2
    exit 1
fi

# Detect file format
FILE_EXT="${INPUT_FILE##*.}"
FILE_EXT_LOWER=$(echo "$FILE_EXT" | tr '[:upper:]' '[:lower:]')

# Convert to WAV if needed
if [ "$FILE_EXT_LOWER" = "wav" ]; then
    # Already WAV, use directly
    AUDIO_FILE="$INPUT_FILE"
    CLEANUP=false
else
    # Need conversion
    if ! command -v ffmpeg &> /dev/null; then
        echo "Error: ffmpeg not found. Required for converting $FILE_EXT_LOWER to WAV" >&2
        exit 1
    fi
    
    # Generate temp WAV file
    TEMP_WAV="$TEMP_DIR/whisper-$(basename "$INPUT_FILE" .$FILE_EXT_LOWER).wav"
    
    # Convert to 16kHz mono WAV (whisper-cli requirement)
    ffmpeg -i "$INPUT_FILE" -ar 16000 -ac 1 -c:a pcm_s16le "$TEMP_WAV" -y 2>/dev/null
    
    AUDIO_FILE="$TEMP_WAV"
    CLEANUP=true
fi

# Run whisper-cli and extract transcript
# Output format: [00:00:00.000 --> 00:00:02.220]  这是一条语音测试
TRANSCRIPT=$(whisper-cli --model "$WHISPER_MODEL" --language "$LANG" "$AUDIO_FILE" 2>/dev/null | \
    grep -E '^\[' | \
    sed 's/^\[[^]]*\] *//' | \
    tr '\n' ' ' | \
    sed 's/  */ /g' | \
    sed 's/^ *//;s/ *$//')

# Cleanup temp file if created
if [ "$CLEANUP" = true ] && [ -f "$TEMP_WAV" ]; then
    rm -f "$TEMP_WAV"
fi

# Output transcript
if [ -n "$TRANSCRIPT" ]; then
    echo "$TRANSCRIPT"
    exit 0
else
    echo "Error: Transcription failed or returned empty result" >&2
    exit 1
fi
