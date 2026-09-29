#!/bin/sh

: "${CPS_ROOT:=}"
CPS_GEM_MEDIA=""
CPS_GEM_PACKAGE=""
CPS_GEM_JAR=""

cps_gem_find_package() {
    for cps_gem_candidate in "${CPS_ROOT}"/media/mp00*; do
        if [ -s "$cps_gem_candidate/custom/java/mst2-carplay-scale.jar" ] && \
                [ -s "$cps_gem_candidate/custom/carplayscale/install.sh" ]; then
            CPS_GEM_MEDIA="$cps_gem_candidate"
            CPS_GEM_PACKAGE="$cps_gem_candidate/custom/carplayscale"
            CPS_GEM_JAR="$cps_gem_candidate/custom/java/mst2-carplay-scale.jar"
            return 0
        fi
    done
    return 1
}

cps_gem_run() {
    cps_gem_action="$1"
    shift
    cps_gem_find_package || {
        echo "FAIL: Toolbox SD payload not found"
        echo "Copy the complete custom folder to the SD card root and retry."
        return 1
    }
    CPS_JAR_SOURCE="$CPS_GEM_JAR" \
    CPS_SD_BACKUP="$CPS_GEM_MEDIA/backup/carplayscale" \
    CPS_ROOT="$CPS_ROOT" \
        sh "$CPS_GEM_PACKAGE/$cps_gem_action" "$@"
}
