#' Summarise records for a radar-sunburst chart
#'
#' Count records along a hierarchy and calculate arithmetic means of numeric
#' metrics within each group. Each input row counts once; rows are not deduplicated
#' and no weight or percentage column is required.
#'
#' @param data A non-empty data frame. Extra columns are ignored.
#' @param metrics Character vector naming at least three distinct numeric columns.
#'   Values must be finite and complete.
#' @param group Single column name identifying radar groups. Character, factor,
#'   numeric and logical identifiers are accepted, with no missing or blank values.
#' @param hierarchy Character vector of distinct column names, from root to leaf.
#'   Missing or blank values below the root terminate a branch. Levels cannot be
#'   skipped. Identifiers accept the same types as `group`.
#' @param radar_limits Optional finite, increasing numeric vector of length two.
#'   It must contain all input metric values. By default, the common input range
#'   is expanded by 5 percent of its span at both ends. A constant value is
#'   expanded by `max(1, abs(value) * 0.05)` at each end.
#' @param group_order,root_order Optional character vectors containing each
#'   observed group or root exactly once. Defaults to first appearance in `data`.
#' @param branch_order A named list of character vectors setting child order.
#'   Names are parent node IDs (see the returned `nodes$id`). Every supplied
#'   order must contain all observed non-empty children of that parent exactly
#'   once. Terminated records always reserve the first, unpainted child interval.
#'
#' @returns A list of class `radar_sunburst_data` with `radar` (a group-by-metric
#'   matrix), `nodes` (a data frame), `radar_limits`, `metrics`, `group_order`,
#'   `root_order`, and `n`. Node columns are `id`, `parent_id`, `root_id`, `level`,
#'   `label`, `path` (a list of complete character paths), `root`, `count`,
#'   `parent_count`, `root_count`, `total_count`, `parent_proportion`,
#'   `root_proportion`, `global_proportion`, `start`, and `end` (radians clockwise
#'   from the top). Proportions lie between zero and one. A root's parent is the entire table.
#'   IDs encode UTF-8 path components without relying on a slash delimiter.
#'   No files or user-session settings are changed.
#' @export
#' @examples
#' d <- data.frame(group = c("A", "A", "B"), category = c("X", "Y", "X"),
#'                 a = c(2, 4, 6), b = c(3, 5, 7), c = c(4, 6, 8))
#' s <- radar_sunburst_data(d, c("a", "b", "c"), "group", "category")
#' s$radar
#' s$nodes[, c("label", "count", "global_proportion")]
radar_sunburst_data <- function(data, metrics, group, hierarchy,
                                radar_limits = NULL, group_order = NULL,
                                root_order = NULL, branch_order = list()) {
  if (!is.data.frame(data) || !nrow(data)) {
    stop("`data` must be a non-empty data frame.", call. = FALSE)
  }
  if (anyNA(names(data)) || anyDuplicated(names(data)) || any(!nzchar(names(data)))) {
    stop("`data` must have unique, non-empty column names.", call. = FALSE)
  }
  check_columns(metrics, "metrics", minimum = 3L)
  check_columns(group, "group", minimum = 1L, maximum = 1L)
  check_columns(hierarchy, "hierarchy", minimum = 1L)
  missing <- setdiff(c(metrics, group, hierarchy), names(data))
  if (length(missing)) {
    stop("`data` is missing columns: ", paste(missing, collapse = ", "), ".",
         call. = FALSE)
  }
  for (metric in metrics) {
    values <- data[[metric]]
    if (!is.numeric(values) || is.complex(values) || !is.null(dim(values))) {
      stop("Metric `", metric, "` must be a numeric vector.", call. = FALSE)
    }
    bad <- which(!is.finite(values))
    if (length(bad)) {
      stop("Metric `", metric, "` has missing or non-finite values at rows: ",
           paste(utils::head(bad, 8L), collapse = ", "), ".", call. = FALSE)
    }
  }
  groups <- identifiers(data[[group]], group)
  if (anyNA(groups) || any(!nzchar(groups))) {
    stop("Group column `", group, "` contains missing or blank identifiers.",
         call. = FALSE)
  }
  categories <- lapply(hierarchy, function(field) identifiers(data[[field]], field))
  names(categories) <- hierarchy
  categories <- lapply(categories, function(x) { x[is.na(x)] <- ""; x })
  if (any(!nzchar(categories[[1L]]))) {
    stop("Root hierarchy column `", hierarchy[1L], "` must not be missing or blank.",
         call. = FALSE)
  }
  if (length(hierarchy) > 1L) {
    for (i in seq_len(length(hierarchy) - 1L)) {
      bad <- which(!nzchar(categories[[i]]) & nzchar(categories[[i + 1L]]))
      if (length(bad)) {
        stop("Hierarchy skips a level between `", hierarchy[i], "` and `",
             hierarchy[i + 1L], "` at rows: ", paste(utils::head(bad, 8L), collapse = ", "),
             ".", call. = FALSE)
      }
    }
  }
  group_order <- check_order(group_order, unique(groups), "group_order")
  root_order <- check_order(root_order, unique(categories[[1L]]), "root_order")
  if (!is.list(branch_order) || (length(branch_order) &&
      (is.null(names(branch_order)) || anyNA(names(branch_order)) ||
       any(!nzchar(names(branch_order))) || anyDuplicated(names(branch_order))))) {
    stop("`branch_order` must be a list with unique, non-empty parent node IDs as names.",
         call. = FALSE)
  }
  input_range <- range(unlist(data[metrics], use.names = FALSE))
  if (is.null(radar_limits)) {
    span <- input_range[2L] - input_range[1L]
    padding <- if (span == 0) max(1, abs(input_range[1L]) * 0.05) else span * 0.05
    radar_limits <- input_range + c(-padding, padding)
  }
  if (!is.numeric(radar_limits) || length(radar_limits) != 2L ||
      any(!is.finite(radar_limits)) || radar_limits[1L] >= radar_limits[2L] ||
      !is.finite(diff(radar_limits))) {
    stop("`radar_limits` must be two finite, increasing numbers with a finite span; ",
         "provide an explicit range if the automatic range overflows.", call. = FALSE)
  }
  if (any(input_range < radar_limits[1L] | input_range > radar_limits[2L])) {
    for (metric in metrics) {
      bad <- which(data[[metric]] < radar_limits[1L] | data[[metric]] > radar_limits[2L])
      if (length(bad)) {
        stop("Metric `", metric, "` is outside `radar_limits` at rows: ",
             paste(utils::head(bad, 8L), collapse = ", "), ".", call. = FALSE)
      }
    }
  }
  radar <- t(vapply(group_order, function(g) {
    vapply(data[groups == g, metrics, drop = FALSE], mean, numeric(1L))
  }, numeric(length(metrics))))
  dimnames(radar) <- list(group_order, metrics)
  # This collector belongs only to this call; recursion never writes to a caller
  # environment or the user's workspace.
  collector <- new.env(parent = emptyenv())
  collector$nodes <- list()
  collector$used_orders <- character()
  root_counts <- vapply(root_order, function(x) sum(categories[[1L]] == x), integer(1L))
  edges <- -pi * root_counts[1L] / nrow(data) +
    2 * pi * c(0, cumsum(root_counts)) / nrow(data)
  add_node <- function(rows, level, path, parent_id, root_id, parent_count,
                       root_count, a, b) {
    id <- path_id(path)
    if (level == 1L) root_id <- id
    count <- length(rows)
    node <- data.frame(id = id, parent_id = parent_id, root_id = root_id,
                       level = level, label = utils::tail(path, 1L), root = path[1L],
                       count = count, parent_count = parent_count,
                       root_count = root_count, total_count = nrow(data),
                       parent_proportion = count / parent_count,
                       root_proportion = count / root_count,
                       global_proportion = count / nrow(data), start = a, end = b,
                       stringsAsFactors = FALSE)
    node$path <- list(path)
    collector$nodes[[length(collector$nodes) + 1L]] <- node
    if (level == length(hierarchy)) return(invisible(NULL))
    next_labels <- categories[[level + 1L]][rows]
    children <- unique(next_labels[nzchar(next_labels)])
    preferred <- branch_order[[id]]
    if (!is.null(preferred)) {
      children <- check_order(preferred, children, paste0("branch_order[['", id, "']]"))
      collector$used_orders <- c(collector$used_orders, id)
    }
    # Terminal records have a real share of the parent, but no painted child.
    cursor <- a + (b - a) * sum(!nzchar(next_labels)) / count
    for (child in children) {
      child_rows <- rows[next_labels == child]
      child_end <- cursor + (b - a) * length(child_rows) / count
      add_node(child_rows, level + 1L, c(path, child), id, root_id, count,
               root_count, cursor, child_end)
      cursor <- child_end
    }
    invisible(NULL)
  }
  for (i in seq_along(root_order)) {
    add_node(which(categories[[1L]] == root_order[i]), 1L, root_order[i],
             NA_character_, NA_character_, nrow(data), root_counts[i],
             edges[i], edges[i + 1L])
  }
  unknown_orders <- setdiff(names(branch_order), collector$used_orders)
  if (length(unknown_orders)) {
    stop("`branch_order` refers to unknown or terminal parent IDs: ",
         paste(unknown_orders, collapse = ", "), ".", call. = FALSE)
  }
  nodes <- do.call(rbind, collector$nodes)
  rownames(nodes) <- NULL
  structure(list(radar = radar, nodes = nodes, radar_limits = unname(radar_limits),
                 metrics = metrics, hierarchy = hierarchy, group_order = group_order,
                 root_order = root_order, n = nrow(data)), class = "radar_sunburst_data")
}

