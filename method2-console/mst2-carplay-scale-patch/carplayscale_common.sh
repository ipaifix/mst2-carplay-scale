#!/bin/sh

: "${CPS_ROOT:=}"
: "${CPS_SOURCE_DIR:=.}"
: "${CPS_BOOT_BLOCK:=$CPS_SOURCE_DIR/carplayscale_boot_block.shinc}"

CPS_TSD="${CPS_ROOT}/tsd"
CPS_RUN_HMI="$CPS_TSD/hmi/runHMI.sh"
CPS_BACKUP="$CPS_TSD/hmi/runHMI.sh.carplayscale.bak"
CPS_JAR_DEST="$CPS_TSD/hmi/HMI/jar/mst2-carplay-scale.jar"
CPS_STATE="$CPS_TSD/var/carplayscale"
: "${CPS_SD_BACKUP:=$CPS_SOURCE_DIR/backup/carplayscale}"
CPS_BEGIN='# mst2-carplay-scale: begin'
CPS_END='# mst2-carplay-scale: end'

cps_say() { echo "$1"; }

cps_remount_rw() {
    if [ -z "$CPS_ROOT" ]; then
        mount -o rw,remount "$CPS_TSD" 2>/dev/null
    fi
    mkdir -p "$CPS_STATE" "$CPS_TSD/hmi/HMI/jar" 2>/dev/null
}

cps_validate_runhmi() {
    [ -s "$1" ] && grep -q '^BOOTCLASSPATH=' "$1" && grep -q 'de\.vw\.mib\.MIBMain' "$1"
}

cps_block_counts_valid() {
    cps_bc_begin=$(grep -c '^# mst2-carplay-scale: begin$' "$1" 2>/dev/null)
    cps_bc_end=$(grep -c '^# mst2-carplay-scale: end$' "$1" 2>/dev/null)
    [ "${cps_bc_begin:-0}" -le 1 ] && [ "${cps_bc_begin:-0}" = "${cps_bc_end:-0}" ]
}

cps_validate_block_file() {
    [ -s "$CPS_BOOT_BLOCK" ] || return 1
    [ "$(grep -c '^# mst2-carplay-scale: begin$' "$CPS_BOOT_BLOCK" 2>/dev/null)" = 1 ] || return 1
    [ "$(grep -c '^# mst2-carplay-scale: end$' "$CPS_BOOT_BLOCK" 2>/dev/null)" = 1 ] || return 1
    [ "$(grep -c 'mst2-carplay-scale\.jar' "$CPS_BOOT_BLOCK" 2>/dev/null)" = 2 ] || return 1
    sh -n "$CPS_BOOT_BLOCK" 2>/dev/null
}

cps_strip_block() {
    cps_sb_input="$1"
    cps_sb_output="$2"
    cps_block_counts_valid "$cps_sb_input" || return 1
    awk '
        /^# mst2-carplay-scale: begin$/ { managed=1; next }
        /^# mst2-carplay-scale: end$/   { managed=0; next }
        !managed { print }
    ' "$cps_sb_input" > "$cps_sb_output" 2>/dev/null
}

cps_backup_runhmi() {
    cps_validate_runhmi "$CPS_RUN_HMI" || return 1
    if [ ! -f "$CPS_BACKUP" ]; then
        cp "$CPS_RUN_HMI" "$CPS_BACKUP.tmp" || return 1
        cps_validate_runhmi "$CPS_BACKUP.tmp" || { rm -f "$CPS_BACKUP.tmp"; return 1; }
        mv "$CPS_BACKUP.tmp" "$CPS_BACKUP" || return 1
    fi
    mkdir -p "$CPS_SD_BACKUP" 2>/dev/null
    if [ ! -f "$CPS_SD_BACKUP/runHMI.sh" ]; then
        cp "$CPS_RUN_HMI" "$CPS_SD_BACKUP/runHMI.sh.tmp" 2>/dev/null && \
            cps_validate_runhmi "$CPS_SD_BACKUP/runHMI.sh.tmp" && \
            mv "$CPS_SD_BACKUP/runHMI.sh.tmp" "$CPS_SD_BACKUP/runHMI.sh"
        rm -f "$CPS_SD_BACKUP/runHMI.sh.tmp" 2>/dev/null
    fi
}

