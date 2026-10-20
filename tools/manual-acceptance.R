# Run in a fresh R session after installing the package. This is a user-invoked
# acceptance exercise, not runtime package code. No dependency is installed here.
library(radarsunburst)
library(ggplot2)

local({
  d <- data.frame(
    team = c("A", "A", "B", "B", "B"),
    category = c("X", "X", "X", "Y", "Y"),
    subcategory = c("X1", "X2", "X1", "Y1", ""),
    quality = c(70, 90, 40, 60, 80),
    efficiency = c(50, 70, 60, 80, 100),
    innovation = c(60, 80, 30, 50, 70)
  )
  metrics <- c("quality", "efficiency", "innovation")
  hierarchy <- c("category", "subcategory")
  s <- radar_sunburst_data(d, metrics, "team", hierarchy)
  stopifnot(identical(unname(s$radar[1L, ]), c(80, 60, 70)),
              identical(unname(s$radar[2L, ]), c(60, 80, 50)),
              nrow(s$nodes) == 5L,
              isTRUE(all.equal(s$radar_limits, c(26.5, 103.5))))
  print(s$radar)
  print(s$nodes[, c("label", "count", "parent_proportion", "root_proportion",
                     "global_proportion")])
  p <- ggplot(d) +
    geom_radsun(metrics = metrics, group = "team", hierarchy = hierarchy) +
    theme_radar_sunburst() + labs(title = "Manual acceptance: five records")
  quick <- radar_sunburst(d, metrics, "team", hierarchy)
  stopifnot(identical(attr(p, "radar_sunburst_summary"),
                      attr(quick, "radar_sunburst_summary")))
  print(p)
  for (scope in c("none", "parent", "root", "global")) {
    print(ggplot(d) + geom_radsun(metrics = metrics, group = "team",
                                  hierarchy = hierarchy, percent = scope) +
            theme_radar_sunburst() + labs(title = paste("Percent:", scope)))
  }
  print(p + theme_minimal() + theme(legend.position = "bottom"))
  fixed <- radar_sunburst(d, metrics, "team", hierarchy,
                           radar_limits = c(0, 100))
  print(fixed)
  # Catch only the intentionally invalid input in this manual exercise.
  bad <- d
  bad$quality[2L] <- NA_real_
  message("Expected next error: metric quality, row 2.")
  tryCatch(radar_sunburst_data(bad, metrics, "team", hierarchy),
             error = function(e) message(conditionMessage(e)))

  output <- file.path(tempdir(), "radarsunburst-manual")
  dir.create(output, showWarnings = FALSE)
  ggsave(file.path(output, "chart.png"), p, width = 10, height = 8, dpi = 150)
  if (requireNamespace("plotly", quietly = TRUE) &&
      requireNamespace("htmlwidgets", quietly = TRUE)) {
    direct <- plotly::ggplotly(p, tooltip = "text")
    configured <- radar_sunburstly(p, width = 900, height = 700)
    stopifnot(inherits(direct, "plotly"), inherits(configured, "plotly"))
    htmlwidgets::saveWidget(configured, file.path(output, "chart.html"),
                            selfcontained = FALSE)
    message("Open chart.html in your browser; inspect hover, zoom, legend toggles",
              " and circle proportions. The *_files directory must stay beside it.")
  } else {
    message("Optional interactive exercise not run: install plotly/htmlwidgets explicitly first.")
  }
  message("Exercise files: ", output,
            ". Temporary files are removed when the R session ends; copy them if needed.")
  message("Numeric checks passed. Visual and browser acceptance still require your review.")
})
