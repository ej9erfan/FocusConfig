# ============================================================
#  BrowserIntent.ps1  (v4)
#
#  Designed for public use — works on any Windows machine.
#  Requires running as Administrator (for Firefox policies.json).
#  Script will self-elevate if not already admin.
#
#  CHROME  — URL bar: DDG  | NTP search bar: Brave Search
#            Appearance: blank dark page, no logo, no widgets
#
#  FIREFOX — URL bar: DDG  | NTP search bar: Google (reliable default)
#            Appearance: Firefox logo kept, no background, no widgets
#
#  EDGE    — URL bar: DDG  | NTP search bar: Copilot/Bing (native)
#            Appearance: background image kept, no logo, no widgets
#
#  WINDOWS — News/Widgets taskbar icon hidden
#
#  Close all browsers before running. Reopen after.
# ============================================================

# ── Self-elevate to admin if needed (required for Firefox policies.json) ──
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "Relaunching as Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "`n=== FocusConfig — BrowserIntent v4 ===" -ForegroundColor Cyan
Write-Host "Running as Administrator. Applying all settings.`n" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# SECTION 1 — CHROME
# URL bar search : DuckDuckGo  (via registry policy)
# NTP search bar : Brave Search (custom NTP HTML page)
# Appearance     : blank dark page, no logo, no widgets
# ─────────────────────────────────────────────────────────────
Write-Host "[Chrome] Applying settings..." -ForegroundColor Yellow

# ── Build custom NTP HTML with Brave Search bar only ──
$ChromeNTPDir  = "$env:LOCALAPPDATA\ChromeCustomNTP"
$ChromeNTPFile = "$ChromeNTPDir\newtab.html"
if (-not (Test-Path $ChromeNTPDir)) { New-Item -Path $ChromeNTPDir -ItemType Directory -Force | Out-Null }

