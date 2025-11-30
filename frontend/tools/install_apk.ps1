param(
  [switch]$Debug,
  # Skip building if APK already exists
  [switch]$NoBuild,
  # Wireless install: connect to IP:port (e.g. 192.168.1.42:5555)
  [string]$Connect,
  # Optional: pair first using Wireless debugging pairing code
  [switch]$Pair,
  # Pairing host:port shown by Android (e.g. 192.168.1.42:37099)
  [string]$PairHost,
  # 6-digit pairing code shown by Android
  [string]$PairCode,
  # Android package name to launch after install
  [string]$Package = 'ca.charlemagne.croiz',
  # Do not auto-launch after install
  [switch]$NoLaunch
)

$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try {
  # Go to project frontend root
  Set-Location ..

  $buildMode = if ($Debug) { 'debug' } else { 'release' }
  $apkName = if ($Debug) { 'app-debug.apk' } else { 'app-release.apk' }

  if (-not $NoBuild) {
    Write-Host "Building APK ($buildMode)..." -ForegroundColor Cyan
    flutter build apk @( if ($Debug) { '--debug' } else { '--release' } )
  } else {
    Write-Host "Skipping build (NoBuild set)." -ForegroundColor Yellow
  }

  $apkPath = Join-Path (Join-Path (Join-Path 'build' 'app') 'outputs') (Join-Path 'flutter-apk' $apkName)
  if (-not (Test-Path $apkPath)) {
    throw "APK not found at $apkPath"
  }

  # Locate adb (search PATH and common SDK locations)
  $adb = Get-Command adb -ErrorAction SilentlyContinue
  if ($adb) { $adb = $adb.Source }
  if (-not $adb) {
    $androidHome = $env:ANDROID_HOME; if (-not $androidHome) { $androidHome = 'C:\Android' }
    $candidates = @(
      (Join-Path (Join-Path $androidHome 'platform-tools') 'adb.exe'),
      (Join-Path (Join-Path $androidHome 'sdk\platform-tools') 'adb.exe'),
      (Join-Path (Join-Path "$env:LOCALAPPDATA\Android\Sdk" 'platform-tools') 'adb.exe')
    )
    $adb = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  }
  if (-not $adb) { throw 'adb not found. Ensure platform-tools is installed and on PATH (or set ANDROID_HOME).' }

  # Wireless pairing (optional)
  if ($Pair) {
    if (-not $PairHost -or -not $PairCode) {
      throw 'When using -Pair, provide -PairHost <ip:port> and -PairCode <code> from Wireless debugging.'
    }
    Write-Host "Pairing with $PairHost ..." -ForegroundColor Cyan
    & $adb pair $PairHost $PairCode
  }

  # Wireless connect (optional)
  if (-not $Connect -and $env:CROIZ_ADB_CONNECT) { $Connect = $env:CROIZ_ADB_CONNECT }
  if ($Connect) {
    Write-Host "Connecting to $Connect ..." -ForegroundColor Cyan
    & $adb connect $Connect | Out-Host
  }

  Write-Host "Checking connected devices..." -ForegroundColor Cyan
  $devices = & $adb devices | Select-String '\tdevice$' | ForEach-Object { ($_ -split '\s+')[0] }
  if (-not $devices -or $devices.Count -eq 0) {
    $hint = if ($Connect) { "Ensure phone is on same Wi‑Fi and Wireless debugging is ON." } else { "Enable USB debugging and authorize the PC (Options pour les développeurs)." }
    throw "No device found. $hint"
  }

  foreach ($d in $devices) {
    Write-Host "Installing to device $d ..." -ForegroundColor Cyan
    & $adb -s $d install -r $apkPath
    if ($LASTEXITCODE -ne 0) { throw "Install failed on $d" }
    if (-not $NoLaunch) {
      Write-Host "Launching $Package on $d ..." -ForegroundColor Cyan
      & $adb -s $d shell monkey -p $Package -c android.intent.category.LAUNCHER 1 | Out-Null
    }
  }

  Write-Host "Done. App installed." -ForegroundColor Green
}
finally {
  Pop-Location
}
