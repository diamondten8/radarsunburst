#' A theme for radar-sunburst charts
#'
#' A void theme with a right-hand legend, modest margins and a white background.
#' Standard themes can replace this theme; axis/grid decorations reintroduced by
#' those themes are ordinary Cartesian decorations, not additional radar axes.
#'
#' @param base_size Base font size in points.
#' @param base_family Font family for theme text, such as titles and legends.
#' @returns A ggplot2 theme. Geometry labels are controlled by the label arguments
#'   of [radar_sunburst()], independently of the theme.
#' @export
#' @examples
#' theme_radar_sunburst(base_size = 12)
theme_radar_sunburst <- function(base_size = 11, base_family = "") {
  positive_scalar(base_size, "base_size")
  if (!is.character(base_family) || length(base_family) != 1L || is.na(base_family)) {
    stop("`base_family` must be one non-missing character string.", call. = FALSE)
  }
  ggplot2::theme_void(base_size = base_size, base_family = base_family) +
    ggplot2::theme(legend.position = "right", legend.title = ggplot2::element_text(face = "bold"),
                   plot.title = ggplot2::element_text(hjust = 0.5),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA),
                   plot.margin = ggplot2::margin(8, 8, 8, 8))
}
