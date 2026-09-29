#!/bin/sh

CPS_GEM_SCRIPT_PATH="$0"
CPS_GEM_SCRIPT_DIR="${CPS_GEM_SCRIPT_PATH%/*}"
[ "$CPS_GEM_SCRIPT_DIR" = "$CPS_GEM_SCRIPT_PATH" ] && CPS_GEM_SCRIPT_DIR=.
. "$CPS_GEM_SCRIPT_DIR/carplayscale_gem_common.sh" || exit 0

cps_gem_find_package || {
    echo "FAIL: Toolbox SD payload not found"
    exit 0
}

CPS_GEM_STATE="${CPS_ROOT}/tsd/var/carplayscale"
CPS_GEM_RUNHMI="${CPS_ROOT}/tsd/hmi/runHMI.sh"
CPS_GEM_TIME=$(date +%Y%m%d-%H%M%S 2>/dev/null)
: "${CPS_GEM_TIME:=manual}"
CPS_GEM_DEST="$CPS_GEM_MEDIA/carplayscale-logs-$CPS_GEM_TIME"
mkdir -p "$CPS_GEM_DEST" 2>/dev/null || {
    echo "FAIL: cannot create log folder on SD"
    exit 0
}

[ -f "$CPS_GEM_STATE/carplayscale.log" ] && \
    cp "$CPS_GEM_STATE/carplayscale.log" "$CPS_GEM_DEST/carplayscale.log" 2>/dev/null
[ -f "$CPS_GEM_RUNHMI" ] && \
    cp "$CPS_GEM_RUNHMI" "$CPS_GEM_DEST/runHMI.sh" 2>/dev/null
[ -f "$CPS_GEM_RUNHMI.carplayscale.bak" ] && \
    cp "$CPS_GEM_RUNHMI.carplayscale.bak" "$CPS_GEM_DEST/runHMI.sh.carplayscale.bak" 2>/dev/null
[ -f "$CPS_GEM_STATE/trial" ] && touch "$CPS_GEM_DEST/trial"
[ -f "$CPS_GEM_STATE/enabled" ] && touch "$CPS_GEM_DEST/enabled"

echo "OK: logs copied to $CPS_GEM_DEST"
exit 0
