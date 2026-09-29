#!/bin/sh

CPS_SCRIPT_PATH="$0"
CPS_SOURCE_DIR="${CPS_SCRIPT_PATH%/*}"
[ "$CPS_SOURCE_DIR" = "$CPS_SCRIPT_PATH" ] && CPS_SOURCE_DIR=.
export CPS_SOURCE_DIR
. "$CPS_SOURCE_DIR/carplayscale_common.sh" || exit 1

cps_remount_rw
rm -f "$CPS_STATE/trial" "$CPS_STATE/enabled" || { echo "FAIL: cannot remove activation markers"; exit 1; }
[ ! -e "$CPS_STATE/trial" ] && [ ! -e "$CPS_STATE/enabled" ] || { echo "FAIL: patch is still active"; exit 1; }
echo "OK: patch disabled for subsequent boots; installation preserved"