cps_build_patched_runhmi() {
    cps_validate_runhmi "$CPS_RUN_HMI" || return 1
    cps_validate_block_file || return 1
    cps_block_counts_valid "$CPS_RUN_HMI" || return 1

    cps_rh_stripped="$CPS_RUN_HMI.carplayscale.stripped"
    cps_rh_new="$CPS_RUN_HMI.carplayscale.new"
    rm -f "$cps_rh_stripped" "$cps_rh_new"
    cps_strip_block "$CPS_RUN_HMI" "$cps_rh_stripped" || return 1
    cps_validate_runhmi "$cps_rh_stripped" || { rm -f "$cps_rh_stripped"; return 1; }

    cps_last=$(awk '/^BOOTCLASSPATH=/{line=NR} END{print line+0}' "$cps_rh_stripped" 2>/dev/null)
    [ "${cps_last:-0}" -gt 0 ] || { rm -f "$cps_rh_stripped"; return 1; }

    awk -v line="$cps_last" '
        NR == FNR { block = block $0 "\n"; next }
        { print; if (FNR == line) printf "%s", block }
    ' "$CPS_BOOT_BLOCK" "$cps_rh_stripped" > "$cps_rh_new" 2>/dev/null
    rm -f "$cps_rh_stripped"

    cps_validate_runhmi "$cps_rh_new" || { rm -f "$cps_rh_new"; return 1; }
    cps_block_counts_valid "$cps_rh_new" || { rm -f "$cps_rh_new"; return 1; }
    [ "$(grep -c 'BOOTCLASSPATH=.*mst2-carplay-scale\.jar' "$cps_rh_new" 2>/dev/null)" = 1 ] || { rm -f "$cps_rh_new"; return 1; }
    sh -n "$cps_rh_new" 2>/dev/null || { rm -f "$cps_rh_new"; return 1; }
    chmod 755 "$cps_rh_new" 2>/dev/null || { rm -f "$cps_rh_new"; return 1; }
    return 0
}

cps_install_patched_runhmi() {
    cps_rh_new="$CPS_RUN_HMI.carplayscale.new"
    [ -s "$cps_rh_new" ] || return 1
    mv "$cps_rh_new" "$CPS_RUN_HMI" || return 1
    cps_validate_runhmi "$CPS_RUN_HMI"
}

cps_remove_block_atomically() {
    cps_validate_runhmi "$CPS_RUN_HMI" || return 1
    cps_block_counts_valid "$CPS_RUN_HMI" || return 1
    cps_rh_new="$CPS_RUN_HMI.carplayscale.new"
    rm -f "$cps_rh_new"
    cps_strip_block "$CPS_RUN_HMI" "$cps_rh_new" || return 1
    cps_validate_runhmi "$cps_rh_new" || { rm -f "$cps_rh_new"; return 1; }
    [ "$(grep -c 'mst2-carplay-scale' "$cps_rh_new" 2>/dev/null)" = 0 ] || { rm -f "$cps_rh_new"; return 1; }
    sh -n "$cps_rh_new" 2>/dev/null || { rm -f "$cps_rh_new"; return 1; }
    chmod 755 "$cps_rh_new" 2>/dev/null || { rm -f "$cps_rh_new"; return 1; }
    mv "$cps_rh_new" "$CPS_RUN_HMI" || return 1
}

cps_stage_jar() {
    cps_sj_source="$1"
    [ -s "$cps_sj_source" ] || return 1
    cp "$cps_sj_source" "$CPS_JAR_DEST.tmp" || return 1
    [ -s "$CPS_JAR_DEST.tmp" ] || { rm -f "$CPS_JAR_DEST.tmp"; return 1; }
    chmod 644 "$CPS_JAR_DEST.tmp" 2>/dev/null || { rm -f "$CPS_JAR_DEST.tmp"; return 1; }
    mv "$CPS_JAR_DEST.tmp" "$CPS_JAR_DEST" || return 1
}
