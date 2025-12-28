param()

# Detect first connected adb device and write it to .vscode/settings.json as croiz.adbConnect
try {
    $adbOutput = & adb devices 2>&1
} catch {
    Write-Host "adb not found in PATH. Make sure Android platform-tools are installed.";
    exit 0
}

$lines = $adbOutput -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

# Skip header line (List of devices attached)
$deviceLine = $lines | Where-Object { $_ -match "\tdevice$" } | Select-Object -First 1

if (-not $deviceLine) {
    Write-Host "No connected Android device found (or device not authorized)."
    exit 0
}

$deviceId = ($deviceLine -split "\t")[0]

$settingsPath = Join-Path (Get-Location) ".vscode\settings.json"

if (Test-Path $settingsPath) {
    try {
        $json = Get-Content $settingsPath -Raw
        if ($json.Trim() -eq '') {
            $settingsObj = @{}
        } else {
            $settingsObj = ConvertFrom-Json $json -ErrorAction Stop
        }
    } catch {
        $settingsObj = @{}
    }
} else {
    $settingsObj = @{}
}

# Safely set the setting depending on the object type
if ($settingsObj -is [System.Collections.Hashtable]) {
    $settingsObj['croiz.adbConnect'] = $deviceId
} elseif ($settingsObj -is [System.Management.Automation.PSCustomObject]) {
    $settingsObj | Add-Member -NotePropertyName 'croiz.adbConnect' -NotePropertyValue $deviceId -Force
} else {
    $settingsObj = @{ 'croiz.adbConnect' = $deviceId }
}

# Write back with pretty JSON
$settingsObj | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Host "Detected device: $deviceId -> wrote croiz.adbConnect to .vscode/settings.json"
