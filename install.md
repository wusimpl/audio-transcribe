# Audio Transcribe 安装说明

这份文件是给 agent 执行的，不是给人类介绍项目的。

你的任务不是总结，而是完成安装、放置 skill、做验证，然后明确汇报结果。

## 目标

安装完成后，环境里应当具备这些东西：

- `whisper-cli` 或 `whisper-cli.exe`
- `ffmpeg` 或 `ffmpeg.exe`
- 模型文件 `~/.openclaw/models/ggml-large-v3-turbo.bin`
- 这个 skill 已经放进 agent 自己会扫描的 skill 目录
- skill 目录里只放当前系统实际需要的脚本和 `SKILL.md`

## 执行要求

安装时不要闷头连续调用工具。

你必须带着人类一步一步汇报，按下面要求执行：

- 开始前先告诉人类，接下来会做哪几步
- 每个大步骤开始前，用一句简单的话说明现在要做什么
- 每个大步骤完成后，明确告诉人类结果是否正常
- 如果发现缺少依赖，要直接说缺什么
- 下载模型前，要提前提醒这一步可能比较慢
- 修改 `PATH` 前，要提前提醒人类后面可能需要重开终端
- 如果需要把文件放到 skill 目录，要明确告诉人类目标目录
- 遇到失败时，不要只贴原始输出，要直接说失败点
- 全部结束后，要明确告诉人类是否已经安装完成

推荐按这个顺序执行：

1. 先确认 skill 目录放置位置
2. 再检查 `whisper-cli` 和 `ffmpeg`
3. 再检查或下载模型
4. 再把 skill 文件放到正确目录
5. 再验证脚本是否能正常调用
6. 最后给出完成结论

## 第一步：确认 skill 目录

优先按 OpenClaw / 龙虾 的默认目录处理：

- macOS / Linux：`~/.openclaw/skills/audio-transcribe/`
- Windows：`~/.openclaw/skills/audio-transcribe/`

如果当前 agent 使用的是别的 skill 根目录，就改用 agent 实际扫描的目录。

最终目标目录都应当是：

- `<skill-root>/audio-transcribe/`

## 第二步：放置 skill 文件

根据系统，只放实际需要的文件。

### macOS / Linux

目标目录示例：

```text
~/.openclaw/skills/audio-transcribe/
├── SKILL.md
└── transcribe.sh
```

可执行示例：

```bash
mkdir -p ~/.openclaw/skills/audio-transcribe
cp SKILL.md transcribe.sh ~/.openclaw/skills/audio-transcribe/
chmod +x ~/.openclaw/skills/audio-transcribe/transcribe.sh
```

### Windows

目标目录示例：

```text
~/.openclaw/skills/audio-transcribe/
├── SKILL.md
└── transcribe.ps1
```

可执行示例：

```powershell
New-Item -ItemType Directory -Force ~/.openclaw/skills/audio-transcribe | Out-Null
Copy-Item SKILL.md, transcribe.ps1 ~/.openclaw/skills/audio-transcribe/
```

注意：

- 不要把当前系统不会用到的脚本也一起塞进去
- macOS / Linux 放 `transcribe.sh`
- Windows 放 `transcribe.ps1`

## 第三步：检查依赖

先检查这些命令是否已经存在：

- `whisper-cli` / `whisper-cli.exe`
- `ffmpeg` / `ffmpeg.exe`

### macOS / Linux

先检查：

```bash
command -v whisper-cli || echo "需要安装 whisper.cpp"
command -v ffmpeg || echo "需要安装 ffmpeg"
```

如果缺失，就安装对应依赖。安装方式按当前系统环境选择，只要最后命令能直接调用即可。

### Windows

优先使用仓库里的安装脚本：

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows.ps1
```

如果安装脚本没有成功，再明确告诉人类失败点，并说明下一步怎么补救。

## 第四步：检查或下载模型

模型目标位置：

- `~/.openclaw/models/ggml-large-v3-turbo.bin`

下载前必须先提醒人类：这一步可能比较慢。

### macOS / Linux

```bash
MODEL_DIR="$HOME/.openclaw/models"
MODEL_FILE="$MODEL_DIR/ggml-large-v3-turbo.bin"
if [ ! -f "$MODEL_FILE" ]; then
    mkdir -p "$MODEL_DIR"
    curl -L -o "$MODEL_FILE" \
      "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
fi
```

### Windows

如果用了 `install-windows.ps1`，它会处理模型下载。

如果模型还不存在，就确保文件最终出现在：

```text
%USERPROFILE%\.openclaw\models\ggml-large-v3-turbo.bin
```

## 第五步：实际验证

不要只看文件在不在，要真的跑一次。

在 skill 目录内执行。

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
- 失败时直接说清楚原因
- 不要在没有验证的情况下说“安装完成”

如果手头没有真实音频文件，也至少要检查：

- 脚本存在
- 路径正确
- 依赖命令可调用
- 模型文件存在
- 调用方式与当前系统匹配

## 按系统选择正确脚本

- macOS：使用 `./transcribe.sh`
- Linux：使用 `./transcribe.sh`
- Windows PowerShell：使用 `.\transcribe.ps1`
- Windows Git Bash：只有在不能用 PowerShell 时，才考虑 `./transcribe.sh`

## 失败时怎么汇报

不要只贴命令输出。

要直接告诉人类：

- 失败发生在哪一步
- 缺的是哪个依赖或哪个文件
- 是否已经放好了 skill
- 是否已经完成安装
- 接下来需要人类做什么

## 完成标准

只有同时满足下面这些条件，才可以说安装完成：

- 依赖已经就绪
- 模型文件已经就绪
- skill 已放进正确目录
- 当前系统对应的脚本已放好
- 已完成一次实际验证，或者至少完成了可靠的就地检查
- 已明确把最终结果告诉人类
