#!/bin/sh

. /bin/boardupgrade.sh

board_prepare_upgrade
mtd erase rootfs_data
mtd write /tmp/squashfs-root.6.mod.bin rootfs
sleep 3
reboot

