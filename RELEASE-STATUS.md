# radarsunburst 0.1.0 release evidence

Status: paused at the maintainer's request; release candidate, not submitted to
or accepted by CRAN. Resume from `docs/NEXT-SESSION.md`.
Recorded on 2026-10-09 (Asia/Shanghai).

## Source and artifact

- Packaged source revision: `114c653e654ff184c32045ac0811ea2b1454ea8d`.
- Repository: <https://github.com/diamondten8/radarsunburst>.
- Tarball: `artifacts/release/radarsunburst_0.1.0.tar.gz`.
- SHA-256: `d9b8de41bdf66aff0d073444be51684c86e454934cb9aba76d3f235e19ed25ca`.
- Built once with R release in the source job of
  <https://github.com/diamondten8/radarsunburst/actions/runs/37854188000>.
  Each platform checks this unchanged tarball and verifies its SHA-256.
- Original prototype, reference graphics, old HTML/ZIP, tools, logs and temporary
  files are excluded from the tarball. The fictional demo table and vignette
  source are included. Tarball contents were inspected.

## Completed local gates on this exact tarball

| Environment | ERROR | WARNING | NOTE |
| --- | ---: | ---: | ---: |
| Windows x86_64, R 4.6.1 (2026-06-24) | 0 | 0 | 1 |
| Windows x86_64, R-devel (2026-10-06 r90643) | 0 | 0 | 1 |

Both used full `R CMD check --as-cran`, including PDF/HTML manuals, examples,
tests, vignette execution and vignette rebuild. The only NOTE is CRAN incoming
feasibility: "New submission". This is the first submission of a currently
unpublished package; no package-code defect or skipped check is being waived.
The check helper deliberately returns a nonzero exit code for this NOTE, so it
is explicitly reviewed here rather than silently classified as acceptance.

Logs and structured records:

- `artifacts/release/windows-release-00check.log` and
  `artifacts/release/windows-release-summary.json`.
- `artifacts/release/windows-devel-00check.log` and
  `artifacts/release/windows-devel-summary.json`.
- Complete original runs are outside the package in
  `E:/desktop/radarsunburst-checks/release/artifact-x7medapf` and
  `E:/desktop/radarsunburst-checks/devel/artifact-ko9ymv58`.

The same tarball also completed cloud R 4.6.1 checks on Linux and Windows:
0 ERROR, 0 WARNING, 1 NOTE each, again only "New submission". Their artifacts
are preserved under `E:/desktop/radarsunburst-checks/github/37854188000`.
The setup-r action sets `_R_CHECK_SYSTEM_CLOCK_=FALSE`; these cloud checks are
supplementary platform evidence. Local complete checks above did not disable it.

macOS code/tests/examples/vignettes and HTML manual passed, but the PDF manual
failed because TinyTeX selected Linux ARM executables on the Apple ARM runner.
The actual macOS result is 1 ERROR, 1 WARNING, 2 NOTEs, and is **not passed**.
Its `Rdlatex.log` and complete job log are saved. The root cause and next
diagnostics are in `docs/NEXT-SESSION.md`.

The cloud Linux R-devel job was still provisioning dependencies when the
maintainer requested a pause. The remaining run was cancelled; no cloud R-devel
pass is claimed. Windows R-devel local checks remain completed on the exact
tarball. Earlier failed or cancelled runs are preserved, not release successes.

## Behaviour and visual gates

- 162 assertions pass, with zero test failures or warnings, on current ggplot2
  and on the declared minimum ggplot2 3.5.0. R 4.1.0 itself has not been tested;
  local development also exercised R 4.4.3.
- The final tarball installs and runs in a new R session outside the checkout.
  Four exports, demonstration means, 21 nodes and unmodified session state were
  verified. Runtime Plotly and HTML export remain optional dependencies.
- Static and actual browser interaction were inspected. See
  `docs/VISUAL-QA.md`; previews are in `artifacts/preview`.
- The maintainer requested removal of the entire grey metric ring, and otherwise
  accepted the example appearance. The default now has no metric ring; names
  remain in radar hover information. Optional ring radii restore it when wanted.
- The real maintainer metadata is Muyao Shen, shenmuyao.bio@gmail.com, sole author.
  MIT licensing and AI assistance are documented without claiming unperformed
  human code review.
- Name recheck against current CRAN, its archive and Bioconductor found no exact
  case-insensitive match on 2026-10-09. The snapshot is
  `E:/desktop/radarsunburst-checks/name-availability.json`.

## Toolchain and ongoing maintenance

The existing Windows R startup inherited `C.UTF-8`, an unsupported Windows locale.
Developer commands use `English_United States.utf8` only in the child process.
User startup files, persistent locale, PATH and RStudio configuration were not
changed to conceal this issue. Separate release/devel runtimes, libraries, TeX
and HTML Tidy are in `E:/desktop/radarsunburst-checks`; they are not runtime
requirements or package assets. Pandoc uses the existing RStudio installation.

See `docs/MAINTENANCE.md` for release commands, mailbox duties and update handling;
`docs/QUICKSTART-zh.md` for use; `cran-comments.md` for the submission comment.
Formal CRAN upload and its confirmation email are separate from technical checks.
No acceptance or publication is claimed here.
