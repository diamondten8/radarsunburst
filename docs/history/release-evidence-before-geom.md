# radarsunburst 0.1.0 release evidence

Status: technical release gates complete; ready for the maintainer's formal
submission decision. Not submitted to or accepted by CRAN.
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

## Completed cloud gates on this exact tarball

| Environment | ERROR | WARNING | NOTE | Run |
| --- | ---: | ---: | ---: | --- |
| Ubuntu 24.04.5 x86_64, R 4.6.1 | 0 | 0 | 1 | 37899396257 |
| Windows x86_64, R 4.6.1 | 0 | 0 | 1 | 37899396257 |
| macOS Tahoe 26.6.2 Apple ARM, R 4.6.1 | 0 | 0 | 1 | 37899782528 |
| Ubuntu 24.04.5 x86_64, R-devel 2026-10-06 r90643 | 0 | 0 | 1 | 37899396257 |

All ran full `R CMD check --as-cran`, including PDF/HTML manuals, examples,
tests and vignette execution/rebuild. The system clock check was explicitly
enabled and suggested packages required. Every NOTE is only "New submission".

Run links: <https://github.com/diamondten8/radarsunburst/actions/runs/37899396257>
and <https://github.com/diamondten8/radarsunburst/actions/runs/37899782528>.
The first run's overall status is failed because its first macOS provisioning
attempt needed a TeX manager update. Its other three check jobs passed. The
second run checks only macOS and passed. Use the individual logs and hashes,
not the overall badge, as release evidence.

Workflow revisions `e047ced` and `05a189b` repair developer tooling only. On
macOS, a SHA-256-verified official native Darwin TeX archive replaces the
installer that incorrectly selected Linux ARM binaries; tlmgr is updated before
installing manual fonts. No package source was changed or check disabled.
Earlier failures/cancellations remain audit history, not claimed successes.

Final logs and summaries are in `artifacts/release/{linux-release,
cloud-windows-release,macos-release,linux-devel}-{00check.log,summary.txt}`.
`artifacts/release/release-manifest.json` records their hashes and counts.
Complete cloud artifacts are preserved outside the package under
`E:/desktop/radarsunburst-checks/github/37899396257` and `37899782528`.

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
The exact form fields and mailbox steps are in `docs/SUBMISSION-zh.md`.
