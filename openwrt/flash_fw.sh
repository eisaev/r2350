#!/bin/sh

. /bin/boardupgrade.sh

board_prepare_upgrade
mtd erase rootfs_data
mtd write /tmp/openwrt-ath79-generic-xiaomi_aiot-ac2350-squashfs-sysupgrade.bin firmware
sleep 3
reboot

