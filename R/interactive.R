#' Convert a radar-sunburst plot to an interactive widget
#'
#' Configure hover information, equal-axis scaling and linked radar-group traces.
#' Plotly is optional: it is never installed automatically. Standard ggplot themes
#' are translated by Plotly, whose support for custom fonts, rotated geometry text
#' and third-party extensions can differ from static rendering.
#'
#' @param p A ggplot object produced by [radar_sunburst()], optionally modified
#'   with a theme, labels or scales.
#' @param width,height Optional widget width and height in pixels; finite positive
#'   numbers. When omitted, the containing page controls sizing.
#' @param ... Additional arguments passed to `plotly::ggplotly()`. The `tooltip`
#'   argument is managed by this function and must not be supplied here.
#' @returns A Plotly HTML widget. Hover shows counted paths and radar means;
#'   clicking a radar-group legend toggles its line, points and fill together.
#'   Category legend entries are explanatory and do not toggle isolated traces.
#'   No browser is opened and no file is written. Save explicitly with
#'   `htmlwidgets::saveWidget()`. Branch drill-down is not implemented.
#' @export
#' @examples
#' if (requireNamespace("plotly", quietly = TRUE)) {
#'   d <- data.frame(g = c("A", "B"), category = c("X", "Y"),
#'                   a = c(1, 3), b = c(2, 4), c = c(3, 5))
#'   p <- radar_sunburst(d, c("a", "b", "c"), "g", "category")
#'   w <- radar_sunburstly(p)
#'   inherits(w, "plotly")
#' }
radar_sunburstly <- function(p, width = NULL, height = NULL, ...) {
  if (!inherits(p, "ggplot")) stop("`p` must be a ggplot object.", call. = FALSE)
  for (name in c("width", "height")) {
    if (!is.null(get(name))) positive_scalar(get(name), name)
  }
  dots <- list(...)
  if ("tooltip" %in% names(dots)) {
    stop("`tooltip` is managed by radar_sunburstly(); do not supply it in `...`.",
         call. = FALSE)
  }
  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("Interactive conversion requires the optional 'plotly' package. ",
         "Install it in your R session before calling radar_sunburstly().", call. = FALSE)
  }
  w <- plotly::ggplotly(p, tooltip = "text", width = width, height = height, ...)
  w <- plotly::plotly_build(w)
  shown <- character()
  for (i in seq_along(w$x$data)) {
    trace <- w$x$data[[i]]
    text <- as.character(trace$text)
    useful <- text[!is.na(text) & nzchar(text)]
    if (!length(useful) || identical(trace$mode, "text")) {
      trace$hoverinfo <- "skip"
      trace$showlegend <- FALSE
    } else if (any(startsWith(useful, "Radar group: "))) {
      group <- sub("<br>.*$", "", sub("^Radar group: ", "", useful[1L]))
      trace$legendgroup <- paste0("radar:", group)
      trace$name <- group
      trace$showlegend <- !group %in% shown && identical(trace$mode, "markers")
      if (isTRUE(trace$showlegend)) shown <- c(shown, group)
    } else if (any(startsWith(useful, "Category path: "))) {
      root <- sub(".*<br>Root category: ([^<]*)<br>.*", "\\1", useful[1L])
      trace$name <- root
      trace$legendgroup <- paste0("category:", root)
      trace$hoveron <- "fills"
    }
    w$x$data[[i]] <- trace
  }
  w <- plotly::layout(w, yaxis = list(scaleanchor = "x", scaleratio = 1),
                      legend = list(groupclick = "togglegroup",
                                    title = list(text = "Categories and radar groups")))
  # Prevent category legend clicks while retaining radar toggling. No network
  # callbacks or persistent state are used; this hook runs only in the widget.
  if (!requireNamespace("htmlwidgets", quietly = TRUE)) {
    stop("Interactive conversion requires 'htmlwidgets'.", call. = FALSE)
  }
  htmlwidgets::onRender(w, "function(el, x) {
    el.on('plotly_legendclick', function(e) {
      var trace = el.data[e.curveNumber];
      if (trace && trace.legendgroup && trace.legendgroup.indexOf('category:') === 0) return false;
    });
    el.on('plotly_legenddoubleclick', function(e) {
      var trace = el.data[e.curveNumber];
      if (trace && trace.legendgroup && trace.legendgroup.indexOf('category:') === 0) return false;
    });
  }")
}
