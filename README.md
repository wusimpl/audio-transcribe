# Audio Transcribe

基于 whisper.cpp 的本地语音转文字工具，支持自动格式转换。

## 功能

- 🎙️ 本地语音识别，保护隐私
- 🔄 自动音频格式转换（OGG/Opus/MP3/M4A 等 → WAV）
- 🌐 多语言支持（默认中文）
- ⚡ 轻量快速

## 安装

### 依赖

1. **whisper.cpp** - 语音识别引擎
   ```bash
   # macOS
   brew install whisper-cpp
   
   # 或从源码编译
   git clone https://github.com/ggerganov/whisper.cpp.git
   cd whisper.cpp
   make
   cp main /usr/local/bin/whisper-cli
   ```

2. **ffmpeg** - 音频格式转换
   ```bash
   # macOS
   brew install ffmpeg
   
   # Ubuntu/Debian
   sudo apt-get install ffmpeg
   ```

3. **模型文件**
   
   下载 whisper 模型（推荐 large-v3-turbo）：
   ```bash
   mkdir -p ~/.openclaw/models
   curl -L -o ~/.openclaw/models/ggml-large-v3-turbo.bin \
     https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
   ```

## 使用

```bash
./transcribe.sh <音频文件> [语言代码]
```

示例：
```bash
# 中文语音（默认）
./transcribe.sh voice.ogg

# 英文语音
./transcribe.sh meeting.mp3 en

# 日文语音
./transcribe.sh podcast.m4a ja
```

## 配置

通过环境变量自定义：

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `WHISPER_MODEL` | 模型文件路径 | `~/.openclaw/models/ggml-large-v3-turbo.bin` |
| `LANGUAGE` | 默认语言 | `zh` |
| `TEMP_DIR` | 临时文件目录 | `/tmp` |

示例：
```bash
LANGUAGE=en ./transcribe.sh audio.ogg
WHISPER_MODEL=/path/to/model.bin ./transcribe.sh audio.ogg
```

## 支持格式

- **直接支持**: WAV (16kHz mono PCM)
- **自动转换**: OGG/Opus, MP3, M4A, AAC, FLAC 等（任何 ffmpeg 支持的格式）

## 语言代码

常用语言代码：
- `zh` - 中文
- `en` - 英文
- `ja` - 日文
- `ko` - 韩文
- `es` - 西班牙文
- `fr` - 法文
- `de` - 德文

## 许可证

MIT
