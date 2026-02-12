#!/bin/bash
cd /home/pi/nhl-led-scoreboard

#Install rgb matrix
# Pull submodule and ignore changes from script
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

make build-python PYTHON=/home/pi/nhlsb-venv/bin/python3
make install-python PYTHON=/home/pi/nhlsb-venv/bin/python3

mv bindings/python/samples/runtext.py bindings/python/samples/runtext.py.ori
mv /home/pi/sbtools/runtext.py bindings/python/samples/

# Install led-image-viewer - this is currently broken
# Will use pre built binary instead
# cd utils
# make led-image-viewer

# cp led-image-viewer /home/pi/sbtools/led-image-viewer
# chmod +x /home/pi/sbtools/led-image-viewer#!/bin/bash
set -e

# Target paths
SB_DIR="/home/pi/nhl-led-scoreboard"
VENV_PATH="/home/pi/nhlsb-venv"
SB_TOOLS="/home/pi/sbtools"

# Portability flags for aarch64 (Zero 2W / Pi 3 / Pi 4)
export EXTRA_CXXFLAGS="${EXTRA_CXXFLAGS:-"-march=armv8-a -mtune=cortex-a53"}"
export HARDWARE_DESC="${HARDWARE_DESC:-"regular"}"

# --- Function: Verify Binary Compatibility ---
verify_binary_compatibility() {
    local bin_path="$1"
    echo "Verifying portability for: $bin_path"

    # Check for LSE instructions (Atomic Compare-and-Swap, LDADD, etc.)
    # These exist in ARMv8.1+ but will CRASH a Cortex-A53 (Pi 3 / Zero 2W)
    # We look for the instruction mnemonics surrounded by whitespace
    if objdump -d "$bin_path" | grep -E -q "[[:space:]](cas|casp|ldadd|stadd|ldclr|stclr|ldeor|steor)[[:space:]]"; then
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "CRITICAL BUILD ERROR: INCOMPATIBLE INSTRUCTIONS DETECTED"
        echo "The binary '$bin_path' contains LSE atomics (e.g., 'cas', 'ldadd')."
        echo "This WILL crash on Raspberry Pi 3 and Zero 2W."
        echo "Ensure -march=armv8-a is being passed to the compiler."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        # We exit with error 1 to fail the entire Ansible/Pi-Gen build immediately
        exit 1
    else
        echo "PASS: Binary is safe (No LSE atomics detected)."
    fi
}

cd "$SB_DIR"

# Ensure submodules are ready
git submodule update --init --recursive
git config submodule.matrix.ignore all

cd submodules/matrix 

# Clean previous artifacts
make clean

# Build and Install Python bindings
make build-python PYTHON="$VENV_PATH/bin/python3"
make install-python PYTHON="$VENV_PATH/bin/python3"

# Swap custom runtext script
if [ -f "$SB_TOOLS/runtext.py" ]; then
    mv bindings/python/samples/runtext.py bindings/python/samples/runtext.py.ori 2>/dev/null || true
    cp "$SB_TOOLS/runtext.py" bindings/python/samples/
fi

# Build the led-image-viewer utility
cd utils
make clean
make led-image-viewer

# --- RUN VERIFICATION ---
if [ -f "led-image-viewer" ]; then
    verify_binary_compatibility "led-image-viewer"
    
    # Only deploy if verification passed
    cp led-image-viewer "$SB_TOOLS/led-image-viewer"
    chmod +x "$SB_TOOLS/led-image-viewer"
    echo "Successfully built, verified, and deployed led-image-viewer."
else
    echo "Error: led-image-viewer failed to compile."
    exit 1
fi