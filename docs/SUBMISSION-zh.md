# 首次提交 CRAN

技术检查的最终状态以 `RELEASE-STATUS.md` 为准。本文件是提交操作说明，
不是已提交或已收录的证明。任何修改发布源码的操作都需要重新构建、检查。

## 表单材料

- 官方入口：<https://cran.r-project.org/submit.html>。
- 维护者：Muyao Shen。
- 邮箱：shenmuyao.bio@gmail.com。
- 文件：`E:/desktop/radarsunburst/artifacts/release/radarsunburst_0.1.0.tar.gz`。
- SHA-256：`d9b8de41bdf66aff0d073444be51684c86e454934cb9aba76d3f235e19ed25ca`。
- Optional comment：复制项目根目录 `cran-comments.md` 的英文内容；
  在平台检查和说明全部完成前不要上传。
- 开源仓库：<https://github.com/diamondten8/radarsunburst>。

## 维护者需要完成的步骤

1. 阅读 <https://cran.r-project.org/web/packages/policies.html>。
   提交即表示同意该政策，包括代码授权清楚、允许 CRAN 分发、邮箱可收信，
   以及持续处理检查问题。确认这些承诺后才进行正式上传。
2. 上传上面这份已检查的文件，核对包名、版本和维护者信息。
3. 完成表单后续步骤，保存回执或提交编号。
4. 查看维护邮箱及垃圾邮件，按 CRAN 的确认邮件完成确认。
   查看 <https://cran.r-project.org/incoming/> 可辅助核实接收情况。
5. 等待自动检查和人工审核。待审期间不要重复提交；检查通过不等于收录。
   如果收到修改意见，把邮件内容交给 Codex 修订、重建和检查，再准备重提。

## 本地安装和使用

```r
install.packages(
  "E:/desktop/radarsunburst/artifacts/release/radarsunburst_0.1.0.tar.gz",
  repos = NULL, type = "source"
)
library(radarsunburst)
```

使用教程见 `docs/QUICKSTART-zh.md`。运行依赖 ggplot2 与 rlang 需预先安装；
交互转换另需 plotly 和 htmlwidgets。包本身不会自动安装这些依赖。
