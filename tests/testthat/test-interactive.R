test_that("direct conversion and the wrapper preserve data and aspect ratio", {
  skip_if_not_installed("plotly")
  p <- plot_small()
  expect_no_warning(direct <- plotly::plotly_build(plotly::ggplotly(p, tooltip = "text")))
  expect_no_warning(w <- radar_sunburstly(p))
  expect_s3_class(w, "plotly")
  expect_equal(w$x$layout$yaxis$scaleanchor, "x")
  expect_equal(w$x$layout$yaxis$scaleratio, 1)
  texts <- unlist(lapply(w$x$data, function(t) t$text))
  expect_true(any(grepl("Mean: 6", texts, fixed = TRUE)))
  expect_true(any(grepl("Count: 3", texts, fixed = TRUE)))
  expect_true(any(grepl("Denominator (root): 3", texts, fixed = TRUE)))
  expect_setequal(unlist(lapply(direct$x$data, function(t) t$text)), texts)
  radar <- Filter(function(t) startsWith(t$legendgroup %||% "", "radar:"), w$x$data)
  expect_equal(sum(vapply(radar, function(t) isTRUE(t$showlegend), logical(1))), 2L)
  expect_true(all(vapply(radar, function(t) t$legendgroup %in% c("radar:one", "radar:two"), logical(1))))
  decorations <- Filter(function(t) !length(t$text) || all(is.na(t$text) | !nzchar(t$text)), w$x$data)
  expect_true(all(vapply(decorations, function(t) identical(t$hoverinfo, "skip"), logical(1))))
  geometry_labels <- Filter(function(t) identical(t$mode, "text"), w$x$data)
  expect_true(all(vapply(geometry_labels, function(t) identical(t$hoverinfo, "skip"), logical(1))))
  expect_true(grepl("plotly_legendclick", w$jsHooks$render[[1L]]$code, fixed = TRUE))
})

test_that("themes, count-only hover, Unicode and safe text conversion work", {
  skip_if_not_installed("plotly")
  for (th in list(ggplot2::theme_minimal(), ggplot2::theme_classic(),
                  ggplot2::theme_bw(), ggplot2::theme_dark())) {
    expect_no_warning(radar_sunburstly(plot_small() + th))
  }
  d <- small_data(); d$root[1:2] <- "\u4e2d\u6587 <x> & y"
  w <- radar_sunburstly(plot_small(d, percent = "none"))
  texts <- unlist(lapply(w$x$data, function(t) t$text))
  expect_true(any(grepl("\u4e2d\u6587 &lt;x&gt; &amp; y", texts, fixed = TRUE)))
  expect_false(any(grepl("Denominator", texts, fixed = TRUE)))
})

test_that("interactive arguments are validated", {
  expect_error(radar_sunburstly(NULL), "ggplot")
  expect_error(radar_sunburstly(plot_small(), width = -1), "width")
  expect_error(radar_sunburstly(plot_small(), tooltip = "all"), "managed")
})

`%||%` <- function(a, b) if (is.null(a)) b else a
