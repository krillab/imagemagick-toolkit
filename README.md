# ImageMagick Toolkit

面向 Codex、WorkBuddy 及兼容 Agent Skills 的工具，提供 **ImageMagick 7 的介绍、安装、使用、批量图片处理与故障排查**。

内置 Windows x64 便携版。在对应 Windows 环境中，无需另外安装 ImageMagick，无需 Python、Node 或 MCP，即可执行图片处理。技能不绑定公众号、社交平台或任何固定业务场景。

> 技能名称：`imagemagick-toolkit`  
> 技能介绍：介绍、安装和使用 ImageMagick 7，完成图片转换、缩放、裁剪、压缩、拼接、水印、动画与批量处理；内置 Windows x64 便携版，并提供跨平台安装和故障排查指引。

## 能做什么

| 方向 | 功能 |
| --- | --- |
| 了解工具 | 介绍能力、解释命令与参数顺序、选择处理方法 |
| 安装与准备 | 启用内置便携版、检查可用性、指导系统安装和跨平台配置 |
| 基础操作 | 缩放、裁剪、旋转、翻转、补边、格式转换 |
| 优化与合成 | 压缩、透明通道、ICC/元数据、拼接、文字和图片水印 |
| 批量与动画 | 目录批处理、帧处理、输出验证、失败记录 |
| 排查问题 | 路径、格式支持、字体、依赖、策略和资源限制 |

ImageMagick 按明确规则处理图片；生成式补画、语义移除人物等需求需要其他工具。

## 平台与验证范围

| 环境 | 运行方式 | 当前验证状态 |
| --- | --- | --- |
| Windows x64 + PowerShell 7 | 内置 7.1.2-35 Q16-HDRI | 本机实际命令与图片处理验证 |
| Windows x64 + PowerShell 5.1 | 同一内置版与 PS 脚本 | 本机执行策略拒绝启动，未完成实测 |
| macOS / Linux | 系统 ImageMagick 7 + POSIX sh 启动器 | 提供脚本与指引，未在对应系统实测 |
| Windows ARM64 / x86 | 指定匹配的系统程序 | 未包含匹配二进制，未实测 |
| Codex / WorkBuddy | 导入完整技能目录后由宿主执行脚本 | 标准文件结构；客户端导入与自动触发尚未逐一实测 |

宿主需要能够读取图片、访问完整技能目录并执行本地命令。云端 Linux 沙箱不能使用本包的 Windows 程序。技能不绕过宿主权限、组织策略或安全软件。

## 安装技能

### Codex

