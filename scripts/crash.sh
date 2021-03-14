#!/usr/bin/env sh

set -e

CRASH=/tmp/crash_unlock.bin
CRASHDATA=/tmp/crash.data

dd if=/dev/zero ibs=65536 count=1 2> /dev/null | tr "\000" "\377" > "${CRASH}"
PRINTF=$(which printf)
${PRINTF} "\xa5\x5a\0\0" > "${CRASHDATA}"
dd conv=notrunc if="${CRASHDATA}" of="${CRASH}" bs=1 count=4 > /dev/null 2>&1

echo "'crash_unlock' hack generated."
echo
echo "Write 'crash_unlock' dump using the following command:"
printf "\tmtd write %s crash\n" ${CRASH}
printf "\treboot\n"
echo
echo "After applying 'crash_unlock' hack, don't forget to run the command:"
printf "\tmtd erase crash\n"

