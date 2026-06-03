# Blog draft: Why my menu bar app wouldn’t give memory back

**Status:** Draft — ready to edit and publish  
**Suggested titles:**
- *Why closing the settings window didn’t shrink my macOS menu bar app*
- *Debugging resident memory (RSS) in a SwiftUI menu bar app*
- *140 MB idle? Tracking RSS in Hourly Audio Player*

**Tags:** macOS, Swift, SwiftUI, menu bar app, memory, RSS, Instruments  
**Estimated length:** 1,200–1,800 words  
**Audience:** macOS developers shipping long-lived background apps

---

## Outline

1. Hook — menu bar app should be ~70 MB, not ~140 MB forever  
2. What RSS measures (and what it doesn’t)  
3. How we observed it (`monitor_memory.sh`, in-app logging)  
4. What actually uses memory in our settings UI  
5. False leads vs real retention  
6. What we changed (release path, window lifecycle)  
7. Debug vs Release expectations  
8. Takeaways + checklist for readers

---

## Draft body

### The symptom

Hourly Audio Player is a menu bar utility meant to run for days. In normal use it sits at roughly **70–75 MB** resident set size (RSS). Open the settings window — a 24-slot SwiftUI grid with waveform thumbnails — and RSS climbs to about **140–155 MB**. That part is expected.

The surprise was what happened **after** closing settings. In early builds, RSS **stayed on the plateau** for many minutes, as if the UI had never been dismissed. Activity Monitor showed the process alive; only the menu bar icon remained. From a user perspective the window was gone; from the kernel’s perspective, a large chunk of memory was still attributed to the process.

### RSS is a blunt instrument

Resident set size is “pages currently mapped and resident in RAM for this process.” It is useful for spotting leaks and retained heaps, but:

- **Freed memory is not always returned to the OS immediately.** Allocators (and the kernel) often keep pages for reuse. Calling `free` does not guarantee RSS drops on the next sample.
- **Debug builds retain more** than Release — extra metadata, assertions, less aggressive optimisation.
- A **single plateau** after UI activity is not always a leak; a **steady climb over hours** with no user action is.

We still cared about the post-close plateau because it was tens of megabytes above idle and correlated exactly with “settings was open.”

### How we measured it

We added two complementary approaches:

**1. External sampling script** (`scripts/monitor_memory.sh`):

```bash
./build_and_run.sh
./scripts/monitor_memory.sh 30   # sample every 30s → test-results/memory-samples.csv
```

Each row: `timestamp_iso`, `rss_bytes`, `rss_mb`. Easy to plot or grep.

**2. In-app logging** (developer builds, subsystem `com.example.HourlyAudioPlayer`):

- Category `MemoryFootprint` — periodic samples  
- Category `AppWindowController` — `settings-opened`, `settings-released`, `settings-released+1s`, `settings-released+5s`

Example session:

| Phase | RSS | Notes |
|-------|-----|--------|
| Idle | ~73 MB | Menu bar only |
| Settings opened | ~122 MB → ~143 MB | Grid + waveforms loading |
| After close (old behaviour) | ~143 MB | No drop — window shell retained |

Full interpretation notes live in [MEMORY.md](../MEMORY.md).

### What uses memory in settings

| Component | Typical impact |
|-----------|----------------|
| 24× `HourSlotView` SwiftUI tree | Moderate view/state overhead |
| `NSHostingController` + AppKit bridge | Non-trivial |
| `AudioWaveformCache` | Tiny (~40 floats × up to 32 files) |
| Waveform **generation** | Chunked AVFoundation reads (8k frames); avoids loading whole decoded files |
| `AVAudioPlayer` during preview | Short spike; should end after stop |

An earlier bug decoded **entire audio files** into one buffer for waveforms; that could spike RAM for long MP3s. Generation now reads in **8k-frame chunks** — covered by unit tests in `MemoryFootprintTests`.

The ~70 MB jump when opening settings is mostly **the grid and hosting stack**, not the waveform cache dictionary.

### False leads

- **“It’s the waveform cache.”** Cache entries are small and capped at 32; clearing them on dismiss is necessary but doesn’t explain 70 MB alone.  
- **“It’s a leak in HourlyTimer.”** Idle baseline was stable for many minutes before opening settings.  
- **“malloc didn’t return pages.”** We added `malloc_zone_pressure_relief` via `MemoryFootprint.encourageReturnOfFreedMemory()` — helpful hint, not a guarantee RSS matches idle.

### Real retention: window + SwiftUI lifecycle

The settings UI is hosted in a dedicated `NSWindow` owned by `AppWindowController`, not the deprecated menu-bar popover pattern.

Older dismiss behaviour:

- Called `orderOut` on the window (hide, don’t destroy)  
- Released SwiftUI content in some paths but **kept the `NSWindow` shell** for faster reopen  
- RSS stayed elevated because the window object (and associated infrastructure) remained allocated

Desired behaviour on **Done** or window close:

1. Stop audio preview  
2. Clear `AudioWaveformCache`  
3. Close the window through AppKit’s normal path  
4. Drop **our** references to the hosting controller — let AppKit release `contentViewController` with the window (see blog post 02 for why order matters)  
5. Optionally nudge the allocator with `encourageReturnOfFreedMemory()`

After fix, expect RSS to fall **meaningfully** from the ~140 MB plateau within 60–90 seconds, though not always back to the exact idle number in Debug.

### Debug vs Release

For leak hunting and “what will users see,” compare **Release** builds. Debug RSS is often higher and stickier even when behaviour is correct.

Instruments (**Allocations**, **Leaks**): open settings, scroll all hours, preview files, close, mark generation — look for **persistent growth** across cycles, not a one-time bump.

### Takeaways for other menu bar apps

1. **Measure externally** (`ps`, script, Instruments) — don’t rely on gut feel.  
2. **Log at lifecycle boundaries** (open / release / +1s / +5s) with RSS and domain-specific counters (e.g. `waveformCacheEntries`).  
3. **Separate “hide window” from “release UI.”** `orderOut` ≠ teardown.  
4. **Document expected RSS phases** so future you doesn’t chase ghosts.  
5. **Automate what you can** — see [03-regression-testing-lifecycle-bugs.md](03-regression-testing-lifecycle-bugs.md).

### Pre-publish checklist

- [ ] Screenshot: Activity Monitor before/after settings  
- [ ] Screenshot or paste: `memory-samples.csv` snippet  
- [ ] Link to `MemoryFootprint.swift`, `AppWindowController.swift`, `monitor_memory.sh`  
- [ ] Clarify your macOS / Xcode versions  
- [ ] Optional: one Instruments allocation graph

---

## Code references (repo)

- `src/MemoryFootprint.swift` — RSS read, `encourageReturnOfFreedMemory()`  
- `src/AppWindowController.swift` — settings window lifecycle  
- `src/AudioWaveform.swift` — chunked generation, cache  
- `scripts/monitor_memory.sh` — CSV sampling  
- `test/MemoryFootprintTests.swift` — cache + chunked read tests  
- [MEMORY.md](../MEMORY.md) — operator guide
