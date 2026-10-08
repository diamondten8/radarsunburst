# radarsunburst 中文入门

本包尚未在 CRAN 发表。先安装本地构建出的 `radarsunburst_0.1.0.tar.gz`，
不要提前使用 `install.packages("radarsunburst")` 当作 CRAN 安装说明。

```r
install.packages("实际路径/radarsunburst_0.1.0.tar.gz", repos = NULL, type = "source")
library(radarsunburst)
data(radar_sunburst_demo)
metrics <- c("score_stability", "score_efficiency", "score_innovation",
             "score_quality", "score_collaboration")
hierarchy <- c("main_category", "sub_category", "leaf_category")
p <- radar_sunburst(radar_sunburst_demo, metrics, "series", hierarchy,
  metric_labels = c("Stability", "Efficiency", "Innovation", "Quality", "Collaboration"))
p
```

## 换成自己的表格

每行代表一个计数条目。`metrics` 是至少三个数值列，`group` 是雷达分组列，
`hierarchy` 是从大类到末级依次排列的分类列。列名由你指定，不必叫演示名称。
分类可以是文字、因子、数值代码或逻辑值。分组不能为空；下级分类空白或 NA
表示到此结束，不能跳过中间层又填后面的类别。

雷达使用单元格中的值，同组多行取普通平均；旭日图只计行数，不读取权重或
用户输入的百分比。重复行也计数，如果应该按唯一项目统计，请先明确去重。
缺失、非数值、无限大的指标会报出列名和行位置，不会补零。

```r
my_table <- data.frame(
  group = c("组一", "组二", "组二"),
  category = c("类别甲", "类别乙", "类别乙"),
  quality = c(70, 80, 90), efficiency = c(50, 60, 80), innovation = c(60, 70, 90)
)
radar_sunburst(my_table, c("quality", "efficiency", "innovation"), "group", "category")
```

## 数量、占比与刻度

`percent = "none"`：只显示名称和数量。
`"parent"`：占直接父节点，顶层用全部条目作分母。
`"root"`：占所属大类，默认值。
`"global"`：占整个表格。改变显示口径不会改变扇区角度。

默认刻度取所有原始指标值的共同最小值、最大值，两端各增加跨度的 5%，
在平均前计算。可以用 `radar_limits = c(0, 100)` 指定固定范围。中心对应实际
下界，并不一定是 0。不同单位不会自动标准化；不能直接把预算和评分解释为
可比较指标。

```r
s <- radar_sunburst_data(radar_sunburst_demo, metrics, "series", hierarchy)
s$radar
s$nodes[, c("label", "count", "parent_proportion", "root_proportion", "global_proportion")]
s$radar_limits
```

## 主题、配色与保存

```r
p + ggplot2::theme_bw() + ggplot2::labs(title = "我的复合图")
p + ggplot2::theme(legend.position = "bottom")
ggplot2::ggsave("我的图.png", p, width = 12, height = 8, dpi = 300)
ggplot2::ggsave("我的图.svg", p, width = 12, height = 8, device = grDevices::svg)
```

主题控制背景、标题和图例；图内标签由 `label_size`、`metric_label_size`、
`label_colour`、`metric_label_colour`、`label_family` 等参数控制。填色 scale
控制外圈大类；colour scale 控制雷达组，含淡色填充。指标环颜色独立指定。
保留固定坐标比例，避免圆形变椭圆。字体需要在实际输出机器上存在。

细小扇区、长标签会缩小字号，低于最低字号就隐藏文字，但保留扇区和悬停
信息。字号拟合按典型图幅估计，所以保存后仍需查看实际图片。

```r
# 事先安装可选的 plotly；本包不会自动安装任何软件。
if (requireNamespace("plotly", quietly = TRUE)) {
  w <- radar_sunburstly(p)
  w
  plotly::ggplotly(p, tooltip = "text")
  htmlwidgets::saveWidget(w, "我的交互图.html", selfcontained = FALSE)
}
```

`selfcontained = FALSE` 生成 HTML 和旁边的资源文件夹，两者一起保留即可离线
打开。交互支持悬停、缩放和雷达组显隐；大类图例只作解释，不做下钻或筛选。
非零文字旋转和部分第三方主题元素在 Plotly 中可能不同，默认横排文字。

作者及维护者：Muyao Shen。OpenAI Codex 参与设计、代码、数据和文档生成以及
自动验证；最终人工审核与发布决定由维护者负责。
