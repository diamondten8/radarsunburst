# radarsunburst 0.1.0

* Add `geom_radsun()` for `ggplot(data) + geom_radsun(...)` composition, with
  inherited or explicit data, preserved plot themes/labels/layers, fixed
  coordinates and standard scales. Generated layers isolate parent aesthetics.
* Keep `radar_sunburst()` as the default-themed one-call interface to the same
  shared calculation and geometry core. Both interfaces support direct ggplotly
  conversion and the configured `radar_sunburstly()` converter.
* Add a shorter plain-language Chinese architecture and manual testing guide.

* Introduce counted, variable-depth sunburst hierarchies and numeric radar means.
* Add root, parent and global label denominators, and count-only labels.
* Omit the metric ring by default, with optional ring radii and metric labels.
* Add common automatic or explicit radar limits.
* Return standard ggplot objects with optional Plotly interaction.
* Include fictional project data and offline examples.
