param(
  # Option: true = launch Chrome headless (utile CI)
  [switch]$Headless,
  # Option: ouvrir DevTools automatiquement
  [switch]$DevTools
)

$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
  Set-Location ..  # racine frontend

  # Vérif Flutter installé
  $flutter = Get-Command flutter -ErrorAction SilentlyContinue
  if (-not $flutter) { throw 'flutter introuvable dans PATH.' }

  # Choix arguments Chrome
  $chromeArgs = @()
  if ($Headless) { $chromeArgs += '--headless' }
  if ($DevTools) { $chromeArgs += '--auto-open-devtools-for-tabs' }
  if ($chromeArgs.Count -gt 0) {
    Write-Host "Lancement Chrome avec: $($chromeArgs -join ' ')" -ForegroundColor Cyan
    $env:CHROME_EXECUTABLE_ARGS = $chromeArgs -join ' '
  }

  Write-Host 'Lancement Flutter web (Chrome) avec hot reload...' -ForegroundColor Green
  Write-Host 'Raccourcis: r = hot reload | R = hot restart | q = quitter' -ForegroundColor DarkGray
  flutter run -d chrome
}
finally {
  Pop-Location
}