check_columns <- function(x, name, minimum, maximum = Inf) {
  if (!is.character(x) || length(x) < minimum || length(x) > maximum ||
      anyNA(x) || any(!nzchar(x)) || anyDuplicated(x)) {
    stop("`", name, "` must contain ", if (minimum == maximum) minimum else
      paste0("at least ", minimum), " distinct, non-empty column name(s).", call. = FALSE)
  }
}

identifiers <- function(x, field) {
  if (!(is.character(x) || is.factor(x) || is.numeric(x) || is.logical(x)) ||
      !is.null(dim(x)) || is.complex(x)) {
    stop("Identifier column `", field, "` must be character, factor, numeric or logical.",
         call. = FALSE)
  }
  if (is.numeric(x) && any(is.infinite(x))) {
    stop("Identifier column `", field, "` contains infinite values.", call. = FALSE)
  }
  trimws(enc2utf8(as.character(x)))
}

check_order <- function(order, observed, name) {
  if (is.null(order)) return(observed)
  if (!is.character(order) || anyNA(order) || anyDuplicated(order) ||
      !setequal(order, observed) || length(order) != length(observed)) {
    stop("`", name, "` must contain every observed identifier exactly once.", call. = FALSE)
  }
  order
}

path_id <- function(path) {
  components <- vapply(path, function(x) {
    paste(sprintf("%02x", as.integer(charToRaw(enc2utf8(x)))), collapse = "")
  }, character(1L))
  paste(components, collapse = ".")
}
