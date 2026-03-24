# Audio Transcribe - Agent 安装指南

给安装部署 Agent 用的说明文档。

## 一句话描述
基于 whisper.cpp 的本地语音转文字工具，支持自动格式转换。可在 macOS、Linux、Windows 上使用。

## 安装目标
安装完成后，环境里应当具备这些东西：

- `whisper-cli` 或 `whisper-cli.exe`
- `ffmpeg` 或 `ffmpeg.exe`
- 模型文件 `~/.openclaw/models/ggml-large-v3-turbo.bin`
- 本仓库里的 `transcribe.sh` 和 `transcribe.ps1`

## 安装流程

### macOS / Linux

```bash
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

command -v whisper-cli || echo "需要安装 whisper.cpp"
command -v ffmpeg || echo "需要安装 ffmpeg"

MODEL_DIR="$HOME/.openclaw/models"
MODEL_FILE="$MODEL_DIR/ggml-large-v3-turbo.bin"
if [ ! -f "$MODEL_FILE" ]; then
    mkdir -p "$MODEL_DIR"
    curl -L -o "$MODEL_FILE" \
      "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
fi
```

### Windows PowerShell（推荐）

```powershell
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe
powershell -ExecutionPolicy Bypass -File .\install-windows.ps1
```

说明：
- 支持 Windows PowerShell 5.1 和 PowerShell 7+
- 如果安装过程中更新了 PATH，重新打开终端最稳妥
- 如果模型已经存在，可加 `-SkipModelDownload`

### Windows Git Bash

```bash
git clone https://github.com/wusimpl/audio-transcribe.git
cd audio-transcribe

# 手动安装 whisper-cli 和 ffmpeg，并加入 PATH

MODEL_DIR="$USERPROFILE/.openclaw/models"
MODEL_FILE="$MODEL_DIR/ggml-large-v3-turbo.bin"
if [ ! -f "$MODEL_FILE" ]; then
    mkdir -p "$MODEL_DIR"
    curl -L -o "$MODEL_FILE" \
      "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
fi
```

## 安装后验证

### macOS / Linux / Git Bash

```bash
./transcribe.sh /path/to/audio.ogg zh
```

### Windows PowerShell

```powershell
.\transcribe.ps1 -File "C:\path\to\audio.ogg" -Language "zh"
```

预期结果：
- 成功时输出纯文本转录结果
- 失败时直接报清楚原因，不应假装安装完成

## 常见问题

| 问题 | 处理方式 |
|------|----------|
| `whisper-cli not found` | 安装 whisper.cpp 并加入 PATH |
| `ffmpeg not found` | 安装 ffmpeg 并加入 PATH |
| `Model file not found` | 下载模型到 `~/.openclaw/models/` |
| Windows 路径带空格 | 用引号包住完整路径 |
| Git Bash 下找不到 `C:\...` 文件 | 改用 `/c/...` 路径，或直接用 PowerShell |

## 说明

- `SKILL.md` 用来告诉 Agent 怎么调用已经装好的工具
- `README.md` 用来告诉 Agent 怎么安装和部署这个 skill
