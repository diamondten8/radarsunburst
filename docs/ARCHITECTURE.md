# Public interfaces and composition contract

The package has five public functions. `radar_sunburst_data()` validates a wide
data frame, averages metrics within radar groups and counts rows within a
hierarchy. It returns means, nodes, angles, all three proportions and raw-input
radar limits. `geom_radsun()` creates an addable component specification;
`radar_sunburst()` adds the same specification to an empty ggplot with its default
theme. `theme_radar_sunburst()` supplies only a theme. `radar_sunburstly()` converts
either completed ggplot and configures interaction.

## Data and aesthetics

`metrics`, `group` and `hierarchy` are column-name strings. Metric order sets the
radar axes clockwise from the top; hierarchy order sets levels from inner to
outer. Parent ggplot aesthetics are not inherited: generated coordinates and
summary rows cannot safely use original-row x/y/group mappings. The component
inherits only the parent data frame when `data = NULL`. Explicit data take
priority. Data functions, quosure metric mappings and automatic pivoting from
long input are not part of this API.

Fill maps root categories; colour maps radar groups and their translucent fill.
The size scale is used internally for fitted label text. These component scales
share the plot's scale space. Add replacement category/group scales afterwards;
do not expect unrelated fill/colour/size layers to acquire separate scales.

## Addition and shared core

`R/geom-radsun.R` registers an S3 `ggplot_add.radsun_layer` method for ggplot2 3.5
and its 4.x compatibility path. The method resolves input, calls the single
`radsun_components()` compiler in `R/plot.R`, adds its standard layers/scales/
coordinates and attaches the numerical summary. It preserves existing parent
data, mappings, layers, labels and themes except the supplied x/y labels, scales
and coordinates. Every generated layer has its own data and `inherit.aes = FALSE`.
No custom Geom or Plotly geometry translation is required.

The component supplies a fixed linear coordinate system and no theme. Additional
annotations use the generated Cartesian positions. One composite per plot is
supported; a second raises an error. Faceting and transformed coordinates are
outside the supported scope. The one-call interface keeps its previous argument
names, defaults and return type, including the omitted metric ring.

## Validation

Regression tests compare built layer data and numerical summaries across the
two interfaces, all percentage conventions, inherited and explicit data, themes,
preserved parent elements, reused specifications and direct/configured Plotly
conversion. Installed-session checks verify all five exports. Static and actual
browser review remain separate from numerical and widget-structure tests.

The previous candidate's check results do not cover changed source. Rebuild,
check and record a new tarball hash before claiming release readiness.
