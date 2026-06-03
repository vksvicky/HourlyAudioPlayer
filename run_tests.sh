#!/bin/bash
# Run HourlyAudioPlayer unit tests via Xcode (real XCTest execution).

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${YELLOW}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ ! -f "HourlyAudioPlayer.xcodeproj/project.pbxproj" ]; then
    print_error "Run from the project root (HourlyAudioPlayer.xcodeproj not found)"
    exit 1
fi

mkdir -p test-results

print_status "Building app and running HourlyAudioPlayerTests…"
set +e
xcodebuild test \
    -project HourlyAudioPlayer.xcodeproj \
    -scheme HourlyAudioPlayer \
    -configuration Debug \
    -destination 'platform=macOS' \
    -resultBundlePath test-results/TestResults.xcresult \
    2>&1 | tee test-results/xcodebuild-test.log
BUILD_EXIT=${PIPESTATUS[0]}
set -e

if [ "$BUILD_EXIT" -ne 0 ]; then
    print_error "xcodebuild test failed (exit $BUILD_EXIT). See test-results/xcodebuild-test.log"
    exit "$BUILD_EXIT"
fi

print_success "All unit tests passed"
echo "Test completed successfully at $(date)" > test-results/test-summary.txt
echo "xcodebuild test: passed" >> test-results/test-summary.txt
echo "macOS version: $(sw_vers -productVersion)" >> test-results/test-summary.txt
