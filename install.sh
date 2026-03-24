#!/bin/bash
# 安装脚本 - audio-transcribe

set -e

echo "🎙️  Audio Transcribe 安装脚本"
echo ""

# 检查依赖
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ 未找到: $1"
        return 1
    else
        echo "✅ 已安装: $1"
        return 0
    fi
}

echo "检查依赖..."
check_command whisper-cli || {
    echo ""
    echo "请安装 whisper.cpp:"
    echo "  macOS: brew install whisper-cpp"
    echo "  或从源码编译: https://github.com/ggerganov/whisper.cpp"
    exit 1
}

check_command ffmpeg || {
    echo ""
    echo "请安装 ffmpeg:"
    echo "  macOS: brew install ffmpeg"
    echo "  Ubuntu: sudo apt-get install ffmpeg"
    exit 1
}

echo ""

# 检查/下载模型
MODEL_DIR="${HOME}/.openclaw/models"
MODEL_FILE="${MODEL_DIR}/ggml-large-v3-turbo.bin"

if [ -f "$MODEL_FILE" ]; then
    echo "✅ 模型文件已存在: $MODEL_FILE"
else
    echo "📥 下载模型文件..."
    mkdir -p "$MODEL_DIR"
    
    # 使用 huggingface 镜像加速
    HF_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
    
    if command -v curl &> /dev/null; then
        curl -L --progress-bar -o "$MODEL_FILE" "$HF_URL"
    elif command -v wget &> /dev/null; then
        wget --progress=bar:force -O "$MODEL_FILE" "$HF_URL"
    else
        echo "❌ 需要 curl 或 wget 来下载模型"
        exit 1
    fi
    
    echo "✅ 模型下载完成"
fi

echo ""
echo "🎉 安装完成！"
echo ""
echo "使用方法:"
echo "  ./transcribe.sh <音频文件> [语言]"
echo ""
echo "示例:"
echo "  ./transcribe.sh voice.ogg      # 中文识别"
echo "  ./transcribe.sh meeting.mp3 en # 英文识别"
