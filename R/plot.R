#' Draw a radar chart surrounded by a counted sunburst
#'
#' The radar summarises numeric cells by group; the sunburst independently counts
#' rows along a hierarchy. Metric axes and root categories need not correspond.
#' All geometry is built from standard 'ggplot2' layers in Cartesian coordinates.
#'
#' @inheritParams radar_sunburst_data
#' @param percent Label denominator: `"root"` (default), `"parent"`, `"global"`,
#'   or `"none"`. Counts are always shown. This does not change sector angles.
#' @param metric_labels Optional character vector, one label per metric.
#' @param root_colors,group_colors Optional colour vectors, either unnamed in the
#'   corresponding order or named for every root/group. Defaults use the
#'   qualitative "Dark 3" palette. Change the fill/colour scales on the returned
#'   plot to override them using standard ggplot2 scales.
#' @param metric_colors Optional colours for metric-name sectors, independent of
#'   the root fill scale. Defaults to light grey. Supply one or one per metric.
#' @param radar_radius Positive radius of the radar. Defaults to 1.
#' @param metric_ring Increasing length-two numeric vector outside the radar.
#' @param sunburst_radii Increasing vector with one more entry than hierarchy
#'   levels, outside `metric_ring`. Defaults to equally thick rings of width 0.55.
#' @param label_size,metric_label_size Text sizes in millimetres for hierarchy and
#'   metric labels. Long labels are reduced to fit, then hidden below `min_label_size`.
#' @param min_label_size Minimum readable label size in millimetres.
#' @param label_colour,metric_label_colour Colours of hierarchy and metric labels.
#' @param label_angle Clockwise text rotation in degrees, between -90 and 90.
#'   The default is horizontal, which also converts reliably with ggplotly.
#'   Nonzero angles are for static output; Plotly may not retain rotation.
#' @param label_family Font family for labels and radar ticks. An empty string
#'   uses the device default. Theme text settings control titles and legends,
#'   not these geometry labels. Fonts must exist on the rendering machine.
#' @param line_width,point_size Radar line width and node size in millimetres.
#' @param fill_alpha Radar polygon opacity, between zero and one.
#' @param border_width Sector boundary width in millimetres.
#' @param ticks Optional finite numeric radar ticks within `radar_limits`.
#'   Defaults to the lower limit and pretty interior ticks. The actual lower
#'   bound is labelled at the centre, not an implicit zero.
#' @param theme A ggplot2 theme. Defaults to [theme_radar_sunburst()]. Standard
#'   themes can also be added afterwards with `+`.
#'
#' @returns A standard ggplot object, with a `radar_sunburst_summary` attribute
#'   containing the result of [radar_sunburst_data()]. Creating the plot does not
#'   open a device or write files. Use `ggplot2::ggsave()` for static export,
#'   [radar_sunburstly()] for configured interaction, or
#'   `plotly::ggplotly(p, tooltip = "text")` for direct conversion.
#' @importFrom rlang .data
#' @export
#' @examples
#' d <- data.frame(group = c("A", "A", "B"), category = c("X", "Y", "X"),
#'                 a = c(2, 4, 6), b = c(3, 5, 7), c = c(4, 6, 8))
#' p <- radar_sunburst(d, c("a", "b", "c"), "group", "category")
#' p + ggplot2::theme_minimal() + ggplot2::labs(title = "Counted categories")
radar_sunburst <- function(data, metrics, group, hierarchy,
                           percent = c("root", "parent", "global", "none"),
                           radar_limits = NULL, group_order = NULL,
                           root_order = NULL, branch_order = list(),
                           metric_labels = NULL, root_colors = NULL,
                           group_colors = NULL, metric_colors = "#E5E7EB",
                           radar_radius = 1, metric_ring = c(1.06, 1.55),
                           sunburst_radii = NULL, label_size = 4,
                           metric_label_size = 3, min_label_size = 1.5,
                           label_colour = "white", metric_label_colour = "#283142",
                           label_angle = 0, label_family = "",
                           line_width = 0.65, point_size = 2, fill_alpha = 0.04,
                           border_width = 0.55, ticks = NULL,
                           theme = theme_radar_sunburst()) {
  percent <- match.arg(percent)
  s <- radar_sunburst_data(data, metrics, group, hierarchy, radar_limits,
                          group_order, root_order, branch_order)
  positive_scalar(radar_radius, "radar_radius")
  for (name in c("label_size", "metric_label_size", "min_label_size", "point_size")) {
    positive_scalar(get(name), name)
  }
  for (name in c("line_width", "border_width")) positive_scalar(get(name), name, zero = TRUE)
  if (!is.numeric(fill_alpha) || length(fill_alpha) != 1L ||
      !is.finite(fill_alpha) || fill_alpha < 0 || fill_alpha > 1) {
    stop("`fill_alpha` must be a finite number between 0 and 1.", call. = FALSE)
  }
  if (!is.numeric(label_angle) || length(label_angle) != 1L ||
      !is.finite(label_angle) || abs(label_angle) > 90) {
    stop("`label_angle` must be a finite number between -90 and 90.", call. = FALSE)
  }
  if (!is.character(label_family) || length(label_family) != 1L || is.na(label_family)) {
    stop("`label_family` must be one non-missing character string.", call. = FALSE)
  }
  increasing_radii(metric_ring, 2L, "metric_ring")
  if (metric_ring[1L] <= radar_radius) {
    stop("`metric_ring` must lie outside `radar_radius`.", call. = FALSE)
  }
  if (is.null(sunburst_radii)) {
    sunburst_radii <- metric_ring[2L] + 0.08 + seq.int(0, length(hierarchy)) * 0.55
  }
  increasing_radii(sunburst_radii, length(hierarchy) + 1L, "sunburst_radii")
  if (sunburst_radii[1L] <= metric_ring[2L]) {
    stop("`sunburst_radii` must lie outside `metric_ring`.", call. = FALSE)
  }
  if (is.null(metric_labels)) metric_labels <- metrics
  if (!is.character(metric_labels) || length(metric_labels) != length(metrics) ||
      anyNA(metric_labels) || any(!nzchar(metric_labels))) {
    stop("`metric_labels` must contain one non-empty label per metric.", call. = FALSE)
  }
  root_colors <- chart_colors(root_colors, s$root_order, "root_colors")
  group_colors <- chart_colors(group_colors, s$group_order, "group_colors")
  if (length(metric_colors) == 1L) metric_colors <- rep(metric_colors, length(metrics))
  if (length(metric_colors) != length(metrics)) {
    stop("`metric_colors` must have length one or the number of metrics.", call. = FALSE)
  }
  validate_colors(metric_colors, "metric_colors")
  validate_colors(label_colour, "label_colour", scalar = TRUE)
  validate_colors(metric_label_colour, "metric_label_colour", scalar = TRUE)
  if (!inherits(theme, "theme")) stop("`theme` must be a ggplot2 theme.", call. = FALSE)
  lim <- s$radar_limits
  if (is.null(ticks)) {
    ticks <- pretty(lim, n = 5L)
    ticks <- sort(unique(c(lim[1L], ticks[ticks > lim[1L] & ticks <= lim[2L]])))
  }
  if (!is.numeric(ticks) || !length(ticks) || any(!is.finite(ticks)) ||
      any(ticks < lim[1L] | ticks > lim[2L]) || anyDuplicated(ticks)) {
    stop("`ticks` must be distinct finite numbers within `radar_limits`.", call. = FALSE)
  }
  ticks <- sort(unique(c(lim[1L], ticks)))
  nodes <- s$nodes
  nodes$root <- factor(nodes$root, levels = s$root_order)
  nodes$tooltip <- node_tooltips(nodes, percent)
  nodes$display_label <- node_labels(nodes, percent)
  polygons <- do.call(rbind, lapply(seq_len(nrow(nodes)), function(i) {
    xy <- annular_sector(nodes$start[i], nodes$end[i],
                         sunburst_radii[nodes$level[i]],
                         sunburst_radii[nodes$level[i] + 1L])
    xy$id <- nodes$id[i]
    xy$root <- nodes$root[i]
    xy$tooltip <- nodes$tooltip[i]
    xy
  }))
  polygons$root <- factor(polygons$root, levels = s$root_order)
  p <- ggplot2::ggplot(polygons,
                       ggplot2::aes(x = .data$x, y = .data$y, text = .data$tooltip)) +
    ggplot2::geom_polygon(ggplot2::aes(group = .data$id, fill = .data$root),
                          colour = "white", linewidth = border_width) +
    ggplot2::scale_fill_manual(values = root_colors, breaks = s$root_order,
                               name = "Categories", drop = FALSE)
  labels <- sector_text_data(nodes, sunburst_radii, label_size, min_label_size,
                              label_angle, max(sunburst_radii))
  if (nrow(labels)) {
    p <- p + ggplot2::geom_text(data = labels,
      mapping = ggplot2::aes(label = .data$label, size = .data$size),
      colour = label_colour, angle = label_angle, family = label_family,
      fontface = "bold", show.legend = FALSE)
  }
  angles <- 2 * pi * (seq_along(metrics) - 1L) / length(metrics)
  metric_nodes <- data.frame(start = angles - pi / length(metrics),
                             end = angles + pi / length(metrics), level = 1L,
                             display_label = metric_labels)
  for (i in seq_along(metrics)) {
    xy <- annular_sector(metric_nodes$start[i], metric_nodes$end[i],
                         metric_ring[1L], metric_ring[2L])
    xy$tooltip <- ""
    p <- p + ggplot2::geom_polygon(data = xy, fill = metric_colors[i],
                                    colour = "white", linewidth = border_width,
                                    show.legend = FALSE)
  }
  metric_text <- sector_text_data(metric_nodes, metric_ring, metric_label_size,
                                   min_label_size, 0, max(sunburst_radii))
  if (nrow(metric_text)) {
    p <- p + ggplot2::geom_text(data = metric_text,
      mapping = ggplot2::aes(label = .data$label, size = .data$size),
      colour = metric_label_colour, family = label_family, fontface = "bold",
      show.legend = FALSE)
  }
  closed <- c(seq_along(metrics), 1L)
  radius <- function(x) radar_radius * (x - lim[1L]) / diff(lim)
  grid <- do.call(rbind, lapply(seq_along(ticks), function(i) {
    data.frame(x = radius(ticks[i]) * sin(angles[closed]),
               y = radius(ticks[i]) * cos(angles[closed]), id = i, tooltip = "")
  }))
  axes <- data.frame(x = 0, y = 0, xend = radar_radius * sin(angles),
                      yend = radar_radius * cos(angles), tooltip = "")
  p <- p + ggplot2::geom_path(data = grid, ggplot2::aes(group = .data$id),
                              colour = "#B6B7BC", linewidth = 0.25, show.legend = FALSE) +
    ggplot2::geom_segment(data = axes,
      mapping = ggplot2::aes(xend = .data$xend, yend = .data$yend),
      colour = "#CDCDD1", linewidth = 0.25, show.legend = FALSE)
  radar_points <- do.call(rbind, lapply(seq_along(s$group_order), function(i) {
    r <- radius(s$radar[i, ])
    data.frame(x = r * sin(angles), y = r * cos(angles),
               series = s$group_order[i], metric = metrics,
               tooltip = paste0("Radar group: ", html_escape(s$group_order[i]),
                                "<br>Metric: ", html_escape(metric_labels),
                                "<br>Mean: ", format_number(s$radar[i, ])),
               stringsAsFactors = FALSE)
  }))
  radar_points$series <- factor(radar_points$series, levels = s$group_order)
  radar_paths <- do.call(rbind, lapply(s$group_order, function(g) {
    rows <- radar_points[radar_points$series == g, , drop = FALSE]
    rows[closed, , drop = FALSE]
  }))
  # Use the line colour scale for fills as well, preserving a single group legend.
  if (fill_alpha > 0) {
    p <- p + ggplot2::geom_polygon(data = radar_paths,
      mapping = ggplot2::aes(group = .data$series, colour = .data$series,
                              fill = ggplot2::after_scale(.data$colour)),
      linewidth = 0, alpha = fill_alpha, show.legend = FALSE)
  }
  p <- p + ggplot2::geom_path(data = radar_paths,
      mapping = ggplot2::aes(group = .data$series, colour = .data$series),
      linewidth = line_width) +
    ggplot2::geom_point(data = radar_points, ggplot2::aes(colour = .data$series),
                         size = point_size) +
    ggplot2::scale_colour_manual(values = group_colors, breaks = s$group_order,
                                 name = "Radar groups", drop = FALSE)
  tick_text <- data.frame(x = radar_radius * 0.035, y = radius(ticks),
                           label = format_number(ticks), tooltip = "")
  outer <- utils::tail(sunburst_radii, 1L) * 1.07
  p <- p + ggplot2::geom_text(data = tick_text, ggplot2::aes(label = .data$label),
                               colour = metric_label_colour, family = label_family,
                               size = 2.5, hjust = 0, show.legend = FALSE) +
    ggplot2::scale_size_identity() +
    ggplot2::coord_fixed(xlim = c(-outer, outer), ylim = c(-outer, outer),
                         expand = FALSE, clip = "off") +
    ggplot2::labs(x = NULL, y = NULL) + theme
  attr(p, "radar_sunburst_summary") <- s
  p
}

