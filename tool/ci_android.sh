#!/usr/bin/env bash
# Runs in CI after `flutter create` generated android/ (which is not committed).
# Sets the launcher name to the Arabic app name; fails loudly if the manifest does not look as expected.
set -euo pipefail
manifest="android/app/src/main/AndroidManifest.xml"
test -f "$manifest" || { echo "missing $manifest"; exit 1; }
sed -i 's/android:label="[^"]*"/android:label="عَدّادي"/' "$manifest"
grep -q 'android:label="عَدّادي"' "$manifest" || { echo "could not set the app label"; exit 1; }
echo "app label set"
