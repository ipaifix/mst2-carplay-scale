#!/bin/sh
MIBJAR="${CPS_ROOT}/tsd/hmi/HMI/jar"
BOOTCLASSPATH="-Xbootclasspath:/tsd/hmi/HMI/jar/MIBHMI.jxe"
echo "$BOOTCLASSPATH" > "${CPS_ROOT}/bootclasspath.result"
: de.vw.mib.MIBMain
