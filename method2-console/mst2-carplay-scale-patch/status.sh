#!/bin/sh

CPS_SCRIPT_PATH="$0"
CPS_SOURCE_DIR="${CPS_SCRIPT_PATH%/*}"
[ "$CPS_SOURCE_DIR" = "$CPS_SCRIPT_PATH" ] && CPS_SOURCE_DIR=.
export CPS_SOURCE_DIR
. "$CPS_SOURCE_DIR/carplayscale_common.sh" || exit 1

CPS_STATUS_BLOCK=no
CPS_STATUS_JAR=no
CPS_STATUS_TRIAL=no
CPS_STATUS_ENABLED=no
CPS_STATUS_EMERGENCY=no
CPS_STATUS_SCALE=100
grep -q '^# mst2-carplay-scale: begin$' "$CPS_RUN_HMI" 2>/dev/null && CPS_STATUS_BLOCK=yes
[ -s "$CPS_JAR_DEST" ] && CPS_STATUS_JAR=yes
[ -f "$CPS_STATE/trial" ] && CPS_STATUS_TRIAL=yes
[ -f "$CPS_STATE/enabled" ] && CPS_STATUS_ENABLED=yes
for CPS_STATUS_MEDIA in "${CPS_ROOT}"/media/mp00*; do
    [ -f "$CPS_STATUS_MEDIA/carplayscale-disable" ] && CPS_STATUS_EMERGENCY=yes
done
[ -f "$CPS_STATE/config" ] && CPS_STATUS_SCALE=$(sed -n 's/^scale=//p' "$CPS_STATE/config" 2>/dev/null)
case "$CPS_STATUS_SCALE" in
    100|110|115|120|125) ;;
    *) CPS_STATUS_SCALE=100 ;;
esac
echo "runHMI block: $CPS_STATUS_BLOCK"
echo "JAR installed: $CPS_STATUS_JAR"
echo "trial armed: $CPS_STATUS_TRIAL"
echo "permanent enabled: $CPS_STATUS_ENABLED"
echo "emergency SD disable: $CPS_STATUS_EMERGENCY"
echo "configured physical scale: $CPS_STATUS_SCALE%"
