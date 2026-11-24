---
name: imagemagick-toolkit
description: "介绍、安装、配置和使用 ImageMagick 7，执行图片缩放、裁剪、格式转换、压缩、拼接、水印、动画及批量处理，并排查运行问题。内置 Windows x64 便携版；适用于 ImageMagick、magick 用法及确定性图片处理请求，不用于 AI 生图或语义修图。"
---

# ImageMagick Toolkit

将需求转换为 ImageMagick 7 原生命令。用户要求处理图片时执行并交付文件；询问功能、安装或参数时按问题解释。技能不预设公众号、社交平台或其他业务尺寸。

## 按需阅读

- 介绍、能力范围和参数顺序：[references/overview.md](references/overview.md)。
- 安装技能、启用便携版、系统安装与跨平台：[references/installation.md](references/installation.md)。
- 常见操作和批处理：[references/usage.md](references/usage.md)。
- 程序、字体、格式、策略或内存报错：[references/troubleshooting.md](references/troubleshooting.md)。

## 程序选择

以本 SKILL.md 所在目录为技能根目录，调用脚本时使用实际完整路径，不假定当前工作目录为技能目录。

- Windows：优先使用内置便携版。首次执行或技能更新后运行 `scripts/doctor.ps1`；同一任务中通过后无需反复检查版本、PATH 或哈希。后续由 `scripts/run-magick.ps1` 转交原生参数。
- macOS/Linux：使用 `sh scripts/run-magick.sh -version` 检查系统 ImageMagick 7。未安装时按安装文档处理；不尝试运行 Windows EXE。
- 用户明确指定其他版本时，用进程环境变量 `IMAGEMAGICK_EXECUTABLE` 指定可执行文件的完整路径。显式指定的路径失效时直接报错，不悄悄切回内置版。
- 内置版缺失或架构不符时说明原因，按安装文档选择匹配版本。系统安装、永久 PATH 变更只在用户要求的范围内进行；无需为使用便携版改系统配置。
- 自包含脚本不依赖 Python、Node、MCP 或特定代理的 API。宿主仍需具备文件访问和命令执行能力；技能不会绕过沙箱权限。

PowerShell 示例（将技能路径替换为实际安装目录）：

```powershell
$tool = 'C:\skills\imagemagick-toolkit\scripts\run-magick.ps1'
& 'C:\skills\imagemagick-toolkit\scripts\doctor.ps1'
& $tool identify 'D:\images\input.png'
& $tool 'D:\images\input.png' -auto-orient -resize '1200x1200>' 'D:\images\output.webp'
```

## 图片处理流程

1. 确认输入和目标效果。能从上下文得到的参数直接采用；裁剪或拉伸选择不明确且会影响内容时澄清。
2. 先用 `identify` 读取格式、尺寸、帧数，必要时读取方向、透明通道和 ICC。特殊格式及字体仅在相关任务中检查。
3. 默认保留原图，写入独立输出目录。已有输出使用新名称，除非用户要求覆盖。批处理先固定输入清单，排除输出目录，同名文件保留相对路径或使用唯一名称。
4. 使用参数数组或正常命令参数调用，保留含空格路径为单个参数。不把文件名、文字或命令拼成字符串交给 Invoke-Expression、eval 或 shell 执行。
5. 检查退出码和输出文件，再用 identify 核对目标尺寸、格式和帧数。有体积上限时测量字节数，不能用 quality 值推断体积。
6. 裁剪、拼接、水印、透明化等操作预览结果。批量抽查代表样本并记录失败项。交付路径、成功/失败数量及与需求相关的验证结果，不能把未执行的命令说成已完成。

## 参数约束

- 默认保持比例；几何参数中的 `>`、`^`、`!` 等加引号。裁剪后通常使用 `+repage` 清理虚拟画布偏移。
- `-auto-orient` 在删除 EXIF 之前。不要默认 `-strip`：它也会移除 ICC。有颜色管理要求时保留配置或使用合适的源/目标 ICC 转换；不能仅通过添加标签假装转换。
- JPEG 不支持透明度，转 JPEG 前明确底色；未指定时可用白色并说明。需要透明度时使用合适格式。
- JPEG 的 `-quality` 不保证文件大小；PNG 的质量参数含义不同。目标 KB 采用有界调整并实测，仍超限再依据用户允许范围缩小尺寸。
- 动画先确认完整动画还是静态帧；完整动画通常 coalesce 后处理并优化，核对帧数、延时和循环。仅在明确需要静态图时选取 `[0]`。
- 不默认用 mogrify 覆盖源文件。基于颜色的透明化不能冒充复杂背景抠图。
- 需要中文文字时选择实际存在且支持中文的字体。PDF、EPS、HEIC 等能力按实际构建和任务检查，不承诺所有格式都可读写。
- 遇到 policy 拒绝不要自动放开全局策略。说明受限操作，并按用户任务选择最小必要处理。
