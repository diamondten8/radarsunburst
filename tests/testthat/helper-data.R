small_data <- function() {
  data.frame(g = c("one", "one", "two", "two", "two"),
             root = c("A", "A", "B", "B", "B"),
             child = c("same", "", "same", "same", "other"),
             leaf = c("x", "", "y", "", "z"),
             a = c(-2, 2, 4, 6, 8), b = c(0, 4, 6, 8, 10),
             c = c(2, 6, 8, 10, 12), stringsAsFactors = FALSE)
}

summarise_small <- function(d = small_data(), ...) {
  radar_sunburst_data(d, c("a", "b", "c"), "g", c("root", "child", "leaf"), ...)
}

plot_small <- function(d = small_data(), ...) {
  radar_sunburst(d, c("a", "b", "c"), "g", c("root", "child", "leaf"), ...)
}
