param(
  # Optional: connect via Wi‑Fi before running if no devices
  [string]$Connect
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
  # Resolve an SDK base that actually contains platform-tools
  $sdkBase = $null
  foreach ($c in $sdkCandidates) {
    if (Test-Path (Join-Path $c 'platform-tools\adb.exe')) { $sdkBase = $c; break }
  }
  if (-not $sdkBase -and (Test-Path (Join-Path "$env:LOCALAPPDATA\Android\Sdk" 'platform-tools\adb.exe'))) {
    $sdkBase = "$env:LOCALAPPDATA\Android\Sdk"
  }
  if (-not $env:ANDROID_SDK_ROOT -and $sdkBase) { $env:ANDROID_SDK_ROOT = $sdkBase }
  # PATH enrichments for this process
  $pathsToAdd = @()
  if ($env:ANDROID_HOME) {
    $pathsToAdd += (Join-Path $env:ANDROID_HOME 'platform-tools')
    $pathsToAdd += (Join-Path (Join-Path $env:ANDROID_HOME 'cmdline-tools') 'cmdline-tools\bin')
  }
  if ($env:ANDROID_SDK_ROOT) {
    $pathsToAdd += (Join-Path $env:ANDROID_SDK_ROOT 'platform-tools')
    $pathsToAdd += (Join-Path (Join-Path $env:ANDROID_SDK_ROOT 'cmdline-tools') 'cmdline-tools\bin')
  }
  foreach ($p in $pathsToAdd) { if ($p -and (Test-Path $p) -and ($env:PATH -notlike "*${p}*")) { $env:PATH += ";$p" } }

  # Ensure Java (JDK)
  $javaCmd = Get-Command java -ErrorAction SilentlyContinue
  if (-not $javaCmd) {
    $jdkPath = $null
    $jdkCandidates = @()
    if ($env:JAVA_HOME) { $jdkCandidates += $env:JAVA_HOME }
    if (Test-Path 'C:\Java') { $jdkCandidates += (Get-ChildItem 'C:\Java' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-*' } | Select-Object -ExpandProperty FullName) }
    if (Test-Path 'C:\Program Files\Microsoft') { $jdkCandidates += (Get-ChildItem 'C:\Program Files\Microsoft' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-*' } | Select-Object -ExpandProperty FullName) }
    if (Test-Path 'C:\Program Files\Eclipse Adoptium') { $jdkCandidates += (Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-*' } | Select-Object -ExpandProperty FullName) }
    if (Test-Path 'C:\Program Files\Java') { $jdkCandidates += (Get-ChildItem 'C:\Program Files\Java' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk*' } | Select-Object -ExpandProperty FullName) }
    foreach ($cand in $jdkCandidates) { if ($cand -and (Test-Path (Join-Path $cand 'bin\java.exe'))) { $jdkPath = $cand; break } }
    if ($jdkPath) {
      $env:JAVA_HOME = $jdkPath
      $javaBin = (Join-Path $jdkPath 'bin')
      if ($env:PATH -notlike "*${javaBin}*") { $env:PATH += ";$javaBin" }
      Write-Host "Using JAVA_HOME=$env:JAVA_HOME" -ForegroundColor DarkCyan
    }
  }

  # Locate adb
  $adb = Get-Command adb -ErrorAction SilentlyContinue
  if ($adb) { $adb = $adb.Source }
  if (-not $adb) {
    $candidates = @(
      (Join-Path (Join-Path $env:ANDROID_HOME 'platform-tools') 'adb.exe'),
      (Join-Path (Join-Path $env:ANDROID_SDK_ROOT 'platform-tools') 'adb.exe'),
      (Join-Path (Join-Path "$env:LOCALAPPDATA\Android\Sdk" 'platform-tools') 'adb.exe')
    )
    $adb = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  }
  if (-not $adb) { throw 'adb not found. Ensure Android platform-tools installed.' }

  # Make sure Flutter knows the Android SDK path and adb server is running
  try { flutter config --android-sdk $env:ANDROID_HOME | Out-Null } catch {}
  & $adb start-server | Out-Null

  # Check devices; attempt Wi‑Fi connect only if none (ADB perspective)
  Write-Host 'Checking connected devices...' -ForegroundColor Cyan
  $adbDevices = & $adb devices | Select-String '\tdevice$' | ForEach-Object { ($_ -split '\s+')[0] }
  if (-not $adbDevices -or $adbDevices.Count -eq 0) {
    if (-not $Connect -and $env:CROIZ_ADB_CONNECT) { $Connect = $env:CROIZ_ADB_CONNECT }
    if ($Connect) {
      Write-Host "Connecting to $Connect ..." -ForegroundColor Cyan
      $null = & $adb connect $Connect 2>$null
      $adbDevices = & $adb devices | Select-String '\tdevice$' | ForEach-Object { ($_ -split '\s+')[0] }
    }
  }
  if (-not $adbDevices -or $adbDevices.Count -eq 0) { throw 'No device found. Connect via USB or Wireless debugging.' }

  # Use flutter devices to select a valid Flutter device id for Android
  $flutterList = & flutter devices --machine 2>$null | Out-String
  $flutterDevices = @()
  if ($flutterList) {
    try { $flutterDevices = $flutterList | ConvertFrom-Json } catch {}
  }
  $androidDevice = $null
  if ($flutterDevices) {
    $androidDevice = $flutterDevices | Where-Object { $_.platformType -eq 'android' -and $_.ephemeral } | Select-Object -First 1
  }
  if (-not $androidDevice) {
    Write-Warning 'Flutter did not list an Android device; using install+launch+attach fallback.'
    # Always (re)build debug APK to ensure latest code is installed
    $apkDebug = Join-Path (Join-Path (Join-Path 'build' 'app') 'outputs') (Join-Path 'flutter-apk' 'app-debug.apk')
    Write-Host 'Building APK (debug)...' -ForegroundColor Cyan
    flutter build apk --debug
    if (-not (Test-Path $apkDebug)) { throw "Debug APK not found at $apkDebug after build." }

    # Install to first adb device and launch
    $target = $adbDevices | Select-Object -First 1
    Write-Host "Installing to $target ..." -ForegroundColor Cyan
    & $adb -s $target install -r $apkDebug | Out-Null
    Write-Host 'Launching app...' -ForegroundColor Cyan
    & $adb -s $target shell monkey -p ca.charlemagne.croiz -c android.intent.category.LAUNCHER 1 | Out-Null

    # Try to attach for hot reload; first with device id, then without if not recognized
    Write-Host 'Attaching for hot reload (q to quit)...' -ForegroundColor DarkGray
    try {
      flutter attach -d $target --app-id ca.charlemagne.croiz
    } catch {
      Write-Warning "Attach with device id '$target' failed; retrying without -d."
      flutter attach --app-id ca.charlemagne.croiz
    }
    return
  }

  $flutterId = $androidDevice.id
  Write-Host "Running on $($androidDevice.name) [$flutterId] (debug, hot reload enabled)." -ForegroundColor Green
  Write-Host "Hot reload: press r | Full restart: R | Quit: q" -ForegroundColor DarkGray
  flutter run -d $flutterId
}
finally {
  Pop-Location
}
