# Files for Xiaomi Mi AIoT Router AC2350 (R2350)
This repository contains the files necessary to extend the capabilities of WiFi router Xiaomi Mi AIoT Router AC2350 in black (however, some of the files are also suitable for the white version).

## Table of Contents
- 3.0.36.mod - diff files of root filefs modifications based on firmware version 3.0.36 (International)
- fw - official firmwares:
  - miwifi_r2350_firmware_0cc61_1.3.8.bin.7z - 1.3.8 (China)
  - miwifi_r2350_firmware_bd55f_3.0.36_INT.bin.7z - 3.0.36 (International)
- scripts - some useful scripts:
  - art.sh - patching `art` partition on the black version of the router to equalize the 2.4 GHz WiFi transmission power limits with the white version
  - bdata.sh - patching `Bdata` partition to remove some restrictions (SSH access, access to the u-boot console, etc.)
  - crash.sh - `crash` partition dump generator for switching the router to emergency mode, in which all partitions become writable (for example, Bdata, art)

## Obtain SSH Access
- Flash the firmware version 1.3.8 (China)
- Login to the router web interface and get the value of `stok=` from the URL
- Open a new tab and go to the following URL (replace <STOK> with the stok value gained above):
```
http://192.168.31.1/cgi-bin/luci/;stok=<STOK>/api/misystem/set_config_iotdev?bssid=any&user_id=any&ssid=-h%0Anvram%20set%20ssh_en%3D1%0Anvram%20commit%0Ased%20-i%20%27s%2Fchannel%3D.%2A%2Fchannel%3D%5C%5C%22debug%5C%5C%22%2Fg%27%20%2Fetc%2Finit.d%2Fdropbear%0A%2Fetc%2Finit.d%2Fdropbear%20start%0A
```
- Wait 30-60 seconds (this is the time required to generate keys for the SSH server on the router)

## Create Full Backup
- Obtain SSH Access
- Create backup of all flash (on router):
```
dd if=/dev/mtd0 of=/tmp/ALL.backup
```
- Copy backup to PC (on PC):
```
scp root@192.168.31.1:/tmp/ALL.backup ./
```
Tip: backup of the original firmware, taken three times, increases the chances of recovery :)

## Calculate The Password
- Locally using shell (replace "12345/E0QM98765" with your router's serial number):
 
On Linux
```
printf "%s6d2df50a-250f-4a30-a5e6-d44fb0960aa0" "12345/E0QM98765" | md5sum - | head -c8 && echo
```
On macOS
```
printf "%s6d2df50a-250f-4a30-a5e6-d44fb0960aa0" "12345/E0QM98765" | md5 | head -c8
```
- Locally using python [script](https://github.com/eisaev/ax3600-files/blob/master/scripts/calc_passwd.py) (replace "12345/E0QM98765" with your router's serial number):
```
python3.7 -c 'from calc_passwd import calc_passwd; print(calc_passwd("12345/E0QM98765"))'
```
- [Online](https://www.oxygen7.cn/miwifi/)

## Flash Modified RootFS (so far, only for the black version of the router!)
- Obtain SSH Access
- Download [flash.sh](https://raw.githubusercontent.com/eisaev/r2350/main/flash.sh)
- Copy `flash.sh` to the router (on PC):
```
scp flash.sh root@192.168.31.1:/tmp/
```
- Download [squashfs-root.6.mod.bin](https://mega.nz/file/WAszla7J#66I_8tX7zLXnH9nawaap_UrKsifll-JjxetzGNejgc4)
- Copy `squashfs-root.6.mod.bin` to the router (on PC):
```
scp squashfs-root.6.mod.bin root@192.168.31.1:/tmp/
```
- Flash modified RootFS (on router):
```
/bin/ash /tmp/flash.sh &
```
- SSH connection will be interrupted - this is normal.
- Wait for the indicator to turn blue.
- Reset router to factory defaults.

## Patch Bdata Partition (on router)
This action is required only once.
- Generate a dump of the `crash` partition:
```
/root/scripts/crash.sh
```
- Flash the generated dump of the `crash` partition:
```
mtd write /tmp/crash_unlock.bin crash
```
- Reboot:
```
reboot
```
- Read and patch the dump of the `Bdata` partition:
```
/root/scripts/bdata.sh
```
- Flash modified dump of Bdata partition:
```
mtd write /tmp/bdata.mod.bin Bdata
```
- Erase the `crash` partition:
```
mtd erase crash
```
- Reboot:
```
reboot
```

## Patch art Partition (for black version only; on router)
This action is required only once.
- Generate a dump of the `crash` partition:
```
/root/scripts/crash.sh
```
- Flash the generated dump of the `crash` partition:
```
mtd write /tmp/crash_unlock.bin crash
```
- Reboot:
```
reboot
```
- Read and patch the dump of the `art` partition:
```
/root/scripts/art.sh
```
- Flash modified dump of Bdata partition:
```
mtd write /tmp/art.mod.bin art
```
- Erase the `crash` partition:
```
mtd erase crash
```
- Reboot:
```
reboot
```

## Disable LED
- Login to the router web interface and get the value of `stok=` from the URL
- Open a new tab and go to the following URL (replace <STOK> with the stok value gained above):
```
http://192.168.31.1/cgi-bin/luci/;stok=<STOK>/api/misystem/led?on=0
```

## Debricking (lite)
If you have a healthy bootloader, you can use recovery via TFTP using programs like TinyPXE on Windows or dnsmasq on Linux. To switch the router to TFTP recovery mode, hold down the reset button, connect the power supply, and release the button after about 10 seconds. The router must be connected directly to the PC via the LAN port.

## Debricking
You will need a full dump of your flash, a CH341 programmer, and a clip for in-circuit programming.

