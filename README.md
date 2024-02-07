```
 _   _               _       ____  ____    ___   _   _ 
| | | |  __ _   ___ | | __  / ___||  _ \  / _ \ | \ | |
| |_| | / _` | / __|| |/ / | |  _ | |_) || | | ||  \| |
|  _  || (_| || (__ |   <  | |_| ||  __/ | |_| || |\  |
|_| |_| \__,_| \___||_|\_\  \____||_|     \___/ |_| \_|
```

# Zyxel PMG3000-d20b firmware mod kit

> [!IMPORTANT] 
> See https://hack-gpon.org/ont-zyxel-pmg3000-d20b/ before use this mod kit.

## Prerequisites
- Linux os
- firmware-mod-kit built. Use https://github.com/st-ty1/Arch-Linux_firmware-mod-kit on a modern distro
- an mtd dump of the rootfs to be modded

## Usage
- Edit build.sh, changing the settings at the top
- Run build.sh as root
- The script will tell you where the new mtd is

## Flashing

> [!IMPORTANT] 
> See https://hack-gpon.org/ont-zyxel-pmg3000-d20b/ for up-to-date command.

Note: all commands start from the twmanu shell
- Transfer the new mtd on the stick via tftp
```
linuxshell
tftp -gr mtd2.mod.bin TFTP_SERVER_IP
```
- Flash it on the standby partition. 
You can use `system` and then `show actimage` to get the current active image. Check `/proc/mtd` for the right mtds. Usually:
- if the currect active image is A the mtd in use is mtd2
- If the current active image is B the mtd in use is mtd3
```
linuxshell
mtd -e /dev/mtd2 write /tmp/mtd2.mod.bin /dev/mtd2
```
- Switch to the new image
```
system
set actimage a
```
- Reboot the ONT
```
system
reboot
```

## Other tibits

> [!IMPORTANT] 
> See https://hack-gpon.org/ont-zyxel-pmg3000-d20b/ for up-to-date command.

## Change PLOAM
Use the web UI
## Change ONT S/N
```
manufactory
set sn ALCLf0f0f0f0
exit
hal
set sn ALCLf0f0f0f0
```
## Change ONT equipment ID
Note: model number must be 20 chars total (or less?)

```
manufactory
set equipment id __________G-010G-R__
exit
omci
equipment id __________G-010G-R__
```
## Change hardware version
```
manufactory
set hardware version 3FE49165BFAA01
```
