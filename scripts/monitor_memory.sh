#!/bin/bash
# Sample Hourly Audio Player resident memory over time (CSV log).
#
# Usage:
#   ./scripts/monitor_memory.sh [interval_seconds] [duration_seconds]
#
# Examples:
#   ./scripts/monitor_memory.sh          # every 30s until Ctrl+C
#   ./scripts/monitor_memory.sh 10 600   # every 10s for 10 minutes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils/common.sh
source "${SCRIPT_DIR}/utils/common.sh"

INTERVAL="${1:-30}"
DURATION="${2:-0}"
APP_NAME="HourlyAudioPlayer"
LOG_DIR="${PROJECT_ROOT}/test-results"
LOG_FILE="${LOG_DIR}/memory-samples.csv"

mkdir -p "$LOG_DIR"

if ! pgrep -xq "$APP_NAME"; then
  log_warning "${APP_NAME} is not running. Start it with ./build_and_run.sh first."
fi

log_info "Logging resident memory every ${INTERVAL}s → ${LOG_FILE}"
echo "timestamp_iso,rss_bytes,rss_mb" >"$LOG_FILE"

start_epoch=$(date +%s)
while true; do
  now_iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  pid=$(pgrep -x "$APP_NAME" | head -1 || true)

  if [[ -z "$pid" ]]; then
    log_warning "Process not found; waiting…"
    rss_bytes=""
    rss_mb=""
  else
    rss_bytes=$(ps -o rss= -p "$pid" | tr -d ' ')
    # ps rss is kilobytes on macOS
    rss_mb=$(awk "BEGIN { printf \"%.2f\", ${rss_bytes} / 1024 }")
    rss_bytes=$((rss_bytes * 1024))
  fi

  echo "${now_iso},${rss_bytes},${rss_mb}" >>"$LOG_FILE"
  log_info "${now_iso}  RSS=${rss_mb:-"n/a"} MB  (pid=${pid:-"—"})"

  if [[ "$DURATION" -gt 0 ]]; then
    elapsed=$(( $(date +%s) - start_epoch ))
    if [[ "$elapsed" -ge "$DURATION" ]]; then
      log_success "Done (${DURATION}s). See ${LOG_FILE}"
      exit 0
    fi
  fi

  sleep "$INTERVAL"
done
