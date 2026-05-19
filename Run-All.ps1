# ============================================================
#  Run-All.ps1
#  FocusConfig suite master runner
#
#  Runs all FocusConfig scripts in the correct order.
#  Self-elevates to Administrator (required for all scripts).
#
#  Usage:
#    Right-click Run-All.ps1 -> "Run with PowerShell"
#    OR: powershell -ExecutionPolicy Bypass -File .\Run-All.ps1
#
#  BEFORE RUNNING: Close all browsers.
# ============================================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Relaunching as Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$SuiteDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  FocusConfig Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  This will apply all FocusConfig scripts:" -ForegroundColor White
Write-Host "   1. BrowserIntent.ps1   - Browser NTP + search config"
Write-Host "   2. Win11Streamline.ps1 - Windows 11 UX restoration"
Write-Host ""
Write-Host "  Make sure all browsers are closed before continuing." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "  Ready? Type YES to proceed"
if ($confirm -ne "YES") {
    Write-Host "`n  Aborted. No changes made." -ForegroundColor DarkGray
    exit
}

Write-Host ""

# -- Script 1: BrowserIntent --
$script1 = Join-Path $SuiteDir "BrowserIntent.ps1"
if (Test-Path $script1) {
    Write-Host "----------------------------------------" -ForegroundColor DarkCyan
    Write-Host " Running BrowserIntent.ps1..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor DarkCyan
    & $script1
} else {
    Write-Host "[SKIP] BrowserIntent.ps1 not found in $SuiteDir" -ForegroundColor DarkYellow
}

Write-Host ""

# -- Script 2: Win11Streamline --
$script2 = Join-Path $SuiteDir "Win11Streamline.ps1"
if (Test-Path $script2) {
    Write-Host "----------------------------------------" -ForegroundColor DarkCyan
    Write-Host " Running Win11Streamline.ps1..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor DarkCyan
    & $script2
} else {
    Write-Host "[SKIP] Win11Streamline.ps1 not found in $SuiteDir" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FocusConfig Suite complete." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  NEXT STEPS:" -ForegroundColor White
Write-Host "  1. Reopen your browsers and verify NTP search bars"
Write-Host "  2. Log out and back in if taskbar changes aren't visible"
Write-Host "  3. Install Kagi browser extension for taskbar search routing"
Write-Host "     https://kagi.com  (free trial available)"
Write-Host "  4. Firefox: confirm DuckDuckGo at about:preferences#search"
Write-Host ""
