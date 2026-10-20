# radarsunburst 0.1.0: geom_radsun update

Recorded on 2026-10-20 (Asia/Shanghai). Not submitted to or accepted by CRAN.
The maintainer is reviewing the implementation and the shorter Chinese guide.

## Current interfaces

Five exports: geom_radsun(), radar_sunburst(), radar_sunburst_data(),
theme_radar_sunburst(), radar_sunburstly(). Both plotting interfaces use the
same numerical and standard-layer core. The metric ring remains absent by default.

## Current evidence

- 216 assertions pass with the development ggplot2 and minimum supported 3.5.0,
  with zero failures, warnings or skipped assertions.
- Source build, including executed/rebuilt vignette: passed locally.
- Source installation and fresh-session use outside the checkout: passed;
  five exports, identical interface summaries, original demo and session invariants.
- The five-row manual exercise executes all five public functions and produces
  the documented means, counts, proportions, range and deliberate error.
- Actual browser and final exact-tarball cross-platform checks are being renewed.
  Their final status and new SHA-256 will be recorded here before release readiness
  is claimed. The previous candidate's hash is not evidence for changed source.

## Review material

- docs/GUIDE-zh.md and docs/radarsunburst-guide-zh.pdf: plain-language input
  mappings, architecture, local build/install, all five functions, manual actions,
  expected results and the reason for each check; skill experience and suggestions.
- docs/ARCHITECTURE.md: exact component/data/aesthetic/coordinate contract.
- tools/manual-acceptance.R: installed-package teaching exercise.

The original 2026-10-09 release record is historical:
docs/history/release-evidence-before-geom.md. Its exact tarball and logs were
preserved under artifacts/archive/2026-10-09 before this update.
Any package input change requires a fresh build and check. User review is still
pending; do not upload to CRAN or claim the maintainer has completed acceptance.
