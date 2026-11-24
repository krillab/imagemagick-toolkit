# 常用操作

以下 PowerShell 示例先设置启动器路径。输入输出按任务替换，输出路径不得与源文件相同；已有输出需换名或取得覆盖授权。

```powershell
$im = 'C:\skills\imagemagick-toolkit\scripts\run-magick.ps1'
& $im identify 'input.png'
& $im identify -verbose 'input.png'
```

macOS/Linux 将 `& $im` 换为 `sh /path/to/scripts/run-magick.sh`，并按 shell 语法引用路径。

## 缩放、裁剪和补边

```powershell
# 装入边界，只缩小，保持比例
& $im 'input.jpg' -auto-orient -resize '1200x800>' 'resized.jpg'

# 覆盖区域后居中裁剪，得到严格尺寸
& $im 'input.jpg' -auto-orient -resize '800x600^' -gravity center -extent '800x600' +repage 'cropped.jpg'

# 完整保留内容，居中补白
& $im 'input.png' -resize '800x600' -background white -gravity center -extent '800x600' 'padded.png'

# 指定矩形区域：宽x高+左偏移+上偏移
& $im 'input.png' -crop '300x200+50+40' +repage 'region.png'
```

`800x600` 是装入边界，`800x600^` 是覆盖边界，`800x600!` 强制拉伸，仅在明确允许时使用。

## 转格式、透明度和压缩

```powershell
& $im 'input.png' -quality 85 'output.webp'
& $im 'transparent.png' -background white -alpha remove -alpha off -quality 88 'output.jpg'
& $im 'input.jpg' -auto-orient -rotate 90 'rotated.jpg'
& $im 'input.png' -flop 'horizontal-flip.png'
& $im 'input.png' -flip 'vertical-flip.png'
```

体积限制先以字节约定 KB/KiB。示例“200KiB”阈值是 `200 * 1024`。对 JPEG/WebP 可在有限次数内降低质量并测量长度；保存每次的独立候选或在专用临时目录重写。到质量下限仍超标时说明结果，或在用户允许范围缩小尺寸。不要承诺 quality 85 一定更小。

## 元数据与色彩

```powershell
# 明确允许删除 EXIF、ICC 等全部配置时
& $im 'input.jpg' -auto-orient -strip 'clean.jpg'
```

需保留色彩管理时不要默认 strip。对于带有正确嵌入源 ICC 的输入，可使用 `-profile` 加目标 ICC 执行转换。内置的 sRGB.icc 位于 vendor/imagemagick/windows-x64；无源 ICC 的输入需要先确认其色彩空间，不能盲目假定。

## 拼接与图片合成

```powershell
& $im 'a.png' 'b.png' +append 'horizontal.png'
& $im 'a.png' 'b.png' -append 'vertical.png'
& $im montage 'a.png' 'b.png' -tile '2x1' -geometry '+12+12' -background white 'grid.png'
& $im 'photo.png' 'logo.png' -gravity southeast -geometry '+20+20' -composite 'watermarked.png'
```

拼接前核对尺寸；不同高度或宽度的图片会影响画布及对齐。

## 文字水印

```powershell
& $im -list font
# 字体路径为示例，必须先确认该字体文件存在并包含目标字形
& $im 'input.png' -font 'C:/Windows/Fonts/msyh.ttc' -pointsize 28 -fill white -gravity southeast -annotate '+20+20' '示例水印' 'text.png'
```

对于用户提供的任意文本，不把内容拼成 shell 表达式；将它作为独立参数。ImageMagick 本身也解释部分字符序列和文件间接读取语法，需要按意图处理并预览，不把它当成纯文本渲染服务。

## 动画和多页文件

```powershell
# 仅在要求静态首帧时
& $im 'animation.gif[0]' 'first.png'

# 处理完整动画
& $im 'animation.gif' -coalesce -resize '480x480>' -layers Optimize 'small.gif'
& $im identify -format '%n %T\n' 'small.gif'
& $im identify -verbose 'small.gif' # 查看 Iterations 等动画属性
```

核对帧数、延时、循环和透明度。多页 TIFF、PDF 也有帧/页语义，未经要求不能只保留第一页。

## 对比

```powershell
& $im compare -metric AE 'a.png' 'b.png' 'difference.png'
# 立即读取 $LASTEXITCODE：0 相同，1 不同，2 错误
```

## 批量处理

先枚举输入，再建输出。以下示例仅处理输入目录顶层的 JPG，不递归，也不覆盖已有输出；文件名保持不变。

```powershell
$inputDir = 'D:\photos'
$outputDir = Join-Path $inputDir 'converted'
$inputs = @(Get-ChildItem -LiteralPath $inputDir -File -Filter '*.jpg')
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
$failed = @()
$completed = 0
foreach ($file in $inputs) {
    $output = Join-Path $outputDir ($file.BaseName + '.webp')
    if (Test-Path -LiteralPath $output) {
        $failed += "$($file.Name): output already exists"
        continue
    }
    & $im $file.FullName -auto-orient -resize '1600x1600>' -quality 85 $output
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $output)) {
        $failed += "$($file.Name): conversion failed"
        continue
    }
    & $im identify $output
    if ($LASTEXITCODE -ne 0) {
        $failed += "$($file.Name): output validation failed"
        continue
    }
    $completed++
}
"Completed: $completed; failed/skipped: $($failed.Count)"
$failed
```

递归处理时保留相对目录结构或生成唯一名称，并排除输出子树。最终抽查代表样本；不要用并发任务把内存占满。

## 更多功能

模糊、锐化、亮度/对比度、灰度、颜色替换、边框等可直接使用原生选项组合，按需查询 [官方选项文档](https://imagemagick.org/command-line-options/)。颜色透明化使用小容差预览，不代替复杂背景抠图。
