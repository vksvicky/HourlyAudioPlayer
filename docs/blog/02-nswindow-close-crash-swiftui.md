# Blog draft: The Done button that killed my menu bar app

**Status:** Draft — ready to edit and publish  
**Suggested titles:**
- *Fixing a `_NSWindowTransformAnimation` crash when closing SwiftUI settings*
- *Don’t nil `contentViewController` during `windowWillClose`*
- *Why Done and the red close button segfaulted my macOS app*

**Tags:** macOS, AppKit, SwiftUI, NSHostingController, crash, debugging, EXC_BAD_ACCESS  
**Estimated length:** 1,500–2,000 words  
**Audience:** macOS developers mixing AppKit windows with SwiftUI

---

## Outline

1. Hook — app “quits” when clicking Done (actually crashed)  
2. How we noticed (monitor script: “Process not found”)  
3. Reading the crash report  
4. Root cause — tearing down content during close animation  
5. Failed fixes (manual `close()`, early `contentViewController = nil`)  
6. Final fix — defer Done, disable animation, let AppKit release content  
7. Rules of thumb for NSWindow + SwiftUI  
8. Takeaways

---

## Draft body

### It wasn’t quit — it was a segfault

After fixing memory retention, we tested the full user flow: open settings, assign audio, preview, remove, click **Done**. The settings window disappeared. The menu bar icon vanished too. Our memory monitor printed:

```text
⚠️  Process not found; waiting…
ℹ️  RSS=n/a MB  (pid=—)
```

The app hadn’t gracefully quit — **`HourlyAudioPlayer` crashed**. The same happened with the standard red **window close** button. `applicationShouldTerminateAfterLastWindowClosed` returned `false`; this was not intentional termination.

### The crash report

Path: `~/Library/Logs/DiagnosticReports/HourlyAudioPlayer-*.ips`

Key fields:

- **Exception:** `EXC_BAD_ACCESS` / `SIGSEGV`  
- **Faulting thread:** main  
- **Stack (top):**

```text
objc_release
-[_NSWindowTransformAnimation dealloc]
...
CA::Transaction::commit()
-[NSApplication run]
```

Same signature on multiple incidents (same pid lifecycle as manual testing). The crash happened **during Core Animation’s transaction commit**, while AppKit was tearing down a **window transform animation** — not in our Swift code directly.

### What we were doing wrong

Settings live in an `NSWindow` with an `NSHostingController<ContentView>` as `contentViewController`. On dismiss we tried to be aggressive about memory:

1. Stop preview, clear waveform cache  
2. Nil `settingsHostingController`  
3. **`settingsWindow?.contentViewController = nil`** — detach SwiftUI immediately  
4. `orderOut` / `close()` / `performClose`

Step 3 while the window is **closing** (especially with animation) left AppKit’s close animation holding references into objects we had already detached. When `_NSWindowTransformAnimation` deallocated, it called `objc_release` on a **bad address** → segfault.

This is a **lifecycle ordering bug**, not a SwiftUI bug per se. AppKit owns the window teardown sequence; ripping out `contentViewController` mid-flight fights that sequence.

### Attempts that didn’t work

| Approach | Result |
|----------|--------|
| `orderOut` only, keep window shell | No crash; RSS stayed high |
| `close()` + nil `contentViewController` before animation completes | **Crash** |
| `performClose` + detach in `windowWillClose` | **Crash** (same stack) |
| `malloc_zone_pressure_relief` | No effect on crash |

The crash report was identical across attempts until we stopped clearing `contentViewController` during close.

### The fix (conceptual)

**Invariant (document in code and tests):**

> During window close, drop **our** strong ref to the hosting controller (`settingsHostingController = nil`). Do **not** set `window.contentViewController = nil`. Let the window release it when `isReleasedWhenClosed` tears the window down.

**Done button path:**

1. User taps Done → `closeAuxiliaryWindows()`  
2. **`DispatchQueue.main.async`** — let the button action and SwiftUI update cycle finish before close starts  
3. `window.animationBehavior = .none` — avoid the transform animation path that crashed  
4. `performClose(nil)` → `windowWillClose` → `finishSettingsDismissal()`  
5. In `finishSettingsDismissal`: release audio/cache state, nil hosting ref + window ref, **never** nil `contentViewController` on the closing window

**Replacing content while window stays open** (reopen / refresh) is a **different** path: `detachSettingsContentFromWindow()` may nil `contentViewController` because the window is **not** closing — that is safe.

Relevant comment in `AppWindowController.swift`:

```swift
/// Clears app state and drops our references. Does not nil `contentViewController` — AppKit
/// must release it with the window or a close animation can crash in `_NSWindowTransformAnimation`.
private func finishSettingsDismissal() { ... }
```

### Rules of thumb: NSWindow + NSHostingController + SwiftUI

1. **Don’t detach `contentViewController` in `windowWillClose`** unless you know the window is not animating closed.  
2. **Defer close from SwiftUI actions** (`Button`, `onSubmit`) to the next run-loop turn if you see flaky teardown.  
3. **`animationBehavior = .none`** is a valid tool for utility windows where you prefer correctness over zoom animation.  
4. **`isReleasedWhenClosed = true`** — window deallocates itself; keep a weak discipline: nil **your** refs in the delegate, don’t fight AppKit release order.  
5. **Separate “hide” (`orderOut`) from “close” (`performClose`)** — menu bar apps often need explicit lifecycle docs for which you use when.  
6. **Read the crash report stack for AppKit animation frames** — not every EXC_BAD_ACCESS is your array subscript.

### How to verify the fix

Manual:

1. Open settings → Done → menu bar icon still present  
2. Open settings → red close → same  
3. Assign audio → preview → remove → Done → no crash  
4. Repeat 10× rapidly  

Automated (planned — see post 03): integration test pumps run loop after `closeAuxiliaryWindows()` and asserts `isSettingsWindowOpen == false` and process survival.

### Takeaways

- Memory optimisation that **fights AppKit lifecycle** can crash worse than leaking a window shell.  
- **`Process not found` in a shell script** can mean crash, not quit — check DiagnosticReports.  
- Keep a **one-line invariant** in source for the next refactor (“never nil contentViewController during close”).  
- Unit tests alone would **not** have caught this; needs main-thread window integration test or manual QA.

### Pre-publish checklist

- [ ] Redacted crash report excerpt (pid/uuid only)  
- [ ] Before/after code diff narrative (not necessarily full diff)  
- [ ] Screen recording: Done + close button working  
- [ ] Mention macOS 26.5 / AppKit version if relevant  
- [ ] Cross-link to memory post [01-menu-bar-app-memory-footprint.md](01-menu-bar-app-memory-footprint.md)

---

## Code references (repo)

- `src/AppWindowController.swift` — `closeAuxiliaryWindows`, `finishSettingsDismissal`, `requestCloseSettingsWindow`  
- `src/ContentView.swift` — Done → `closeAuxiliaryWindows()`  
- `src/HourlyAudioPlayerApp.swift` — `applicationShouldTerminateAfterLastWindowClosed` → `false`  
- Crash logs: `~/Library/Logs/DiagnosticReports/HourlyAudioPlayer-*.ips`
