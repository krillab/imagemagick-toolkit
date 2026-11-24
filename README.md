# ImageMagick Toolkit

适用于 Codex、WorkBuddy 等 AI 工具的 ImageMagick 技能，支持安装指导、用法答疑，以及图片转换、缩放、裁剪、压缩、拼接、水印和批量处理。

附带 Windows x64 运行程序，其他系统需安装 ImageMagick 7。

## 安装

### 复制指令给 AI

将下面这段话发送给 Codex、WorkBuddy 或支持安装 Skill 的工具：

```text
请从 https://github.com/krillab/imagemagick-toolkit 安装 imagemagick-toolkit 技能，保留完整文件，安装到当前工具的技能目录。
```

### 命令行安装

已安装 Node.js 22.20+ 时，在终端执行，并按提示选择目标工具：

```sh
npx skills add krillab/imagemagick-toolkit
```

### 下载导入

[下载 ZIP](https://github.com/krillab/imagemagick-toolkit/archive/refs/heads/main.zip)，解压后将完整文件夹重命名为 `imagemagick-toolkit`。

- **Codex**：将文件夹放入 `~/.agents/skills/`；Windows 对应 `%USERPROFILE%\.agents\skills\`。
- **WorkBuddy**：将该文件夹重新压缩为 ZIP，在“技能 → 添加技能 → 上传技能”中导入。

安装与运行问题见 [安装指引](references/installation.md) 和 [故障排查](references/troubleshooting.md)。

## 使用示例

安装后，直接在对话中描述需求：

- “使用 imagemagick-toolkit，把这批 JPG 转成 WebP，保留原图。”
- “把图片调整为 800×600，完整保留内容，空白补白色。”
- “给图片加中文水印，放在右下角。”

更多操作见 [使用说明](references/usage.md)。

## 开源许可

原创技能说明和脚本采用 [MIT License](LICENSE)。ImageMagick 及第三方组件遵循各自许可，详见 [第三方声明](THIRD_PARTY_NOTICES.md)。

## 交流与关注

如果这个技能对你有帮助，欢迎点个 Star，也欢迎扫码关注我的公众号，一起交流 AI 工具与技能实践。

<img src="assets/wechat-qrcode.jpg" alt="微信公众号二维码" width="240" />
