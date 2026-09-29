#!/bin/sh
set -u

TEST_ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DIST="$TEST_ROOT_DIR/method2-console/mst2-carplay-scale-patch"
FIXTURES="$TEST_ROOT_DIR/tests/fixtures"
TMP_BASE=$(mktemp -d "${TMPDIR:-/tmp}/carplayscale-tests.XXXXXX") || exit 1
PASS=0
FAIL=0

cleanup() { rm -rf "$TMP_BASE"; }
trap cleanup EXIT HUP INT TERM

ok() { PASS=$((PASS + 1)); echo "ok $PASS - $1"; }
not_ok() { FAIL=$((FAIL + 1)); echo "not ok - $1"; }
assert_file() { [ -f "$1" ] || { not_ok "$2"; return 1; }; ok "$2"; }
assert_no_file() { [ ! -e "$1" ] || { not_ok "$2"; return 1; }; ok "$2"; }
assert_contains() { grep -q "$2" "$1" || { not_ok "$3"; return 1; }; ok "$3"; }
assert_not_contains() { if grep -q "$2" "$1"; then not_ok "$3"; return 1; fi; ok "$3"; }
assert_count() { count=$(grep -c "$2" "$1" 2>/dev/null); [ "${count:-0}" = "$3" ] || { not_ok "$4 (got ${count:-0})"; return 1; }; ok "$4"; }

