# Audio Transcribe

这是一个本地语音转文字 skill。

它适合交给 agent 安装和接入，不适合把完整安装说明直接塞进 `README.md`。

## 你该怎么用

把下面这段话直接发给你的 agent：

```text
请先克隆这个仓库：https://github.com/wusimpl/audio-transcribe.git

如果本地已经有这个仓库，就先进入仓库目录并拉取最新内容。

然后进入仓库目录，读取 `install.md`，严格按里面的步骤安装这个工具和 skill，不要跳步骤，不要自己猜。

要求：
1. 先确认你的 skill 安装目录
2. 再检查并安装需要的依赖
3. 再检查或下载模型
4. 再把这个 skill 放到正确目录
5. 再做一次实际验证
6. 最后明确告诉我是否已经安装完成；如果失败，直接说卡在哪一步

安装过程中，请每做一大步就告诉我你现在在做什么、结果是否正常。
```

如果 agent 没按要求做，就再补一句：

```text
不要只读 README，请先克隆仓库，进入仓库目录，再读取并执行 `install.md`。
```

## 这东西会装什么

安装完成后，环境里应该有这些东西：

- `whisper-cli` 或 `whisper-cli.exe`
- `ffmpeg` 或 `ffmpeg.exe`
- 模型文件 `~/.openclaw/models/ggml-large-v3-turbo.bin`
- 正确放到 skill 目录里的 `audio-transcribe`

## 提醒

- 下载模型可能比较慢