positive_scalar <- function(x, name, zero = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) ||
      if (zero) x < 0 else x <= 0) {
    stop("`", name, "` must be a finite ", if (zero) "non-negative" else "positive",
         " number.", call. = FALSE)
  }
}

increasing_radii <- function(x, n, name) {
  if (!is.numeric(x) || length(x) != n || any(!is.finite(x)) ||
      any(x <= 0) || any(diff(x) <= 0)) {
    stop("`", name, "` must contain ", n, " finite, positive, increasing radii.",
         call. = FALSE)
  }
}

validate_colors <- function(x, name, scalar = FALSE) {
  if (!is.character(x) || !length(x) || anyNA(x) ||
      (scalar && length(x) != 1L)) {
    stop("`", name, "` must contain valid colour strings.", call. = FALSE)
  }
  tryCatch(grDevices::col2rgb(x), error = function(e) {
    stop("`", name, "` contains an invalid colour: ", conditionMessage(e), call. = FALSE)
  })
  invisible(NULL)
}

chart_colors <- function(colors, identifiers, name) {
  if (is.null(colors)) colors <- grDevices::hcl.colors(length(identifiers), "Dark 3")
  if (!is.null(names(colors))) {
    if (anyDuplicated(names(colors)) || !setequal(names(colors), identifiers)) {
      stop("`", name, "` names must match every identifier exactly once.", call. = FALSE)
    }
    colors <- colors[identifiers]
  }
  if (length(colors) != length(identifiers)) {
    stop("`", name, "` must provide one colour per identifier.", call. = FALSE)
  }
  validate_colors(colors, name)
  stats::setNames(colors, identifiers)
}

