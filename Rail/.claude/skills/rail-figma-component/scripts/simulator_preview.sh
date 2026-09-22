#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Uso: $0 <Harness.swift con struct ZZHarness: View> <carpeta-de-salida> [udid-simulador]" >&2
    exit 64
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR=$(cd "$SCRIPT_DIR/../../../.." && pwd)
APP_DIR="$PROJECT_DIR/Rail"
ENTRY="$APP_DIR/RailApp.swift"
HARNESS_SRC=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
OUT=$(mkdir -p "$2" && cd "$2" && pwd)
UDID=${3:-}
WAIT=${WAIT:-6}

grep -q "struct ZZHarness" "$HARNESS_SRC" || { echo "El harness debe declarar 'struct ZZHarness: View'." >&2; exit 65; }
grep -q "RootView()" "$ENTRY" || { echo "RailApp.swift no contiene RootView(); ¿quedó un harness sin restaurar?" >&2; exit 66; }
[ ! -e "$APP_DIR/ZZHarness.swift" ] || { echo "Ya existe Rail/ZZHarness.swift; bórralo antes." >&2; exit 67; }

cp "$ENTRY" "$OUT/RailApp.swift.bak"
restore() {
    cp "$OUT/RailApp.swift.bak" "$ENTRY"
    rm -f "$APP_DIR/ZZHarness.swift" "$APP_DIR/ZZMeasure.swift"
}
trap restore EXIT

if [ -z "$UDID" ]; then
    UDID=$(xcrun simctl list devices booted -j | python3 -c '
import json, sys
devices = [d for runtime in json.load(sys.stdin)["devices"].values() for d in runtime]
iphones = [d for d in devices if d["name"].startswith("iPhone")]
print((iphones or devices or [{"udid": ""}])[0]["udid"])')
fi
[ -n "$UDID" ] || { echo "No hay ningún simulador arrancado; arranca uno o pasa su UDID." >&2; exit 69; }

cp "$HARNESS_SRC" "$APP_DIR/ZZHarness.swift"
cp "$SCRIPT_DIR/ZZMeasure.swift" "$APP_DIR/ZZMeasure.swift"
sed -i '' 's/RootView()/ZZHarness()/' "$ENTRY"

echo "Compilando para el simulador $UDID…"
if ! xcodebuild -project "$PROJECT_DIR/Rail.xcodeproj" -scheme Rail \
    -destination "platform=iOS Simulator,id=$UDID" \
    -derivedDataPath "$OUT/DerivedData" build -quiet > "$OUT/build.log" 2>&1; then
    grep -E "error:" "$OUT/build.log" | sort -u | head -20 >&2
    exit 70
fi
restore

APP="$OUT/DerivedData/Build/Products/Debug-iphonesimulator/Rail.app"
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP/Info.plist")
xcrun simctl install "$UDID" "$APP"

PREVIOUS_APPEARANCE=$(xcrun simctl ui "$UDID" appearance)
xcrun simctl ui "$UDID" appearance light
xcrun simctl launch --console-pty --terminate-running-process "$UDID" "$BUNDLE_ID" > "$OUT/console.log" 2>&1 &
LAUNCH_PID=$!
sleep "$WAIT"
xcrun simctl io "$UDID" screenshot "$OUT/light.png" > /dev/null 2>&1
xcrun simctl ui "$UDID" appearance dark
sleep 2
xcrun simctl io "$UDID" screenshot "$OUT/dark.png" > /dev/null 2>&1
xcrun simctl ui "$UDID" appearance "$PREVIOUS_APPEARANCE"
kill "$LAUNCH_PID" 2> /dev/null || true
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2> /dev/null || true

grep "MEASURE" "$OUT/console.log" | sort -u > "$OUT/measures.txt" || true
echo "Capturas: $OUT/light.png y $OUT/dark.png"
echo "Medidas ($OUT/measures.txt):"
sed 's/^MEASURE /  /' "$OUT/measures.txt"
