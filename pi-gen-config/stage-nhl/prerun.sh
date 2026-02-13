if [ ! -d "${ROOTFS_DIR}" ]; then
	echo "Manually copying rootfs from stage2..."
    mkdir -p "${ROOTFS_DIR}"
	rsync -aHAX "${WORK_DIR}/stage2/rootfs/" "${ROOTFS_DIR}/"
fi

if [ -d "/pip-cache" ]; then
    echo "Mounting /pip-cache to ${ROOTFS_DIR}/tmp/pip_cache"
    mkdir -p "${ROOTFS_DIR}/tmp/pip_cache"
    mount --bind /pip-cache "${ROOTFS_DIR}/tmp/pip_cache"
    
    # Ensure it gets unmounted on exit
    # trap "umount ${ROOTFS_DIR}/tmp/pip_cache" EXIT
else
    echo "Warning: /pip-cache not found, skipping mount."
fi
