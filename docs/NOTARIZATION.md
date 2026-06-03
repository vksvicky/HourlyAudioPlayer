# Notarising release builds

Hourly Audio Player can be signed and notarised when you have a **Developer ID Application** certificate.

## One-time setup

1. Install your **Developer ID Application** certificate in Keychain Access.
2. Copy `.env.signing.example` to `.env.signing` (never commit `.env.signing`).
3. Store notary credentials (recommended):

```bash
xcrun notarytool store-credentials "HourlyAudioPlayer-notary" \
  --apple-id "you@example.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "your-app-specific-password"
```

4. Edit `.env.signing` with your signing identity and team ID.

## Build a notarised DMG

```bash
export $(grep -v '^#' .env.signing | xargs)
./build_release.sh 1.3.0
```

With `NOTARIZE=1` (or `NOTARY_KEYCHAIN_PROFILE` set), the script will:

1. Sign the `.app` with hardened runtime
2. Create the DMG
3. Submit to Apple notary service, wait, and staple the ticket

## Verify locally

```bash
spctl -a -vv -t install releases/HourlyAudioPlayer-v1.3.0.dmg
xcrun stapler validate releases/HourlyAudioPlayer-v1.3.0.dmg
```

## Troubleshooting

- **No signing identity**: Run `security find-identity -v -p codesigning` and set `DEVELOPER_ID_APPLICATION` exactly.
- **Notarisation rejected**: Open the log URL from `notarytool` output or run `xcrun notarytool log <submission-id>`.
- **Gatekeeper still blocks**: Ensure users download the stapled DMG, not an old unsigned copy.
