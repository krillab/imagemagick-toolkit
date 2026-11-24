# 安装与运行

## 安装技能和安装 ImageMagick 是两件事

完整技能自带 Windows x64 运行文件。把整个技能文件夹安装到代理后即可调用便携版，不需要安装 ImageMagick、不需要管理员权限或修改永久 PATH；宿主的执行权限仍然适用。

Codex、WorkBuddy 的技能安装入口和验证范围见根目录 [README](../README.md)。不要只复制 SKILL.md，scripts、references、vendor 也需要一起保留。

## Windows 便携版

在 PowerShell 中，将路径替换为实际技能目录：

```powershell
$skill = 'C:\skills\imagemagick-toolkit'
& "$skill\scripts\doctor.ps1"
& "$skill\scripts\run-magick.ps1" -version
& "$skill\scripts\run-magick.ps1" identify 'D:\photos\input.png'
```

PowerShell 5.1 或 7 的原生 Windows x64 进程可使用内置版。从 Bash 宿主调用 Windows 便携版时，启动可用的 Windows PowerShell，并传入脚本的 Windows 路径；不要用 sh 启动 ps1。

首次使用执行 doctor；通过后同一任务内直接调用 run-magick。doctor 不创建全局状态或磁盘缓存。换机器、更新运行包或遇到运行错误后重新检查即可。普通处理不计算哈希。

按需诊断：

```powershell
& "$skill\scripts\doctor.ps1" -Full
& "$skill\scripts\doctor.ps1" -VerifyIntegrity
```

Full 列出格式、字体和生效策略；VerifyIntegrity 核对随包运行文件的 SHA-256，不等于验证上游签名。两者都不会安装软件或修改策略。

## 指定系统安装

用户要求使用系统版本时，在当前进程中明确指定路径：

```powershell
$env:IMAGEMAGICK_EXECUTABLE = 'C:\Program Files\ImageMagick-7\magick.exe'
& "$skill\scripts\doctor.ps1"
& "$skill\scripts\run-magick.ps1" -version
Remove-Item Env:IMAGEMAGICK_EXECUTABLE
```

该路径是示例，先确认实际安装位置。不要写入用户或系统永久变量。显式路径无效会报错，不自动降级。

若用户确实希望安装系统版本，可从 [官方页面](https://imagemagick.org/download/) 选择匹配的安装程序，或根据可用包管理器：

```powershell
winget install --id ImageMagick.Q16-HDRI --exact
```

安装应在用户要求范围内执行；由宿主管理必要授权。安装后用实际完整路径执行 -version，当前进程 PATH 可能尚未刷新，无需重复安装。

## macOS / Linux

本技能不包含这两个系统的二进制包。已安装 ImageMagick 7 时：

```sh
sh /path/to/imagemagick-toolkit/scripts/run-magick.sh -version
sh /path/to/imagemagick-toolkit/scripts/run-magick.sh input.jpg -resize '800x800>' output.webp
```

安装示例：

```sh
# macOS，已安装 Homebrew 时
brew install imagemagick

# Debian / Ubuntu：发行版仓库版本可能是 6，安装后必须确认
sudo apt update
sudo apt install imagemagick
magick -version
```

若仓库只提供 ImageMagick 6，不伪称已完成 ImageMagick 7 安装；使用官方适合该系统的发行包或源码构建。ARM64 Windows 也需要匹配版本，当前启动器不会自动选择 x64 模拟运行。

POSIX 系统可指定完整路径：

```sh
IMAGEMAGICK_EXECUTABLE=/opt/imagemagick/bin/magick sh /path/to/scripts/run-magick.sh -version
```

## 升级便携版

1. 从官方获取相同目标平台的便携包，记录版本、下载地址及校验资料。
2. 在隔离目录检查包内容；更新 magick.exe 和配套配置，保留完整许可证与 NOTICE。
3. 更新 vendor/manifest.json 的版本、源包哈希及所有保留文件的哈希，不把本地重算哈希称为上游认证。
4. 运行 doctor -VerifyIntegrity 和 tests/smoke.ps1；更新 README 的实测记录。
5. 重新生成分发 ZIP。不要静默下载、替换用户正在使用的运行包。
