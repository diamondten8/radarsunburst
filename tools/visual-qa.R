# Developer-only render cases; no package installation or user-state changes.
for (file in list.files("R", pattern = "[.]R$", full.names = TRUE)) source(file)
source("tests/testthat/helper-data.R")
directory <- "artifacts/preview"
dir.create(directory, recursive = TRUE, showWarnings = FALSE)
if (requireNamespace("ggthemes", quietly = TRUE)) {
  p <- plot_small() + ggthemes::theme_few() + ggplot2::theme(legend.position = "bottom")
  ggplot2::ggsave(file.path(directory, "third-party.png"), p, width = 10, height = 8, dpi = 150)
  htmlwidgets::saveWidget(radar_sunburstly(p), file.path(directory, "third-party.html"),
                          selfcontained = FALSE)
}
d <- small_data()
d$g <- c("\u7ec4\u4e00", "\u7ec4\u4e00", rep("\u7ec4\u4e8c", 3))
d$root <- c("\u7c7b\u522b\u7532", "\u7c7b\u522b\u7532", rep("\u7c7b\u522b\u4e59", 3))
d$child <- c("\u5171\u540c", "", "\u5171\u540c", "\u5171\u540c", "\u5176\u4ed6")
p <- plot_small(d, metric_labels = c("\u8d28\u91cf", "\u6548\u7387", "\u521b\u65b0"),
                label_family = "Microsoft YaHei")
ggplot2::ggsave(file.path(directory, "chinese.png"), p, width = 10, height = 8, dpi = 150,
                type = "cairo")
htmlwidgets::saveWidget(radar_sunburstly(p), file.path(directory, "chinese.html"), selfcontained = FALSE)
d <- data.frame(g = rep(c("one", "two"), 50), root = "All records",
                child = c(rep("Common branch", 85), paste0("Rare branch ", 1:15)),
                a = 1:100, b = 2:101, c = 3:102)
p <- radar_sunburst(d, c("a", "b", "c"), "g", c("root", "child"))
ggplot2::ggsave(file.path(directory, "small-sectors.png"), p, width = 10, height = 8, dpi = 150)
htmlwidgets::saveWidget(radar_sunburstly(p), file.path(directory, "small-sectors.html"),
                        selfcontained = FALSE)
