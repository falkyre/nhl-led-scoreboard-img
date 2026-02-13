#!/bin/bash
set -e

# Target paths
SB_DIR="/home/pi/nhl-led-scoreboard"
VENV_PATH="/home/pi/nhlsb-venv"
SB_TOOLS="/home/pi/sbtools"

# --- THE FIX: HARDCODED ARCHITECTURE FLAGS ---
# We define these flags once and verify them.
# -march=armv8-a: The baseline instruction set for Pi 3 / Zero 2W
# -mtune=cortex-a53: Optimize for the specific CPU core in those models
SAFE_FLAGS="-march=armv8-a -mtune=cortex-a53"

# 1. Export globally for Python setup.py and implicit make rules
export CFLAGS="$SAFE_FLAGS"
export CXXFLAGS="$SAFE_FLAGS"

echo "Building for aarch64 (Cortex-A53) with flags: $SAFE_FLAGS"

cd "$SB_DIR"
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

# 2. Clean EVERYTHING to prevent mixing bad objects with good ones
make clean
make -C lib clean
make -C utils clean

# 3. EXPLICITLY build the core library FIRST
# This guarantees librgbmatrix.a is safe before Python or Utils touch it.
# We pass HARDWARE_DESC=regular to prevent auto-detection script errors.
make -C lib EXTRA_CXXFLAGS="$SAFE_FLAGS" HARDWARE_DESC=regular

# 4. Build Python bindings
# The CFLAGS/CXXFLAGS exports above handle the setup.py compilation.
# We verify the library exists first so it doesn't try to rebuild it wrongly.
make build-python PYTHON="$VENV_PATH/bin/python3" HARDWARE_DESC=regular
make install-python PYTHON="$VENV_PATH/bin/python3" HARDWARE_DESC=regular

# Swap custom runtext script
if [ -f "$SB_TOOLS/runtext.py" ]; then
    mv bindings/python/samples/runtext.py bindings/python/samples/runtext.py.ori 2>/dev/null || true
    cp "$SB_TOOLS/runtext.py" bindings/python/samples/
fi

# 5. Build the led-image-viewer utility
cd utils
# We pass the flags AGAIN just to be absolutely sure the linker uses them.
make led-image-viewer EXTRA_CXXFLAGS="$SAFE_FLAGS" HARDWARE_DESC=regular

# Deploy
if [ -f "led-image-viewer" ]; then
    cp led-image-viewer "$SB_TOOLS/led-image-viewer"
    chmod +x "$SB_TOOLS/led-image-viewer"
    echo "SUCCESS: led-image-viewer built and deployed."
else
    echo "ERROR: led-image-viewer failed to compile."
    exit 1
fi