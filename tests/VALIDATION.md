# 验证记录

验证日期：2026-11-24。

## 已完成

- 内置程序启动成功：ImageMagick 7.1.2-35 Q16-HDRI x64。
- Windows x64 / PowerShell 7：smoke.ps1 实测通过，涵盖中文与空格路径、PNG/JPEG/WebP、缩放、裁剪、补边、透明背景合成、拼接、montage、文字渲染、动画帧/延时/循环、批处理、源文件保留。
- compare 返回码：相同 0、不同 1、执行错误 2；无参数返回 2，错误输入及失效的显式程序路径返回失败。
- 内置文件逐项 SHA-256 与 manifest 匹配；原始离线包的文件大小及哈希已记录。
- doctor -Full 可读取格式、字体及生效策略；本包保留原始 policy.xml，不默认修改全局策略。
- 所有本地 Markdown 链接、必需文件、技能名和 frontmatter 的基础结构经检查。
- ZIP 构建后检查单一顶层目录、必需运行文件和许可证存在，逐字节核对 ZIP 中的文件与源目录一致。

## 未完成或受环境限制

- Windows PowerShell 5.1 启动测试被本机 AuthorizationManager 拒绝；没有修改执行策略，不能声明 5.1 已实测通过。
- POSIX sh 语法检查尝试被本机 MSYS 权限拒绝；macOS/Linux 实际运行未测试。
- Codex / WorkBuddy 图形界面导入、自动触发和市场发布尚未逐一验证。
- 官方 skill-creator quick_validate.py 已尝试执行，但本机 Python 缺少 PyYAML，依赖安装也受网络限制；基础结构检查不冒称官方校验器通过。
- 内置运行包来自用户提供文件，未与上游可信独立哈希或签名核验真实性。
- 中文路径已验证；水印测试使用 Arial 英文字体，中文水印仍取决于实际安装的中文字体。
- 未穷举所有格式、PDF 文档或额外外部依赖。

复现：

```powershell
& '.\scripts\doctor.ps1' -VerifyIntegrity
& '.\tests\smoke.ps1'
python '.\scripts\build-release.py'
```

仅打包需要 Python；技能使用不依赖 Python/PyYAML。
