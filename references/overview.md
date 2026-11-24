# ImageMagick 简介

ImageMagick 是命令行图片处理工具，可创建、读取、转换、编辑和组合图片。本技能采用 ImageMagick 7 的 `magick` 命令，支持介绍答疑、安装指导和实际文件处理。

## 能力

- 缩放、裁剪、旋转、翻转、补边和画布调整。
- 图片格式转换、质量调整、文件大小优化。
- 拼接、合成、文字/图片水印、颜色和透明通道处理。
- 动画帧处理、多页图片处理、像素差异比较。
- 批量操作、元数据检查与处理。

这类操作按明确规则改变像素，不提供生成式补画、语义移除人物等 AI 编辑能力。

## 命令结构

```text
magick [输入前设置] 输入文件 [处理操作] [输出设置] 输出文件
magick identify input.png
magick montage a.png b.png -tile 2x1 -geometry +12+12 output.png
magick compare a.png b.png difference.png
```

选项顺序影响结果：先缩放再裁剪与先裁剪再缩放不同。输入前的设置可以影响解码，输入后的操作作用于已读取图片。括号可隔离分组，但必须按当前 shell 正确转义或作为独立参数传入。

ImageMagick 7 不需要调用旧版独立的 convert.exe；Windows 中 convert 还可能指向系统磁盘工具。技能只分发 magick.exe，identify、montage、compare、mogrify 等通过子命令调用。

## 内置构建

Windows x64，ImageMagick 7.1.2-35，Q16-HDRI。Q16 表示通道量化精度，HDRI 支持高动态范围中间计算，不代表输入自动变成 HDR 图片。高精度处理通常需要更多内存。

格式、字体和外部依赖由运行时决定。使用 `magick -list format` 查看读写标记，使用 `magick -list font` 检查字体；对目标格式做小样实测比仅看格式列表更可靠。

## 官方资料

- [首页](https://imagemagick.org/)
- [命令行处理](https://imagemagick.org/command-line-processing/)
- [命令行选项](https://imagemagick.org/command-line-options/)
- [格式支持](https://imagemagick.org/formats/)
- [安全策略](https://imagemagick.org/security-policy/)
