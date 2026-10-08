# Maintaining radarsunburst

The maintainer is Muyao Shen, shenmuyao.bio@gmail.com. Monitor this mailbox for
CRAN check reports and review requests. A successful check is not CRAN acceptance.

## Before the first submission

1. Review the public functions, numerical rules, English help and vignette.
   `docs/QUICKSTART-zh.md` is the Chinese introduction.
2. Confirm the final figures. The requested 0.1.0 default omits the
   entire grey metric ring; radar hover retains metric names. Explicit ring
   radii and `show_metric_labels = TRUE` restore a labelled ring when wanted.
3. Review `RELEASE-STATUS.md` and every NOTE in the actual check logs. Do not
   upload a tarball if ERRORs, WARNINGs or unexplained NOTEs remain.
4. Submit the exact recorded tarball, not a newly rebuilt file. Compare its
   SHA-256 with the release evidence. Any package code, documentation, test or
   DESCRIPTION change requires a fresh build and complete check.
5. Upload using <https://cran.r-project.org/submit.html>, and respond to the
   confirmation email. Keep the submission receipt. Do not repeat a pending
   submission merely because review is taking time.

## Checks and development

On the configured Windows development machine:

```powershell
powershell -NoProfile -File tools/check.ps1 -Runtime release
powershell -NoProfile -File tools/check.ps1 -Runtime devel -Tarball <exact-tarball>
```

`tools/check.ps1` uses process-scoped locale and tool paths. It does not change
the system locale or the user's R startup files. Toolchains and libraries live
outside the package in `E:/desktop/radarsunburst-checks`. These paths are specific
to this development machine; ordinary users need none of them to install the
package. On another machine, run `R CMD build` and `R CMD check --as-cran` with
working Pandoc, TeX (including Courier and makeindex), and declared dependencies.

The GitHub workflow builds one tarball, then checks its verified SHA-256 on
Windows, Linux, macOS and R-devel. Download and preserve the source and check
artifacts. Review NOTEs even if the workflow is green; its failure threshold is
ERRORs or WARNINGs. Browser interaction needs separate visual verification.

After editing roxygen comments, run `roxygen2::roxygenise()` before checking.
Use `testthat::test_local()` for behavioural tests. Do not add tests that rely on
private files, a live service, credentials, or a particular current directory.
Developer previews use `tools/prototype.R` and `tools/visual-qa.R`; they are not
distributed in the CRAN source package.

## After acceptance

- Update the README's publication status only after CRAN actually lists the
  package. Use a version bump and NEWS entry for the next released change.
- Reproduce CRAN reports on the reported R version and operating system. Retest
  ggplot2 and Plotly conversion after dependency updates. Use meaningful numerical
  tests plus browser checks for hover, zoom, group toggling and circular proportions.
- Keep optional dependencies optional. Never install software, change locale,
  write files or open a browser automatically from a package function.
- For reviewer requests, record each comment and the change that addresses it.
  Rebuild and recheck; disclose remaining external limitations in cran-comments.md.
- As there are no published reverse dependencies for this first release, no
  reverse-dependency checks are currently needed. Check them for future API changes.

OpenAI Codex assistance is disclosed in the README. Keep the disclosure accurate;
do not claim human review of code or results that the maintainer has not performed.
