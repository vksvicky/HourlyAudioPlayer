# Blog drafts — Hourly Audio Player

Draft material for posts you can polish and publish later. Each file is self-contained: title options, outline, full draft body, code references, and a pre-publish checklist.

## Planned posts

| # | File | Topic | Status |
|---|------|--------|--------|
| 1 | [01-menu-bar-app-memory-footprint.md](01-menu-bar-app-memory-footprint.md) | Why RSS stayed at ~140 MB after closing settings | Draft |
| 2 | [02-nswindow-close-crash-swiftui.md](02-nswindow-close-crash-swiftui.md) | `_NSWindowTransformAnimation` crash on Done / close | Draft |
| 3 | [03-regression-testing-lifecycle-bugs.md](03-regression-testing-lifecycle-bugs.md) | Test strategy so these bugs never return | Draft |

## Suggested publish order

1. **Post 2** (crash) — dramatic, concrete stack trace, clear fix; good “debugging story” hook.
2. **Post 1** (memory) — pairs naturally; mention `monitor_memory.sh` and Debug vs Release.
3. **Post 3** (testing plan) — “what we learned” follow-up for a technical audience.

Alternatively, merge **1 + 2** into one long “Shipping a menu bar app on macOS” post and keep **3** as a separate engineering practices piece.

## Related project docs

- [MEMORY.md](../MEMORY.md) — operational memory monitoring
- [TESTING.md](../TESTING.md) — current test suite (no window-lifecycle tests yet)
- `src/AppWindowController.swift` — settings window owner
- `scripts/monitor_memory.sh` — RSS sampling CSV

## When you publish

- [ ] Strip internal paths if posting publicly (or keep as open-source companion posts)
- [ ] Add screenshots: Activity Monitor, Console `settings-released` logs, crash report excerpt
- [ ] Note macOS / Xcode versions used (e.g. macOS 26.5, Xcode 17)
- [ ] Link to the GitHub repo and relevant commits
- [ ] Update this README “Status” column to `Published` + URL
