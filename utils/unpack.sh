#!/usr/bin/env sh

FW_FILE="miwifi_r2350_firmware_bd55f_3.0.36_INT.bin"
KERNEL="kernel.bin"
ROOTIMG="rootfs.squashfs"

dd if="${FW_FILE}" of="${KERNEL}" bs=1 skip=$((0x298)) count=$((0x110000))
dd if="${FW_FILE}" of="${ROOTIMG}" bs=1 skip=$((0x110298)) count=$((0xCBDD5C))
