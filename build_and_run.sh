#!/bin/bash
# Build and run Hourly Audio Player (development).
# Version and success/failure counts: scripts/version/manage_version.sh (Trellik pattern).
#
# Usage: ./build_and_run.sh [debug]

set -euo pipefail

DEBUG_MODE="${1:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils/common.sh
source "${SCRIPT_DIR}/scripts/utils/common.sh"

if [[ "$DEBUG_MODE" != "" && "$DEBUG_MODE" != "debug" ]]; then
  log_error "Unknown argument: ${DEBUG_MODE}"
  log_info "Usage: $0 [debug]"
  exit 1
fi

require_command xcodebuild

if [[ ! -f "${XCODE_PROJECT}/project.pbxproj" ]]; then
  log_error "Run this script from the project root (missing ${XCODE_PROJECT})"
  exit 1
fi

log_info "Building ${APP_NAME} (Debug)…"
log_info "Debug mode: $([ "$DEBUG_MODE" = "debug" ] && echo "on" || echo "off")"

xcodebuild clean -project "${XCODE_PROJECT}" -scheme "${SCHEME}" >/dev/null 2>&1 || true

BUILD_ARGS=(
  -project "${XCODE_PROJECT}"
  -scheme "${SCHEME}"
  -configuration Debug
  build
)

if [[ "$DEBUG_MODE" == "debug" ]]; then
  BUILD_ARGS+=(SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG_MODE")
fi

set +e
xcodebuild "${BUILD_ARGS[@]}"
BUILD_EXIT_CODE=$?
set -e

if [[ "$BUILD_EXIT_CODE" -ne 0 ]]; then
  BUILD_EXIT_CODE=$BUILD_EXIT_CODE "${SCRIPT_DIR}/scripts/version/manage_version.sh" failure || true
  log_error "Build failed"
  exit "$BUILD_EXIT_CODE"
fi

APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "${APP_NAME}.app" -path "*/Debug/*" | grep -v "Index.noindex" | head -1)

if [[ -z "$APP_PATH" ]]; then
  log_error "Could not find the built app"
  exit 1
fi

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${APP_PATH}/Contents/Info.plist" 2>/dev/null || echo "unknown")
SUCCESS=$(/usr/libexec/PlistBuddy -c "Print :BuildSuccessCount" "${APP_PATH}/Contents/Info.plist" 2>/dev/null || echo "unknown")
FAILURE=$(/usr/libexec/PlistBuddy -c "Print :BuildFailureCount" "${APP_PATH}/Contents/Info.plist" 2>/dev/null || echo "unknown")

log_success "Build complete — Version: ${VERSION}, Success: ${SUCCESS}, Failure: ${FAILURE}"

pkill -f "${APP_NAME}" >/dev/null 2>&1 || true
sleep 1

open "$APP_PATH"
log_success "${APP_NAME} is running — check the menu bar icon"
