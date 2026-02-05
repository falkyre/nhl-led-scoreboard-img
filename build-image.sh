#!/bin/bash
set -e

# Configuration
PI_GEN_REPO="https://github.com/RPi-Distro/pi-gen.git"
PI_GEN_BRANCH="master"
BUILD_DIR="pi-gen"
CONFIG_FILE="$(pwd)/pi-gen-config/config"
STAGE_NHL="$(pwd)/pi-gen-config/stage-nhl"
REPO_ROOT="$(pwd)"

# Update dependencies (if running in a dev environment)
# sudo apt-get update && sudo apt-get install -y git quilt parted realpath qemu-user-static debootstrap zerofree pxz zip dosfstools bsdtar libcap2-bin grep rsync xz-utils

# Clone pi-gen if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
    git clone --depth 1 -b "$PI_GEN_BRANCH" "$PI_GEN_REPO" "$BUILD_DIR"
else
    echo "pi-gen directory exists, updating..."
    cd "$BUILD_DIR"
    git pull
    cd ..
fi

# Copy config
cp "$CONFIG_FILE" "$BUILD_DIR/config"

# Setup custom stage
# We want to run our stage after stage2 (Lite system)
# Check if stage-nhl already exists in pi-gen, remove it to ensure fresh copy
if [ -d "$BUILD_DIR/stage-nhl" ]; then
    rm -rf "$BUILD_DIR/stage-nhl"
fi
cp -r "$STAGE_NHL" "$BUILD_DIR/stage-nhl"

# We need to make sure stage-nhl is executed. 
# pi-gen runs stages looking for 'stage*' directories and executing them in order (if configured in STAGE_LIST usually, or just by existence if following numbering)
# Using EXPORT_IMAGE/SKIP_IMAGES in config controls output, but stage execution is directory based.
# To insert our stage, we can create a file "stage-nhl/prerun.sh" or just ensure it is named correctly?
# Actually pi-gen executes stages defined in the root directory. 
# We need to ensure stage-nhl has a 'sub-stage' structure like '00-install-ansible' 

# Link our stage into the build if not already there (we moved it)
# Make sure previous entry points to it? 
# Usually you modify the 'stage2/EXPORT_NOOBS' or similar if you want to stop there?
# Or we can use the 'stage-custom' pattern if we just want to run things.

# Let's create a 'EXPORT_IMAGE' file in our stage to indicate we want an image generated after this?
# Or just let it run.

# To simplify, let's create a wrapper config or just drop the folder.
# We also need to copy the 'nhl-image' folder which contains the ansible playbook into the stage so it can be used.

echo "Preparing nhl-image files..."
# Copy the ansible directory to the stage-nhl files directory
# pi-gen copies content of 'files' to root of image. We want it in /tmp/ansible
mkdir -p "$BUILD_DIR/stage-nhl/01-run-ansible/files/tmp/ansible"
cp -r "$REPO_ROOT/nhl-image/ansible/"* "$BUILD_DIR/stage-nhl/01-run-ansible/files/tmp/ansible/"


cd "$BUILD_DIR"

# Ensure stage-nhl is executable
chmod +x stage-nhl/*/*.sh 2>/dev/null || true

# Run build
# Run build
if [[ "$OSTYPE" == "darwin"* ]] || [[ "$USE_DOCKER" == "true" ]]; then
    echo "Building using Container Runtime..."
    
    CONTAINER_CMD="docker"
    if command -v podman &> /dev/null; then
        echo "Detected Podman."
        CONTAINER_CMD="podman"
    elif command -v docker &> /dev/null; then
        echo "Detected Docker."
        CONTAINER_CMD="docker"
    else
        echo "Error: Neither Docker nor Podman found. One is required for this build on macOS."
        exit 1
    fi

    # pi-gen's build-docker.sh tends to use 'docker' explicitly. 
    # If using podman, we might need to rely on 'alias docker=podman' user configuration 
    # OR we can try to pass the command if script supports it (it doesn't usually).
    # However, standard practice for Podman users is to have the docker-compatible CLI or alias.
    
    if [[ "$CONTAINER_CMD" == "podman" ]]; then
        echo "Note: Ensure you have 'podman-docker' installed or alias docker=podman if build fails."
        # Attempt to run build-docker.sh. If it fails due to missing docker command, user needs alias.
    fi

    ./build-docker.sh
else
    echo "Starting build. obtaining sudo..."
    sudo ./build.sh
fi