new_case() {
    name="$1"
    fixture="$2"
    CASE_ROOT="$TMP_BASE/$name/root"
    CASE_DIST="$TMP_BASE/$name/dist"
    mkdir -p "$CASE_ROOT/tsd/hmi/HMI/jar" "$CASE_ROOT/tsd/var" "$CASE_ROOT/media/mp000" "$CASE_DIST"
    cp "$fixture" "$CASE_ROOT/tsd/hmi/runHMI.sh"
    cp "$DIST"/*.sh "$DIST"/*.shinc "$CASE_DIST/"
    printf 'neutral-test-jar\n' > "$CASE_DIST/mst2-carplay-scale.jar"
    chmod 755 "$CASE_ROOT/tsd/hmi/runHMI.sh" "$CASE_DIST"/*.sh
}

run_script() {
    script="$1"
    CPS_ROOT="$CASE_ROOT" CPS_SOURCE_DIR="$CASE_DIST" sh "$CASE_DIST/$script"
}

new_case stock "$FIXTURES/runHMI-stock.sh"
cp "$CASE_ROOT/tsd/hmi/runHMI.sh" "$TMP_BASE/stock-before"
run_script install.sh >/dev/null || not_ok "stock install exits successfully"
assert_file "$CASE_ROOT/tsd/hmi/runHMI.sh.carplayscale.bak" "backup created"
cmp "$TMP_BASE/stock-before" "$CASE_ROOT/tsd/hmi/runHMI.sh.carplayscale.bak" >/dev/null && ok "backup is exact live pre-install file" || not_ok "backup is exact live pre-install file"
assert_file "$CASE_ROOT/tsd/var/carplayscale/trial" "install arms trial"
assert_no_file "$CASE_ROOT/tsd/var/carplayscale/enabled" "install does not enable permanently"
assert_count "$CASE_ROOT/tsd/hmi/runHMI.sh" '^# mst2-carplay-scale: begin$' 1 "one managed block inserted"
assert_count "$CASE_ROOT/tsd/hmi/runHMI.sh" 'BOOTCLASSPATH=.*mst2-carplay-scale\.jar' 1 "one scale bootclasspath line inserted"

CPS_ROOT="$CASE_ROOT" sh "$CASE_ROOT/tsd/hmi/runHMI.sh"
assert_no_file "$CASE_ROOT/tsd/var/carplayscale/trial" "trial consumed before Java"
assert_contains "$CASE_ROOT/bootclasspath.result" 'mst2-carplay-scale.jar' "trial boot loads scale JAR"
CPS_ROOT="$CASE_ROOT" sh "$CASE_ROOT/tsd/hmi/runHMI.sh"
assert_not_contains "$CASE_ROOT/bootclasspath.result" 'mst2-carplay-scale.jar' "second boot skips scale JAR"

run_script enable.sh >/dev/null || not_ok "permanent enable exits successfully"
CPS_ROOT="$CASE_ROOT" sh "$CASE_ROOT/tsd/hmi/runHMI.sh"
assert_contains "$CASE_ROOT/bootclasspath.result" 'mst2-carplay-scale.jar' "permanent boot loads scale JAR"
touch "$CASE_ROOT/media/mp000/carplayscale-disable"
CPS_ROOT="$CASE_ROOT" sh "$CASE_ROOT/tsd/hmi/runHMI.sh"
assert_not_contains "$CASE_ROOT/bootclasspath.result" 'mst2-carplay-scale.jar' "emergency SD overrides permanent marker"
assert_file "$CASE_ROOT/tsd/var/carplayscale/enabled" "emergency SD preserves permanent marker"
rm -f "$CASE_ROOT/media/mp000/carplayscale-disable"

run_script disable.sh >/dev/null || not_ok "disable exits successfully"
assert_no_file "$CASE_ROOT/tsd/var/carplayscale/enabled" "disable removes permanent marker"
assert_count "$CASE_ROOT/tsd/hmi/runHMI.sh" '^# mst2-carplay-scale: begin$' 1 "disable preserves installed block"

new_case xpaiin "$FIXTURES/runHMI-xpaiin.sh"
run_script install.sh >/dev/null || not_ok "xPaiiN coexistence install exits successfully"
assert_count "$CASE_ROOT/tsd/hmi/runHMI.sh" 'mst2-carplay-vc\.jar' 1 "xPaiiN JAR line preserved"
assert_count "$CASE_ROOT/tsd/hmi/runHMI.sh" 'BOOTCLASSPATH=.*mst2-carplay-scale\.jar' 1 "scale line coexists with xPaiiN"
vc_line=$(grep -n 'mst2-carplay-vc\.jar' "$CASE_ROOT/tsd/hmi/runHMI.sh" | sed 's/:.*//')
scale_line=$(grep -n 'BOOTCLASSPATH=.*mst2-carplay-scale\.jar' "$CASE_ROOT/tsd/hmi/runHMI.sh" | sed 's/:.*//')
[ "$vc_line" -lt "$scale_line" ] && ok "scale block inserted after existing xPaiiN bootclasspath" || not_ok "scale block inserted after existing xPaiiN bootclasspath"
run_script install.sh >/dev/null || not_ok "second install exits successfully"
assert_count "$CASE_ROOT/tsd/hmi/runHMI.sh" '^# mst2-carplay-scale: begin$' 1 "double install remains idempotent"
run_script uninstall.sh >/dev/null || not_ok "uninstall exits successfully"
assert_not_contains "$CASE_ROOT/tsd/hmi/runHMI.sh" 'mst2-carplay-scale' "uninstall removes only scale block"
assert_contains "$CASE_ROOT/tsd/hmi/runHMI.sh" 'mst2-carplay-vc.jar' "uninstall preserves xPaiiN"
assert_no_file "$CASE_ROOT/tsd/hmi/HMI/jar/mst2-carplay-scale.jar" "uninstall removes only scale JAR"

new_case third "$FIXTURES/runHMI-third-party.sh"
run_script install.sh >/dev/null || not_ok "third-party coexistence install exits successfully"
run_script uninstall.sh >/dev/null || not_ok "third-party coexistence uninstall exits successfully"
assert_contains "$CASE_ROOT/tsd/hmi/runHMI.sh" 'unknown-patch.jar' "unknown third-party patch preserved"

for invalid in runHMI-empty.sh runHMI-no-bootclasspath.sh runHMI-no-main.sh; do
    new_case "invalid-$invalid" "$FIXTURES/$invalid"
    cp "$CASE_ROOT/tsd/hmi/runHMI.sh" "$TMP_BASE/$invalid.before"
    if run_script install.sh >/dev/null 2>&1; then not_ok "$invalid rejected"; else ok "$invalid rejected"; fi
    cmp "$TMP_BASE/$invalid.before" "$CASE_ROOT/tsd/hmi/runHMI.sh" >/dev/null && ok "$invalid leaves live file unchanged" || not_ok "$invalid leaves live file unchanged"
done

new_case missing-jar "$FIXTURES/runHMI-stock.sh"
rm -f "$CASE_DIST/mst2-carplay-scale.jar"
cp "$CASE_ROOT/tsd/hmi/runHMI.sh" "$TMP_BASE/missing-jar.before"
if run_script install.sh >/dev/null 2>&1; then not_ok "missing JAR rejected"; else ok "missing JAR rejected"; fi
cmp "$TMP_BASE/missing-jar.before" "$CASE_ROOT/tsd/hmi/runHMI.sh" >/dev/null && ok "missing JAR leaves runHMI unchanged" || not_ok "missing JAR leaves runHMI unchanged"

new_case bad-block "$FIXTURES/runHMI-stock.sh"
printf '# mst2-carplay-scale: begin\nif then broken\n# mst2-carplay-scale: end\n' > "$CASE_DIST/bad.shinc"
cp "$CASE_ROOT/tsd/hmi/runHMI.sh" "$TMP_BASE/bad-block.before"
if CPS_ROOT="$CASE_ROOT" CPS_SOURCE_DIR="$CASE_DIST" CPS_BOOT_BLOCK="$CASE_DIST/bad.shinc" sh "$CASE_DIST/install.sh" >/dev/null 2>&1; then not_ok "invalid generated block rejected"; else ok "invalid generated block rejected"; fi
cmp "$TMP_BASE/bad-block.before" "$CASE_ROOT/tsd/hmi/runHMI.sh" >/dev/null && ok "invalid block rolls back without replacing live file" || not_ok "invalid block rolls back without replacing live file"

echo "1..$((PASS + FAIL))"
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
