# Versioning and build counts

Hourly Audio Player uses the same scheme as [Trellik](https://github.com/cycleruncode/Trellik): **`scripts/version/manage_version.sh`**.

## Version format

`CFBundleShortVersionString` / `CFBundleVersion`:

```text
YYYY.MM.DD-NN
```

Example: `2026.06.03-04` — fourth build on 3 June 2026.

## Success and failure counts

Stored in `src/Info.plist`:

| Key | Format | Meaning |
|-----|--------|---------|
| `BuildSuccessCount` | `YYYY.MM.NNN` | Successful builds this month |
| `BuildFailureCount` | `YYYY.MM.NNN` | Failed builds this month |
| `BuildSuccessCountYear` | `YYYY.NNN` | Successful builds this year |
| `BuildFailureCountYear` | `YYYY.NNN` | Failed builds this year |
| `BuildSuccessCountLifetime` | integer | All-time successes |
| `BuildFailureCountLifetime` | integer | All-time failures |
| `BuildInProgress` | `true`/`false` | Detects interrupted builds |

## Flow

1. **Pre-build** (`prepare`): bumps version; if previous build left `BuildInProgress=true`, increments failure count.
2. **Post-build** (`success`): clears flag; increments success count.
3. **CLI failure** (`failure`): explicit failure increment when `xcodebuild` exits non-zero outside Xcode.

## Script output

- ✅ `Build succeeded - Version: …, Success: …`
- ❌ `Build failed - Failure count: …`
- ⚠️ `Previous build failed - incrementing failure count`

## Commands

```bash
./build_and_run.sh          # Debug build + run (Xcode runs prepare/success)
./build_release.sh          # Release DMG; version from built app
./scripts/version/manage_version.sh prepare
./scripts/version/manage_version.sh success
./scripts/version/manage_version.sh failure
```

## About window

Shows marketing version plus ✅ success and ❌ failure counts via `VersionInfoService` (reads built app plist on disk).

## Shared scripts

Copy `scripts/version/manage_version.sh` and `scripts/utils/common.sh` into new CycleRunCode projects; point `RESOURCES_INFO_PLIST` at your `Info.plist` path.
