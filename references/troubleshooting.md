# 故障排查

| 现象 | 检查与处理 |
| --- | --- |
| 找不到 magick.exe | 确认完整技能包已解压；不要只安装 SKILL.md。优先恢复 vendor，而不是修改全局 PATH。 |
| 程序无法启动 / 不兼容 | 核对 Windows x64、终端进程架构及文件是否被宿主或安全软件拦截。若明确缺少运行库，使用官方匹配依赖；不要默认要求管理员或关闭安全软件。 |
| 运行脚本被策略禁止 | 查看组织和宿主策略，使用获准的执行方式；也可直接调用 vendor 内 magick.exe。不自动修改执行策略或使用永久 Bypass。 |
| no decode delegate / no encode delegate | 查看 -list format 的读写标记并做目标格式小样。按需补充依赖，不能只凭扩展名判断可用。 |
| PDF / EPS 失败 | 结合实际构建检查 Ghostscript 或内置 gslib，以及 policy。当前包列有 gslib，但不承诺所有文档均可处理，也不默认安装 Ghostscript。 |
| 中文水印方块 | -list font，指定本机实际存在且包含所需字形的字体或字体文件。字体不随技能分发。 |
| not authorized / security policy | -list policy 查看生效限制；不要自动放开全局策略。按具体需求和用户授权调整最小范围。 |
| 内存不足 / cache exhausted | HDRI、多帧和大图占用较多；缩小任务、分批执行，或在任务允许范围设置 -limit memory、map、disk。 |
| 输出空白、透明底变黑 | 检查输入帧、透明通道、合成顺序、底色及目标格式；JPEG 前明确合成背景。 |
| 体积未达到目标 | 测量实际字节；有界调整 JPEG/WebP 质量，必要时经允许缩小尺寸。PNG quality 并非 JPEG 画质参数。 |
| 执行成功但结果不对 | 核对操作顺序、EXIF、ICC、虚拟画布、帧数和几何参数引号，预览实际输出。 |

Windows 可执行：

```powershell
& 'C:\skills\imagemagick-toolkit\scripts\doctor.ps1' -Full
& 'C:\skills\imagemagick-toolkit\scripts\doctor.ps1' -VerifyIntegrity
```

Unix 上用启动脚本分别传入 -version、-list format、-list font、-list policy。

启动器保留原生命令退出码；启动或路径解析错误返回 1，未传参数返回 2。compare 的退出码 0 表示相同，1 表示存在差异，2 表示错误；不能把预期差异当成执行崩溃。批处理对每个文件检查退出码并记录失败，不能只检查最后一次。
