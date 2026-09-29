#!/bin/sh
MIBJAR="${CPS_ROOT}/tsd/hmi/HMI/jar"
IFSDIR="${CPS_ROOT}/tsd/hmi/ifs"
J9LIB="${CPS_ROOT}/j9/lib"
J9LIBF="${CPS_ROOT}/j9/lib/jclFoundation11"

# Shape and ordering copied from the vehicle's P0468 runHMI.sh.
BOOTCLASSPATH="$IFSDIR/tsd.mibstd2.hmi.v2.jxe:$IFSDIR/MIBHMI.jxe:$J9LIB/charconv.zip:$J9LIBF/locale.zip:$MIBJAR/GEM.jar:$J9LIBF/ext/j9jce.jar"
BOOTCLASSPATH="$BOOTCLASSPATH -Xbootclasspath/p:$MIBJAR/NavActiveIgnore.jar"
BOOTCLASSPATH="$BOOTCLASSPATH -Xbootclasspath/p:$MIBJAR/NavActiveIgnore.jar"
BOOTCLASSPATH="$BOOTCLASSPATH -Xbootclasspath/p:$MIBJAR/mst2-carplay-vc.jar"

echo "$BOOTCLASSPATH" > "${CPS_ROOT}/bootclasspath.result"
: de.vw.mib.MIBMain
