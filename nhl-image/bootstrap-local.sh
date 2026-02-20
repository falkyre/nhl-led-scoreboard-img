#!/bin/bash
set -e

# --- CONFIGURATION ---
IMAGE_URL="https://dietpi.com/downloads/images/DietPi_RPi234-ARMv8-Trixie.img.xz"
LOCAL_IMG="nhl-scoreboard-dietpi.img"
# 8GB to be safe (Orbstack allocates sparsely, so it won't use 8GB of real disk)
TARGET_SIZE="5120M" 
MOUNT_DIR="/mnt/rpi"
LOOP_DEV="" 
# ---------------------

# --- SAFETY TRAP (Runs on Exit/Error/Ctrl+C) ---
cleanup_on_exit() {
    echo ">>> [Trap] Cleaning up mounts and loop devices..."
    
    # 1. Unmount filesystem mounts (ignore errors if not mounted)
    umount "$MOUNT_DIR/dev" 2>/dev/null || true
    umount "$MOUNT_DIR/sys" 2>/dev/null || true
    umount "$MOUNT_DIR/proc" 2>/dev/null || true
    umount "$MOUNT_DIR/boot" 2>/dev/null || true
    umount "$MOUNT_DIR" 2>/dev/null || true
    
    # 2. Detach Loop Device
    if [ -n "$LOOP_DEV" ]; then
        kpartx -d "$LOOP_DEV" 2>/dev/null || true
        losetup -d "$LOOP_DEV" 2>/dev/null || true
        echo "    Detached $LOOP_DEV"
    fi
}
# Register the trap to run on EXIT (success or fail) or INT (Ctrl+C)
trap cleanup_on_exit EXIT INT
# ------------------------------------------------

echo ">>> [1/7] Installing tools..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
# Added 'python3-pip' and 'python3-venv' for Ansible installation
apt-get install -y wget xz-utils parted kpartx git libopenjp2-7 python3-apt sudo e2fsprogs python3-pip python3-venv

echo ">>> [2/7] Preparing Base Image..."
if [ ! -f "$LOCAL_IMG" ]; then
    echo "    Downloading DietPi..."
    wget -qO image.xz "$IMAGE_URL"
    echo "    Extracting..."
    xz -d -c image.xz > "$LOCAL_IMG"
    rm image.xz
else
    echo "    Using existing $LOCAL_IMG"
fi

echo ">>> [3/7] Resizing Image (The Orbstack Fix)..."
truncate -s $TARGET_SIZE "$LOCAL_IMG"
LOOP_DEV=$(losetup -fP --show "$LOCAL_IMG")
echo "    Attached to $LOOP_DEV"
kpartx -va "$LOOP_DEV"
sleep 2

yes | parted ---pretend-input-tty "$LOOP_DEV" resizepart 2 100%

kpartx -u "$LOOP_DEV"
partprobe "$LOOP_DEV" || true 
sleep 2

LOOP_NAME=$(basename $LOOP_DEV)
ROOT_DEV="/dev/mapper/${LOOP_NAME}p2"
BOOT_DEV="/dev/mapper/${LOOP_NAME}p1"

echo "    Checking filesystem..."
e2fsck -f -y "$ROOT_DEV" || true

echo "    Expanding filesystem..."
resize2fs "$ROOT_DEV"

echo ">>> [4/7] Mounting & Verifying..."
mkdir -p "$MOUNT_DIR"
mount "$ROOT_DEV" "$MOUNT_DIR"
mkdir -p "$MOUNT_DIR/boot"
mount "$BOOT_DEV" "$MOUNT_DIR/boot"

echo "    [DEBUG] Checking Disk Size inside Image:"
df -h "$MOUNT_DIR"
SPACE_AVAIL=$(df --output=avail "$MOUNT_DIR" | tail -1)
if [ "$SPACE_AVAIL" -lt 2000000 ]; then
    echo "!!! ERROR: Resize Failed. Filesystem is still too small."
    exit 1
fi
echo "    [DEBUG] Size looks good! Proceeding..."

# Bind mounts for Chroot
mount --bind /dev "$MOUNT_DIR/dev"
mount --bind /sys "$MOUNT_DIR/sys"
mount --bind /proc "$MOUNT_DIR/proc"

echo ">>> [5/7] Installing Ansible Core via Pip..."
# Install modern Ansible (2.16+) to avoid Python 3.12 compatibility issues
pip3 install --break-system-packages "ansible-core>=2.16.0" ansible passlib

echo ">>> [6/7] Running Ansible..."
# 1. Install dependencies INSIDE the image
chroot "$MOUNT_DIR" /bin/bash <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y python3 python3-apt libopenjp2-7 sudo
EOF

# 2. Run Ansible (THE FIX IS HERE)
# -i 'localhost,': Defines the inventory host as "localhost"
# -c chroot: Tells Ansible to use the Chroot connector
# -e ansible_host=$MOUNT_DIR: Tells Ansible WHERE the chroot is located (/mnt/rpi)

USER_CONFIG="../user-config"
if [ ! -f "$USER_CONFIG" ] && [ -f "user-config" ]; then
    USER_CONFIG="user-config"
fi

ANSIBLE_EXTRA_ARGS=()
if [ -f "$USER_CONFIG" ]; then
    source "$USER_CONFIG"
    if [ -n "$APT_PROXY" ]; then
        ANSIBLE_EXTRA_ARGS+=("-e" "apt_proxy=$APT_PROXY")
        ANSIBLE_EXTRA_ARGS+=("-e" "use_apt_proxy=true")
    fi
    if [ -n "$PYPI_PROXY" ]; then
        ANSIBLE_EXTRA_ARGS+=("-e" "pypi_proxy=$PYPI_PROXY")
    fi
    if [ -n "$USE_BETA" ]; then
        ANSIBLE_EXTRA_ARGS+=("-e" "use_beta=$USE_BETA")
    fi
fi

ansible-playbook -i 'localhost,' -c chroot \
    -e "ansible_host=$MOUNT_DIR" \
    -e "ansible_python_interpreter=/usr/bin/python3" \
    "${ANSIBLE_EXTRA_ARGS[@]}" \
    ansible/setup-dietpi.yml

# Note: If Ansible fails, the script STOPS here, and the 'trap' runs automatically.

echo ">>> [7/7] Optimizing Image (Zero-fill)..."
# This step only runs if Ansible SUCCEEDED.
chroot "$MOUNT_DIR" /bin/bash <<EOF
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
# We redirect stderr (2>) to /dev/null to hide the "No space left" message
dd if=/dev/zero of=/zerofile bs=1M status=progress 2>/dev/null || true
rm -f /zerofile
EOF

echo ">>> SUCCESS! Image built: $LOCAL_IMG"
# The 'trap' will now run automatically to unmount everything.

# echo ">>> [8/8] Compressing Image (Best Quality)..."
# -9: Max compression level
# -e: Extreme mode (tries harder to find duplicate data)
# -T0: Use ALL CPU cores (makes it much faster)
# -v: Verbose (shows percentage progress)
# -k: Keep the original .img file (remove -k if you want to delete the raw image)
# xz -9 -e -T0 -v -k "$LOCAL_IMG"
# ls -lh "$LOCAL_IMG.xz"

echo ">>> SUCCESS! Image built and compressed:"
