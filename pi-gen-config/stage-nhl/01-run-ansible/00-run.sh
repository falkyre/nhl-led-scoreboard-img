#!/bin/bash -e

# Files in 'files/' directory of this stage are automatically copied to ROOTFS by pi-gen.
# We placed ansible files in 'files/tmp/ansible', so they are at '/tmp/ansible' inside the image.

# Manually copy files if they haven't been copied by pi-gen mechanism
# (Sometimes behavior varies by pi-gen version or stage config)
if [ -d "files" ]; then
    echo "Syncing files to ROOTFS..."
    rsync -av "files/" "${ROOTFS_DIR}/"
else
    echo "Warning: 'files' directory not found in current directory $(pwd)"
fi

# Verify /tmp/ansible exists in ROOTFS
ls -la "${ROOTFS_DIR}/tmp/"

on_chroot << EOF
cd /tmp/ansible

# Fix permissions on /tmp (required for apt-get to create temp files)
chmod 1777 /tmp

echo "--- DEBUG: PRE-FLIGHT CHECK ---"
ls -ld /tmp
apt-get update || echo "Direct apt-get update failed"
echo "------------------------------"

# Run playbook on localhost (chroot)
# We assume dependencies (ansible) were installed in previous step (00-install-ansible)
EXTRA_VARS="is_pigen_build=true"
if [ -n "$PYPI_PROXY" ]; then
    echo "Using PyPI Proxy: $PYPI_PROXY"
    EXTRA_VARS="$EXTRA_VARS pypi_proxy='$PYPI_PROXY'"
fi

if [ "$USE_BETA" == "true" ]; then
    echo "Using Beta Branch"
    EXTRA_VARS="$EXTRA_VARS use_beta=true"
fi

# Configure pip to use the cache if it exists
if [ -d "/tmp/pip_cache" ]; then
    echo "Configuring pip to use /tmp/pip_cache"
    mkdir -p /root/.config/pip
    echo "[global]" > /root/.config/pip/pip.conf
    echo "cache-dir = /tmp/pip_cache" >> /root/.config/pip/pip.conf
fi

ansible-playbook setup-raspberry.yml -i "localhost," -c local -e "$EXTRA_VARS"

# Cleanup
if [ -d "/tmp/pip_cache" ]; then
    rm -rf /root/.config/pip
fi
EOF

rm -rf "${ROOTFS_DIR}/tmp/ansible"
