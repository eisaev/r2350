#!/usr/bin/env sh

set -e

BACKUP=/root/Bdata.backup
TXTTEMP=/tmp/bdata.temp
BINTEMP=/tmp/bdata.bin.temp
BINDATA=/tmp/bdata.bin
CRC32=/tmp/bdata.crc32
OUTPUT=/tmp/bdata.mod.bin

# Create backup of mtd3 (Bdata)
if [ -f "${BACKUP}" ]; then
    echo "${BACKUP} exists. Please rename file and try again."
    exit
fi
dd if="/dev/$(grep Bdata /proc/mtd | cut -d":" -f1)" of="${BACKUP}" > /dev/null 2>&1

dd if=/dev/zero of="${BINDATA}" ibs=65532 count=1 > /dev/null 2>&1

bdata show > "${TXTTEMP}"
sed -ri "/^(CountryCode|ssh_en|uart_en|boot_wait)=/d" "${TXTTEMP}"
{ echo CountryCode=CN; echo ssh_en=1; echo uart_en=1; echo boot_wait=on; } >> "${TXTTEMP}"
tr '\n' '\0' < "${TXTTEMP}" > "${BINTEMP}"
dd conv=notrunc if="${BINTEMP}" of="${BINDATA}" > /dev/null 2>&1

gzip -c < "${BINDATA}" | tail -c8 | head -c4 > "${CRC32}"
dd if="${CRC32}" of="${OUTPUT}" bs=1 count=1 skip=3 seek=0 > /dev/null 2>&1
dd if="${CRC32}" of="${OUTPUT}" bs=1 count=1 skip=2 seek=1 > /dev/null 2>&1
dd if="${CRC32}" of="${OUTPUT}" bs=1 count=1 skip=1 seek=2 > /dev/null 2>&1
dd if="${CRC32}" of="${OUTPUT}" bs=1 count=1 skip=0 seek=3 > /dev/null 2>&1
dd if="${BINDATA}" of="${OUTPUT}" bs=1 seek=4 > /dev/null 2>&1

echo "Patching done."
echo "You must first unlock Bdata partition using 'crash_unlock' hack!"
echo
echo "Write the modified dump using the following command:"
printf "\tmtd write %s Bdata\n" ${OUTPUT}
echo
echo "After applying 'crash_unlock' hack, don't forget to run the command:"
printf "\tmtd erase crash\n"

