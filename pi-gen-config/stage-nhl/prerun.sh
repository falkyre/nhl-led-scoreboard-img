#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	echo "Manually copying rootfs from stage2..."
    mkdir -p "${ROOTFS_DIR}"
	rsync -aHAX "${WORK_DIR}/stage2/rootfs/" "${ROOTFS_DIR}/"
fi
