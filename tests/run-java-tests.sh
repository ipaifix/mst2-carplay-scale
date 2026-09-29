#!/bin/sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
: "${JAVA_HOME:?Set JAVA_HOME to the JDK 8 used for the MST2 build}"
: "${MIBHMI_JAR:?Set MIBHMI_JAR to the converted P0468 MIBHMI JAR}"
: "${MIBSTD2_BASE_JAR:?Set MIBSTD2_BASE_JAR to the converted P0468 base JAR}"

"$PROJECT_ROOT/scripts/build-neutral-jar.sh"

PATCH_JAR="$PROJECT_ROOT/build/mst2-carplay-scale-neutral-p0468.jar"
TEST_CLASSES="$PROJECT_ROOT/build/test-classes"
STOCK_API="$PROJECT_ROOT/build/stock-serviceconfiguration.api"
PATCH_API="$PROJECT_ROOT/build/patch-serviceconfiguration.api"

rm -rf "$TEST_CLASSES"
mkdir -p "$TEST_CLASSES"

"$JAVA_HOME/bin/javap" -classpath "$MIBHMI_JAR" -p -s \
    org.dsi.ifc.carplay.ServiceConfiguration | \
    sed -n '/public class org.dsi.ifc.carplay.ServiceConfiguration/,$p' > "$STOCK_API"
"$JAVA_HOME/bin/javap" -classpath "$PATCH_JAR:$MIBHMI_JAR" -p -s \
    org.dsi.ifc.carplay.ServiceConfiguration | \
    sed -n '/public class org.dsi.ifc.carplay.ServiceConfiguration/,$p' > "$PATCH_API"
cmp "$STOCK_API" "$PATCH_API"

"$JAVA_HOME/bin/javac" \
    -classpath "$PATCH_JAR:$MIBHMI_JAR" \
    -d "$TEST_CLASSES" \
    "$PROJECT_ROOT/tests/java/ServiceConfigurationNeutralTest.java"

"$JAVA_HOME/bin/java" \
    -classpath "$TEST_CLASSES:$PATCH_JAR:$MIBHMI_JAR" \
    ServiceConfigurationNeutralTest

MAJOR=$("$JAVA_HOME/bin/javap" -classpath "$PATCH_JAR" -verbose \
    org.dsi.ifc.carplay.ServiceConfiguration | awk '/major version/{print $3}')
[ "$MAJOR" = 48 ]

CONTENTS=$("$JAVA_HOME/bin/jar" tf "$PATCH_JAR" | grep '\.class$' | sort)
EXPECTED='com/mst2/carplayscale/NeutralProbe.class
org/dsi/ifc/carplay/ServiceConfiguration.class'
[ "$CONTENTS" = "$EXPECTED" ]

echo "ABI identical to P0468 stock"
echo "Classfile version 48 (J2SE 1.4)"
echo "JAR content limited to the two expected classes"
