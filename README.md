# Audio Transcribe- 安装指南

这是写给Agent的安装文档，当然人类也可以读。

## 一句话描述
基于 whisper.cpp 的本地语音转文字工具，支持自动格式转换。可在 macOS、Linux、Windows 上使用。

## 安装目标
安装完成后，环境里应当具备这些东西：

- `whisper-cli` 或 `whisper-cli.exe`
- `ffmpeg` 或 `ffmpeg.exe`
- 模型文件 `~/.openclaw/models/ggml-large-v3-turbo.bin`
- 这个 skill 被放进 Agent 自己的 skill 目录
- skill 目录里至少包含 `SKILL.md`
- skill 目录里包含实际执行脚本：`transcribe.sh`，Windows 场景还应包含 `transcribe.ps1` 和 `install-windows.ps1`

## 推荐目录结构

以 OpenClaw / 龙虾 这类本地 skill 目录为例，可参考这种结构：

```text
~/.openclaw/skills/audio-transcribe/
├── SKILL.md
├── transcribe.sh
├── transcribe.ps1
└── install-windows.ps1
```

如果你的 Agent 使用的是别的 skill 根目录，也一样处理：
- 新建一个 `audio-transcribe` 目录
- 把本仓库文件放进去
- 确保 Agent 会扫描这个目录

## 安装流程

### 1. 放到 Agent 的 skill 目录

先把仓库内容放到 Agent 能识别的 skill 目录里。

示例：

```bash
mkdir -p ~/.openclaw/skills/audio-transcribe
cp -R ./* ~/.openclaw/skills/audio-transcribe/
```

如果不是 OpenClaw / 龙虾，就把目标路径替换成你的 Agent 实际使用的 skill 目录。

### 2. 安装依赖和模型

### macOS / Linux

```bash
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

先进入 skill 目录，再执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows.ps1
```

说明：
- 支持 Windows PowerShell 5.1 和 PowerShell 7+
- 如果安装过程中更新了 PATH，重新打开终端最稳妥
- 如果模型已经存在，可加 `-SkipModelDownload`

### Windows Git Bash

```bash
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

请在 skill 目录内执行。

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

## Agent 使用要点

- `SKILL.md` 是给 Agent 读的入口说明
- Agent 必须能扫描到这个 skill 所在目录
- macOS / Linux 一般调用 `./transcribe.sh`
- Windows PowerShell 一般调用 `.\transcribe.ps1`
- Windows Git Bash 只有在不用 PowerShell 时再使用 `./transcribe.sh`

## 常见问题

| 问题 | 处理方式 |
|------|----------|
| Agent 找不到这个 skill | 确认 `SKILL.md` 已放进 Agent 实际扫描的 skill 目录 |
| `whisper-cli not found` | 安装 whisper.cpp 并加入 PATH |
| `ffmpeg not found` | 安装 ffmpeg 并加入 PATH |
| `Model file not found` | 下载模型到 `~/.openclaw/models/` |
| Windows 路径带空格 | 用引号包住完整路径 |
| Git Bash 下找不到 `C:\...` 文件 | 改用 `/c/...` 路径，或直接用 PowerShell |

## 说明

- `README.md` 负责告诉安装 Agent 怎么部署这个 skill
- `SKILL.md` 负责告诉运行中的 Agent 怎么调用这个 skill