annular_sector <- function(a, b, r0, r1) {
  theta <- seq(a, b, length.out = max(24L, ceiling((b - a) * 60)))
  data.frame(x = c(r1 * sin(theta), r0 * sin(rev(theta))),
             y = c(r1 * cos(theta), r0 * cos(rev(theta))))
}

format_number <- function(x) format(signif(x, 5L), trim = TRUE, scientific = FALSE)

html_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

node_labels <- function(nodes, percent) {
  count <- paste0("n=", nodes$count)
  if (percent == "none") return(paste(nodes$label, count, sep = "\n"))
  prop <- nodes[[paste0(percent, "_proportion")]]
  paste(nodes$label, count, paste0(format_number(100 * prop), "%"), sep = "\n")
}

node_tooltips <- function(nodes, percent) {
  path <- vapply(nodes$path, function(x) paste(html_escape(x), collapse = " / "), character(1L))
  text <- paste0("Category path: ", path, "<br>Root category: ",
                 html_escape(as.character(nodes$root)), "<br>Count: ", nodes$count)
  if (percent == "none") return(text)
  denominator <- switch(percent, parent = nodes$parent_count, root = nodes$root_count,
                         global = nodes$total_count)
  paste0(text, "<br>Denominator (", percent, "): ", denominator,
         "<br>Proportion: ", format_number(100 * nodes[[paste0(percent, "_proportion")]]), "%")
}

