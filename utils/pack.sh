#!/usr/bin/env sh

if [ "$(id -u)" -ne 0 ]; then
    echo "Use sudo to run this script!"
    exit 1
fi

SQFS="squashfs-root.${1}.mod"
#BLKSZ=262144 # original block size
BLKSZ=524288

rm -f "firmware.${1}.mod.bin"

mksquashfs "${SQFS}" "${SQFS}.raw" -no-xattrs -comp xz -b "${BLKSZ}"
dd if=/dev/zero ibs=13360476 count=1 | LC_ALL=C tr "\000" "\377" > "${SQFS}.bin"
dd conv=notrunc if="${SQFS}.raw" of="${SQFS}.bin"
rm "${SQFS}.raw"

cat kernel.bin "${SQFS}.bin" > "firmware.${1}.mod.bin"
rm "${SQFS}.bin"

