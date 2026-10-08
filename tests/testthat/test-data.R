test_that("original data reproduce independently calculated counts and means", {
  d <- radar_sunburst_demo
  metrics <- c("score_stability", "score_efficiency", "score_innovation",
               "score_quality", "score_collaboration")
  s <- radar_sunburst_data(d, metrics, "series",
                           c("main_category", "sub_category", "leaf_category"))
  expected <- rbind(c(90, 60, 70, 40, 65), c(61, 82, 42, 75, 62),
                    c(46, 62, 85, 60, 83), c(70, 35, 68, 90, 45))
  expect_equal(unname(s$radar), expected)
  expect_equal(s$n, 40L)
  expect_equal(nrow(s$nodes), 21L)
  expect_equal(s$nodes$count[s$nodes$level == 1L], rep(8L, 5L))
  expect_equal(s$nodes$root_proportion[s$nodes$level == 1L], rep(1, 5L))
  expect_equal(s$nodes$global_proportion[s$nodes$level == 1L], rep(0.2, 5L))
  expect_equal(s$radar_limits, c(26.65, 100.35))
  # Rows, not the original weighting column, determine the sector counts.
  d$sample_weight <- seq_len(nrow(d))
  expect_equal(radar_sunburst_data(d, metrics, "series",
    c("main_category", "sub_category", "leaf_category"))$nodes, s$nodes)
})

test_that("denominators, unequal angles and terminated rows remain correct", {
  s <- summarise_small()
  n <- s$nodes
  expect_equal(n$count[n$level == 1L], c(2L, 3L))
  expect_equal(sum(n$end[n$level == 1L] - n$start[n$level == 1L]), 2 * pi)
  expect_equal((n$end[1L] - n$start[1L]) / (2 * pi), 2 / 5)
  a_child <- which(n$root == "A" & n$level == 2L)
  expect_equal(n$parent_proportion[a_child], 1 / 2)
  expect_equal(n$root_proportion[a_child], 1 / 2)
  expect_equal(n$global_proportion[a_child], 1 / 5)
  expect_gt(n$start[a_child], n$start[1L])
  for (i in which(n$level > 1L)) {
    parent <- match(n$parent_id[i], n$id)
    expect_gte(n$start[i] + 1e-12, n$start[parent])
    expect_lte(n$end[i] - 1e-12, n$end[parent])
    expect_equal(n$parent_count[i], n$count[parent])
  }
  expect_equal(s$radar["one", ], c(a = 0, b = 2, c = 4))
  expect_equal(s$radar["two", ], c(a = 6, b = 8, c = 10))
})

test_that("paths distinguish repeated names, delimiters and Unicode", {
  d <- small_data()
  d$root <- c("A/B", "A/B", "A", "A", "A")
  d$child <- c("C", "", "B/C", "B/C", "\u540c\u540d")
  s <- summarise_small(d)
  expect_false(anyDuplicated(s$nodes$id) > 0)
  expect_true(any(vapply(s$nodes$path, identical, logical(1), c("A/B", "C"))))
  expect_true(any(vapply(s$nodes$path, identical, logical(1), c("A", "B/C"))))
  expect_true(any(s$nodes$label == "\u540c\u540d"))
  expect_equal(sum(s$nodes$count[s$nodes$level == 1L]), nrow(d))
  expect_equal(length(unique(s$nodes$id[s$nodes$label == "y"])), 1L)
})

test_that("hierarchy depth is not hard coded and order is explicit", {
  for (depth in seq_len(4L)) {
    d <- small_data()
    fields <- paste0("h", seq_len(depth))
    for (field in fields) d[[field]] <- d$root
    s <- radar_sunburst_data(d, c("a", "b", "c"), "g", fields)
    expect_equal(max(s$nodes$level), depth)
    expect_equal(nrow(s$nodes), depth * 2L)
  }
  s <- summarise_small(root_order = c("B", "A"), group_order = c("two", "one"))
  expect_equal(s$nodes$label[s$nodes$level == 1L], c("B", "A"))
  expect_equal(rownames(s$radar), c("two", "one"))
  parent <- s$nodes$id[s$nodes$level == 1L & s$nodes$label == "B"]
  orders <- stats::setNames(list(c("other", "same")), parent)
  ordered <- summarise_small(branch_order = orders)
  expect_equal(ordered$nodes$label[ordered$nodes$root == "B" & ordered$nodes$level == 2L],
               c("other", "same"))
  expect_error(summarise_small(branch_order = list(unknown = "x")), "unknown or terminal")
  expect_error(summarise_small(root_order = "A"), "every observed")
})

test_that("common ranges include raw extrema and handle constants", {
  d <- small_data()
  d$a[1L] <- -100
  s <- summarise_small(d)
  expect_equal(s$radar_limits, c(-105.6, 17.6))
  expect_equal(summarise_small(radar_limits = c(-10, 20))$radar_limits, c(-10, 20))
  for (value in c(0, -2, 100)) {
    d <- small_data()
    d[c("a", "b", "c")] <- value
    limits <- summarise_small(d)$radar_limits
    expect_equal(limits, value + c(-1, 1) * max(1, abs(value) * 0.05))
  }
  expect_error(summarise_small(radar_limits = c(0, 10)), "outside.*rows")
  expect_error(summarise_small(radar_limits = c(10, 0)), "increasing")
  expect_error(summarise_small(radar_limits = c(0, Inf)), "finite")
})

test_that("input errors identify the actual column and location", {
  expect_error(summarise_small(small_data()[FALSE, ]), "non-empty")
  d <- small_data(); d$a <- NULL
  expect_error(summarise_small(d), "missing columns: a")
  d <- small_data(); names(d)[2L] <- "g"
  expect_error(summarise_small(d), "unique")
  d <- small_data(); d$a <- as.character(d$a)
  expect_error(summarise_small(d), "Metric `a`.*numeric")
  for (bad in c(NA_real_, NaN, Inf, -Inf)) {
    d <- small_data(); d$b[3L] <- bad
    expect_error(summarise_small(d), "Metric `b`.*rows: 3")
  }
  d <- small_data(); d$child[1L] <- NA
  expect_error(summarise_small(d), "skips a level.*rows: 1")
  d <- small_data(); d$root[1L] <- " "
  expect_error(summarise_small(d), "Root hierarchy")
  d <- small_data(); d$g[1L] <- NA
  expect_error(summarise_small(d), "Group column")
  expect_error(radar_sunburst_data(small_data(), c("a", "b"), "g", "root"), "at least 3")
  expect_error(radar_sunburst_data(small_data(), c("a", "a", "c"), "g", "root"), "distinct")
})

test_that("single-row groups, factors and input immutability are supported", {
  d <- small_data()
  before <- d
  d$g <- factor(d$g, levels = c("unused", "two", "one"))
  s <- summarise_small(d)
  expect_equal(s$group_order, c("one", "two"))
  one <- radar_sunburst_data(before[1L, ], c("a", "b", "c"), "g", "root")
  expect_equal(as.numeric(one$radar), c(-2, 0, 2))
  expect_equal(one$nodes$count, 1L)
  summarise_small(before)
  expect_identical(before, small_data())
})
