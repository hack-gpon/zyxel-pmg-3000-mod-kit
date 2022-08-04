# Zyxel pmg3000-d20b firmware mod kit

## Prerequisites
- Linux os
- firmware-mod-kit built. Use https://github.com/st-ty1/Arch-Linux_firmware-mod-kit on a modern distro
- an mtd dump of the rootfs to be modded

## Usage
- Edit build.sh, changing the settings at the top
- Run build.sh as root
- The script will tell you where the new mtd is

## Flashing
- Transfer the new mtd on the stick via tftp
`tftp -gr mtd2.mod.bin TFTP_SERVER_IP`
- Flash it on the standby partition. You can use `show actimage` to get the current active image. Check `/proc/mtd` for the right mtds
`mtd -e /dev/mtd2 write /tmp/mtd2.mod.bin /dev/mtd2`
- Switch to the new image
`set actimage a`
- Reboot the ONT
`reboot`

## Other tibits
## Change PLOAM
Use the web UI
## Change ONT S/N
```
manufactory
set sn XXXXXXXXXXX (ASCII)
```
## Change ONT equipment ID
Note: model number must be 20 chars total (or less?)
```
manufactory
set equipment id MY_MODEL
```
## Change hardware version
```
manufactory
set hardware version MY_HARDWARE_VERSION (ASCII)
```
