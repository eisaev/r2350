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
- [Online](https://miwifi.dev/ssh)

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

## Flash Modified Firmware (tested on both the white and black versions)
- Obtain SSH Access
- Download [flash_fw.sh](https://raw.githubusercontent.com/eisaev/r2350/main/3.0.36.mod/flash_fw.sh)
- Copy `flash_fw.sh` to the router (on PC):
```
scp flash_fw.sh root@192.168.31.1:/tmp/
```
- Download [firmware.7.mod.bin](https://mega.nz/file/CRUlgI5R#NWJAsxw0JiFMEe4gfeGhFXbdCrrmma-7qPt0AuyS_cY)
- Copy `firmware.7.mod.bin` to the router (on PC):
```
scp firmware.7.mod.bin root@192.168.31.1:/tmp/
```
- Flash modified firmware (on router):
```
/bin/ash /tmp/flash_fw.sh &
```
- SSH connection will be interrupted - this is normal.
- Wait for the indicator to turn blue.
- Reset router to factory defaults using the physical reset button.

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
Required only on the black version of the router. This action is required only once.
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
If you have a healthy bootloader, you can use recovery via TFTP using programs like TinyPXE on Windows (with firewalls disabled!) or dnsmasq on Linux.

- set up your PCs network card on the static IP address 192.168.31.100
- the router must be connected directly to the PC via the one of the routers LAN ports
- download the [miwifi_r2350_firmware_0cc61_1.3.8.bin](https://cdn.cnbj1.fds.api.mi-img.com/xiaoqiang/rom/r2350/miwifi_r2350_firmware_0cc61_1.3.8.bin) firmware or use the identical [firmware](https://github.com/eisaev/r2350/raw/main/fw/miwifi_r2350_firmware_0cc61_1.3.8.bin.7z) from this repo and unzip it
- copy the firmware to the TFTP directory and rename it to `test.img`
- start the TFTP server (for TinyPXE: select `test.img` and set it to `Online`)

To switch the router to TFTP recovery mode, hold down the reset button, connect the power supply and release the reset button after the steady enlightened orange LED starts blinking (about 10 seconds after power up). The blinking orange LED also indicates that you still have a healthy bootloader.

Check the LAN LEDs (or the TinyPXE log output) to see the whether the data is transferred to the router. Once the blue LED starts flashing fast, you can reboot the router by disconnecting and reconnecting the power supply.

After the reboot the orange LED becomes steady which is fine: The original firmware waits for the initial setup.

## Debricking (in the case of unhealthy bootloader)
You will need a full dump of your flash, a CH341 programmer, and a clip for in-circuit programming.

## Install OpenWRT (testing!)

Before installing OpenWrt on a black version of the router you should follow the 'Patch art Partition' section to be able to switch the 2.4 GHz WiFi transmission power limits from the OpenWrt application. The `art` partition can not be unlocked and altered after installing OpenWRT so you need to do this with the original firmware.

- Obtain SSH Access
- Download [flash_fw.sh](https://raw.githubusercontent.com/eisaev/r2350/main/openwrt/flash_fw.sh)
- Copy `flash_fw.sh` to the router (on PC):
```
scp flash_fw.sh root@192.168.31.1:/tmp/
```
- Download [openwrt-ath79-generic-xiaomi_aiot-ac2350-squashfs-sysupgrade.bin](https://raw.githubusercontent.com/eisaev/r2350/main/openwrt/openwrt-ath79-generic-xiaomi_aiot-ac2350-squashfs-sysupgrade.bin)
- Copy `openwrt-ath79-generic-xiaomi_aiot-ac2350-squashfs-sysupgrade.bin` to the router (on PC):
```
scp openwrt-ath79-generic-xiaomi_aiot-ac2350-squashfs-sysupgrade.bin root@192.168.31.1:/tmp/
```
- Flash OpenWRT (on router):
```
/bin/ash /tmp/flash_fw.sh &
```
- SSH connection will be interrupted - this is normal.
- Wait for the indicator to turn blue.

