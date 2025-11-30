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

  # Ensure Android SDK env for this process
  $sdkCandidates = @('C:\Android', 'C:\Android\sdk', "$env:LOCALAPPDATA\Android\Sdk")
  $sdkRoot = $null
  foreach ($c in $sdkCandidates) { if (Test-Path $c) { $sdkRoot = $c; break } }
  if (-not $env:ANDROID_HOME -and $sdkRoot) {
    if (Test-Path 'C:\Android') { $env:ANDROID_HOME = 'C:\Android' } else { $env:ANDROID_HOME = $sdkRoot }
  }
  if (-not $env:ANDROID_SDK_ROOT -and $sdkRoot) { $env:ANDROID_SDK_ROOT = $sdkRoot }
  # Make sure PATH has platform-tools for this process
  $pt1 = (Join-Path $env:ANDROID_HOME 'platform-tools')
  $pt2 = (Join-Path $env:ANDROID_SDK_ROOT 'platform-tools')
  $ctb = (Join-Path (Join-Path $env:ANDROID_HOME 'cmdline-tools') 'cmdline-tools\bin')
  foreach ($p in @($pt1,$pt2,$ctb)) { if ($p -and (Test-Path $p) -and ($env:PATH -notlike "*${p}*")) { $env:PATH += ";$p" } }

  # Ensure Java (JDK) for Gradle/Flutter in this process
  $javaOk = $false
  $javaCmd = Get-Command java -ErrorAction SilentlyContinue
  if ($javaCmd) { $javaOk = $true }
  if (-not $javaOk) {
    $jdkPath = $null
    $jdkCandidates = @()
    if ($env:JAVA_HOME) { $jdkCandidates += $env:JAVA_HOME }
    if (Test-Path 'C:\Java') { $jdkCandidates += (Get-ChildItem 'C:\Java' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-*' } | Select-Object -ExpandProperty FullName) }
    if (Test-Path 'C:\Program Files\Microsoft') { $jdkCandidates += (Get-ChildItem 'C:\Program Files\Microsoft' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-*' } | Select-Object -ExpandProperty FullName) }
    if (Test-Path 'C:\Program Files\Eclipse Adoptium') { $jdkCandidates += (Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-*' } | Select-Object -ExpandProperty FullName) }
    if (Test-Path 'C:\Program Files\Java') { $jdkCandidates += (Get-ChildItem 'C:\Program Files\Java' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk*' } | Select-Object -ExpandProperty FullName) }
    foreach ($cand in $jdkCandidates) {
      if ($cand -and (Test-Path (Join-Path $cand 'bin\java.exe'))) { $jdkPath = $cand; break }
    }
    if ($jdkPath) {
      $env:JAVA_HOME = $jdkPath
      $javaBin = (Join-Path $jdkPath 'bin')
      if ($env:PATH -notlike "*${javaBin}*") { $env:PATH += ";$javaBin" }
      $javaOk = $true
      Write-Host "Using JAVA_HOME=$env:JAVA_HOME" -ForegroundColor DarkCyan
    } else {
      Write-Warning 'No JDK found automatically. If build fails, set JAVA_HOME to your JDK path.'
    }
  }

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

  # Wireless pairing (optional)
  if ($Pair) {
  if ($Connect) {
    Write-Host "Connecting to $Connect ..." -ForegroundColor Cyan
    & $adb connect $Connect | Out-Host
  }

  Write-Host "Checking connected devices..." -ForegroundColor Cyan
  $devices = & $adb devices | Select-String '\tdevice$' | ForEach-Object { ($_ -split '\s+')[0] }
  Write-Host "Checking connected devices..." -ForegroundColor Cyan
  $devices = & $adb devices | Select-String '\tdevice$' | ForEach-Object { ($_ -split '\s+')[0] }

  # Wireless connect (optional, only if none connected yet)
  if (-not $devices -or $devices.Count -eq 0) {
    if (-not $Connect -and $env:CROIZ_ADB_CONNECT) { $Connect = $env:CROIZ_ADB_CONNECT }
    if ($Connect) {
      Write-Host "Connecting to $Connect ..." -ForegroundColor Cyan
      $null = & $adb connect $Connect 2>$null
      # Recheck devices after attempting connection
      $devices = & $adb devices | Select-String '\tdevice$' | ForEach-Object { ($_ -split '\s+')[0] }
    }
  }
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
