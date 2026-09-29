#!/bin/sh
CPS_GEM_SCRIPT_DIR="${0%/*}"; [ "$CPS_GEM_SCRIPT_DIR" = "$0" ] && CPS_GEM_SCRIPT_DIR=.
. "$CPS_GEM_SCRIPT_DIR/carplayscale_gem_common.sh" || exit 0
cps_gem_run set-scale.sh 100
exit 0
