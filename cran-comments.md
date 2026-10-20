## New submission

First submission of radarsunburst 0.1.0. It combines arithmetic metric means
with counted hierarchical records. A composite geom_radsun() component and
radar_sunburst() one-call function share standard ggplot2 layers. Plotly
conversion is optional; rows count once and variable-depth branches are supported.

## Current artifact and checks

The geom_radsun update changes the source package. The previous candidate's
checks and hash do not cover this update. Fresh exact-tarball checks and the
new SHA-256 are pending; do not submit this draft until RELEASE-STATUS.md and
these comments have been updated with actual results.

## Additional validation

216 assertions pass with the development ggplot2 and minimum supported 3.5.0.
Both plotting interfaces, inherited/explicit data, themes and direct/configured
Plotly conversion are covered. Source build, installation, fresh-session use
and the documented five-row manual exercise passed locally. Maintainer manual
review remains separate from automated/agent verification.

OpenAI Codex assisted with design, implementation, documentation, fictional
example data and verification. The sole author and responsible maintainer is
Muyao Shen. Assistance is disclosed in README.md.

## Reverse dependencies

Not applicable to this first submission of an unpublished package.
