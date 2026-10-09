## New submission

This is the first submission of radarsunburst 0.1.0. It combines arithmetic
metric means in a radar chart with counted hierarchical records in a sunburst,
using standard ggplot2 layers. Plotly conversion is optional. Rows count once;
variable-depth branches and parent/root/global proportions are supported.

## Artifact

radarsunburst_0.1.0.tar.gz
SHA-256: d9b8de41bdf66aff0d073444be51684c86e454934cb9aba76d3f235e19ed25ca

## Check results

Full R CMD check --as-cran on this unchanged tarball, including the PDF manual:

- Windows x86_64, R 4.6.1: 0 ERROR, 0 WARNING, 1 NOTE.
- Windows x86_64, R-devel 2026-10-06 r90643: 0 ERROR, 0 WARNING, 1 NOTE.
- Linux R 4.6.1, cloud: 0 ERROR, 0 WARNING, 1 NOTE.
- Windows R 4.6.1, cloud: 0 ERROR, 0 WARNING, 1 NOTE.
- macOS Apple ARM, R 4.6.1: 0 ERROR, 0 WARNING, 1 NOTE.
- Linux x86_64, R-devel 2026-10-06 r90643: 0 ERROR, 0 WARNING, 1 NOTE.

Every NOTE is CRAN incoming feasibility: "New submission". This is the first
submission of an unpublished package. No other NOTEs remain. The final cloud
checks explicitly enable system clock checking and require suggested packages;
PDF/HTML manuals, examples, tests and vignette rebuilds were checked.
Platform artifacts and logs are saved from
https://github.com/diamondten8/radarsunburst/actions/runs/37899396257
and https://github.com/diamondten8/radarsunburst/actions/runs/37899782528.
The latter run completes macOS checking after repairing its external TeX tools.

## Additional validation

162 assertions pass with both current ggplot2 and the minimum supported 3.5.0.
Examples and the vignette execute offline. Installation and fresh-session use
outside the checkout were checked. Theme support, Chinese labels, small sectors,
hover information, zoom and linked radar-group toggling were inspected. The
default omits the metric ring; metric names remain in radar hover information.

OpenAI Codex assisted with design, implementation, documentation, fictional
demonstration data and verification. This assistance is disclosed in README.md.
The sole author and responsible maintainer is Muyao Shen.

## Reverse dependencies

Not applicable to this first submission of an unpublished package.
