<#
  scripts/precommit.ps1
  Run local checks before committing. Exits non-zero on failure.
#>
param()

function Invoke-CheckedCommand {
  param(
    [Parameter(Mandatory=$true)]
    [string]$cmd,
    [string]$workingDir = $PWD
  )

  Write-Host "Running: $cmd (in $workingDir)"
  Push-Location $workingDir
  & powershell -NoProfile -ExecutionPolicy Bypass -Command $cmd
  $code = $LASTEXITCODE
  Pop-Location
  if ($code -ne 0) {
    Write-Error ("Command failed with exit code " + $code + ": " + $cmd)
    exit $code
  }
}

Write-Host "== Running frontend-only Dart auto-fix + format + analyze =="

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Write-Host "Repository root: $repoRoot"

# Determine staged files and limit operations to staged frontend Dart files
$stagedRaw = & git diff --name-only --cached
$stagedFiles = $stagedRaw -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
$frontendDartFiles = $stagedFiles | Where-Object { $_ -like 'frontend/*' -and $_ -match '\.dart$' }

if (-not $frontendDartFiles -or $frontendDartFiles.Count -eq 0) {
  Write-Host "No staged frontend Dart files found — nothing to do."
  exit 0
}

Write-Host "Staged frontend Dart files:`n$($frontendDartFiles -join "`n")"

# Run formatter on staged files only
if (Get-Command dart -ErrorAction SilentlyContinue) {
  Write-Host "Running: dart format on staged files"
  & dart format $frontendDartFiles
  $formatCode = $LASTEXITCODE
  if ($formatCode -ne 0) { Write-Warning "dart format exited with code $formatCode" }
} elseif (Get-Command flutter -ErrorAction SilentlyContinue) {
  Write-Host "Running: flutter format on staged files"
  & flutter format $frontendDartFiles
  $formatCode = $LASTEXITCODE
  if ($formatCode -ne 0) { Write-Warning "flutter format exited with code $formatCode" }
} else {
  Write-Warning "No formatter found; skipping format step."
}

# Run analyze only on the staged files and fail the commit if issues remain
Write-Host "Running: flutter analyze --fatal-warnings on staged files"
& flutter analyze --fatal-warnings $frontendDartFiles
$analyzeCode = $LASTEXITCODE
if ($analyzeCode -ne 0) {
  Write-Error "flutter analyze detected issues in staged files (exit code $analyzeCode). Commit blocked until issues are resolved."
  exit $analyzeCode
}

# Stage any modified files so fixes are included in the commit
foreach ($f in $frontendDartFiles) {
  try {
    & git add -- "$f"
  } catch {
    Write-Warning "git add failed for $f: $_"
  }
}

Write-Host "Staged frontend fixes/formats have been added to the index. Proceeding with commit."
exit 0
