#' Add a radar-sunburst composite to a ggplot
#'
#' A composite component made from standard ggplot2 layers. It adds radar
#' profiles, counted hierarchy sectors, labels, fill/colour/size scales, and
#' fixed Cartesian coordinates. It does not add a theme. Use
#' [radar_sunburst()] for the same chart with a default theme in one call.
#'
#' @inheritParams radar_sunburst
#' @param data A data frame, or NULL to use the data supplied to
#'   `ggplot2::ggplot()`. Metrics, group and hierarchy are column-name strings.
#' @details
#' This component computes its own x/y positions and colour groups; it does not
#' inherit the parent plot's `aes()` mappings. Supply column names through
#' `metrics`, `group` and `hierarchy` instead. Data are resolved and validated
#' when the component is added to a plot, not when its specification is created.
#'
#' Existing layers, plot data, titles and themes are preserved. The component
#' supplies fill, colour and size scales and fixed coordinates; add replacement
#' colour scales afterwards. Keep fixed linear coordinates to retain circles.
#' One radar-sunburst component per plot is supported. Faceting, transformed
#' axes and combining multiple radar-sunburst datasets in a panel are outside
#' this interface's scope. Additional annotations use the generated Cartesian
#' coordinates, not the original metric units.
#'
#' @returns An addable `radsun_layer` specification. Adding it to a ggplot
#'   returns a standard ggplot object with a `radar_sunburst_summary` attribute.
#'   Both direct `plotly::ggplotly(p, tooltip = "text")` conversion and
#'   [radar_sunburstly()] are supported. No file or graphics device is opened.
#' @export
#' @examples
#' d <- data.frame(g = c("A", "A", "B"), category = c("X", "Y", "X"),
#'                 a = c(2, 4, 6), b = c(3, 5, 7), c = c(4, 6, 8))
#' p <- ggplot2::ggplot(d) +
#'   geom_radsun(metrics = c("a", "b", "c"), group = "g",
#'               hierarchy = "category") +
#'   theme_radar_sunburst() + ggplot2::labs(title = "A composite component")
#' p
#' # Explicit component data also work on an empty ggplot.
#' ggplot2::ggplot() +
#'   geom_radsun(data = d, metrics = c("a", "b", "c"),
#'               group = "g", hierarchy = "category") +
#'   theme_radar_sunburst()
geom_radsun <- function(data = NULL, metrics, group, hierarchy,
                        percent = c("root", "parent", "global", "none"),
                        radar_limits = NULL, group_order = NULL,
                        root_order = NULL, branch_order = list(),
                        metric_labels = NULL, show_metric_labels = FALSE,
                        root_colors = NULL, group_colors = NULL,
                        metric_colors = "#E5E7EB", radar_radius = 1,
                        metric_ring = NULL, sunburst_radii = NULL,
                        label_size = 4, metric_label_size = 3,
                        min_label_size = 1.5, label_colour = "white",
                        metric_label_colour = "#283142", label_angle = 0,
                        label_family = "", line_width = 0.65,
                        point_size = 2, fill_alpha = 0.04,
                        border_width = 0.55, ticks = NULL) {
  params <- mget(names(formals(geom_radsun)), envir = environment(), inherits = FALSE)
  structure(list(params = params), class = "radsun_layer")
}

# Register the ggplot2 3.5-compatible addition hook. ggplot2 4.x also dispatches
# legacy S3 additions through this hook, keeping the declared minimum supported.
#' @importFrom ggplot2 ggplot_add
#' @export
ggplot_add.radsun_layer <- function(object, plot, object_name) {
  if (!is.null(attr(plot, "radar_sunburst_summary"))) {
    stop("Only one `geom_radsun()` component is supported per plot.", call. = FALSE)
  }
  params <- object$params
  if (is.null(params$data)) params$data <- plot$data
  if (!is.data.frame(params$data)) {
    stop("`geom_radsun()` needs a data frame in `data` or `ggplot(data)`.", call. = FALSE)
  }
  compiled <- do.call(radsun_components, params)
  plot <- plot + compiled$components
  attr(plot, "radar_sunburst_summary") <- compiled$summary
  plot
}
