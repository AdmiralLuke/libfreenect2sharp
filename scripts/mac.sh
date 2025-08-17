#!/bin/bash
# install libfreenect2
# follows https://github.com/OpenKinect/libfreenect2/blob/master/README.md#macos

cd ~ || exit
git clone https://github.com/OpenKinect/libfreenect2.git
cd libfreenect2 || exit

# detect architecture
ARCH=$(uname -m)

echo "Detected architecture: $ARCH"

if [[ "$ARCH" == "arm64" ]]; then
    echo "Using Apple Silicon (arm64) build"
    if [[ -x /opt/homebrew/bin/brew ]]; then
        BREW="arch -arm64 /opt/homebrew/bin/brew"
    else
        echo "Error: Apple Silicon Homebrew not found at /opt/homebrew/bin/brew"
        exit 1
    fi
    CMAKE_ARCH="arm64"
else
    echo "Using Intel (x86_64) build"
    if [[ -x /usr/local/bin/brew ]]; then
        BREW="arch -x86_64 /usr/local/bin/brew"
    else
        echo "Error: Intel Homebrew not found at /usr/local/bin/brew"
        exit 1
    fi
    CMAKE_ARCH="x86_64"
fi
echo "Brew command: $BREW"
# install build tools
$BREW update
$BREW install libusb
$BREW install glfw3

# build
mkdir -p build
cd build || exit
cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_OSX_ARCHITECTURES=$CMAKE_ARCH
# make -j$(sysctl -n hw.ncpu) compile in parallel
make install
