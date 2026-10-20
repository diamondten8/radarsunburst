# 当前状态与下次继续点

2026-10-20 按用户要求加入 geom_radsun()，对齐代码、帮助、README、教程、
GitHub 和更通俗的短版中文 PDF。仍未上传 CRAN；需要用户阅读并亲手审查。

- 五个公开函数；两个绘图入口共用一个核心；默认整个灰色指标环仍移除。
- 新组件继承 ggplot 的数据，不继承 aes；参数以列名字符串指定。
- 当前与最低 ggplot2 3.5.0 的 216 项断言通过，构建和新会话安装检查通过。
- 五行教学数据和完整手动练习已实际运行；不是维护者已手工验收的声明。
- 读 docs/GUIDE-zh.md 或 docs/radarsunburst-guide-zh.pdf；
  本地输出也在 output/pdf/radarsunburst-code-review-and-r-package-guide-zh.pdf。
- 原 136 页手册另存 output/pdf/radarsunburst-full-source-review-2026-10-09.pdf，
  它的接口数量和证据属于旧版本，不要作为当前入口。
- 旧发布记录在 docs/history/release-evidence-before-geom.md，旧制品已备份。
- 当前精确制品、哈希和检查结果以 RELEASE-STATUS.md 为准；任何包输入变化重建重查。
- 用户已授权同步公开 GitHub 仓库与运行跨平台检查，没有授权正式上传 CRAN。
- 本次只记录 skill 体验与改进建议，没有修改安装的 skill。
