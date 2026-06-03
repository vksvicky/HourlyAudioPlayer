# Memory footprint

Hourly Audio Player is a menu bar app meant to stay running for days. This document explains what to watch and how to measure resident memory over time.

## What uses memory

| Area | Typical impact |
|------|----------------|
| SwiftUI settings grid | 24 hour slots; modest view state |
| `AudioWaveformCache` | ~40 floats per cached file (capped at 32 entries) |
| Waveform generation | Chunked reads (8k frames at a time); avoids loading whole decoded files |
| `AVAudioPlayer` | Short-lived during preview or hourly play |
| Singletons | `AudioFileManager`, `HourScheduleManager`, timers — stable, small |

Previously, waveform generation decoded an entire audio file into one buffer. That could spike RAM for long MP3s. Generation now reads in **8k-frame chunks**.

## In-app logging (developer)

When `ShowLaunchTestUI` is `true` in `src/Info.plist`, the app logs resident size every **60 seconds** to the unified log:

- Subsystem: `com.example.HourlyAudioPlayer`
- Category: `MemoryFootprint`

Example:

```text
[sample] resident=42.3 MB waveformCacheEntries=3
```

View in **Console.app** (filter by process or category), or:

```bash
log stream --predicate 'subsystem == "com.example.HourlyAudioPlayer" AND category == "MemoryFootprint"'
```

## External sampling script

With the app running:

```bash
chmod +x scripts/monitor_memory.sh
./scripts/monitor_memory.sh 30        # sample every 30s until Ctrl+C
./scripts/monitor_memory.sh 10 3600     # every 10s for one hour
```

Output: `test-results/memory-samples.csv` (`timestamp_iso`, `rss_bytes`, `rss_mb`).

Plot in Numbers/Excel or:

```bash
column -t -s, test-results/memory-samples.csv | tail
```

## Xcode Instruments

For leaks and allocation growth:

1. **Product → Profile** (⌘I) → **Leaks** or **Allocations**
2. Run the app, open settings, scroll all hours, preview several files
3. Mark a generation before/after and compare persistent growth

## What to expect

- **Idle** (menu bar only): often tens of MB depending on macOS and SwiftUI
- **Settings open**: moderate bump from 24 slots and waveform cache
- **Spike during preview**: `AVAudioPlayer` buffer; should drop after stop

Investigate if resident size **rises steadily** over hours without user action (possible leak). A **single bump** when opening settings or generating waveforms is normal.

## Interpreting `memory-samples.csv`

Example from a real session:

| Phase | RSS | Notes |
|-------|-----|--------|
| 14:02–14:10 | ~73 MB | Menu bar only (baseline) |
| 14:10:59 | ~124 MB | Settings window opened (24-slot SwiftUI grid) |
| 14:11–14:16 | ~154 MB | Plateau while grid + waveform cache populated |
| After close (older behaviour) | ~154 MB | Plateau — settings window shell was kept with `orderOut` only |

That plateau was largely a **retained `NSWindow` shell** (SwiftUI grid was released, but the window object stayed allocated for faster reopen).

**Done** and the red **close** button now:

- Stop preview playback and clear the waveform cache
- **`orderOut`** the settings window, detach the SwiftUI grid, then **`close()`** the shell on the next run-loop turn (with `animationBehavior = .none`) so RSS can return toward idle
- Do not nil `contentViewController` during an in-flight close animation — detach only after `orderOut`
- Red close uses `windowShouldClose` returning **`false`**, then the same dismiss path as **Done**
- `isReleasedWhenClosed = true` — next open creates a fresh window

Defer Done dismissal to the next run-loop turn so the button action finishes first.

**Important:** Dismiss auxiliary sheets (e.g. launch schedule editor) with their own close button, or use **Done** on the main grid — otherwise the main settings window can stay open and RSS stays elevated.

Logs (subsystem `com.example.HourlyAudioPlayer`, category `AppWindowController`):

- `settings-opened`, `settings-released`, `settings-released+1s`, `settings-released+5s`

macOS and **Debug** builds often keep RSS higher than **Release** even when memory is freed correctly. Compare Release builds for leak hunting; use Instruments if RSS climbs without ever opening settings.

## After closing settings (verification)

1. Open settings, wait for RSS to plateau (~140–155 MB in recent samples).
2. Click **Done** on the main grid (or close the settings window).
3. Wait 60–90s and check the next `memory-samples.csv` rows and Console for `settings-released+5s`.
4. Expect RSS to fall **meaningfully** from the plateau (often tens of MB), though not always back to the exact idle baseline until app restart.
