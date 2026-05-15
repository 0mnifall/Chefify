param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $FlutterArgs
)

$setupScript = Join-Path $PSScriptRoot "tools\setup-flutter.ps1"
if (-not (Test-Path -LiteralPath $setupScript)) {
  Write-Error "Flutter setup script was not found at '$setupScript'."
  exit 1
}

$flutter = & $setupScript -PrintFlutterExecutable
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($flutter)) {
  exit 1
}

& $flutter @FlutterArgs
exit $LASTEXITCODE
