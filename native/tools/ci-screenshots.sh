#!/bin/bash
# SPIKE: screenshot the comparison app in the iOS simulator, light and dark.
set -euo pipefail
OUT=native/out
mkdir -p "$OUT"
APP=$(find native/App/build -type d -name PixelSpike.app -path '*iphonesimulator*' | head -1)
BUNDLE=io.github.cixzhang.PixelSpike
UDID=$(xcrun simctl create pixel-spike "iPhone 16")
xcrun simctl boot "$UDID"
xcrun simctl bootstatus "$UDID" -b
xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4
xcrun simctl install "$UDID" "$APP"
for mode in light dark; do
  xcrun simctl ui "$UDID" appearance "$mode"
  for view in components login; do
    for variant in today hooksToday proposed; do
      xcrun simctl launch --terminate-running-process "$UDID" "$BUNDLE" -view "$view" -variant "$variant" >/dev/null
      sleep 4
      xcrun simctl io "$UDID" screenshot "$OUT/ios-$view-$variant-$mode.png"
    done
  done
done
{
  echo "sha: $GITHUB_SHA"
  echo "run: $GITHUB_RUN_ID"
  xcodebuild -version
  xcrun simctl list devices "$UDID" | grep pixel-spike || true
  xcrun simctl getenv "$UDID" SIMULATOR_RUNTIME_VERSION || true
  sw_vers
} > "$OUT/manifest.txt"
ls -la "$OUT"
