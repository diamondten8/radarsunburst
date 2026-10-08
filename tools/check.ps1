param(
  [ValidateSet('local', 'release', 'devel')]
  [string]$Runtime = 'release',
  [string]$Tarball
)
$ErrorActionPreference = 'Stop'
$packageRoot = Split-Path -Parent $PSScriptRoot
$artifactRoot = Join-Path (Split-Path -Parent $packageRoot) 'radarsunburst-checks'
$env:LC_ALL = 'English_United States.utf8'
$env:LC_CTYPE = 'English_United States.utf8'
$env:LANG = 'English_United States.utf8'
$pandocDirectory = 'D:\Rstudio&R\RStudio\resources\app\bin\quarto\bin\tools'
$texDirectory = Join-Path $artifactRoot 'TinyTeX\bin\windows'
$tidyDirectory = Join-Path $artifactRoot 'runtimes\tidy\tidy-5.8.0-win64\bin'
$env:RSTUDIO_PANDOC = $pandocDirectory
$env:PATH = $texDirectory + ';' + $pandocDirectory + ';' + $tidyDirectory + ';' + $env:PATH
if ($Runtime -eq 'local') {
  $rBinary = (Get-Command R.exe -ErrorAction Stop).Source
} else {
  $rBinary = Join-Path $artifactRoot ('runtimes\R-' + $Runtime + '\bin\x64\R.exe')
  $env:R_LIBS_USER = Join-Path $artifactRoot 'runtimes\library-release'
}
if ($Tarball) {
  & python (Join-Path $PSScriptRoot 'check_tarball.py') $Tarball --output (Join-Path $artifactRoot $Runtime) --r $rBinary
  exit $LASTEXITCODE
}
$checker = Join-Path $env:USERPROFILE '.agents\skills\r-package-engineer\scripts\check_package.py'
if (!(Test-Path -LiteralPath $checker)) {
  throw 'Install the r-package-engineer skill or run R CMD build and R CMD check --as-cran manually.'
}
& python $checker $packageRoot --output (Join-Path $artifactRoot $Runtime) --r $rBinary --locale 'English_United States.utf8'
exit $LASTEXITCODE
