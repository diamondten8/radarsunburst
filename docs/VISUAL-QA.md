# Visual and interaction verification for 0.1.0

Verified on 2026-10-09 with the local Windows R/ggplot2/Plotly toolchain and the
Codex in-app browser. Generated previews are outside the CRAN tarball.

The maintainer requested that the entire grey metric ring be removed and
otherwise accepted the example's appearance. This is now the default. Metric
names are retained in radar hover information. Optional ring radii and the
switch `show_metric_labels = TRUE` are covered by tests.

## Numerical and structural verification

- The original 40-row demonstration yields four radar groups, five roots with
  eight records each, and 21 counted nodes. Means and all three proportions are
  tested independently of rendering.
- 162 assertions pass with both current ggplot2 and the declared minimum,
  ggplot2 3.5.0, with no test failures or warnings.
- A clean installed-package session outside the checkout reproduces the chart,
  verifies exactly four exports and leaves the working directory, locale, user
  options and global environment unchanged.

## Export and actual browser checks

- Static PNG/SVG of the demonstration; PNGs using theme_minimal, theme_classic,
  theme_bw and theme_dark. Normal themes can expose Cartesian axes/background
  grids; this is standard theme behaviour. The default circular theme hides them.
- Third-party ggthemes::theme_few with a bottom legend: static and actual browser
  rendering verified. Plotly unifies the guides, keeping the bottom position.
- Chinese group/category labels render in static PNG and in the browser. The
  developer PNG uses the Cairo device and Microsoft YaHei; requesting that font
  through the standard Windows device without registration warns. Font support
  is device-dependent and the package does not install or register fonts.
- Fifteen narrow one-record branches keep their sectors and suppress labels that
  cannot fit. Actual browser hover over Rare branch 13 shows the complete path,
  count 1, root denominator 100 and proportion 1 percent.
- Hover over Series1's Stability point shows metric Stability and mean 90.
  Hover over a category label reaches the sector's full metadata; decorative
  text no longer replaces it with a short label in the configured widget.
- Clicking the Series1 legend hides its line, points and fill together; clicking
  again restores them. Category legend clicks retain the counted view.
- Zoom-in and Reset axes work; the equal x/y ratio keeps circles circular.
- Automatic radar ticks omit a pretty tick very close to the real lower bound.
  Explicit user ticks remain available. The lower bound is always labelled.

The browser-rendered PNG is `artifacts/preview/interactive-browser.png`; the
interactive HTML and its assets are `artifacts/preview/interactive.html` and
`interactive_files`. All remain developer/user outputs, not package assets.

These checks establish agent inspection and automated verification, not a claim
that the maintainer has personally reviewed every line of code. Very long labels,
unavailable fonts, unusual export dimensions and nonzero rotated text need review
on the target device. Direct ggplotly conversion is supported; the package wrapper
also cleans hover/legend behaviour. No branch drill-down is provided.
