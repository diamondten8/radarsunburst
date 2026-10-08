# 明天从这里继续

用户在 2026-10-09 要求今晚收尾并停止，明天继续。不要把暂停当作已经完成发布。
未上传 CRAN，也未发送 CRAN 邮件。剩余 GitHub 检查已取消，不再启动新的检查。

## 已确定的内容

- 包名 radarsunburst，0.1.0，MIT。
- 作者/维护者 Muyao Shen，shenmuyao.bio@gmail.com，独立创作。
- 用户已授权公开仓库：<https://github.com/diamondten8/radarsunburst>。
- 最新图形要求是**整个灰色环去掉**，不是只去掉文字。默认
  `metric_ring = NULL`，旭日图靠近雷达。雷达悬停仍显示指标名称。
  显式 `metric_ring = c(1.06, 1.55)` 可加回环；显示环内名称还需
  `show_metric_labels = TRUE`。用户对其他原示例效果没有意见。
- 四个公开函数、英文帮助、离线教程、中文入门、演示数据和测试已完成。
  原型保留但不进入 CRAN 包。162 项断言通过，包括最低 ggplot2 3.5.0。
- 新会话安装、数值与计数、实际浏览器悬停/显隐/缩放及主题已验证。

## 当前源码包与证据

打包源码提交：`114c653e654ff184c32045ac0811ea2b1454ea8d`。
以后只改开发文档不会改变包制品；修改 R、man、DESCRIPTION、测试、教程等
任何包输入都必须重新构建检查。

最终候选文件：`E:/desktop/radarsunburst/artifacts/release/radarsunburst_0.1.0.tar.gz`

SHA-256：`d9b8de41bdf66aff0d073444be51684c86e454934cb9aba76d3f235e19ed25ca`

该制品由 GitHub run 37854188000 的 source job 用 R release 构建。平台检查
以及下面的本机检查都是这份不变的 tarball。

- 本机 Windows R 4.6.1：0 ERROR、0 WARNING、1 NOTE。
- 本机 Windows R-devel 2026-10-06 r90643：同上。
- 云端 Linux R 4.6.1 和 Windows R 4.6.1：同上。
- NOTE 都是首次提交的 New submission，已核实。
- 本机 PDF/HTML 手册、示例、测试及教程重建都通过，没有跳过手册检查。
- 云端 setup-r 默认关闭时钟检查；不能把这点隐藏，应在最终工作流中恢复。

本机日志/JSON 在 `artifacts/release`；完整云端目录在
`E:/desktop/radarsunburst-checks/github/37854188000`。已下载 release-source、
check-ubuntu-latest-release、check-windows-latest-release、
check-macos-latest-release，并保存 macos-job.log。

## 明天先处理

1. **macOS TeX 平台问题**。该平台其他检查和 HTML 手册通过，但 PDF 失败，
   实际是 1 ERROR、1 WARNING、2 NOTEs。Rdlatex.log 明确显示
   `/Users/runner/.TinyTeX/bin/aarch64-linux/pdflatex: cannot execute binary file`。
   macos-job.log 显示 tinytex::install_tinytex() 实际下载了
   `TinyTeX-1-linux-arm64.tar.xz`。R 平台实际是 aarch64-apple-darwin23。
   不要改包代码掩盖这个工具链问题，也不要关闭 PDF 检查。
   已检查官方 tinytex 的 R/install.R：os_index 是包加载前计算的常量；
   需要调查二进制包的平台识别，或用官方 Darwin 归档独立配置原生工具。
   官方已验证存在的制品：
   <https://github.com/rstudio/tinytex-releases/releases/download/v2026.10/TinyTeX-1-darwin-v2026.10.tar.xz>。
   尚未应用/验证修复，不要宣称已解决。
2. 修复 CI 后，最好通过 workflow_dispatch 复用同一已检查 tarball，避免仅改
   工作流又生成不同 hash 的包。若重建，则所有最终证据必须对应新 hash。
3. 恢复 CI 的时钟检查（setup-r 注入 `_R_CHECK_SYSTEM_CLOCK_=FALSE`）。
   不要用环境变量隐藏 NOTE 或缺失工具。当前工作流已安装 HTML Tidy，并通过
   GITHUB_PATH 跨步骤传递 TeX 路径；这两点已在 Linux/Windows 验证有效。
4. 取得 macOS 完整通过及 Linux R-devel 证据。后者暂停时还在安装依赖，已取消，
   所以没有通过记录。已完成本机 Windows R-devel 检查可作为现有证据。
5. 更新 RELEASE-STATUS.md 和 cran-comments.md，整理所有日志、hash 和提交说明。
   最终提交前应让用户确认 CRAN 政策的承诺，并由维护者处理邮箱确认；不要把
   “准备材料”当成 CRAN 已收录。CRAN 表单已只读访问，尚未填表或上传。

## 本机工具，避免重复安装或踩坑

- 原 R：`D:/Rstudio&R/R-4.4.3`。不要让它加载 R 4.6 的 DLL 库。
- release/devel：`E:/desktop/radarsunburst-checks/runtimes/R-release`、`R-devel`。
- R 4.6 开发库：`.../runtimes/library-release`；最低 ggplot2 库：
  `.../runtimes/library-min-ggplot`，使用时放在 .libPaths 第一项。
- TeX：`E:/desktop/radarsunburst-checks/TinyTeX/bin/windows`，Courier、makeindex 已安装。
- HTML Tidy：`.../runtimes/tidy/tidy-5.8.0-win64/bin`。
- Pandoc：`D:/Rstudio&R/RStudio/resources/app/bin/quarto/bin/tools`。
- 每个 Windows R 子进程使用 `LC_ALL`、`LC_CTYPE`、`LANG` 为
  `English_United States.utf8`。继承的 C.UTF-8 不可用；不修改用户启动文件。
- `tools/check.ps1 -Runtime release` 构建检查；加 `-Tarball <path>` 检查同一制品。
  NOTE 导致辅助脚本退出 1 是刻意设计，必须读日志，而不是当成 ERROR。
- gh：`D:/GithubCLI/gh.exe`，账户 diamondten8。当前分支 master。
- 预览：`artifacts/preview/default.png`、`interactive-browser.png`、
  `interactive.html` 及资源目录。重新开 HTTP 预览时可从该目录启动服务；
  检查和工具目录不要暴露给 HTTP 服务。

更详细的使用、维护和视觉证据在 QUICKSTART-zh.md、MAINTENANCE.md、VISUAL-QA.md。
