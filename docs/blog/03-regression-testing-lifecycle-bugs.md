# Blog draft: Testing what XCTest won’t catch — window lifecycle regressions

**Status:** Draft — ready to edit and publish  
**Suggested titles:**
- *How to stop menu bar app memory and crash bugs from coming back*
- *A regression plan for NSWindow + SwiftUI lifecycle*
- *Right-BICEP for a macOS settings window nobody unit-tested*

**Tags:** testing, XCTest, macOS, regression, TDD, menu bar app, QA  
**Estimated length:** 2,000–2,500 words  
**Audience:** Engineers who ship macOS UI and want a practical test pyramid

---

## Outline

1. Hook — we fixed two production bugs tests never flagged  
2. What broke (summary + link to posts 01 & 02)  
3. Current test coverage (honest audit)  
4. Four-layer prevention strategy  
5. Unit tests to add (`AppWindowControllerTests`)  
6. Integration tests (run loop + real window)  
7. Manual / scripted smoke (`monitor_memory.sh` checklist)  
8. CI and code guardrails  
9. Scenario matrix (additional cases)  
10. Implementation roadmap + priority order

---

## Draft body

### We fixed bugs our test suite didn’t know about

Two issues shipped to manual QA:

1. **Memory:** RSS stayed ~140 MB after closing settings ([post 01](01-menu-bar-app-memory-footprint.md))  
2. **Crash:** Done / window close → `EXC_BAD_ACCESS` in `_NSWindowTransformAnimation` ([post 02](02-nswindow-close-crash-swiftui.md))

`./run_tests.sh` was green. The gaps were predictable in hindsight: **no tests touched `AppWindowController`**, and **no XCUITest target** ([TESTING.md](../TESTING.md) documents this explicitly).

This post is the plan to ensure those issues **never regress silently** — written so you can implement it incrementally or turn sections into their own articles.

---

### Current coverage (audit)

| Area | Tests today | Gap |
|------|-------------|-----|
| Waveform chunked read | `MemoryFootprintTests` | ✓ |
| Waveform cache eviction / `removeAll` | `MemoryFootprintTests` | ✓ |
| RSS read API | `MemoryFootprintTests` | ✓ |
| Preview / stop / remove audio | `AudioPreviewTests` | ✓ at `AudioFileManager` level |
| Settings window open/close | **None** | **Critical** |
| Crash on Done / red close | **None** | **Critical** |
| RSS after dismiss | **None** | Manual only |
| UI automation (grid, sheets) | **None** | No XCUITest target |

---

### Four-layer strategy

```
Layer 1 — Unit tests        Fast, every PR, logic invariants
Layer 2 — Integration tests Real NSWindow + run loop, crash survival
Layer 3 — Manual smoke      monitor_memory.sh + checklist before release
Layer 4 — CI guardrails     run_tests.sh, PR template, code comments
```

No single layer catches everything. **Layer 2** is required for the AppKit crash; **Layer 3** is required for RSS behaviour in Debug builds.

---

### Layer 1: Unit tests — `AppWindowControllerTests.swift`

**Goal:** Fail fast on logic regressions without needing a visible window.

| Test | Assert |
|------|--------|
| `givenSettingsOpen_whenCloseAuxiliaryWindows_thenIsSettingsWindowOpenFalse` | Flag cleared after async close pump |
| `givenSettingsOpen_whenClose_thenWaveformCacheEmpty` | `AudioWaveformCache.shared.entryCount == 0` |
| `givenPreviewActive_whenClose_thenStopPreviewCalled` | Mock `AudioPreviewPlaying` receives stop |
| `givenAlreadyClosed_whenCloseAgain_thenNoOp` | Idempotent `finishSettingsDismissal` |
| `givenClosed_whenOpenSettings_thenIsSettingsWindowOpenTrue` | Reopen works |
| `givenOpenCloseOpen_whenSecondOpen_thenNewHostingController` | Fresh grid (compare object identity if exposed) |

**Document invariant in test file:**

```swift
// REGRESSION (2026-06): finishSettingsDismissal must NOT set
// window.contentViewController = nil during close — see crash in
// _NSWindowTransformAnimation dealloc. Post 02 in docs/blog/.
```

**Extend existing tests:**

- `MemoryFootprintTests`: async waveform load cancelled when `removeAll()` bumps epoch (in-flight generation)  
- `AudioPreviewTests`: already has `test_givenPreviewActive_whenRemoveAudio_thenStopsPreview` — add window-close integration separately

**Testability note:** May require `@testable import HourlyAudioPlayer` and optionally a package-internal test hook to reset `AppWindowController.shared` state between tests, or a dedicated non-singleton instance for tests (better long-term).

---

### Layer 2: Integration tests — macOS host + run loop

**Goal:** Process survives real close paths; catches `_NSWindowTransformAnimation` class crashes.

Run on main actor; pump run loop after async dismiss:

```swift
@MainActor
func test_givenSettingsWindow_whenCloseViaDonePath_thenSurvives() async {
    AppWindowController.shared.openSettings()
    await pumpRunLoop(seconds: 0.5)
    AppWindowController.shared.closeAuxiliaryWindows()
    await pumpRunLoop(seconds: 1.0)
    XCTAssertFalse(AppWindowController.shared.isSettingsWindowOpen)
}
```

**Scenarios (each = one test method):**

| # | Scenario | Pass criteria |
|---|----------|---------------|
| I1 | Done after idle open | No crash; flag false |
| I2 | Red close via `performClose` / delegate | Same |
| I3 | Assign → preview → remove → Done | Reproduces user bug |
| I4 | Close with launch schedule sheet open | No crash |
| I5 | Close while waveforms loading | No crash |
| I6 | Open → close → open again | Second open works |
| I7 | Double Done rapidly | Idempotent |
| I8 | ⌘, while already open | Focus, not duplicate window |

