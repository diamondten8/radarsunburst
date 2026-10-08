test_that("plot geometry builds across percentages, depths and themes", {
  for (scope in c("root", "parent", "global", "none")) {
    p <- plot_small(percent = scope)
    expect_true(inherits(p, "ggplot"))
    expect_no_warning(ggplot2::ggplot_build(p))
    labels <- unlist(lapply(p$layers, function(layer) layer$data$label))
    expect_true(any(grepl("n=", labels, fixed = TRUE)))
    if (scope == "none") expect_false(any(grepl("%", labels, fixed = TRUE)))
    else expect_true(any(grepl("%", labels, fixed = TRUE)))
  }
  for (depth in seq_len(4L)) {
    d <- small_data(); fields <- paste0("h", seq_len(depth))
    for (field in fields) d[[field]] <- d$root
    expect_no_warning(ggplot2::ggplot_build(radar_sunburst(d, c("a", "b", "c"), "g", fields)))
  }
  p <- plot_small()
  for (th in list(ggplot2::theme_minimal(), ggplot2::theme_classic(),
                  ggplot2::theme_bw(), ggplot2::theme_dark())) {
    expect_no_warning(ggplot2::ggplot_build(p + th + ggplot2::labs(title = "Title")))
  }
  expect_no_warning(ggplot2::ggplot_build(p + ggplot2::theme(legend.position = "bottom")))
})

test_that("metric ring is independent and radar fills follow colour scales", {
  p <- plot_small(group_colors = c(one = "red", two = "blue"))
  b <- ggplot2::ggplot_build(p)
  expect_equal(b$plot$scales$get_scales("fill")$get_labels(), c("A", "B"))
  expect_equal(b$plot$scales$get_scales("colour")$get_labels(), c("one", "two"))
  # Changing a standard colour scale must change the translucent radar fill too.
  q <- p + ggplot2::scale_colour_manual(values = c(one = "green", two = "orange"))
  bb <- ggplot2::ggplot_build(q)
  fill_layer <- which(vapply(q$layers, function(l) {
    inherits(l$geom, "GeomPolygon") && identical(l$aes_params$alpha, 0.04)
  }, logical(1)))
  expect_length(fill_layer, 1L)
  expect_setequal(unique(bb$data[[fill_layer]]$fill), c("green", "orange"))
})

test_that("labels, lower bound and summaries preserve their contracts", {
  p <- plot_small(radar_limits = c(-10, 20), ticks = c(0, 10, 20))
  labels <- unlist(lapply(p$layers, function(l) l$data$label))
  expect_true(any(grepl("-10", labels, fixed = TRUE)))
  expect_equal(attr(p, "radar_sunburst_summary")$radar_limits, c(-10, 20))
  d <- small_data(); d$root <- paste0("Very long ", strrep("label", 30), d$root)
  crowded <- plot_small(d)
  expect_equal(nrow(attr(crowded, "radar_sunburst_summary")$nodes), 8L)
  expect_true(any(grepl("Very long", crowded$data$tooltip, fixed = TRUE)))
  # All five usual metric labels must remain present in the documented demo.
  d <- radar_sunburst_demo
  demo <- radar_sunburst(d, c("score_stability", "score_efficiency", "score_innovation",
    "score_quality", "score_collaboration"), "series",
    c("main_category", "sub_category", "leaf_category"),
    metric_labels = c("Stability", "Efficiency", "Innovation", "Quality", "Collaboration"))
  labels <- unlist(lapply(demo$layers, function(l) l$data$label))
  expect_true(all(c("Stability", "Efficiency", "Innovation", "Quality", "Collaboration") %in% labels))
})

test_that("plot validation is actionable", {
  expect_error(plot_small(percent = "wrong"), "arg")
  expect_error(plot_small(metric_ring = c(0.8, 1.2)), "outside")
  expect_error(plot_small(sunburst_radii = c(1, 2)), "4.*radii")
  expect_error(plot_small(label_size = -1), "label_size")
  expect_error(plot_small(root_colors = "red"), "one colour")
  expect_error(plot_small(root_colors = c("invalid", "red")), "invalid colour")
  expect_error(plot_small(metric_labels = "a"), "one non-empty")
  expect_error(plot_small(fill_alpha = 2), "between 0 and 1")
  expect_error(plot_small(ticks = c(-100, 100)), "within")
  expect_error(plot_small(label_angle = 100), "between -90 and 90")
  expect_error(plot_small(theme = list()), "ggplot2 theme")
})

test_that("runtime code does not mutate the user session or write files", {
  wd <- getwd(); locale <- Sys.getlocale(); opts <- options()
  globals <- ls(envir = .GlobalEnv, all.names = TRUE)
  files <- list.files(wd, all.files = TRUE, recursive = TRUE)
  plot_small()
  expect_identical(getwd(), wd)
  expect_identical(Sys.getlocale(), locale)
  expect_identical(options(), opts)
  expect_identical(ls(envir = .GlobalEnv, all.names = TRUE), globals)
  expect_identical(list.files(wd, all.files = TRUE, recursive = TRUE), files)
})

test_that("a third-party theme builds", {
  skip_if_not_installed("ggthemes")
  expect_no_warning(ggplot2::ggplot_build(plot_small() + ggthemes::theme_few()))
})
