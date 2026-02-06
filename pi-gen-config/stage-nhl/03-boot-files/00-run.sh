#!/bin/bash -e

SCOREBOARD_DIR="${ROOTFS_DIR}/boot/scoreboard"
# Check if /boot/firmware exists (Bookworm+), if so, maybe we want it there?
# But user requested /boot/scoreboard. 
# Note: In Bookworm/Trixie, /boot is the mount point, but sometimes actual boot partition is /boot/firmware.
# However, user likely wants it visible on the FAT partition when plugged into PC.
# On newer RPi OS, the FAT partition is mounted at /boot/firmware.
# On older, it was /boot.
# We should probably put it in the FAT partition so it's accessible.

BOOT_PART="${ROOTFS_DIR}/boot"
if [ -d "${ROOTFS_DIR}/boot/firmware" ]; then
    BOOT_PART="${ROOTFS_DIR}/boot/firmware"
fi

SCOREBOARD_DIR="${BOOT_PART}/scoreboard"

mkdir -p "$SCOREBOARD_DIR"

if [ -f "files/import_readme.txt" ]; then
    cp "files/import_readme.txt" "$SCOREBOARD_DIR/"
else
    echo "Warning: import_readme.txt not found in files directory"
fi
