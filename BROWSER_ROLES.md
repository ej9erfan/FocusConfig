# Browser Role Assignments — Rationale

This document describes the intentional separation of work contexts across three browsers. The goal is cognitive context separation: each browser represents a distinct domain of responsibility, so switching browsers is a deliberate context switch rather than an accidental one.

---

## The Core Problem This Solves

When everything lives in one browser, tabs bleed into each other. A Slack notification fires while you're reviewing a pull request. A personal email sits next to a corporate dashboard. Your mutual aid group's spreadsheet is two tabs away from your company's Jira board. For an ADHD brain, proximity is contamination — if it's visible, it's a potential interrupt.

Separating by browser creates a hard boundary. Closing a browser is closing a context. Opening one is a deliberate signal to yourself about what mode you're in.

---

## Microsoft Edge — Corporate & Microsoft Ecosystem

**Assigned work:**
- Microsoft 365 tenants (two separate organizational suites)
- Mattermost (external communications server)
- Corporate interests and business operations

**Why Edge:**
Edge has the deepest native integration with the Microsoft ecosystem. Single sign-on across M365 tenants works more smoothly in Edge than in any other browser. The Copilot search bar on the NTP is a natural fit — AI-assisted search makes sense in a corporate productivity context where you're often looking for internal documentation, policies, or M365 feature guidance.

**The Mattermost placement is intentional:** By corralling all outside communication into Edge alongside corporate tools, external attention demands are contained in one browser. When Edge is closed, the outside world stops pinging you. This is not isolation — it's scheduled access.

---

## Google Chrome — Personal, Volunteer & LLM Work

**Assigned work:**
- LLM chat interfaces (non-corporate, non-government)
- Personal accounts and services
- Volunteer work and community organizations

**Why Chrome:**
Chrome's profile system makes it easy to maintain clean separation between personal identities. It's also the most widely supported browser for consumer web apps, which is where personal and volunteer tools tend to live.

The LLM work is placed here deliberately — these are personal AI interactions, not corporate ones, and keeping them out of the Edge/M365 ecosystem maintains a clean separation between professional AI usage (which may be subject to organizational policy) and personal exploration.

The Brave Search NTP bar is a good fit here: independent search results with no filter bubble suits the research and exploration nature of this context.

---

## Firefox — Engineering, Infrastructure & Government

**Assigned work:**
- Engineering tools and development environments
- Infrastructure and environment access
- Atlassian suite (Jira, Confluence, etc.)
- Government-related work (non-Microsoft)
- Certificate and site association management

**Why Firefox:**
Firefox has the most mature and flexible certificate management of the three browsers. For engineering work involving internal CAs, self-signed certs, client certificates, or government PKI infrastructure, Firefox's certificate store is independent of the Windows system store — which means you can add, trust, and scope certificates precisely without affecting the rest of the system.

Firefox also has the strongest extension ecosystem for engineering workflows, and its developer tools are excellent for frontend and API work.

**The Atlassian placement makes sense here** because Atlassian tools are typically accessed via internal SSO that may involve certificates or custom identity providers — Firefox handles these most reliably.

---

## Summary Table

| Browser | Domain | Key Reason |
|---------|--------|------------|
| Edge    | Corporate, M365, external comms | Native M365 SSO, Copilot integration, Mattermost containment |
| Chrome  | Personal, volunteer, LLM chats | Profile separation, consumer app support, personal AI work |
| Firefox | Engineering, infra, gov, Atlassian | Superior cert management, independent cert store, dev tooling |

---

## The Underlying Principle

Each browser is a *mode*, not just a container. Opening Edge means you're in work mode. Opening Chrome means you're in personal or exploration mode. Opening Firefox means you're in engineering mode. The visual distinctiveness of each browser's new tab page (enforced by `BrowserIntent.ps1`) reinforces this — your environment gives you a constant low-cost signal about what context you're operating in, without requiring any conscious effort to check.

This is sometimes called *environmental design* in ADHD management literature: structuring your physical and digital environment so that the right behavior is the path of least resistance, rather than relying on willpower or reminders.
