# radarsunburst

Draw numeric radar profiles inside a sunburst of counted records. The centre
shows each group's arithmetic metric means; the outside shows how the same
records are classified. A separate ring identifies the metric axes. The two
sets of categories are independent.

**Development version 0.1.0. This package has not yet been published on CRAN.**

## Install a built source package

Run in R after building the package (replace the filename with its actual path):

```r
install.packages("radarsunburst_0.1.0.tar.gz", repos = NULL, type = "source")
```

Installation of development tools and optional dependencies is a separate user
action. The package never installs software, changes the working directory or
writes a file simply because a chart is created.

## Draw a chart

```r
library(radarsunburst)
data(radar_sunburst_demo)

metrics <- c("score_stability", "score_efficiency", "score_innovation",
             "score_quality", "score_collaboration")
hierarchy <- c("main_category", "sub_category", "leaf_category")

p <- radar_sunburst(
  radar_sunburst_demo, metrics, group = "series", hierarchy = hierarchy,
  metric_labels = c("Stability", "Efficiency", "Innovation", "Quality",
                    "Collaboration"),
  percent = "root"
)
p
p + ggplot2::theme_minimal() + ggplot2::labs(title = "Fictional projects")
```

For your own table, change the column-name strings. Each row counts once in the
sunburst, including repeated rows. There is no automatic deduplication or
weighting. Numeric cells supply the radar values: a single row per group passes
through unchanged; multiple rows are averaged. Missing/non-finite metrics are
errors. Blank lower hierarchy cells end a branch; skipped levels are errors.

`percent = "none"` shows names and counts. Other choices are `"parent"` (direct
parent; the roots use the whole table), `"root"` (top-level category) and
`"global"` (whole table). The percentages never change the sector angles.

The default common radar limits include the raw input minimum and maximum,
plus 5% of their span on either side. Override with `radar_limits = c(0, 100)`
when a fixed comparison scale is appropriate. The centre is the lower bound,
not necessarily zero. The package does not independently standardise axes or
make different units scientifically comparable.

## Inspect, style and export

```r
s <- radar_sunburst_data(radar_sunburst_demo, metrics, "series", hierarchy)
s$radar
s$nodes[, c("label", "count", "parent_proportion", "root_proportion",
             "global_proportion")]

# Explicit, user-chosen output filename:
ggplot2::ggsave("my-chart.png", p, width = 12, height = 8, dpi = 300)
ggplot2::ggsave("my-chart.svg", p, width = 12, height = 8,
                device = grDevices::svg)
```

Standard ggplot themes control titles, legends and backgrounds. Fill scales
control root categories; colour scales control radar groups, including their
translucent fill. Metric-ring colours and geometry text have separate function
arguments. Keep the fixed coordinate ratio so circles remain circular. Font
availability and export size affect label fit; inspect dense charts after export.

```r
if (requireNamespace("plotly", quietly = TRUE)) {
  w <- radar_sunburstly(p)
  w
  # Direct conversion also works:
  plotly::ggplotly(p, tooltip = "text")
  # Save explicitly; selfcontained = FALSE does not require Pandoc.
  htmlwidgets::saveWidget(w, "my-chart.html", selfcontained = FALSE)
}
```

The configured widget shows counts, denominators and means on hover, supports
zoom, and toggles all traces of a radar group together. Category legends are
explanatory; they do not filter records. Small hidden labels remain available
on hover. Branch drill-down is not provided. Horizontal geometry text is the
conversion default; nonzero rotations and some third-party theme elements can
render differently in Plotly. The widget's categorical legend is unified by
Plotly rather than laid out as two separate static guides.

## Documentation and development

See `vignette("radar-sunburst", package = "radarsunburst")` for a complete
workflow, and `docs/QUICKSTART-zh.md` in the source checkout for Chinese guidance.
Four functions form the public API; all geometry helpers are internal.

Original prototype files are preserved on disk and excluded from the source
tarball. `README-original.md` describes that prototype. New package code lives
in `R/`; the old R Markdown document is no longer the package's code source.

Developer commands and release evidence are recorded in `RELEASE-STATUS.md`.
Tests cover numerical contracts, variable hierarchy depth, themes and widget
structure. Browser checks are also needed for actual interaction. A passing
local test suite does not by itself establish CRAN readiness.

## Authorship and AI assistance

Muyao Shen is the sole author, maintainer and designated copyright holder.
OpenAI Codex assisted with design, implementation, demonstration-data generation,
documentation and automated verification. AI assistance is acknowledged as a
tool contribution, not listed as a human author. The maintainer remains responsible
for reviewing the work, approving the final figures and responding to CRAN.
Automated checks and agent visual inspection are recorded separately; they do
not assert that the maintainer has personally reviewed every line or result.

The demonstration records are fictional. No reference image, third-party source
code, credentials, original generated report, or development cache is bundled.
Package source and demonstration data are distributed under the MIT licence.
