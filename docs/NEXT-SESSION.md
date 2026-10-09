# 从正式提交确认继续

2026-10-09 已按用户“继续吧”恢复，技术准备全部完成。
尚未上传 CRAN，也没有发送确认邮件或声称收录。

- 包：radarsunburst 0.1.0，MIT；维护者 Muyao Shen，shenmuyao.bio@gmail.com。
- 用户已授权公开仓库、推送和跨平台检查：<https://github.com/diamondten8/radarsunburst>。
- 默认整个灰色环已移除，`metric_ring = NULL`；不是仅隐藏名称。
- 四个公开函数、英文帮助和离线教程、中文说明、演示数据、162 项断言已完成。
- 已实际在浏览器验证悬停、组显隐、缩放、圆形比例及主题。
- 候选源码包：`E:/desktop/radarsunburst/artifacts/release/radarsunburst_0.1.0.tar.gz`。
- SHA-256：`d9b8de41bdf66aff0d073444be51684c86e454934cb9aba76d3f235e19ed25ca`。
- 包内源码提交 `114c653`；此后仅修改排除于包的开发工具与发布说明。
- 六份完整检查均为 0 ERROR、0 WARNING、1 NOTE，只是 New submission。
  本机 Windows release/devel、云端 Windows/Linux/macOS release、Linux devel。
- 云端最终检查恢复了时钟检查，并包含 PDF 手册；macOS TeX 平台问题已实际解决。
- Linux/Windows/devel 证据：run 37899396257；macOS：run 37899782528。
  前者整体显示失败源于首次 macOS 工具配置失败，其他三个任务通过；
  第二个 run 仅重跑 macOS 并通过。不要用总徽章代替逐平台日志。
- 最终日志、hash 和 `release-manifest.json` 在 `artifacts/release`。

下一步阅读 RELEASE-STATUS.md、cran-comments.md 和 docs/SUBMISSION-zh.md，
由维护者确认正式提交及 CRAN 政策承诺后，上传上面这份已检查的文件。
邮箱确认由维护者处理，待审期间不要重复提交。没有同意政策之前不代为作出法律承诺。
任何包内 R、帮助、教程、测试或元数据修改都须重新构建和检查。

本机工具、子进程 locale 配置和维护流程在 docs/MAINTENANCE.md；
包代码不自动安装依赖、不修改用户环境、不写文件。