sector_text_data <- function(nodes, radii, size, minimum, angle, panel_radius) {
  output <- lapply(seq_len(nrow(nodes)), function(i) {
    r0 <- radii[nodes$level[i]]
    r1 <- radii[nodes$level[i] + 1L]
    theta <- (nodes$start[i] + nodes$end[i]) / 2
    r <- (r0 + r1) / 2
    x <- r * sin(theta)
    y <- r * cos(theta)
    lines <- strsplit(nodes$display_label[i], "\n", fixed = TRUE)[[1L]]
    # Device-independent, conservative text bounds at a 180 mm panel diameter.
    # Actual font metrics vary; crowded charts should be inspected at export size.
    units_per_mm <- 2 * panel_radius / 180
    fitted <- size
    fits <- function(text_size) {
      half_width <- max(nchar(lines, type = "width")) * text_size * 0.60 * units_per_mm / 2
      half_height <- length(lines) * text_size * 1.18 * units_per_mm / 2
      corners <- expand.grid(x = c(-half_width, half_width), y = c(-half_height, half_height))
      rotation <- angle * pi / 180
      cx <- x + corners$x * cos(rotation) - corners$y * sin(rotation)
      cy <- y + corners$x * sin(rotation) + corners$y * cos(rotation)
      rho <- sqrt(cx^2 + cy^2)
      offsets <- (atan2(cx, cy) - theta + pi) %% (2 * pi) - pi
      all(rho > r0 + 0.015 & rho < r1 - 0.015) &&
        all(abs(offsets) < (nodes$end[i] - nodes$start[i]) / 2 - 0.01)
    }
    while (fitted >= minimum && !fits(fitted)) fitted <- fitted * 0.9
    if (fitted < minimum) return(NULL)
    data.frame(x = x, y = y, label = nodes$display_label[i], size = fitted, tooltip = "")
  })
  result <- do.call(rbind, output)
  if (is.null(result)) data.frame() else result
}
