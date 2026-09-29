#!/bin/sh

CPS_SCRIPT_PATH="$0"
CPS_SOURCE_DIR="${CPS_SCRIPT_PATH%/*}"
[ "$CPS_SOURCE_DIR" = "$CPS_SCRIPT_PATH" ] && CPS_SOURCE_DIR=.
export CPS_SOURCE_DIR
. "$CPS_SOURCE_DIR/carplayscale_common.sh" || exit 1

CPS_JAR_SOURCE="$CPS_SOURCE_DIR/mst2-carplay-scale.jar"
echo "mst2-carplay-scale safe install (trial only)"

cps_remount_rw
[ -d "$CPS_STATE" ] || { echo "FAIL: cannot create $CPS_STATE"; exit 1; }
[ -s "$CPS_JAR_SOURCE" ] || { echo "FAIL: missing or empty $CPS_JAR_SOURCE"; exit 1; }
cps_validate_runhmi "$CPS_RUN_HMI" || { echo "FAIL: invalid runHMI.sh"; exit 1; }
cps_block_counts_valid "$CPS_RUN_HMI" || { echo "FAIL: incomplete or duplicate managed block"; exit 1; }
cps_validate_block_file || { echo "FAIL: invalid boot block template"; exit 1; }

# A fresh install is always trial-only. Clear older activation state before
# touching the JAR or runHMI; if a later step fails, the patch stays dormant.
rm -f "$CPS_STATE/enabled" "$CPS_STATE/trial" || { echo "FAIL: cannot clear old activation markers"; exit 1; }

cps_backup_runhmi || { echo "FAIL: runHMI.sh backup failed"; exit 1; }
cps_stage_jar "$CPS_JAR_SOURCE" || { echo "FAIL: JAR staging failed; runHMI.sh unchanged"; exit 1; }
cps_build_patched_runhmi || { echo "FAIL: generated runHMI.sh rejected; live file unchanged"; exit 1; }
cps_install_patched_runhmi || { echo "FAIL: atomic runHMI.sh install failed"; exit 1; }

touch "$CPS_STATE/trial" || { echo "FAIL: cannot create trial marker; JAR remains dormant"; exit 1; }
echo "OK: installed safely; next boot is a one-shot trial"
exit 0
