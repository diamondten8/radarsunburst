param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RArguments
)
# Process-scoped Windows locale repair; do not alter the user's persistent setup.
$env:LC_ALL = 'English_United States.utf8'
$env:LC_CTYPE = 'English_United States.utf8'
$env:LANG = 'English_United States.utf8'
$rScript = (Get-Command Rscript.exe -ErrorAction Stop).Source
& $rScript --vanilla @RArguments
exit $LASTEXITCODE
