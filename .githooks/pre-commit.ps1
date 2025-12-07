try {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot '..\scripts\precommit.ps1')
    exit $LASTEXITCODE
} catch {
    Write-Error "Pre-commit PowerShell hook failed: $_"
    exit 1
}
