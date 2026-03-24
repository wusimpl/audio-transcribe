# Audio Transcribe - Agent 安装指南

> ⚠️ **这是给 Agent 读的文档。人类不需要读，把仓库链接扔给 Agent 就好。**
> 
> 时代变了。安装软件只需一个 prompt。

---

## 一句话描述
基于 whisper.cpp 的本地语音转文字工具，支持自动格式转换。

## Agent 安装流程

```bash
# 1. 克隆仓库
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

# 2. 检查依赖（whisper-cli 和 ffmpeg）
command -v whisper-cli || echo "需要安装 whisper.cpp"
command -v ffmpeg || echo "需要安装 ffmpeg"

# 3. 确保模型文件存在
MODEL_DIR="$HOME/.openclaw/models"
MODEL_FILE="$MODEL_DIR/ggml-large-v3-turbo.bin"
if [ ! -f "$MODEL_FILE" ]; then
    mkdir -p "$MODEL_DIR"
    curl -L -o "$MODEL_FILE" \
      "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
fi

# 4. 验证安装
./transcribe.sh --help 2>/dev/null || head -20 transcribe.sh
```

## 测试验证

```bash
# 创建测试音频（或用现有音频文件）
# 运行转录测试
./transcribe.sh <音频文件路径> [语言代码]

# 预期输出：纯文本转录结果，无时间戳
```

## 配置（可选）

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `WHISPER_MODEL` | `~/.openclaw/models/ggml-large-v3-turbo.bin` | 模型路径 |
| `LANGUAGE` | `zh` | 默认语言 |
| `TEMP_DIR` | `/tmp` | 临时目录 |

## 依赖清单

- `whisper-cli` (whisper.cpp)
- `ffmpeg`
- 模型文件: `ggml-large-v3-turbo.bin`

## 故障排除

- **"whisper-cli not found"** → 安装 whisper.cpp
- **"ffmpeg not found"** → 安装 ffmpeg
- **"Model file not found"** → 执行第 3 步下载模型
- **转录失败** → 检查音频文件是否存在、格式是否支持

## 仓库
https://github.com/wusimpl/audio-transcribe
