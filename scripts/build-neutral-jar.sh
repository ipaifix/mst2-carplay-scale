#!/bin/sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
: "${JAVA_HOME:?Set JAVA_HOME to the JDK 8 used for the MST2 build}"
: "${MIBHMI_JAR:?Set MIBHMI_JAR to the JAR converted from P0468 MIBHMI.jxe}"
: "${MIBSTD2_BASE_JAR:?Set MIBSTD2_BASE_JAR to the JAR converted from P0468 tsd.mibstd2.hmi.v2.jxe}"

EXPECTED_SERVICE_CONFIGURATION_SHA256=612c2e8572a05d3ca4f84a666e4ce3bba526a5e94385f407093837397066a31a
EXPECTED_DSI_CARPLAY_IMPL_SHA256=688c536dd42ff1e8a40fa0e0c56bb94dfad8b5b5434e75eeac65bab15ed128e9
OUTPUT_JAR="$PROJECT_ROOT/build/mst2-carplay-scale-p0468.jar"
DIST_JAR="$PROJECT_ROOT/method2-console/mst2-carplay-scale-patch/mst2-carplay-scale.jar"
BUILD_DIR="$PROJECT_ROOT/build/neutral-classes"
MANIFEST="$PROJECT_ROOT/build/neutral-manifest.mf"

sha256_stdin() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 | awk '{print $1}'
    else
        sha256sum | awk '{print $1}'
    fi
}

[ -x "$JAVA_HOME/bin/javac" ] || { echo "FAIL: JDK javac not found"; exit 1; }
[ -x "$JAVA_HOME/bin/jar" ] || { echo "FAIL: JDK jar not found"; exit 1; }
[ -x "$JAVA_HOME/bin/javap" ] || { echo "FAIL: JDK javap not found"; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "FAIL: unzip not found"; exit 1; }
[ -s "$MIBHMI_JAR" ] || { echo "FAIL: missing MIBHMI analysis JAR"; exit 1; }
[ -s "$MIBSTD2_BASE_JAR" ] || { echo "FAIL: missing base analysis JAR"; exit 1; }

[ "$(unzip -p "$MIBHMI_JAR" org/dsi/ifc/carplay/ServiceConfiguration.class | sha256_stdin)" = "$EXPECTED_SERVICE_CONFIGURATION_SHA256" ] || {
    echo "FAIL: ServiceConfiguration is not the validated P0468 class"
    exit 1
}
[ "$(unzip -p "$MIBSTD2_BASE_JAR" tsd/mibstd2/hmi/dsi/carplay/DSICarplayImpl.class | sha256_stdin)" = "$EXPECTED_DSI_CARPLAY_IMPL_SHA256" ] || {
    echo "FAIL: DSICarplayImpl is not the validated P0468 class"
    exit 1
}

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR" "$PROJECT_ROOT/build"

"$JAVA_HOME/bin/javac" \
    -source 1.4 \
    -target 1.4 \
    -Xlint:-options \
    -bootclasspath "$MIBSTD2_BASE_JAR" \
    -classpath "$MIBHMI_JAR" \
    -d "$BUILD_DIR" \
    "$PROJECT_ROOT/src/main/java/com/mst2/carplayscale/CarPlayScale.java" \
    "$PROJECT_ROOT/src/main/java/org/dsi/ifc/carplay/ServiceConfiguration.java"

printf '%s\n' \
    'Manifest-Version: 1.0' \
    'Implementation-Title: MST2 CarPlay Display Scale - P0468' \
    'Implementation-Version: 0.2.0' \
    'Bundle-RequiredExecutionEnvironment: J2SE-1.4' \
    'X-MST2-Phase: D-E-safe-default-100' \
    'X-MST2-Firmware: MST2_EU_VW_ZR_P0468T' \
    > "$MANIFEST"

rm -f "$PROJECT_ROOT/build/mst2-carplay-scale-neutral-p0468.jar"
rm -f "$OUTPUT_JAR" "$DIST_JAR"
"$JAVA_HOME/bin/jar" cfm "$OUTPUT_JAR" "$MANIFEST" -C "$BUILD_DIR" .
cp "$OUTPUT_JAR" "$DIST_JAR"
"$PROJECT_ROOT/scripts/prepare-toolbox-package.sh"

echo "OK: $OUTPUT_JAR"
echo "OK: staged installer JAR at $DIST_JAR"
echo "OK: staged Toolbox payload at $PROJECT_ROOT/method1-GEM/custom"
