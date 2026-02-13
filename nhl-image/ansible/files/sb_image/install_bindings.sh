#!/bin/bash
set -e

# Target paths
SB_DIR="/home/pi/nhl-led-scoreboard"
VENV_PATH="/home/pi/nhlsb-venv"
SB_TOOLS="/home/pi/sbtools"

# Portability flags for aarch64 (Zero 2W / Pi 3 / Pi 4)
# We define them here for re-use, but pass them explicitly below
ARCH_FLAGS="-march=armv8-a -mtune=cortex-a53"
HW_FLAGS="HARDWARE_DESC=regular"

cd "$SB_DIR"

# Ensure submodules are ready
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

# Clean previous artifacts to avoid "Illegal Instruction" from architecture drift
make clean

# Build and Install Python bindings
# We pass flags explicitly here too, just to be safe
make build-python PYTHON="$VENV_PATH/bin/python3" EXTRA_CXXFLAGS="$ARCH_FLAGS" $HW_FLAGS
make install-python PYTHON="$VENV_PATH/bin/python3" EXTRA_CXXFLAGS="$ARCH_FLAGS" $HW_FLAGS

# Swap custom runtext script if it exists
if [ -f "$SB_TOOLS/runtext.py" ]; then
    mv bindings/python/samples/runtext.py bindings/python/samples/runtext.py.ori 2>/dev/null || true
    cp "$SB_TOOLS/runtext.py" bindings/python/samples/
fi

# Build the led-image-viewer utility
cd utils
make clean

# EXPLICITLY pass the flags here to guarantee they are used
make led-image-viewer EXTRA_CXXFLAGS="$ARCH_FLAGS" $HW_FLAGS

# Deploy the binary to sbtools
if [ -f "led-image-viewer" ]; then
    cp led-image-viewer "$SB_TOOLS/led-image-viewer"
    chmod +x "$SB_TOOLS/led-image-viewer"
    echo "Successfully built and deployed led-image-viewer."
else
    echo "Error: led-image-viewer failed to compile."
    exit 1
fi