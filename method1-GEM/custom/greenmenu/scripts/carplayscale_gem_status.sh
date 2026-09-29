#!/bin/sh

CPS_GEM_SCRIPT_PATH="$0"
CPS_GEM_SCRIPT_DIR="${CPS_GEM_SCRIPT_PATH%/*}"
[ "$CPS_GEM_SCRIPT_DIR" = "$CPS_GEM_SCRIPT_PATH" ] && CPS_GEM_SCRIPT_DIR=.
. "$CPS_GEM_SCRIPT_DIR/carplayscale_gem_common.sh" || exit 0

cps_gem_run status.sh
exit 0
