#!/bin/bash

echo "
 _   _               _       ____  ____    ___   _   _ 
| | | |  __ _   ___ | | __  / ___||  _ \  / _ \ | \ | |
| |_| | / _` | / __|| |/ / | |  _ | |_) || | | ||  \| |
|  _  || (_| || (__ |   <  | |_| ||  __/ | |_| || |\  |
|_| |_| \__,_| \___||_|\_\  \____||_|     \___/ |_| \_|
"

SRC=../src/mtd3
FMK_DIR="../../firmware-mod-kit"


NAME="home"
ISP="Mod"
VENDOR="ALCL"
HWVER="3FE49165BFAA01"
SWVER="3FE49717AOCK12"

### Do not change anything below ###
SRC_NAME=$(basename ${SRC})
FIRMWARE_IN="./target/${SRC_NAME}.with-header"
FIRMWARE_OUT="./target/ZIZA-${ISP}.${NAME}-${SWVER}.bin"
FMK_EXTRACT="${FMK_DIR}/extract-firmware.sh"
FMK_BUILD="${FMK_DIR}/build-firmware.sh"
FMK_EXTRACTED="./fmk/"
CRC32="${FMK_DIR}/src/crcalc/crc32"

BUILD_TIME=`date '+%Y-%m-%d %H:%M:%S'`

function firmware_patch_src {
    cd "${FMK_EXTRACTED}rootfs/"

    sed -i -r "s/Hardware Version:          .+/Hardware Version:          ${HWVER}/1"      ./show_version
    sed -i -r "s/Client Software Version:   .+/Client Software Version:   ${SWVER}/1"      ./show_version
    sed -i -r "s/Client Version      : .+/Client Version      : ${SWVER}/1"              ./version
    sed -i -r "s/Client ONU Version  : .+/Client ONU Version  : ${SWVER}/1"              ./version
    sed -i -r "s/VENDOR ID           : .+/VENDOR ID           : ${VENDOR}/1"             ./version
    sed -i -r "s/Hardware Version    : .+/Hardware Version    : ${HWVER}/1"              ./version

    cd -
}
function firmware_patch_img {
    dd if=/dev/zero of=$FIRMWARE_OUT bs=1 seek=124 count=32 conv=notrunc
    echo -n $SWVER | dd of=$FIRMWARE_OUT bs=1 seek=124 conv=notrunc
    
    dd if=/dev/zero of=$FIRMWARE_OUT bs=1 seek=632 count=32 conv=notrunc
    echo -n $SWVER | dd of=$FIRMWARE_OUT bs=1 seek=632 conv=notrunc
    
    dd if=/dev/zero of=$FIRMWARE_OUT bs=1 seek=664 count=32 conv=notrunc
    echo -n $VENDOR | dd of=$FIRMWARE_OUT bs=1 seek=664 conv=notrunc

    # squashfs on 0x140200 make time swapped to 0x208
    stime=`binwalk $FIRMWARE_OUT | grep 0x140200 | grep -oP "created\: ([0-9\-\: ]+)" | sed -e "s/created: //g"`
    itime=`date --date="${stime}" +"%s"`
    itime=$(($itime + 3600 * 3 + 1))
    htime=`echo "obase=16; ${itime}" | bc`
    htime=$(byte_hex2bin $htime 1)
    echo -e "${htime}" | dd of=$FIRMWARE_OUT bs=1 seek=520 count=4 conv=notrunc
}
function byte_hex2bin {
    v=$1
    if [ $2 -eq 1 ]; then
	echo "\x${v:6:2}\x${v:4:2}\x${v:2:2}\x${v:0:2}"
    else
	echo "\x${v:0:2}\x${v:2:2}\x${v:4:2}\x${v:6:2}"
    fi
}
function firmware_crc {
    dd if=/dev/zero of=$FIRMWARE_OUT bs=1 seek=$1 count=4 conv=notrunc
    crc=`$CRC32 $FIRMWARE_OUT $3 $4 | tail -n 1 | awk '{print $2}' | sed "s/0x//1"`
    crc=$(byte_hex2bin $crc $2)
    echo -e "${crc}" | dd of=$FIRMWARE_OUT bs=1 seek=$1 count=4 conv=notrunc
}

echo "Creating target folder"
mkdir -p target

echo "Unpacking ${SRC}"
echo "Appending header to ${SRC_NAME}"
cat ZISA.header ${SRC} > ${FIRMWARE_IN}

rm -rf $FMK_EXTRACTED
$FMK_EXTRACT $FIRMWARE_IN
firmware_patch_src
$FMK_BUILD
mv "${FMK_EXTRACTED}new-firmware.bin" $FIRMWARE_OUT
#cp $FIRMWARE_OUT ./Telia
firmware_patch_img
firmware_crc 540 1 1024 3669504 # 0x21C,<><------>true,<->0x400,<><------>0x380200],<---->// from bootloader to the end
firmware_crc 544 1 512  512     # 0x220,<><------>true,<->0x200,<><------>0x400],><------>//
firmware_crc 104 0 0    3670528 # 0x68,<-><------>false,<>0,<----><------>0x380200]<----->// for all file
#rm -rf $FMK_EXTRACTED
dd if=${FIRMWARE_OUT} of=target/${SRC_NAME}.mod.bin skip=512 bs=1

echo "Modded MTD can be found at target/${SRC_NAME}.mod.bin"
