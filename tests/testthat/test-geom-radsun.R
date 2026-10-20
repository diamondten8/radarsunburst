component_small <- function(data = NULL, ...) {
  geom_radsun(data = data, metrics = c("a", "b", "c"), group = "g",
               hierarchy = c("root", "child", "leaf"), ...)
}

test_that("component and one-call interfaces produce the same chart", {
  d <- small_data()
  for (scope in c("root", "parent", "global", "none")) {
    complete <- plot_small(d, percent = scope)
    inherited <- ggplot2::ggplot(d) + component_small(percent = scope) +
      theme_radar_sunburst()
    explicit <- ggplot2::ggplot() + component_small(d, percent = scope) +
      theme_radar_sunburst()
    expect_equal(attr(inherited, "radar_sunburst_summary"),
                   attr(complete, "radar_sunburst_summary"))
    expect_no_warning(b <- ggplot2::ggplot_build(inherited))
    expect_equal(b$data, ggplot2::ggplot_build(complete)$data)
    expect_equal(b$data, ggplot2::ggplot_build(explicit)$data)
    expect_identical(inherited$data, d)
  }
})

test_that("component preserves the parent plot and isolates generated mappings", {
  d <- small_data()
  # These columns are deliberately absent from the generated geometry tables.
  base <- ggplot2::ggplot(d, ggplot2::aes(x = .data$a, y = .data$b,
                                         shape = .data$g)) +
    ggplot2::geom_point() + ggplot2::theme_minimal() +
    ggplot2::labs(title = "Keep me", subtitle = "Keep this too")
  p <- base + component_small()
  expect_identical(p$data, base$data)
  expect_identical(p$mapping, base$mapping)
  expect_identical(p$layers[[1L]], base$layers[[1L]])
  expect_identical(p$theme, base$theme)
  expect_identical(p$labels$title, "Keep me")
  expect_identical(p$labels$subtitle, "Keep this too")
  expect_true(all(vapply(p$layers[-1L], function(l) !l$inherit.aes, logical(1L))))
  expect_no_warning(ggplot2::ggplot_build(p))
  expect_equal(p$coordinates$ratio, 1)
  # Data supplied on the component take priority over unrelated plot data.
  q <- ggplot2::ggplot(data.frame(unrelated = 1)) + component_small(d)
  expect_no_warning(ggplot2::ggplot_build(q))
  expect_equal(attr(q, "radar_sunburst_summary"), summarise_small(d))
  # The same specification can be reused without retaining prior input data.
  specification <- component_small()
  first <- ggplot2::ggplot(d) + specification
  second <- ggplot2::ggplot(d[1:2, ]) + specification
  expect_equal(attr(first, "radar_sunburst_summary")$nodes$total_count[1L], 5)
  expect_equal(attr(second, "radar_sunburst_summary")$nodes$total_count[1L], 2)
})

test_that("component styling and annotation remain standard ggplot operations", {
  p <- ggplot2::ggplot(small_data()) + component_small()
  for (th in list(ggplot2::theme_minimal(), ggplot2::theme_classic(),
                  ggplot2::theme_bw(), ggplot2::theme_dark())) {
    expect_no_warning(ggplot2::ggplot_build(p + th))
  }
  q <- p + ggplot2::scale_colour_manual(values = c(one = "red", two = "blue")) +
    ggplot2::annotate("point", x = 0, y = 0, colour = "black") +
    ggplot2::labs(title = "Custom")
  expect_no_warning(b <- ggplot2::ggplot_build(q))
  expect_equal(q$labels$title, "Custom")
  expect_setequal(b$plot$scales$get_scales("colour")$map(c("one", "two")),
                    c("red", "blue"))
  colours <- unlist(lapply(b$data, function(l) l$fill))
  expect_false("#E5E7EB" %in% colours)
})

test_that("component validates resolved data and unsupported duplication", {
  expect_s3_class(component_small(), "radsun_layer")
  expect_error(ggplot2::ggplot() + component_small(), "data frame")
  expect_error(ggplot2::ggplot() + component_small(1), "data frame")
  expect_error(ggplot2::ggplot(data.frame(a = 1)) + component_small(), "missing columns")
  expect_error(ggplot2::ggplot(small_data()) + component_small(label_size = -1), "label_size")
  expect_error(ggplot2::ggplot(small_data()) + component_small(percent = "bad"), "arg")
  p <- ggplot2::ggplot(small_data()) + component_small()
  expect_error(p + component_small(), "Only one")
})

test_that("component supports direct and configured Plotly conversion", {
  skip_if_not_installed("plotly")
  p <- ggplot2::ggplot(small_data()) + component_small() + theme_radar_sunburst()
  expect_no_warning(direct <- plotly::plotly_build(plotly::ggplotly(p, tooltip = "text")))
  expect_no_warning(w <- radar_sunburstly(p))
  expected <- radar_sunburstly(plot_small())
  texts <- function(widget) unlist(lapply(widget$x$data, function(t) t$text))
  expect_setequal(texts(direct), texts(expected))
  expect_setequal(texts(w), texts(expected))
  expect_equal(w$x$layout$yaxis$scaleanchor, "x")
  expect_equal(w$x$layout$yaxis$scaleratio, 1)
})
