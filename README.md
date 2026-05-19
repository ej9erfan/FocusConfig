# FocusConfig

A suite of PowerShell scripts for Windows that strips browser and OS interfaces down to deliberate, intentional entry points — and nothing else. Built by and for ADHD engineers who need their tools to work *for* their attention, not against it.

---

## The Problem

Modern browser new tab pages and Windows 11 defaults are attention traps by design. Every new tab delivers weather you didn't ask for, news headlines engineered to pull you sideways, sponsored shortcuts, and a search bar defaulting to whoever paid to be there. Windows 11 adds its own layer: a centered taskbar that feels subtly wrong, a right-click menu truncated to five options, ads inside the Start menu, and a Bing-powered search bar that fires up Cortana when you just wanted to find a file.

For a neurotypical user this is mild background noise. For an ADHD brain, any one of these can derail a task completely. You opened a tab to look up a Kubernetes flag and twenty minutes later you're reading about a hurricane.

The fix is not discipline. The fix is removing the stimuli.

---

## What's in the Suite

```
FocusConfig\
  ├── BrowserIntent.ps1       Browser NTP + search engine configuration
  ├── Win11Streamline.ps1     Windows 11 UX restoration
  ├── Run-All.ps1             Master runner — runs both scripts in order
  └── docs\
      ├── README.md           This file
      └── BROWSER_ROLES.md    Why each browser is assigned to each work context
```

---

## Scripts

### BrowserIntent.ps1

Configures the new tab page and search engines for Chrome, Firefox, and Edge. Each browser gets exactly one search bar on its NTP and nothing else. Each browser retains a distinct visual identity so you always know which context you're in at a glance.

| Browser | NTP Search | URL Bar Search | Visual Identity        |
|---------|-----------|----------------|------------------------|
| Chrome  | Brave Search | DuckDuckGo  | Blank dark page        |
| Firefox | Google       | DuckDuckGo  | Firefox logo           |
| Edge    | Copilot/Bing | DuckDuckGo  | Background image       |

All settings are applied via official policy mechanisms (Windows Registry `HKLM` for Chrome and Edge, `policies.json` for Firefox) so they survive browser updates and profile resets.

See `docs/BROWSER_ROLES.md` for the reasoning behind each browser's assigned work context.

---

### Win11Streamline.ps1

Restores Windows 11 to a less distracting default state. Does not uninstall anything or touch security settings.

| Change | What it does |
|--------|-------------|
| Taskbar left-align | Moves Start button and icons back to the left |
| Full right-click menu | Removes the "Show more options" truncation — full menu on first click |
| Start menu ads | Kills Microsoft's promoted/suggested app ads in Start |
| Start menu Recommended | Removes the recently opened files feed from Start |
| OneDrive autostart | Stops OneDrive launching silently on login (still installed) |
| Xbox Game Bar | Disables Win+G overlay and background capture/DVR |
| Taskbar Search | Disables Bing; web queries route to your default browser instead |

**On taskbar search and Kagi:** Windows doesn't expose a clean registry key to route taskbar searches to an arbitrary engine. The reliable approach is: disable Bing (done by the script), which causes web queries to open in your default browser using its default search engine (DDG in this setup). Install the [Kagi browser extension](https://kagi.com) to intercept and transparently redirect those queries to Kagi. Net result: taskbar search → browser → Kagi.

---

### Run-All.ps1

Runs both scripts in sequence with a single confirmation prompt. Start here if you're setting up a fresh machine or want to reapply everything after a Windows update.

---

## Requirements

- Windows 10 or 11
- PowerShell 5.1 or later (included in Windows by default)
- Administrator rights (all scripts self-elevate automatically)
- Close all browsers before running

---

## Usage

```powershell
# Run everything (recommended for first-time setup):
.\Run-All.ps1

# Or run scripts individually:
.\BrowserIntent.ps1
.\Win11Streamline.ps1
```

Right-click any `.ps1` file and select **Run with PowerShell**, or run from a PowerShell terminal. Scripts will prompt for elevation if needed.

---

## After Running

- **Browsers**: Reopen them. Verify each NTP shows only the expected search bar.
- **Chrome**: If a policy warning bar appears, go to `chrome://policy` — `NewTabPageLocation` should be listed. This is normal for policy-managed browsers.
- **Firefox**: Open `about:preferences#search` once and confirm DuckDuckGo is selected. Firefox requires one manual confirmation for search engine changes.
- **Taskbar**: If left-alignment doesn't take effect immediately, log out and back in.
- **Kagi**: Install the [Kagi extension](https://kagi.com/settings?p=user_details) in your browser of choice to complete the taskbar search routing.

---

## Philosophy

This suite does not try to make your environment "productive" in the motivational-poster sense. It does not add focus timers, block websites, or gamify your workflow. It simply removes things that compete for your attention when you haven't asked them to.

This is environmental design: structuring your digital environment so that the right behavior is the path of least resistance, rather than relying on willpower or reminders. Each browser is a mode. Each NTP is a clean entry point. Each context switch is a deliberate act.

> Attention is not a character flaw to be managed. It's a resource to be respected.

---

## Contributing

If you're an ADHD engineer who has found other reliable policy keys, NTP prefs, or Windows registry settings worth including, PRs are welcome. Please test on a clean profile before submitting and document the before/after behavior clearly.