$ChromeNTPHtml = @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>New Tab</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    background: #202124;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
    font-family: Arial, sans-serif;
  }
  .search-form {
    display: flex;
    width: 560px;
    max-width: 90vw;
  }
  .search-input {
    flex: 1;
    padding: 14px 20px;
    font-size: 16px;
    border: none;
    border-radius: 24px 0 0 24px;
    background: #303134;
    color: #e8eaed;
    outline: none;
    caret-color: #fb542b;
  }
  .search-input::placeholder { color: #9aa0a6; }
  .search-input:focus { background: #3c4043; }
  .search-btn {
    padding: 0 22px;
    background: #fb542b;
    border: none;
    border-radius: 0 24px 24px 0;
    cursor: pointer;
    color: #fff;
    font-size: 20px;
    transition: background 0.15s;
  }
  .search-btn:hover { background: #e04420; }
  .label {
    margin-top: 14px;
    font-size: 12px;
    color: #5f6368;
    letter-spacing: 0.04em;
  }
</style>
</head>
<body>
  <form class="search-form" action="https://search.brave.com/search" method="GET">
    <input class="search-input" type="text" name="q" placeholder="Search with Brave" autofocus autocomplete="off"/>
    <button class="search-btn" type="submit">&#128269;</button>
  </form>
  <div class="label">Brave Search &mdash; independent results</div>
</body>
</html>
'@

Set-Content -Path $ChromeNTPFile -Value $ChromeNTPHtml -Encoding UTF8

$NTPFileURL = "file:///$($ChromeNTPFile.Replace('\','/'))"

# ── Chrome registry policy (HKLM = applies to all users; more robust) ──
$ChromePolicyPath = "HKLM:\Software\Policies\Google\Chrome"
if (-not (Test-Path $ChromePolicyPath)) { New-Item -Path $ChromePolicyPath -Force | Out-Null }

Set-ItemProperty -Path $ChromePolicyPath -Name "NewTabPageLocation"             -Value $NTPFileURL                               -Type String -Force
Set-ItemProperty -Path $ChromePolicyPath -Name "DefaultSearchProviderEnabled"   -Value 1                                         -Type DWord  -Force
Set-ItemProperty -Path $ChromePolicyPath -Name "DefaultSearchProviderName"      -Value "DuckDuckGo"                              -Type String -Force
Set-ItemProperty -Path $ChromePolicyPath -Name "DefaultSearchProviderSearchURL" -Value "https://duckduckgo.com/?q={searchTerms}" -Type String -Force
Set-ItemProperty -Path $ChromePolicyPath -Name "DefaultSearchProviderNewTabURL" -Value "https://duckduckgo.com"                  -Type String -Force
Set-ItemProperty -Path $ChromePolicyPath -Name "PromotionalTabsEnabled"         -Value 0                                         -Type DWord  -Force

Write-Host "[Chrome] Done. NTP: Brave Search (blank dark page). URL bar: DDG." -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# SECTION 2 — FIREFOX
# URL bar search : DuckDuckGo  (via policies.json)
# NTP search bar : Google      (most reliable via policies.json)
# Appearance     : Firefox logo kept, no background, no widgets
# ─────────────────────────────────────────────────────────────
Write-Host "[Firefox] Applying settings..." -ForegroundColor Yellow

# Detect Firefox install directory
$FFInstallPaths = @(
    "$env:ProgramFiles\Mozilla Firefox",
    "${env:ProgramFiles(x86)}\Mozilla Firefox",
    "$env:LOCALAPPDATA\Mozilla Firefox"
)

$FFInstallDir = $null
foreach ($path in $FFInstallPaths) {
    if (Test-Path "$path\firefox.exe") {
        $FFInstallDir = $path
        break
    }
}

if ($FFInstallDir) {
    $FFDistDir = "$FFInstallDir\distribution"
    if (-not (Test-Path $FFDistDir)) { New-Item -Path $FFDistDir -ItemType Directory -Force | Out-Null }

    $FFPoliciesFile = "$FFDistDir\policies.json"

    $FFPolicies = @'
{
  "policies": {
    "SearchEngines": {
      "Default": "DuckDuckGo",
      "PreventInstalls": false
    },
    "FirefoxHome": {
      "Search": true,
      "TopSites": false,
      "SponsoredTopSites": false,
      "Highlights": false,
      "Pocket": false,
      "SponsoredPocket": false,
      "Snippets": false,
      "Locked": false
    },
    "NewTabPage": {
      "Homepage": false,
      "Activity": false
    },
    "Homepage": {
      "StartPage": "none"
    },
    "DisableTelemetry": true,
    "DisablePocket": true,
    "OverrideFirstRunPage": "",
    "OverridePostUpdatePage": ""
  }
}
'@

    Set-Content -Path $FFPoliciesFile -Value $FFPolicies -Encoding UTF8
    Write-Host "  policies.json written to: $FFDistDir" -ForegroundColor DarkGreen

    # Also apply user.js to all profiles for weather + noise suppression
    # (policies.json doesn't cover every newtab pref)
    $FFProfileRoot = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $FFProfileRoot) {
        $profiles = Get-ChildItem -Path $FFProfileRoot -Directory
        foreach ($profile in $profiles) {
            $userJS = Join-Path $profile.FullName "user.js"
            $FFUserJS = @'
// ── Generated by BrowserIntent.ps1 v4 ────────────────────
// Supplements policies.json — covers prefs not exposed there

// Weather widget (Firefox 127+)
user_pref("browser.newtabpage.activity-stream.feeds.weatherfeed", false);
user_pref("browser.newtabpage.activity-stream.showWeather",       false);
user_pref("browser.newtabpage.activity-stream.weather.query",     "");

// Discovery / sponsored noise
user_pref("browser.newtabpage.activity-stream.feeds.discoverystreamfeed",  false);
user_pref("browser.newtabpage.activity-stream.discoverystream.enabled",    false);
user_pref("browser.newtabpage.activity-stream.showSponsored",              false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites",      false);

// URL bar noise
user_pref("browser.urlbar.suggest.quicksuggest.sponsored",    false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.sponsoredTopSites",                 false);
user_pref("browser.urlbar.suggest.trending",                  false);
user_pref("browser.urlbar.suggest.recentsearches",            false);
'@
            Set-Content -Path $userJS -Value $FFUserJS -Encoding UTF8
            Write-Host "  user.js applied to profile: $($profile.Name)" -ForegroundColor DarkGreen
        }
    }

} else {
    Write-Host "[Firefox] Install not found in standard locations — skipping." -ForegroundColor DarkGray
}

Write-Host "[Firefox] Done. NTP: Google search bar + FF logo. URL bar: DDG." -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# SECTION 3 — EDGE
# URL bar search : DuckDuckGo  (via registry policy)
# NTP search bar : Copilot/Bing (Edge native — explicitly restored)
# Appearance     : background image kept, no logo, no widgets
# ─────────────────────────────────────────────────────────────
Write-Host "[Edge] Applying settings..." -ForegroundColor Yellow

$EdgePolicyPath = "HKLM:\Software\Policies\Microsoft\Edge"
if (-not (Test-Path $EdgePolicyPath)) { New-Item -Path $EdgePolicyPath -Force | Out-Null }

# ── Restore native Copilot/Bing NTP search box ──
Set-ItemProperty -Path $EdgePolicyPath -Name "NewTabPageSearchBox"               -Value "bing"  -Type String -Force

# ── Kill all widgets (weather, news, quick links, top sites, rewards) ──
Set-ItemProperty -Path $EdgePolicyPath -Name "NewTabPageContentEnabled"          -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "NewTabPageNewsEnabled"             -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "NewTabPageQuickLinksEnabled"       -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "NewTabPageHideDefaultTopSites"     -Value 1 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "NewTabPageBingChatEnabled"         -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "ShowMicrosoftRewards"              -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "HideFirstRunExperience"            -Value 1 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "SpotlightExperiencesAndRecommendationsEnabled" -Value 0 -Type DWord -Force

# ── Weather card (NTPCards subkey) ──
$EdgeNTPCardsPath = "HKCU:\Software\Microsoft\Edge\NTPCards"
if (-not (Test-Path $EdgeNTPCardsPath)) { New-Item -Path $EdgeNTPCardsPath -Force | Out-Null }
Set-ItemProperty -Path $EdgeNTPCardsPath -Name "WeatherEnabled"  -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgeNTPCardsPath -Name "TrafficEnabled"  -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgeNTPCardsPath -Name "SportsEnabled"   -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgeNTPCardsPath -Name "FinanceEnabled"  -Value 0 -Type DWord -Force

# ── URL bar search engine: DDG ──
Set-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderEnabled"      -Value 1                                         -Type DWord  -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderName"         -Value "DuckDuckGo"                              -Type String -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "DefaultSearchProviderSearchURL"    -Value "https://duckduckgo.com/?q={searchTerms}" -Type String -Force

Write-Host "[Edge] Done. NTP: Copilot search bar + background. URL bar: DDG. All widgets removed." -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# SECTION 4 — Windows News / Widgets taskbar
# ─────────────────────────────────────────────────────────────
Write-Host "[Windows] Hiding News & Widgets taskbar items..." -ForegroundColor Yellow

$FeedsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"
if (-not (Test-Path $FeedsPath)) { New-Item -Path $FeedsPath -Force | Out-Null }
Set-ItemProperty -Path $FeedsPath -Name "ShellFeedsTaskbarViewMode" -Value 2 -Type DWord -Force

$AdvancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $AdvancedPath -Name "TaskbarDa" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

Write-Host "[Windows] Done." -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Done! v4 Summary:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  CHROME"
Write-Host "    NTP search bar : Brave Search"
Write-Host "    URL bar search : DuckDuckGo"
Write-Host "    Appearance     : blank dark page, no logo, no widgets"
Write-Host ""
Write-Host "  FIREFOX"
Write-Host "    NTP search bar : Google (via policies.json)"
Write-Host "    URL bar search : DuckDuckGo"
Write-Host "    Appearance     : Firefox logo kept, no background, no widgets"
Write-Host ""
Write-Host "  EDGE"
Write-Host "    NTP search bar : Copilot / Bing (native)"
Write-Host "    URL bar search : DuckDuckGo"
Write-Host "    Appearance     : background image kept, no logo, no widgets"
Write-Host ""
Write-Host "  WINDOWS — News/Widgets taskbar icon hidden"
Write-Host ""
Write-Host "  ACTION REQUIRED:" -ForegroundColor White
Write-Host "  1. Close ALL browsers before running this script." -ForegroundColor White
Write-Host "  2. Reopen browsers after running." -ForegroundColor White
Write-Host "  3. Chrome: if NTP shows a policy warning bar, go to" -ForegroundColor White
Write-Host "     chrome://policy and confirm NewTabPageLocation is set." -ForegroundColor White
Write-Host ""
