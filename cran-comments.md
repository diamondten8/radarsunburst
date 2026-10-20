## New submission

First submission of radarsunburst 0.1.0. A composite geom_radsun() component
and radar_sunburst() one-call interface share standard ggplot2 layers for
numeric radar profiles surrounded by counted hierarchies. Rows count once;
variable-depth branches and parent/root/global proportions are supported.
Plotly conversion is optional. The default omits the metric-name ring.

## Exact source artifact

radarsunburst_0.1.0.tar.gz
SHA-256: ce1930c36cf93068b07b2e964f1081b95c2c6c7dea26106c9ba56ac04cec59b9
Packaged source revision: 6a01b3eaf9238ec7fd8a5b54ee5383c8b107fbab

## Check results

Full R CMD check --as-cran, including PDF/HTML manuals, examples, tests,
executed vignettes and vignette rebuilds, on this unchanged tarball:

- Local Windows, R 4.6.1: 0 ERROR, 0 WARNING, 1 NOTE.
- Local Windows, R-devel 2026-10-06 r90643: 0 ERROR, 0 WARNING, 1 NOTE.
- Cloud Linux, R 4.6.1: 0 ERROR, 0 WARNING, 1 NOTE.
- Cloud Windows, R 4.6.1: 0 ERROR, 0 WARNING, 1 NOTE.
- Cloud macOS Apple ARM, R 4.6.1: 0 ERROR, 0 WARNING, 1 NOTE.
- Cloud Linux, R-devel 2026-10-18 r90707: 0 ERROR, 0 WARNING, 1 NOTE.

Each NOTE is incoming feasibility: "New submission". This unpublished package
is being prepared for its first submission. System clock checking was enabled
and suggested packages were required. No check was skipped to remove a finding.
All four cloud checks and the workflow completed successfully:
https://github.com/diamondten8/radarsunburst/actions/runs/39393653771
Logs, hashes and structured evidence are preserved under artifacts/release.

## Additional validation

216 assertions pass with ggplot2 4.0.3 and minimum supported 3.5.0. Both plotting
interfaces, explicit/inherited data, preserved plot elements and direct/configured
Plotly conversion are tested. Installation and fresh-session use outside the
checkout passed, including all five exports and original demonstration numbers.
Static and actual browser checks cover hover, zoom/reset, group visibility,
circular proportions, Chinese, third-party themes and small sectors.
R >= 4.1 is declared; R 4.1 itself was not exercised.

OpenAI Codex assisted with design, implementation, documentation, fictional data
and verification, as disclosed in README.md. Muyao Shen is the sole author and
responsible maintainer. Maintainer manual review is pending; these notes do not
claim the maintainer has completed that review. No submission has been made.

## Reverse dependencies

Not applicable to this first submission of an unpublished package.
