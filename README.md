# Audio Transcribe - Agent 安装指南

给安装部署 Agent 用的说明文档。

## 一句话描述
基于 whisper.cpp 的本地语音转文字工具，支持自动格式转换。可在 macOS、Linux、Windows 上使用。

## 安装目标
安装完成后，环境里应当具备这些东西：

- `whisper-cli` 或 `whisper-cli.exe`
- `ffmpeg` 或 `ffmpeg.exe`
- 模型文件 `~/.openclaw/models/ggml-large-v3-turbo.bin`
- 这个 skill 被放进 Agent 自己的 skill 目录
- skill 目录里只放 `SKILL.md` 和当前系统实际要用的脚本

## 安装时的人类提示要求

安装这个 skill 时，不要一上来连续调用工具而不解释。要把安装过程当成“带着人类一步一步完成”。

请遵守这些要求：

- 开始前先告诉人类，接下来会做哪几步
- 每个大步骤开始前，先用一句简单的话说明现在要做什么
- 每个大步骤完成后，告诉人类结果是否正常
- 如果发现缺少依赖，要明确告诉人类缺的是什么
- 下载模型前，要提前提醒这一步可能比较慢
- 修改 PATH 前，要提前提醒人类后面可能需要重开终端
- 如果需要把文件放到 skill 目录，要明确告诉人类目标目录
- 遇到失败时，不要只贴原始输出，要直接说明失败点
- 全部结束后，要明确告诉人类“是否已经安装完成”

推荐按下面这种节奏汇报：

1. 先确认 skill 目录放置位置
2. 再检查 `whisper-cli` 和 `ffmpeg`
3. 再检查或下载模型
4. 再验证脚本是否能正常调用
5. 最后给出完成结论

## 推荐目录结构

以 OpenClaw / 龙虾 这类本地 skill 目录为例，可参考这种结构：

```text
macOS / Linux:
~/.openclaw/skills/audio-transcribe/
├── SKILL.md
└── transcribe.sh

Windows:
~/.openclaw/skills/audio-transcribe/
├── SKILL.md
└── transcribe.ps1
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
cp SKILL.md transcribe.sh ~/.openclaw/skills/audio-transcribe/
```

Windows 示例：

```powershell
New-Item -ItemType Directory -Force ~/.openclaw/skills/audio-transcribe
Copy-Item SKILL.md, transcribe.ps1 ~/.openclaw/skills/audio-transcribe/
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

### Windows PowerShell

建议在普通目录先完成依赖安装，再把 `SKILL.md` 和 `transcribe.ps1` 放入 skill 目录。

```powershell
# 安装 whisper-cli 和 ffmpeg，并确保它们已加入 PATH
# 下载模型到 $HOME\.openclaw\models\ggml-large-v3-turbo.bin
```

说明：
- 支持 Windows PowerShell 5.1 和 PowerShell 7+
- 如果安装过程中更新了 PATH，重新打开终端最稳妥
- Windows 运行时只需要 `SKILL.md` 和 `transcribe.ps1`

## 安装后验证

请在 skill 目录内执行。

### macOS / Linux

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
- skill 目录里只放当前系统真正会执行的脚本
- macOS / Linux 使用 `./transcribe.sh`
- Windows 使用 `.\transcribe.ps1`

## 常见问题

| 问题 | 处理方式 |
|------|----------|
| Agent 找不到这个 skill | 确认 `SKILL.md` 已放进 Agent 实际扫描的 skill 目录 |
| `whisper-cli not found` | 安装 whisper.cpp 并加入 PATH |
| `ffmpeg not found` | 安装 ffmpeg 并加入 PATH |
| `Model file not found` | 下载模型到 `~/.openclaw/models/` |
| Windows 路径带空格 | 用引号包住完整路径 |

## 说明

- `README.md` 负责告诉安装 Agent 怎么部署这个 skill
- `SKILL.md` 负责告诉运行中的 Agent 怎么调用这个 skill
