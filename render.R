# Run from any directory: Rscript /path/to/render.R [--plot-only]
# Plotting uses only base R; HTML additionally needs rmarkdown and Pandoc.
args <- commandArgs(trailingOnly = FALSE)
file_arg <- args[grepl("^--file=", args)]
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg[1]), mustWork = TRUE))
} else getwd()
setwd(script_dir)
# Windows R 4.2+ supports UTF-8. This affects only this Rscript process.
if (.Platform$OS.type == "windows" && !isTRUE(l10n_info()[["UTF-8"]])) {
  invisible(Sys.setlocale("LC_CTYPE", ".UTF-8"))
}
input <- "radar_sunburst.Rmd"
plot_only <- "--plot-only" %in% commandArgs(trailingOnly = TRUE)

if (plot_only) {
  # This extracts the ordinary R chunks and skips chunks marked purl=FALSE.
  # Thus the Rmd is the single source of drawing code, even without knitr.
  text <- readLines(input, encoding = "UTF-8", warn = FALSE)
  code <- character()
  in_chunk <- FALSE
  keep_chunk <- FALSE
  for (line in text) {
    if (!in_chunk && grepl("^```\\{r([ ,}])", line)) {
      in_chunk <- TRUE
      keep_chunk <- !grepl("purl\\s*=\\s*FALSE", line)
    } else if (in_chunk && grepl("^```\\s*$", line)) {
      in_chunk <- FALSE
      keep_chunk <- FALSE
    } else if (in_chunk && keep_chunk) code <- c(code, line)
  }
  env <- new.env(parent = globalenv())
  eval(parse(text = code, keep.source = TRUE), envir = env)
  cat("Saved output/radar_sunburst.png and, when Cairo is available, .svg\n")
} else {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("HTML needs rmarkdown. To draw with base R only, run: Rscript render.R --plot-only")
  }
  if (!rmarkdown::pandoc_available()) {
    # Find the installed RStudio Pandoc without installing anything.
    candidates <- c(
      file.path(R.home(), "..", "RStudio", "resources", "app", "bin",
                "quarto", "bin", "tools"),
      file.path(Sys.getenv("ProgramFiles"), "RStudio", "resources", "app",
                "bin", "quarto", "bin", "tools"),
      file.path(Sys.getenv("LOCALAPPDATA"), "Programs", "RStudio", "resources",
                "app", "bin", "quarto", "bin", "tools")
    )
    found <- candidates[file.exists(file.path(candidates, "pandoc.exe"))]
    if (length(found)) Sys.setenv(RSTUDIO_PANDOC = normalizePath(found[1]))
  }
  if (!rmarkdown::pandoc_available()) {
    stop("Pandoc not found. Knit in RStudio, set RSTUDIO_PANDOC, or use --plot-only.")
  }
  rmarkdown::render(input, output_file = "radar_sunburst.html",
                    envir = new.env(parent = globalenv()), quiet = TRUE)
  cat("Saved radar_sunburst.html and output/radar_sunburst.png/.svg\n")
}
