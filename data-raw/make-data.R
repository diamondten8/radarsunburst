# Run from the package root. The installed CSV is also the recoverable source.
radar_sunburst_demo <- utils::read.csv("inst/extdata/demo_data.csv",
                                      fileEncoding = "UTF-8-BOM",
                                      stringsAsFactors = FALSE)
dir.create("data", showWarnings = FALSE)
save(radar_sunburst_demo, file = "data/radar_sunburst_demo.rda", compress = "xz",
      version = 3)
