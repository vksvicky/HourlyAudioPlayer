#!/bin/bash
# Shared helpers for Hourly Audio Player build and release scripts.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
XCODE_PROJECT="${PROJECT_ROOT}/HourlyAudioPlayer.xcodeproj"
APP_NAME="HourlyAudioPlayer"
SCHEME="HourlyAudioPlayer"
INFO_PLIST="${PROJECT_ROOT}/src/Info.plist"

log_info() { echo "ℹ️  $1" >&2; }
log_success() { echo "✅ $1" >&2; }
log_error() { echo "❌ $1" >&2; }
log_warning() { echo "⚠️  $1" >&2; }

require_command() {
  local cmd=$1
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Required command not found: ${cmd}"
    exit 1
  fi
}

get_app_version_slug() {
  local app_path=$1
  local plist="${app_path}/Contents/Info.plist"
  local version=""

  if [[ ! -f "$plist" ]]; then
    echo "$(date +"%Y%m")-0"
    return
  fi

  version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist" 2>/dev/null || true)
  if [[ -z "$version" ]]; then
    version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$plist" 2>/dev/null || true)
  fi
  if [[ -z "$version" ]]; then
    echo "$(date +"%Y%m")-0"
    return
  fi

  if [[ "$version" =~ ^([0-9]{4})\.([0-9]{2})\.([0-9]{2})-([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}-${BASH_REMATCH[4]}"
  elif [[ "$version" =~ ^([0-9]{4})\.([0-9]{2})\.([0-9]{2})$ ]]; then
    echo "${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}-0"
  else
    echo "$version" | tr '.' '-' | tr ' ' '-'
  fi
}

export PROJECT_ROOT XCODE_PROJECT APP_NAME SCHEME INFO_PLIST