把本仓库完整内容放进一个名为 `imagemagick-toolkit` 的技能目录。按 [Codex 官方技能文档](https://developers.openai.com/codex/skills/) 使用当前版本支持的技能目录，例如：

- 用户级：`~/.agents/skills/imagemagick-toolkit/`
- 项目级：`<project>/.agents/skills/imagemagick-toolkit/`

也可以直接克隆到用户级技能目录：

```sh
git clone https://github.com/krillab/imagemagick-toolkit.git ~/.agents/skills/imagemagick-toolkit
```

若当前客户端使用其他已配置目录，以客户端说明为准。安装后在新会话中确认技能可见，可使用：

```text
使用 $imagemagick-toolkit，把这些 PNG 转为 WebP，保留原图。
```

### WorkBuddy

在“专家·技能·连接器 → 技能 → 添加技能 → 上传技能”中，导入含完整技能文件的 ZIP。[官方操作说明](https://www.codebuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Skills-Market)

包的结构应为 `imagemagick-toolkit/SKILL.md`，并同时包含 scripts、references、vendor。导入后确认 vendor 中的 EXE 没有被过滤，再试运行 doctor。上传大小、二进制文件处理及审核以实际客户端为准；本项目不保证所有版本都允许该运行包。

本仓库提供通用技能，不包含 WorkBuddy 市场发布者身份。若要提交其开放平台市场，按 [开放平台文档](https://open.workbuddy.cn/en/docs/skill) 补充真实作者、版本、中英文展示信息等市场字段；不能把本地导入当成已通过市场审核。

### 其他代理

导入完整技能目录，并让代理读取 SKILL.md。核心不依赖 Codex 专属 API，agents/openai.yaml 仅提供 Codex 展示信息；代理仍需支持命令执行。若只支持提示词而不能执行本地程序，只能提供用法解释和命令。

## 快速使用

PowerShell 中把路径改为实际技能安装位置：

```powershell
$skill = 'C:\skills\imagemagick-toolkit'

# 首次检查：只确认路径、能否启动和主版本
& "$skill\scripts\doctor.ps1"

# 图片信息
& "$skill\scripts\run-magick.ps1" identify 'D:\images\input.png'

# 缩放并转 WebP；输出新文件
& "$skill\scripts\run-magick.ps1" 'D:\images\input.png' -auto-orient -resize '1200x1200>' -quality 85 'D:\images\output.webp'
```

不使用代理也能手动运行以上命令。脚本自身不会保护指定输出文件免于覆盖，使用前选择新输出路径；代理的默认保留原图规则在 SKILL.md 中定义。

macOS/Linux 已安装 ImageMagick 7 时：

```sh
sh /path/to/imagemagick-toolkit/scripts/run-magick.sh -version
sh /path/to/imagemagick-toolkit/scripts/run-magick.sh input.png -resize '1200x1200>' output.webp
```

## 自然语言示例

- “介绍一下 ImageMagick，适合做什么？”
- “在这台电脑启用 ImageMagick，先用技能自带的版本。”
- “完整保留图片内容，统一到 800×600，空白补白色。”
- “把这批 JPG 转为 WebP，保留原图，列出失败文件。”
- “把 JPEG 压到 200KiB 以内，先保证尺寸不变；达不到就告诉我。”
- “给图片加中文水印，使用本机可用的中文字体。”
- “缩小 GIF，但保留所有帧、播放延时和循环。”
- “为什么这个文件提示 no decode delegate？”

## 为什么内置后还有检查

内置解决程序分发问题，不能保证文件未丢失、架构匹配或宿主允许执行。

- 首次任务、更新或更换环境：执行 doctor，确认可启动。
- 正常处理：直接调用启动器，不扫描 PATH、不重复计算哈希。
- 使用特殊格式或字体时：按需核对相关能力。
- 每次处理后：检查退出码、文件存在与目标属性。
- 明确排障时：doctor -Full 列出格式/字体/策略；-VerifyIntegrity 校验随包运行文件。

没有自动下载、后台更新或永久 PATH 修改。需要系统安装时，参阅 [安装指引](references/installation.md)。

## 仓库结构

```text
imagemagick-toolkit/
├── SKILL.md
├── README.md
├── LICENSE
├── THIRD_PARTY_NOTICES.md
├── agents/openai.yaml
├── scripts/
│   ├── common.ps1
│   ├── doctor.ps1
│   ├── run-magick.ps1
│   ├── run-magick.sh
│   └── build-release.py
├── references/
│   ├── overview.md
│   ├── installation.md
│   ├── usage.md
│   └── troubleshooting.md
├── tests/smoke.ps1
└── vendor/
    ├── manifest.json
    └── imagemagick/windows-x64/
        ├── magick.exe
        ├── 配套 XML 和 sRGB.icc
        ├── LICENSE.txt
        └── NOTICE.txt
```

## 离线包和体积

源包为 `ImageMagick-7.1.2-35-portable-Q16-HDRI-x64.7z`，压缩大小 12,117,825 字节，来源为项目创建时用户提供的离线文件。

完整原包有 8 个体积相同、哈希不同的独立命令 EXE。为避免解压后约 248MiB 的命令程序占用，本项目仅保留未修改的 magick.exe；其余操作通过 magick identify、magick montage、magick compare 等子命令调用。所有配套配置、ICC、LICENSE、NOTICE 保留，原包上游 ChangeLog 未随运行子集分发。

源包哈希和保留文件的逐项 SHA-256 见 [vendor/manifest.json](vendor/manifest.json)。该记录用于可追溯与完整性检查；未完成与上游签名或可信独立哈希的比对，不能作为上游真实性认证。发布者可在公开发布前补充验证记录。

## 测试与构建 ZIP

无需运行 HarmonyOS、Android 或其他应用工程构建。本项目独立验证：

```powershell
& '.\scripts\doctor.ps1' -VerifyIntegrity
& '.\tests\smoke.ps1'
python '.\scripts\build-release.py'
```

Python 3.8+ 仅用于维护者打包，不是使用技能的依赖。打包脚本生成 `dist/imagemagick-toolkit.zip` 和 ZIP 的 SHA-256 文本，保留单一顶层目录，排除 Git 元数据、测试输出和 dist 自身。无需 Git LFS；保留的 EXE 约 31MiB，但二进制更新仍会增加 Git 历史体积。

冒烟测试在系统临时目录创建唯一输出目录，保留结果供检查，不改原图。覆盖中文和空格路径、缩放/补边、透明 PNG 转 JPEG、WebP、拼接、文字、动画、批处理、compare 语义及错误返回。实测详情见 [tests/VALIDATION.md](tests/VALIDATION.md)。

## 贡献与维护

欢迎提交具体问题、复现命令、预期和实际结果；图片应去除敏感信息或换成可公开的最小样本。

修改脚本后运行 doctor 和冒烟测试。更新内置运行时需同时更新 manifest、许可证和验证记录，流程见安装指引。不要在公共仓库提交本地输入图片、Token 或绝对个人路径。

## 开源许可

本项目原创技能说明和脚本使用 [MIT License](LICENSE)。内置 ImageMagick 及第三方组件适用其各自许可证，见 [第三方声明](THIRD_PARTY_NOTICES.md)。本项目与 ImageMagick Studio LLC 无隶属关系，不表示获得其背书。

## 官方参考

- [ImageMagick 下载](https://imagemagick.org/download/)
- [命令行选项](https://imagemagick.org/command-line-options/)
- [格式支持](https://imagemagick.org/formats/)
- [安全策略](https://imagemagick.org/security-policy/)
- [ImageMagick 许可证](https://imagemagick.org/license/)

## 交流与关注

如果这个技能对你有帮助，欢迎给项目点个 Star，也欢迎扫码关注我的公众号，一起交流 AI 工具与技能实践。

<img src="assets/wechat-qrcode.jpg" alt="微信公众号二维码" width="240" />
