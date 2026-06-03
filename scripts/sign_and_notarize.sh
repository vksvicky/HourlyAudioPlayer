#!/bin/bash
# Sign and notarise Hourly Audio Player for distribution.
# Source from build_release.sh or run directly after a Release .app exists.
#
# Required (choose auth style):
#   DEVELOPER_ID_APPLICATION  e.g. "Developer ID Application: Your Name (TEAMID)"
#   APPLE_TEAM_ID
#   NOTARY_KEYCHAIN_PROFILE   (recommended) OR APPLE_ID + APPLE_APP_SPECIFIC_PASSWORD
#
# Optional:
#   ENTITLEMENTS_PATH  (default: src/HourlyAudioPlayer.entitlements)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils/common.sh
source "${SCRIPT_DIR}/utils/common.sh"

ENTITLEMENTS_PATH="${ENTITLEMENTS_PATH:-src/HourlyAudioPlayer.entitlements}"
BUNDLE_ID="${BUNDLE_ID:-club.cycleruncode.HourlyAudioPlayer}"

_resolve_signing_identity() {
    if [ -n "${DEVELOPER_ID_APPLICATION:-}" ]; then
        echo "$DEVELOPER_ID_APPLICATION"
        return 0
    fi
    security find-identity -v -p codesigning | sed -n 's/.*"\(Developer ID Application:.*\)".*/\1/p' | head -1
}

sign_application_bundle() {
    local app_path="$1"
    local identity
    identity="$(_resolve_signing_identity)"

    if [ -z "$identity" ]; then
        log_error "No Developer ID Application identity found. Set DEVELOPER_ID_APPLICATION."
        return 1
    fi

    if [ ! -f "$ENTITLEMENTS_PATH" ]; then
        log_error "Entitlements not found: $ENTITLEMENTS_PATH"
        return 1
    fi

    log_info "Signing $(basename "$app_path") with: $identity"
    codesign --force --deep --options runtime \
        --entitlements "$ENTITLEMENTS_PATH" \
        --sign "$identity" \
        --timestamp \
        "$app_path"

    codesign --verify --deep --strict --verbose=2 "$app_path"
    spctl -a -t exec -vv "$app_path" || log_warning "spctl assess returned non-zero (may still be fine before notarisation)"
    log_success "Application signed"
}

notarise_disk_image() {
    local dmg_path="$1"

    if [ ! -f "$dmg_path" ]; then
        log_error "DMG not found: $dmg_path"
        return 1
    fi

  if [ -z "${APPLE_TEAM_ID:-}" ]; then
        log_error "APPLE_TEAM_ID is required for notarisation"
        return 1
    fi

    log_info "Submitting $(basename "$dmg_path") for notarisation…"

    local submit_args=(submit "$dmg_path" --wait)
    if [ -n "${NOTARY_KEYCHAIN_PROFILE:-}" ]; then
        submit_args+=(--keychain-profile "$NOTARY_KEYCHAIN_PROFILE")
    elif [ -n "${APPLE_ID:-}" ] && [ -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" ]; then
        submit_args+=(--apple-id "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --team-id "$APPLE_TEAM_ID")
    else
        log_error "Set NOTARY_KEYCHAIN_PROFILE or APPLE_ID + APPLE_APP_SPECIFIC_PASSWORD"
        return 1
    fi

    xcrun notarytool "${submit_args[@]}"

    xcrun stapler staple "$dmg_path"
    xcrun stapler validate "$dmg_path"
    log_success "DMG notarised and stapled: $dmg_path"
}

sign_and_notarise_release() {
    local app_path="$1"
    local dmg_path="$2"

    sign_application_bundle "$app_path"

    if [ -n "${DEVELOPER_ID_APPLICATION:-}" ] || security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
        local identity
        identity="$(_resolve_signing_identity)"
        codesign --force --sign "$identity" --timestamp "$dmg_path" 2>/dev/null || true
    fi

    notarise_disk_image "$dmg_path"
}
