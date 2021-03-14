#!/usr/bin/env sh

set -e

BACKUP=/root/art.backup
PWRTEMP=/tmp/art.txpwr.temp
PWRPATCH=/tmp/art.txpwr.patch
OUTPUT=/tmp/art.mod.bin
MD5ORIG="16e0a5bf7f859455381a8ff4da86e170"
MD5PATCH="9f2027ebf7e67b1ca3c827e5f9ce2c52"

# Create backup of mtd5 (art)
if [ -f "${BACKUP}" ]; then
    echo "${BACKUP} exists. Please rename file and try again."
    exit
fi
dd if="/dev/$(grep art /proc/mtd | cut -d":" -f1)" of="${BACKUP}" > /dev/null 2>&1

dd if="${BACKUP}" of="${PWRTEMP}" bs=1 count=104 skip=$((0x10CE)) > /dev/null 2>&1
MD5=$(md5sum "${PWRTEMP}" | cut -d" " -f1)
if [ "${MD5}" = "${MD5PATCH}" ]; then
    echo "Art already patched."
    exit
fi

if [ "${MD5}" != "${MD5ORIG}" ]; then
    echo "Unknown content of art partition was detected. Patching is canceled. Contact the developer."
    exit
fi

cp "${BACKUP}" "${OUTPUT}"

PRINTF=$(which printf)
${PRINTF} "\x30\x30\x30\x30\x30\x30\x30\x30\x2E\x2E\x2E\x2C\x2E\x2E\x2E\x2C\x2E\x2E\x2E\x2C\x2E\x2E\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A\x2E\x2E\x2C\x2A" > "${PWRPATCH}"
dd conv=notrunc if="${PWRPATCH}" of="${OUTPUT}" bs=1 count=104 seek=$((0x10CE)) > /dev/null 2>&1

echo "Patching done."
echo "You must first unlock art partition using 'crash_unlock' hack!"
echo
echo "Write the modified dump using the following command:"
printf "\tmtd write %s art\n" ${OUTPUT}
echo
echo "After applying 'crash_unlock' hack, don't forget to run the command:"
printf "\tmtd erase crash\n"

