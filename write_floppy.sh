#!/bin/sh

# Don't just run this without reading it! Raw dd being used!!
# You can really mess up your computer!!!

FLOPPY_FILE=""
FLOPPY_DEVICE=""
if [ -z "$1" ]
then
    echo "Specify floppy file"
    exit 1
fi
FLOPPY_FILE="$1"
shift
if [ ! -f "${FLOPPY_FILE}" ]
then
    echo "Can't access floppy file"
    exit 1
fi
if [ -z "$1" ]
then
    echo "Specify floppy device"
    exit 1
fi
FLOPPY_DEVICE="$1"
shift
CHECK_FLOPPY_FILE="${FLOPPY_FILE}.check"

# You might need to change the below in case you have a different floppy device
# I have it just in case.
if ! lsblk -do +VENDOR,MODEL | grep "$(basename "${FLOPPY_DEVICE}")" | grep -q "USB UF000x"
then
    echo "${FLOPPY_DEVICE} doesn't look like a floppy to me"
    exit 1
fi

if ! touch "${FLOPPY_DEVICE}"
then
    echo "Can't access ${FLOPPY_DEVICE}"
    exit 1
fi

# If it fails to access the floppy it'll just loop infinitely here
# CTRL-C works but ugh should really do a permissions check instead
while true
do
    ufiformat -v -V -f 1440 "${FLOPPY_DEVICE}" \
        && dd if="${FLOPPY_FILE}" of="${FLOPPY_DEVICE}" conv=notrunc status=progress \
        && dd if="${FLOPPY_DEVICE}" of="${CHECK_FLOPPY_FILE}" status=progress
    if diff "${FLOPPY_FILE}" "${CHECK_FLOPPY_FILE}"
    then
        echo "Done!"
        rm "${CHECK_FLOPPY_FILE}"
        exit
    fi
done
