<#
.SYNOPSIS
  Create the croiz_avd Android Virtual Device.
.DESCRIPTION
  Installs the system image and creates an AVD for local development.
  Run this once to set up the emulator, then use start_emulator.ps1.
#>

param(
    [string]$AvdName = "croiz_avd",
    [string]$SystemImage = "system-images;android-30;google_apis;x86_64",
    [string]$Device = "pixel"
)

$ErrorActionPreference = 'Stop'

$sdkRoot = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } 
           elseif ($env:ANDROID_HOME) { $env:ANDROID_HOME } 
           else { "C:\Android" }

$sdkmanager = Join-Path $sdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
if (-not (Test-Path $sdkmanager)) {
    $sdkmanager = Join-Path $sdkRoot "tools\bin\sdkmanager.bat"
}

$avdmanager = Join-Path $sdkRoot "cmdline-tools\latest\bin\avdmanager.bat"
if (-not (Test-Path $avdmanager)) {
    $avdmanager = Join-Path $sdkRoot "tools\bin\avdmanager.bat"
}

if (-not (Test-Path $sdkmanager)) {
    Write-Error "sdkmanager not found. Install Android SDK command-line tools."
    exit 1
}

Write-Host "SDK root: $sdkRoot" -ForegroundColor Cyan
Write-Host "Creating AVD: $AvdName" -ForegroundColor Cyan
Write-Host "System image: $SystemImage" -ForegroundColor Cyan

# Install system image
Write-Host "`nInstalling system image..." -ForegroundColor Yellow
& $sdkmanager $SystemImage --install

if (-not (Test-Path $avdmanager)) {
    Write-Error "avdmanager not found. Cannot create AVD."
    exit 1
}

# Create AVD
Write-Host "`nCreating AVD..." -ForegroundColor Yellow
& $avdmanager create avd -n $AvdName -k $SystemImage --device $Device --force

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nAVD '$AvdName' created successfully!" -ForegroundColor Green
    Write-Host "Run 'start_emulator.ps1' to launch the emulator."
} else {
    Write-Error "Failed to create AVD."
    exit 1
}
