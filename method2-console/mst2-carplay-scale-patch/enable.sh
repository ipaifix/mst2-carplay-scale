#!/bin/sh

CPS_SCRIPT_PATH="$0"
CPS_SOURCE_DIR="${CPS_SCRIPT_PATH%/*}"
[ "$CPS_SOURCE_DIR" = "$CPS_SCRIPT_PATH" ] && CPS_SOURCE_DIR=.
export CPS_SOURCE_DIR
. "$CPS_SOURCE_DIR/carplayscale_common.sh" || exit 1

cps_remount_rw
[ -s "$CPS_JAR_DEST" ] || { echo "FAIL: patch JAR is not installed"; exit 1; }
rm -f "$CPS_STATE/trial" || { echo "FAIL: cannot clear trial marker"; exit 1; }
touch "$CPS_STATE/enabled" || exit 1
echo "OK: permanent loading enabled"
