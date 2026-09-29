#!/bin/sh

CPS_SCRIPT_PATH="$0"
CPS_SOURCE_DIR="${CPS_SCRIPT_PATH%/*}"
[ "$CPS_SOURCE_DIR" = "$CPS_SCRIPT_PATH" ] && CPS_SOURCE_DIR=.
export CPS_SOURCE_DIR
. "$CPS_SOURCE_DIR/carplayscale_common.sh" || exit 1

CPS_SCALE="${1:-}"
case "$CPS_SCALE" in
    100|110|115|120|125) ;;
    *) echo "FAIL: scale must be 100, 110, 115, 120 or 125"; exit 1 ;;
esac

cps_remount_rw
[ -d "$CPS_STATE" ] || { echo "FAIL: patch is not installed"; exit 1; }
CPS_CONFIG_NEW="$CPS_STATE/config.new"
echo "scale=$CPS_SCALE" > "$CPS_CONFIG_NEW" || { echo "FAIL: cannot write config"; exit 1; }
[ "$(grep -c "^scale=$CPS_SCALE$" "$CPS_CONFIG_NEW" 2>/dev/null)" = 1 ] || {
    rm -f "$CPS_CONFIG_NEW"
    echo "FAIL: config validation failed"
    exit 1
}
mv "$CPS_CONFIG_NEW" "$CPS_STATE/config" || { echo "FAIL: cannot install config"; exit 1; }
echo "OK: CarPlay physical display scale set to $CPS_SCALE%"
echo "The setting applies only when the patch is loaded on the next CarPlay start."
exit 0
