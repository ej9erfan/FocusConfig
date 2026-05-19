# ============================================================
#  Win11Streamline.ps1  (v1)
#  Part of the FocusConfig suite
#
#  Restores Windows 11 to a less distracting, more deliberate
#  UX without removing features, just moving them out of
#  the ambient peripheral vision of an ADHD engineer.
#
#  WHAT THIS DOES:
#  1. Taskbar      -- left-align icons + Start button
#  2. Right-click  -- full options immediately, no "Show more"
#  3. Start menu   -- kill ads and Recommended items feed
#  4. OneDrive     -- disable autostart (does not uninstall)
#  5. Xbox Game Bar-- disable background hotkey hijacking
#  6. Taskbar Search -- disable Bing, route to default browser (Kagi via extension)
#
#  Run as Administrator (script self-elevates).
#  Log out and back in after running for full effect.
# ============================================================

# -- Self-elevate if not already admin --
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Relaunching as Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "`n=== FocusConfig --- Win11Streamline v1 ===" -ForegroundColor Cyan
Write-Host "Running as Administrator.`n" -ForegroundColor Green

# -------------------------------------------------------------
# 1. TASKBAR -- Left-align everything
#    TaskbarAl = 0 -> left  |  1 -> center (Win11 default)
# -------------------------------------------------------------
Write-Host "[Taskbar] Left-aligning icons and Start button..." -ForegroundColor Yellow

$ExplorerAdvanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $ExplorerAdvanced -Name "TaskbarAl" -Value 0 -Type DWord -Force

Write-Host "[Taskbar] Done." -ForegroundColor Green

# -------------------------------------------------------------
# 2. RIGHT-CLICK MENU -- Restore full classic context menu
#    Win11 truncates to ~5 items + "Show more options"
#    Empty default value on this CLSID key restores classic handler
# -------------------------------------------------------------
Write-Host "[Right-click] Restoring full context menu..." -ForegroundColor Yellow

$ContextMenuKey = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (-not (Test-Path $ContextMenuKey)) { New-Item -Path $ContextMenuKey -Force | Out-Null }
Set-ItemProperty -Path $ContextMenuKey -Name "(Default)" -Value "" -Type String -Force

Write-Host "[Right-click] Done. Full menu on first right-click." -ForegroundColor Green

# -------------------------------------------------------------
# 3. START MENU -- Kill ads and Recommended feed
#    Recommended shows recently opened files and suggested apps
#    which are attention magnets disguised as productivity
# -------------------------------------------------------------
Write-Host "[Start Menu] Removing ads and Recommended items..." -ForegroundColor Yellow

Set-ItemProperty -Path $ExplorerAdvanced -Name "Start_TrackProgs" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $ExplorerAdvanced -Name "Start_TrackDocs"  -Value 0 -Type DWord -Force

$ContentDelivery = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (-not (Test-Path $ContentDelivery)) { New-Item -Path $ContentDelivery -Force | Out-Null }
@{
    "SystemPaneSuggestionsEnabled"     = 0
    "SubscribedContent-338388Enabled"  = 0   # Start suggestions
    "SubscribedContent-338389Enabled"  = 0   # Lock screen tips
    "SubscribedContent-353698Enabled"  = 0   # Timeline suggestions
    "SubscribedContent-338387Enabled"  = 0   # Settings tips
    "SubscribedContent-338393Enabled"  = 0
    "SubscribedContent-353694Enabled"  = 0
    "SubscribedContent-314559Enabled"  = 0
    "SubscribedContent-314563Enabled"  = 0
    "SoftLandingEnabled"               = 0
    "RotatingLockScreenOverlayEnabled" = 0
}.GetEnumerator() | ForEach-Object {
    Set-ItemProperty -Path $ContentDelivery -Name $_.Key -Value $_.Value -Type DWord -Force
}

$StartPolicyPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
if (-not (Test-Path $StartPolicyPath)) { New-Item -Path $StartPolicyPath -Force | Out-Null }
Set-ItemProperty -Path $StartPolicyPath -Name "HideRecommendedSection" -Value 1 -Type DWord -Force

Write-Host "[Start Menu] Done. Ads and Recommended feed removed." -ForegroundColor Green

# -------------------------------------------------------------
# 4. ONEDRIVE -- Disable autostart only (does not uninstall)
# -------------------------------------------------------------
Write-Host "[OneDrive] Disabling autostart..." -ForegroundColor Yellow

$RunKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Remove-ItemProperty -Path $RunKey -Name "OneDrive" -ErrorAction SilentlyContinue

$ODPath = "HKCU:\Software\Microsoft\OneDrive"
if (Test-Path $ODPath) {
    Set-ItemProperty -Path $ODPath -Name "DisableAutoStart" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}

Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue

Write-Host "[OneDrive] Done. Still installed; launch manually when needed." -ForegroundColor Green

# -------------------------------------------------------------
# 5. XBOX GAME BAR -- Disable overlay and background DVR
#    Irrelevant on engineering workstations; Win+G hijack removed
# -------------------------------------------------------------
Write-Host "[Xbox Game Bar] Disabling..." -ForegroundColor Yellow

$GameDVR = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
if (-not (Test-Path $GameDVR)) { New-Item -Path $GameDVR -Force | Out-Null }
Set-ItemProperty -Path $GameDVR -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force

$GameConfig = "HKCU:\System\GameConfigStore"
if (-not (Test-Path $GameConfig)) { New-Item -Path $GameConfig -Force | Out-Null }
Set-ItemProperty -Path $GameConfig -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force

$GamePolicy = "HKLM:\Software\Policies\Microsoft\Windows\GameDVR"
if (-not (Test-Path $GamePolicy)) { New-Item -Path $GamePolicy -Force | Out-Null }
Set-ItemProperty -Path $GamePolicy -Name "AllowGameDVR" -Value 0 -Type DWord -Force

Write-Host "[Xbox Game Bar] Done. Win+G overlay and background capture disabled." -ForegroundColor Green

# -------------------------------------------------------------
# 6. TASKBAR SEARCH -- Disable Bing, route to default browser
#
#    Windows does not expose a clean registry key to swap the
#    taskbar search engine to an arbitrary URL. The reliable
#    cross-version approach is:
#      a) Disable Bing web results in taskbar search (done here)
#      b) This causes web queries to open in the default browser
#         using that browser's default search engine (DDG in our setup)
#      c) Install the Kagi browser extension to intercept and
#         redirect those DDG queries to Kagi transparently
#
#    Net result: taskbar search -> browser -> Kagi
# -------------------------------------------------------------
Write-Host "[Taskbar Search] Disabling Bing web results..." -ForegroundColor Yellow

$SearchKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
if (-not (Test-Path $SearchKey)) { New-Item -Path $SearchKey -Force | Out-Null }
Set-ItemProperty -Path $SearchKey -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $SearchKey -Name "CortanaConsent"    -Value 0 -Type DWord -Force

$SearchPolicy = "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
if (-not (Test-Path $SearchPolicy)) { New-Item -Path $SearchPolicy -Force | Out-Null }
Set-ItemProperty -Path $SearchPolicy -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force

Write-Host "[Taskbar Search] Done. Bing disabled; web queries go to default browser." -ForegroundColor Green
Write-Host "  >> For Kagi: install the Kagi extension in your browser of choice." -ForegroundColor DarkYellow
Write-Host "  >> kagi.com > Settings > Extensions  (free trial available)" -ForegroundColor DarkYellow

# -------------------------------------------------------------
# RESTART EXPLORER to apply taskbar + context menu changes now
# -------------------------------------------------------------
Write-Host "`n[System] Restarting Explorer to apply changes..." -ForegroundColor Yellow
Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process "explorer.exe"
Write-Host "[System] Explorer restarted." -ForegroundColor Green

# -------------------------------------------------------------
# SUMMARY
# -------------------------------------------------------------
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Done! Win11Streamline v1 Summary:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Taskbar        - Icons and Start button left-aligned"
Write-Host "  Right-click    - Full context menu, no 'Show more options'"
Write-Host "  Start menu     - Ads and Recommended feed removed"
Write-Host "  OneDrive       - Autostart disabled (not uninstalled)"
Write-Host "  Xbox Game Bar  - Win+G overlay and background DVR off"
Write-Host "  Taskbar Search - Bing disabled; routes to default browser"
Write-Host ""
Write-Host "  ACTION REQUIRED:" -ForegroundColor White
Write-Host "  Kagi routing: install the Kagi browser extension." -ForegroundColor White
Write-Host "  kagi.com > Settings > Extensions" -ForegroundColor White
Write-Host ""
Write-Host "  Log out and back in if taskbar changes don't appear." -ForegroundColor White
Write-Host ""
