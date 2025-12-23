<#
.SYNOPSIS
    Run Croiz performance benchmarks.

.DESCRIPTION
    Executes performance benchmarks to detect regressions.
    Results are compared against hardcoded thresholds.
    Ideal for CI pipelines to catch performance issues early.

.EXAMPLE
    .\run_benchmarks.ps1           # Run all performance benchmarks
    .\run_benchmarks.ps1 -Verbose  # Run with detailed output
#>

param(
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$frontendDir = Split-Path -Parent $scriptDir

Push-Location $frontendDir
try {
    if ($Help) {
        Write-Host @"
Croiz Performance Benchmarks
=============================

Usage:
  .\tools\run_benchmarks.ps1           Run all performance benchmarks

The benchmarks are:
  - FastTyping_200chars:      Simulates typing 200 characters quickly
  - SetLetter_1000ops:        Tests setLetter performance (1000 operations)
  - BoardRead_10000reads:     Tests provider read performance (10000 reads)
  - CellKeyHash_100000ops:    Tests CellKey hash/equality (100000 operations)
  - BoardCopyWith_1000copies: Tests board copyWith performance (1000 copies)

Each benchmark has a threshold. If exceeded, the test fails.
This helps catch performance regressions before they reach production.
"@
        exit 0
    }

    Write-Host "Running Croiz performance benchmarks..." -ForegroundColor Cyan
    Write-Host ""

    # Run the benchmark tests
    & flutter test test/perf/benchmarks.dart --reporter=expanded

    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ Performance regression detected!" -ForegroundColor Red
        exit 1
    }

    Write-Host "`n✅ All performance benchmarks passed." -ForegroundColor Green
}
finally {
    Pop-Location
}
