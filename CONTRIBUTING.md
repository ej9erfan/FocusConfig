# Contributing to FocusConfig

First — thank you. This project exists because ADHD engineers deserve tools built for how their brains actually work, not how productivity culture wishes they did. Every contribution that makes this more useful, more portable, or more robust is a direct benefit to people who need it.

---

## License and Derivatives

FocusConfig is licensed under **GPL v3**.

What that means in plain terms:

- You can use, modify, and redistribute this freely
- If you distribute a modified version, you must release your changes under GPL v3 as well
- You cannot take this, improve it, and keep those improvements private or proprietary
- Attribution to the original project is required

This is intentional. The goal is that improvements flow back to everyone. If you find a better registry key, a cleaner policy approach, or a way to make this work on macOS — that discovery belongs to the community, not just to you.

If GPL v3 creates a genuine conflict with your use case, open an issue and explain the situation. Edge cases exist and can be discussed.

---

## What We're Looking For

### Registry keys and policy settings
The highest-value contributions are verified registry keys, browser policy settings, or OS-level prefs that suppress distraction, noise, or unsolicited UI. If you've found something that works reliably across versions, document it and submit it.

### Cross-platform support
The current suite is Windows-only. Equivalent scripts for macOS (`defaults write` commands, LaunchAgent plists) and Linux (GNOME/KDE settings, Firefox `policies.json`) are very welcome. Please follow the same structure — one script per concern, a master runner, self-elevation where needed.

### New tool scripts
Browser and OS are just the start. Other high-value targets for ADHD engineers:
- VS Code (disable telemetry, notifications, welcome tabs, update nags)
- Windows Terminal (strip default profiles, disable first-run)
- Slack (notification defaults, sidebar noise)
- Any tool that opens with unsolicited content or interrupts focus

### Bug fixes and version compatibility
Windows updates occasionally break registry keys or reset policy values. If something stops working on a new OS or browser version, a fix with version notes is extremely useful.

---

## How to Contribute

### For registry/policy findings (no coding required)
Open an issue with:
- The registry path or policy key
- What it does before and after
- Which Windows version and browser version you tested on
- Whether it survives updates/restarts

That's it. You don't need to write the PowerShell — someone else can pick it up, or we'll add it together.

### For code contributions
1. Fork the repository
2. Create a branch named for what you're adding: `feature/macos-safari-intent`, `fix/edge-weather-win11-23h2`, etc.
3. Follow the existing script structure:
   - Self-elevation block at the top
   - Clearly commented sections with `# ---` dividers
   - `Write-Host` status lines in consistent colors (Yellow for in-progress, Green for done, DarkYellow for warnings/notes)
   - Summary block at the end listing every change made
4. Test on a clean profile or VM before submitting
5. Update or add to `docs/` if your change affects setup instructions or adds a new script
6. Open a pull request with a clear description of what changed and why

### For documentation
Corrections, clarifications, and additions to the `docs/` folder are welcome as PRs directly. No issue needed for small fixes.

---

## Tested-On Format

When submitting anything that touches registry keys or OS behavior, please include a tested-on note in your PR description or issue:

```
Tested on: Windows 11 23H2, Chrome 124, Edge 124, Firefox 125
```

This helps everyone know how broadly a change has been verified.

---

## Things We Won't Add

- Anything that uninstalls software (this suite only disables, redirects, or suppresses)
- Changes to security or firewall settings
- Scripts that require third-party tools not already present on a standard Windows install
- Anything that can't be cleanly reversed by the user

If you're unsure whether something fits, open an issue and ask before writing the code.

---

## Code of Conduct

This project is for people who have often been told their brains are the problem. That framing is not welcome here. Contributions, issues, and discussions should treat ADHD as a legitimate cognitive style, not a deficit to be overcome through more discipline.

Be direct, be kind, be useful.