Helper:

```swift
func pumpRunLoop(seconds: TimeInterval) async {
    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { cont.resume() }
    }
}
```

**Optional later:** XCUITest target — menu bar → Open Settings → Done. Slower, closest to user behaviour; CI needs GUI session.

---

### Layer 3: Manual smoke checklist

Add to release QA ([TESTING.md](../TESTING.md) or [MEMORY.md](../MEMORY.md)). Run before tagged releases.

**Terminal 1:** `./build_and_run.sh`  
**Terminal 2:** `./scripts/monitor_memory.sh 10 300`

| Step | Action | Pass |
|------|--------|------|
| M1 | Idle 2 min | RSS ~70–80 MB stable |
| M2 | Open settings | RSS ~140 MB |
| M3 | Assign audio, preview, remove | No crash |
| M4 | Done | Menu bar icon remains; Console: `[settings-released]` |
| M5 | Wait 90 s | RSS drops meaningfully; same pid |
| M6 | Reopen settings | Grid loads |
| M7 | Red close | Same as Done |
| M8 | Repeat M4–M7 × 10 | No crash |
| M9 | Release build repeat M4–M7 | Compare RSS |

**Instruments (quarterly or pre-major release):**

- Profile → Leaks / Allocations  
- Mark generation: open settings → scroll all hours → preview 3 files → close  
- Repeat 10×; no unbounded persistent growth

---

### Layer 4: CI and guardrails

**Today:** GitHub Actions runs `./run_tests.sh` on macOS 13–15 (+ 26 beta). Window lifecycle tests are **not** in the suite yet.

**When tests exist:**

```yaml
- name: Settings lifecycle tests
  run: |
    xcodebuild test \
      -scheme HourlyAudioPlayer \
      -destination 'platform=macOS' \
      -only-testing:HourlyAudioPlayerTests/AppWindowControllerTests
```

**PR template checkbox:**

- [ ] Settings open/close tested (Done + red X)  
- [ ] No new `contentViewController = nil` during close paths  

**Source guardrail:** Keep comment on `finishSettingsDismissal()` in `AppWindowController.swift`.

**Docs:** [MEMORY.md](../MEMORY.md) for operators; this file for engineering strategy.

---

### Scenario matrix — additional cases to think about

Use for test design, exploratory QA, or future blog “edge cases” post.

**Window / UI**

- Settings open while About open  
- External launch notification (`hourlyPlayerDidLaunchExternalItem`) closes settings  
- Theme toggle + immediate Done  
- Volume slider drag + Done mid-drag  
- Launch schedule editor sheet: close sheet only vs Done on main grid  
- Window miniaturised (yellow button) then restored then Done  

**Memory**

- 0 vs 24 hours with custom audio (waveform fan-out)  
- Large file near 2.5 MB limit  
- Preview several files sequentially then Done  
- 1-hour idle run (`monitor_memory.sh 60 3600`) — slow leak detection  

**Audio**

- Close settings during active preview  
- Hourly chime fires while settings open  
- Remove audio while preview playing (unit test exists; add integration)  

**Platform**

- Debug vs Release RSS expectations  
- macOS 12 vs 15 vs 26 window behaviour (CI matrix)  
- Apple Silicon vs Intel (self-hosted runner)  

**Concurrency**

- `AudioWaveformCache.samples(for:)` in flight → immediate Done  
- `removeAll()` epoch bump → continuation returns `[]`  

---

### Right-BICEP mapping (for test design)

| Principle | Application |
|-----------|-------------|
| **Right** | After Done, app alive; cache empty; preview stopped |
| **Boundary** | Double close; close with no settings open; reopen immediately |
| **Inverse** | Open after close restores `isSettingsWindowOpen == true` |
| **Cross-check** | Console logs + CSV RSS + Instruments generations |
| **Error** | Crash report absent; no `Process not found` in monitor script |
| **Performance** | RSS drops after dismiss; no linear RSS growth over 1 h idle |
| **Edge** | Sheet open, preview playing, waveform loading |

---

### Implementation roadmap (priority)

| Priority | Task | Effort |
|----------|------|--------|
| P0 | Manual checklist in TESTING.md | ~30 min |
| P1 | `AppWindowControllerTests` unit invariants | ~2 h |
| P2 | Integration open/close/reopen tests | ~4 h |
| P3 | CI `-only-testing:AppWindowControllerTests` | ~30 min |
| P4 | XCUITest target (optional) | ~1 day |
| P5 | Self-hosted memory smoke job | ~1 day |

---

### Closing thought for the blog post

Unit tests gave us confidence in **audio files and waveforms** — the domains we actually tested. Lifecycle bugs lived in the **glue** between SwiftUI, AppKit, and a singleton window controller we never exercised. The fix is not “more tests everywhere”; it is **targeted layers** for the glue: invariants in unit tests, survival in integration tests, RSS in scripted smoke, and a one-line invariant in code so the next refactor doesn’t nil the wrong pointer.

---

### Pre-publish checklist

- [ ] Link to posts [01](01-menu-bar-app-memory-footprint.md) and [02](02-nswindow-close-crash-swiftui.md)  
- [ ] Table of “what CI catches vs what it doesn’t”  
- [ ] Optional: diagram of four-layer pyramid (export from Mermaid)  
- [ ] Mention `./run_tests.sh` and current XCUITest gap honestly

---

## Code references (repo)

- `test/MemoryFootprintTests.swift`  
- `test/AudioPreviewTests.swift`  
- `src/AppWindowController.swift`  
- `docs/TESTING.md`  
- `docs/MEMORY.md`  
- `scripts/monitor_memory.sh`  
- `.github/workflows/macos-version-tests.yml`
