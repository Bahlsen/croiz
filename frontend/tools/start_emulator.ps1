<#
.SYNOPSIS
  Start the Android emulator for Croiz development.
.DESCRIPTION
  Starts the croiz_avd emulator with GPU acceleration.
  Waits for adb to register the device.
#>

param(
    [string]$AvdName = "croiz_avd",
    [switch]$WipeData,
    [int]$TimeoutSeconds = 60
)

$ErrorActionPreference = 'Stop'

# Locate tools
$emulator = "C:\Android\emulator\emulator.exe"
$adb = "C:\Android\platform-tools\adb.exe"

if (-not (Test-Path $emulator)) {
    Write-Error "Emulator not found at $emulator"
    exit 1
}

if (-not (Test-Path $adb)) {
    Write-Error "ADB not found at $adb"
    exit 1
}

# Check if emulator is already running
$existingDevices = & $adb devices 2>$null | Select-String "emulator-\d+\s+device"
if ($existingDevices) {
    Write-Host "Emulator already running: $($existingDevices.Matches.Value)" -ForegroundColor Green
    & $adb devices -l
    exit 0
}

# Build emulator arguments
$emulatorArgs = @("-avd", $AvdName, "-gpu", "auto", "-no-boot-anim")
if ($WipeData) {
    $emulatorArgs += "-wipe-data"
}

Write-Host "Starting emulator '$AvdName'..." -ForegroundColor Cyan
Start-Process -FilePath $emulator -ArgumentList $emulatorArgs -WindowStyle Normal

# Wait for adb to see the device
Write-Host "Waiting for emulator to connect (timeout: ${TimeoutSeconds}s)..." -ForegroundColor Yellow
$startTime = Get-Date
$connected = $false

while (((Get-Date) - $startTime).TotalSeconds -lt $TimeoutSeconds) {
    Start-Sleep -Seconds 2
    $devices = & $adb devices 2>$null
    if ($devices -match "emulator-\d+\s+device") {
        $connected = $true
        break
    }
    Write-Host "." -NoNewline
}

Write-Host ""

if ($connected) {
    Write-Host "Emulator connected successfully!" -ForegroundColor Green
    & $adb devices -l
    exit 0
} else {
    Write-Warning "Emulator started but not yet registered with adb. Check emulator window."
    Write-Host "Run 'adb devices' to verify connection."
    exit 0
}
