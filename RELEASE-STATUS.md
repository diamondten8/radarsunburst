# radarsunburst 0.1.0: geom_radsun update

Recorded on 2026-10-20 (Asia/Shanghai). Not submitted to or accepted by CRAN.
Maintainer manual acceptance remains pending; the Chinese review guide does not
claim the maintainer has personally completed any check.

## Source and exact release artifact

- Repository: https://github.com/diamondten8/radarsunburst
- Packaged source revision: `6a01b3eaf9238ec7fd8a5b54ee5383c8b107fbab`.
- Shared source workflow: https://github.com/diamondten8/radarsunburst/actions/runs/39393653771
- Tarball: `artifacts/release/radarsunburst_0.1.0.tar.gz`.
- SHA-256: `ce1930c36cf93068b07b2e964f1081b95c2c6c7dea26106c9ba56ac04cec59b9`.
- The shared artifact was downloaded and checked unchanged locally. Its contents
  were audited: five exports, updated addition method, no developer docs/tools/
  caches, original prototypes or reference images. The default metric ring is absent.
- Old candidate evidence is historical: `docs/history/release-evidence-before-geom.md`.
  Its tarball/logs were backed up under `artifacts/archive/2026-10-09`.

## Current complete checks on this exact artifact

| Environment | ERROR | WARNING | NOTE |
| --- | ---: | ---: | ---: |
| Local Windows, R 4.6.1 | 0 | 0 | 1 |
| Local Windows, R-devel 2026-10-06 r90643 | 0 | 0 | 1 |
| Cloud Linux, R 4.6.1 | 0 | 0 | 1 |
| Cloud Windows, R 4.6.1 | 0 | 0 | 1 |
| Cloud macOS Apple ARM, R 4.6.1 | 0 | 0 | 1 |
| Cloud Linux, R-devel 2026-10-18 r90707 | 0 | 0 | 1 |

All four cloud jobs and the overall workflow completed successfully.
Each of the six checks is full
`R CMD check --as-cran`, including PDF/HTML manuals, tests, examples, vignette
execution and rebuild. System clock checking and required Suggests were enabled.

Every completed check has only the incoming-feasibility NOTE "New submission".
This unpublished package is being prepared for its first submission. The local
helper intentionally returns nonzero for NOTEs; the underlying checks returned
zero and all NOTEs are explicitly investigated, not silently waived.

An earlier intermediate tarball exposed an S3 generic/method consistency warning.
It was fixed by accepting the compatible method arguments and `...`, then rebuilt
and rechecked. That intermediate artifact is not the release candidate above.

## Other verification and limitations

- 216 assertions pass on ggplot2 4.0.3 and minimum supported ggplot2 3.5.0,
  with zero failures, warnings or skips. Data, geometry, themes, inherited/explicit
  data, preserved parent elements and both Plotly conversion paths are covered.
- Installation and fresh-session use outside the checkout verify all five exports,
  both interfaces, original demonstration means/counts and session invariants.
- All five functions were exercised by the five-row manual teaching script from
  the installed candidate. The documented numbers and intentional error match.
- Actual browser checks cover radar/category hover, group hide/restore, zoom/reset,
  circular proportions, Chinese, a third-party theme/bottom legend and small sectors
  whose hidden labels still retain full hover metadata. See `docs/VISUAL-QA.md`.
- R >= 4.1 is declared; R 4.1 itself has not been exercised. Minimum ggplot2 testing
  is not evidence that all old R versions were tested.

## Aligned review materials

- `docs/ARCHITECTURE.md`: five functions and exact composition contract.
- `docs/GUIDE-zh.md` and `docs/radarsunburst-guide-zh.pdf`: input table/mappings,
  architecture, local build/install, all five functions, manual action/expected/
  purpose checklists, a complete small-package exercise and skill experience.
- The same final PDF is in `output/pdf/radarsunburst-code-review-and-r-package-guide-zh.pdf`.
- 35 pages rasterised and reviewed; 35 bookmarks and Chinese text verified; no
  out-of-page characters; 24 R blocks parsed and seven teaching assertions passed. The teaching package was also documented,
  built, installed and loaded in a fresh R 4.4.3 session.
- PDF SHA-256: `86d55a8764b229d6469c3069d6ebe9ba7aece142c580f22fa6e2484e5980efa1`.
- The original 136-page source book was preserved locally as
  `output/pdf/radarsunburst-full-source-review-2026-10-09.pdf`.
- Installed skills were not modified. Recommendations are clearly separated
  from unperformed behavior evaluations.

Any package source, documentation, tests or metadata change requires another
build/check. Later changes confined to excluded developer docs/PDF/evidence do
not alter this tarball. User review and explicit CRAN upload authorization are
still required before any submission; no upload or email has been performed.
