# Developer-only preview. Run from the package root before installing the package.
for (file in list.files("R", pattern = "[.]R$", full.names = TRUE)) source(file)
dir.create("artifacts/preview", recursive = TRUE, showWarnings = FALSE)
d <- utils::read.csv("demo_data.csv", fileEncoding = "UTF-8-BOM")
metrics <- c("score_stability", "score_efficiency", "score_innovation",
             "score_quality", "score_collaboration")
hierarchy <- c("main_category", "sub_category", "leaf_category")
options_demo <- list(data = d, metrics = metrics, group = "series", hierarchy = hierarchy,
  metric_labels = c("Stability", "Efficiency", "Innovation", "Quality", "Collaboration"),
  root_order = c("F", "C", "D", "B", "E"),
  root_colors = c(B = "#FF954F", C = "#F45668", D = "#DE578A", E = "#AE4D7C", F = "#725993"),
  group_colors = c("#8E176C", "#1485C8", "#00A58E", "#C78800"))
s <- radar_sunburst_data(d, metrics, "series", hierarchy)
stopifnot(nrow(s$nodes) == 21L, nrow(s$radar) == 4L)
p <- do.call(radar_sunburst, options_demo)
ggplot2::ggsave("artifacts/preview/default.png", p, width = 12, height = 8, dpi = 200)
ggplot2::ggsave("artifacts/preview/default.svg", p, width = 12, height = 8, device = grDevices::svg)
for (name in c("minimal", "classic", "bw", "dark")) {
  th <- get(paste0("theme_", name), envir = asNamespace("ggplot2"))()
  themed <- p + th + ggplot2::labs(title = paste("radarsunburst:", name))
  ggplot2::ggsave(paste0("artifacts/preview/", name, ".png"), themed,
                   width = 12, height = 8, dpi = 150)
  plotly::plotly_build(radar_sunburstly(themed))
}
w <- radar_sunburstly(p, width = 1100, height = 750)
htmlwidgets::saveWidget(w, "artifacts/preview/interactive.html", selfcontained = FALSE)
direct <- plotly::plotly_build(plotly::ggplotly(p, tooltip = "text"))
cat("Groups:", nrow(s$radar), "nodes:", nrow(s$nodes), "limits:", s$radar_limits, "\n")
cat("Interactive traces:", length(w$x$data), "direct:", length(direct$x$data), "\n")
cat("Visible legends:\n")
for (trace in w$x$data) if (isTRUE(trace$showlegend)) cat(trace$name, trace$legendgroup, trace$mode, "\n")
print(s$radar)
