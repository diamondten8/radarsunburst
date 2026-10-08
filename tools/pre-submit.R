# Developer-only submission gate. No uploading or mail is performed.
arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) != 2L) {
  stop("Usage: Rscript tools/pre-submit.R package-root final-summary.json")
}
if (!requireNamespace("jsonlite", quietly = TRUE) ||
    !requireNamespace("digest", quietly = TRUE)) stop("Developer gate needs jsonlite and digest.")
package_root <- normalizePath(arguments[1L], mustWork = TRUE)
description <- read.dcf(file.path(package_root, "DESCRIPTION"))
if (grepl("example[.]org|Development.*Maintainer", description[1L, "Authors@R"])) {
  stop("Replace development author metadata before submission.")
}
record <- jsonlite::fromJSON(arguments[2L])
if (!identical(record$mode, "full-as-cran") || is.null(record$counts) ||
    record$counts$ERROR != 0L || record$counts$WARNING != 0L) {
  stop("A completed full-as-CRAN check with zero ERRORs and WARNINGs is required.")
}
if (!file.exists(record$tarball) || !file.exists(record$check_log)) {
  stop("The checked source tarball and its log must still exist.")
}
actual_hash <- digest::digest(file = record$tarball, algo = "sha256")
if (!identical(actual_hash, record$sha256)) stop("Tarball SHA-256 differs from the checked artifact.")
cat("Tarball:", record$tarball, "\nSHA-256:", record$sha256, "\n")
cat("NOTE count:", record$counts$NOTE, "- review every NOTE in", record$check_log, "\n")
cat("Still confirm: this tarball reflects the final source; hash matches;",
    "cross-platform evidence; each NOTE; maintainer review of final figures;",
    "then use the CRAN submission form and verify the confirmation email.\n")
