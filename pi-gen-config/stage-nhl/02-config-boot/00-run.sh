#!/bin/bash -e

CMDLINE_PATH="${ROOTFS_DIR}/boot/firmware/cmdline.txt"
if [ ! -f "$CMDLINE_PATH" ]; then
    CMDLINE_PATH="${ROOTFS_DIR}/boot/cmdline.txt"
fi

if [ -f "$CMDLINE_PATH" ]; then
    if ! grep -q "isolcpus=3" "$CMDLINE_PATH"; then
        echo "Adding isolcpus=3 to $CMDLINE_PATH"
        sed -i 's/$/ isolcpus=3/' "$CMDLINE_PATH"
    else
        echo "isolcpus=3 already present in $CMDLINE_PATH"
    fi
else
    echo "Warning: cmdline.txt not found in /boot/firmware or /boot"
fi

CONFIG_PATH="${ROOTFS_DIR}/boot/firmware/config.txt"
if [ ! -f "$CONFIG_PATH" ]; then
    CONFIG_PATH="${ROOTFS_DIR}/boot/config.txt"
fi

if [ -f "$CONFIG_PATH" ]; then
    echo "Configuring audio in $CONFIG_PATH"
    if grep -q "dtparam=audio=on" "$CONFIG_PATH"; then
        sed -i 's/dtparam=audio=on/dtparam=audio=off/' "$CONFIG_PATH"
        echo "Changed dtparam=audio=on to off"
    elif grep -q "dtparam=audio=off" "$CONFIG_PATH"; then
        echo "dtparam=audio=off already set"
    else
        echo "dtparam=audio=on not found, appending dtparam=audio=off"
        echo "dtparam=audio=off" >> "$CONFIG_PATH"
    fi
else
    echo "Warning: config.txt not found in /boot/firmware or /boot"
fi
