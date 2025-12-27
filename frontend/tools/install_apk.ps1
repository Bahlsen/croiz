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
    & $adb pair $PairHost $PairCode | Out-Host
  }

  Write-Host "Checking connected devices..." -ForegroundColor Cyan
  # Read adb devices output robustly (join & split to ensure lines are strings)
  $rawOut = (& $adb devices) -join "`n"
  $lines = $rawOut -split "`r?`n"
  $devices = @()
  foreach ($line in $lines) {
    if ($line -match '^\s*(\S+)\s+(device|offline|unauthorized)\s*$') { $devices += $matches[1] }
  }
  # Filter out any spurious single-character tokens
  $devices = $devices | Where-Object { $_ -and ($_.Length -gt 2) }
  if ($Debug) {
    Write-Host "Raw adb output:" -ForegroundColor DarkCyan
    $lines | ForEach-Object { Write-Host "RAW> '$_'" }
    Write-Host "Parsed devices (post-filter):" -ForegroundColor DarkCyan
    $devices | ForEach-Object { Write-Host ("DEV> '{0}' (len={1})" -f $_, ($_.Length)) }
  }

  # Wireless connect (optional). If -Connect is provided, always attempt it
  if (-not $Connect -and $env:CROIZ_ADB_CONNECT) { $Connect = $env:CROIZ_ADB_CONNECT }
  if ($Connect) {
    # If the requested device is already visible to adb (including mDNS TLS names), skip connect
    $alreadyPresent = $false
    if ($devices -and ($devices -contains $Connect)) { $alreadyPresent = $true }
    if (-not $alreadyPresent) {
      foreach ($dev in $devices) {
        if ($dev -match '_adb-tls-connect') { $alreadyPresent = $true; break }
      }
    }
    if ($alreadyPresent) {
      Write-Host "Device $Connect already visible to adb; skipping adb connect." -ForegroundColor Yellow
    } else {
      Write-Host "Connecting to $Connect ..." -ForegroundColor Cyan
    # Capture and show adb connect output for easier debugging
    $connectOut = & $adb connect $Connect 2>&1
    if ($connectOut) { $connectOut | ForEach-Object { Write-Host "ADB> $_" -ForegroundColor DarkCyan } }

    # If connect failed (common: connection refused), try restarting adb server and retry once
    $connected = $false
    if ($connectOut -and ($connectOut -match 'connected to' -or $connectOut -match 'already connected to')) { $connected = $true }
    if (-not $connected) {
      Write-Warning "adb connect did not report success; restarting adb server and retrying..."
      & $adb kill-server 2>&1 | ForEach-Object { Write-Host "ADB> $_" -ForegroundColor DarkCyan }
      Start-Sleep -Seconds 1
      $startTmpOut = [System.IO.Path]::GetTempFileName()
      $startTmpErr = [System.IO.Path]::GetTempFileName()
      Start-Process -FilePath $adb -ArgumentList 'start-server' -NoNewWindow -Wait -RedirectStandardOutput $startTmpOut -RedirectStandardError $startTmpErr
      $startOut = ''
      if (Test-Path $startTmpOut) { $startOut += (Get-Content $startTmpOut -Raw) }
      if (Test-Path $startTmpErr) { $startOut += "`n" + (Get-Content $startTmpErr -Raw) }
      if ($startOut) { $startOut -split "`r?`n" | ForEach-Object { if ($_ -ne '') { Write-Host "ADB> $_" -ForegroundColor DarkCyan } } }
      Remove-Item $startTmpOut,$startTmpErr -ErrorAction SilentlyContinue
      Start-Sleep -Seconds 1
      $connectOut2 = & $adb connect $Connect 2>&1
      if ($connectOut2) { $connectOut2 | ForEach-Object { Write-Host "ADB> $_" -ForegroundColor DarkCyan } }
      if ($connectOut2 -and ($connectOut2 -match 'connected to' -or $connectOut2 -match 'already connected to')) { $connected = $true }
      # Prefer the latest output in logs
      if ($connectOut2) { $connectOut = $connectOut2 }
    }

    }
    # Recheck devices after attempting connection (robustly)
    $rawOut = (& $adb devices) -join "`n"
    $lines = $rawOut -split "`r?`n"
    $devices = @()
    foreach ($line in $lines) {
      if ($line -match '^\s*(\S+)\s+device\s*$') { $devices += $matches[1] }
    }
    # Filter out spurious single-character tokens after recheck
    $devices = $devices | Where-Object { $_ -and ($_.Length -gt 2) }
    if ($Debug) {
      Write-Host "Raw adb output (after connect):" -ForegroundColor DarkCyan
      $lines | ForEach-Object { Write-Host "RAW> '$_'" }
      Write-Host "Parsed devices (post-filter after connect):" -ForegroundColor DarkCyan
      $devices | ForEach-Object { Write-Host ("DEV> '{0}' (len={1})" -f $_, ($_.Length)) }
    }
  }

  if (-not $devices -or $devices.Count -eq 0) {
    throw 'No device connected. Use -Connect or -Pair first, or connect via USB.'
  }

  # Prefer Wi‑Fi devices and avoid emulators. Wi‑Fi devices appear as IP:PORT (e.g. 192.168.1.42:5555).
  $ipPortRegex = '^\d{1,3}(?:\.\d{1,3}){3}:\d+$'
  # Ensure these are arrays even when there's a single match
  $nonEmulator = @($devices | Where-Object { -not ($_ -like 'emulator*') })
  # Recognize Wi‑Fi devices by IP:port, or mDNS/TLS device names from Android wireless debugging
  $wifiDevices = @($nonEmulator | Where-Object { ($_ -match $ipPortRegex) -or ($_ -match '_adb-tls-connect') -or ($_ -match '\._adb-tls-connect\._tcp') })

  if ($Debug) {
    Write-Host "Wi‑Fi candidates:" -ForegroundColor DarkCyan
    $wifiDevices | ForEach-Object { Write-Host ("WIFI> '{0}' (len={1})" -f $_, ($_.Length)) }
  }

  if ($wifiDevices -and $wifiDevices.Count -gt 0) {
    $targetDevices = @($wifiDevices[0])
    Write-Host "Selected Wi‑Fi device: $($targetDevices -join ', ')" -ForegroundColor Cyan
  } elseif ($nonEmulator -and $nonEmulator.Count -gt 0) {
    # Fallback to non-emulator device (USB)
    $targetDevices = @($nonEmulator[0])
    Write-Host "No Wi‑Fi device found; using non-emulator device: $($targetDevices -join ', ')" -ForegroundColor Yellow
  } else {
    # Last resort: include emulators
    $targetDevices = @($devices[0])
    Write-Host "No physical devices found; falling back to device: $($targetDevices -join ', ')" -ForegroundColor Yellow
  }

  # Install to the selected device(s) (usually one)
  foreach ($d in $targetDevices) {
    Write-Host "Installing APK to $d ..." -ForegroundColor Cyan
    & $adb -s $d install -r $apkPath | Out-Host
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
