#!/usr/bin/env sh

if [ "$(id -u)" -ne 0 ]; then
    echo "Use sudo to run this script!"
    exit 1
fi

ROOTIMG="rootfs.squashfs"
ROOTFS="squashfs-root"

if [ -z "${1}" ]; then
    SUFFIX=""
else
    SUFFIX=".${1}.mod"
fi

rm -rf "${ROOTFS}${SUFFIX}"
unsquashfs -f -d "${ROOTFS}${SUFFIX}" "${ROOTIMG}"
