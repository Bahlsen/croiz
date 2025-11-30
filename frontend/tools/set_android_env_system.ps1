param(
  [string]$AndroidHome = "C:\\Android",
  [switch]$SetJAVAHome,
  [string]$JdkPath
)

$ErrorActionPreference = 'Stop'

function Ensure-Elevated {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $p = New-Object Security.Principal.WindowsPrincipal($id)
  if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $args = @(
      '-NoProfile',
      '-ExecutionPolicy', 'Bypass',
      '-File', ('"' + $PSCommandPath + '"'),
      '-AndroidHome', ('"' + $AndroidHome + '"')
    )
    if ($SetJAVAHome) { $args += '-SetJAVAHome' }
    if ($JdkPath) { $args += @('-JdkPath', ('"' + $JdkPath + '"')) }
    Start-Process PowerShell -Verb RunAs -ArgumentList ($args -join ' ')
    exit 0
  }
}

function Add-ToMachinePath([string]$entry) {
  $path = [Environment]::GetEnvironmentVariable('Path','Machine')
  if ($path -notlike ('*' + $entry.Replace('\','\\') + '*')) {
    $newPath = if ([string]::IsNullOrEmpty($path)) { $entry } else { $path + ';' + $entry }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
  }
}

Ensure-Elevated

Write-Host "Setting ANDROID_HOME (Machine) to $AndroidHome" -ForegroundColor Cyan
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $AndroidHome, 'Machine')

Add-ToMachinePath '%ANDROID_HOME%\platform-tools'
Add-ToMachinePath '%ANDROID_HOME%\cmdline-tools\cmdline-tools\bin'

if ($SetJAVAHome) {
  if (-not $JdkPath) {
    $candidates = @()
    if (Test-Path 'C:\\Java') { $candidates += (Get-ChildItem -Path 'C:\\Java' -Directory | Where-Object { $_.Name -like 'jdk-*' } | Select-Object -ExpandProperty FullName) }
    if (Test-Path 'C:\\Program Files\\Microsoft') { $candidates += (Get-ChildItem 'C:\\Program Files\\Microsoft' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-*' } | Select-Object -ExpandProperty FullName) }
    if ($candidates.Count -gt 0) { $JdkPath = $candidates[0] }
  }
  if ($JdkPath) {
    Write-Host "Setting JAVA_HOME (Machine) to $JdkPath" -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable('JAVA_HOME', $JdkPath, 'Machine')
    Add-ToMachinePath '%JAVA_HOME%\bin'
  } else {
    Write-Warning 'No JDK path provided or found; JAVA_HOME unchanged.'
  }
}

Write-Host 'System environment variables updated.' -ForegroundColor Green

# Also update current process for immediate use in this session
$env:ANDROID_HOME = $AndroidHome
if ($env:PATH -notlike '*\platform-tools*') { $env:PATH += ';' + (Join-Path $AndroidHome 'platform-tools') }
if ($env:PATH -notlike '*\cmdline-tools\\cmdline-tools\\bin*') { $env:PATH += ';' + (Join-Path (Join-Path $AndroidHome 'cmdline-tools') 'cmdline-tools\\bin') }

Write-Host ("ANDROID_HOME(Machine)=" + [Environment]::GetEnvironmentVariable('ANDROID_HOME','Machine'))
Write-Host ("JAVA_HOME(Machine)=" + [Environment]::GetEnvironmentVariable('JAVA_HOME','Machine'))
