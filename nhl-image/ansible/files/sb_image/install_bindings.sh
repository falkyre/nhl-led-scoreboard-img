#!/bin/bash
set -e

# Target paths
SB_DIR="/home/pi/nhl-led-scoreboard"
VENV_PATH="/home/pi/nhlsb-venv"
SB_TOOLS="/home/pi/sbtools"

# Portability flags for aarch64 (Zero 2W / Pi 3 / Pi 4)
SAFE_FLAGS="-march=armv8-a -mtune=cortex-a53 -D_GLIBCXX_USE_CXX11_ABI=1"

echo "Applying architecture lock: $SAFE_FLAGS"

cd "$SB_DIR"
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

# 1. Clean previous artifacts
make clean
make -C lib clean
make -C utils clean

# --- CRITICAL FIX: PATCH THE MAKEFILE ---
# The library's Makefile ignores environment variables for CXXFLAGS.
# We must physically write our flags into the file to stop it from using
# 'native' optimizations that cause the SIGILL on Pi 3.

# Remove the line that tries to auto-detect hardware
sed -i '/DEFINES+=-march=native/d' lib/Makefile

# Force our flags at the top of the CXXFLAGS definition in lib/Makefile
# This ensures they take precedence over any other internal flags.
sed -i "s|^CXXFLAGS=|CXXFLAGS=$SAFE_FLAGS |g" lib/Makefile

# Do the same for the utils/Makefile
sed -i "s|^CXXFLAGS=|CXXFLAGS=$SAFE_FLAGS |g" utils/Makefile

# ------------------------------------------

# 2. Build Core Library (Forced to ARMv8-A)
# We explicitly set HARDWARE_DESC to avoid the library's shell script from 
# guessing the wrong Pi model during the build.
make -C lib HARDWARE_DESC=regular

# 3. Build Python bindings
# Export flags just in case setup.py decides to use them
export CFLAGS="$SAFE_FLAGS"
export CXXFLAGS="$SAFE_FLAGS"
make build-python PYTHON="$VENV_PATH/bin/python3" HARDWARE_DESC=regular
make install-python PYTHON="$VENV_PATH/bin/python3" HARDWARE_DESC=regular

# Swap custom runtext script
if [ -f "$SB_TOOLS/runtext.py" ]; then
    mv bindings/python/samples/runtext.py bindings/python/samples/runtext.py.ori 2>/dev/null || true
    cp "$SB_TOOLS/runtext.py" bindings/python/samples/
fi

# 4. Build the led-image-viewer utility
cd utils
make led-image-viewer HARDWARE_DESC=regular

# Deploy
if [ -f "led-image-viewer" ]; then
    cp led-image-viewer "$SB_TOOLS/led-image-viewer"
    chmod +x "$SB_TOOLS/led-image-viewer"
    echo "SUCCESS: led-image-viewer built with forced architecture flags."
else
    echo "ERROR: led-image-viewer failed to compile."
    exit 1
fi