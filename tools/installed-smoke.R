# Run in a clean R session, from outside the checkout, after source installation.
library(radarsunburst)
stopifnot(setequal(getNamespaceExports("radarsunburst"),
                  c("radar_sunburst_data", "radar_sunburst", "radar_sunburstly",
                    "theme_radar_sunburst")))
requireNamespace("plotly", quietly = TRUE)
local({
  data("radar_sunburst_demo", package = "radarsunburst", envir = environment())
  d <- radar_sunburst_demo
  metrics <- c("score_stability", "score_efficiency", "score_innovation",
               "score_quality", "score_collaboration")
  hierarchy <- c("main_category", "sub_category", "leaf_category")
  before <- list(wd = getwd(), locale = Sys.getlocale(), options = options(),
                 globals = ls(envir = .GlobalEnv, all.names = TRUE))
  s <- radar_sunburst_data(d, metrics, "series", hierarchy)
  stopifnot(nrow(s$nodes) == 21L, all(s$nodes$count[s$nodes$level == 1L] == 8L),
            identical(unname(s$radar[1L, ]), c(90, 60, 70, 40, 65)))
  p <- radar_sunburst(d, metrics, "series", hierarchy)
  ggplot2::ggplot_build(p)
  w <- radar_sunburstly(p)
  stopifnot(inherits(w, "plotly"), identical(before$wd, getwd()),
            identical(before$locale, Sys.getlocale()), identical(before$options, options()),
            identical(before$globals, ls(envir = .GlobalEnv, all.names = TRUE)))
  cat("Clean installed-package session: OK; 4 exports; 21 nodes; means verified; session unchanged.\n")
})
