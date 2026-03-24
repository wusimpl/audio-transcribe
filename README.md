# Audio Transcribe - Agent 安装指南

> ⚠️ **这是给 Agent 读的文档。人类不需要读，把仓库链接扔给 Agent 就好。**
> 
> 时代变了。安装软件只需一个 prompt。

---

## 一句话描述
基于 whisper.cpp 的本地语音转文字工具，支持自动格式转换。跨平台：macOS、Linux、Windows。

## Agent 安装流程

### macOS / Linux

```bash
# 1. 克隆仓库
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

# 2. 检查依赖
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

### Windows (Git Bash)

```bash
# 1. 克隆仓库
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

# 2. 安装依赖（如果未安装）
# whisper-cli: 下载 whisper.cpp Windows 构建版并添加到 PATH
# ffmpeg: 下载 Windows 构建版并添加到 PATH

# 3. 确保模型文件存在
MODEL_DIR="$USERPROFILE/.openclaw/models"
MODEL_FILE="$MODEL_DIR/ggml-large-v3-turbo.bin"
if [ ! -f "$MODEL_FILE" ]; then
    mkdir -p "$MODEL_DIR"
    curl -L -o "$MODEL_FILE" \
      "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
fi

# 4. 验证安装
./transcribe.sh --help 2>/dev/null || head -20 transcribe.sh
```

### Windows (PowerShell)

```powershell
# 1. 克隆仓库
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

# 2. 使用 PowerShell 脚本安装依赖和模型
.\install-windows.ps1

# 3. 验证安装
.\transcribe.ps1 -Help
```

## 测试验证

```bash
# 运行转录测试
./transcribe.sh <音频文件路径> [语言代码]

# Windows PowerShell 示例
.\transcribe.ps1 -File "C:\path\to\voice.ogg" -Language "zh"

# 预期输出：纯文本转录结果，无时间戳
```

## 配置（可选）

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `WHISPER_MODEL` | `~/.openclaw/models/ggml-large-v3-turbo.bin` | 模型路径 |
| `LANGUAGE` | `zh` | 默认语言 |
| `TEMP_DIR` | `/tmp` (macOS/Linux)<br>`$TEMP` (Windows) | 临时目录 |

## 依赖清单

| 平台 | whisper-cli | ffmpeg |
|------|-------------|--------|
| macOS | `brew install whisper-cpp` | `brew install ffmpeg` |
| Linux | 编译安装 | `apt install ffmpeg` |
| Windows | 下载 exe 添加到 PATH | 下载 exe 添加到 PATH |

## 故障排除

| 错误 | 解决方案 |
|------|---------|
| "whisper-cli not found" | 安装 whisper.cpp 并添加到 PATH |
| "ffmpeg not found" | 安装 ffmpeg 并添加到 PATH |
| "Model file not found" | 执行模型下载步骤 |
| "Input file not found" (Windows) | 使用双反斜杠或引号包裹路径 |
| 转录失败 | 检查音频文件格式是否支持 |

## 仓库
https://github.com/wusimpl/audio-transcribe
