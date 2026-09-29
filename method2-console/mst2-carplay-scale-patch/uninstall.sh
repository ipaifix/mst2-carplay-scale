#!/bin/sh

CPS_SCRIPT_PATH="$0"
CPS_SOURCE_DIR="${CPS_SCRIPT_PATH%/*}"
[ "$CPS_SOURCE_DIR" = "$CPS_SCRIPT_PATH" ] && CPS_SOURCE_DIR=.
export CPS_SOURCE_DIR
. "$CPS_SOURCE_DIR/carplayscale_common.sh" || exit 1

echo "mst2-carplay-scale surgical uninstall"
cps_remount_rw
cps_remove_block_atomically || { echo "FAIL: runHMI.sh cleanup failed; JAR and state kept"; exit 1; }
rm -f "$CPS_JAR_DEST" "$CPS_STATE/trial" "$CPS_STATE/enabled" "$CPS_STATE/config" "$CPS_STATE/carplayscale.log" || {
    echo "WARN: boot block removed, but some dormant files could not be deleted"
    exit 1
}
echo "OK: managed block, JAR and active state removed"
echo "Backup retained at $CPS_BACKUP"
