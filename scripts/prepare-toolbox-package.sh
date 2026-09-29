#!/bin/sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CORE="$PROJECT_ROOT/method2-console/mst2-carplay-scale-patch"
CUSTOM="$PROJECT_ROOT/method1-GEM/custom"
PACKAGE="$CUSTOM/carplayscale"
JAVA_DIR="$CUSTOM/java"
JAR="$CORE/mst2-carplay-scale.jar"
ARCHIVE="$PROJECT_ROOT/build/mst2-carplay-scale-toolbox-p0468.zip"

[ -s "$JAR" ] || { echo "FAIL: build the neutral JAR first"; exit 1; }
mkdir -p "$PACKAGE" "$JAVA_DIR"

for file in carplayscale_boot_block.shinc carplayscale_common.sh \
        install.sh trial.sh enable.sh disable.sh status.sh set-scale.sh uninstall.sh; do
    cp "$CORE/$file" "$PACKAGE/$file"
done
cp "$JAR" "$JAVA_DIR/mst2-carplay-scale.jar"
chmod 755 "$PACKAGE"/*.sh

if command -v zip >/dev/null 2>&1; then
    rm -f "$ARCHIVE"
    (cd "$PROJECT_ROOT/method1-GEM" && zip -qr "$ARCHIVE" custom)
fi

echo "Toolbox package ready"
[ -f "$ARCHIVE" ] && echo "Toolbox archive ready: $ARCHIVE"
