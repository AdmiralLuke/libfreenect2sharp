#!/bin/bash
echo "=== Building libfreenect2sharp for Linux ==="
echo
echo "This script will build the C# wrapper library and compile the native shared library."
echo

find . -type f -name "libfreenect2_w.so" -exec rm -v {} \;


# Check for available C++ compilers
echo "Checking for available C++ compilers..."

# Check for GCC
if command -v gcc &> /dev/null; then
    echo "Found GCC compiler"
    COMPILER="gcc"
elif command -v clang &> /dev/null; then
    echo "Found Clang compiler" 
    COMPILER="clang"
else
    echo
    echo "No C++ compiler found!"
    echo
    echo "To build libfreenect2sharp, you need a C++ compiler:"
    echo
    echo "For Ubuntu/Debian:"
    echo "  sudo apt-get install build-essential"
    echo
    echo "For CentOS/RHEL/Fedora:"
    echo "  sudo yum install gcc gcc-c++"
    echo "  # or for newer versions:"
    echo "  sudo dnf install gcc gcc-c++"
    echo
    echo "For Arch Linux:"
    echo "  sudo pacman -S base-devel"
    echo
    echo "After installing a compiler, run this script again."
    echo
    exit 1
fi

# Check for .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo
    echo ".NET SDK not found!"
    echo
    echo "To install .NET SDK:"
    echo
    echo "For Ubuntu/Debian:"
    echo "  wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
    echo "  sudo dpkg -i packages-microsoft-prod.deb"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y dotnet-sdk-9.0"
    echo
    echo "For other distributions, see: https://docs.microsoft.com/en-us/dotnet/core/install/linux"
    echo
    exit 1
fi

echo "Found .NET SDK"

# Build native library
echo
echo "Building native library with $COMPILER..."

# Check for local libfreenect2 build
if [ -f ~/libfreenect2/build/lib/libfreenect2.so ] && [ -d ~/libfreenect2/include ]; then
    echo "Using local libfreenect2 build..."
    # First, try to create a symlink to the correct version name
    cd ~/libfreenect2/build/lib
    if [ ! -f libfreenect2.so.0.2 ] && [ -f libfreenect2.so.0.2.0 ]; then
        ln -sf libfreenect2.so.0.2.0 libfreenect2.so.0.2
    fi
    cd - > /dev/null
    
    $COMPILER -shared -fPIC -o libfreenect2_w.so wrapper/freenect2_wrapper.cpp \
      -I ~/libfreenect2/include \
      -I ~/libfreenect2/build \
      -L ~/libfreenect2/build/lib \
      -lfreenect2 \
      -Wl,-rpath,'$ORIGIN' \
      -Wl,-rpath-link,~/libfreenect2/build/lib
else
    echo "❌ libfreenect2 not found!"
    echo
    echo "libfreenect2 needs to be built from source:"
    echo
    echo "1. Clone and build libfreenect2:"
    echo "   git clone https://github.com/OpenKinect/libfreenect2.git ~/libfreenect2"
    echo "   cd ~/libfreenect2"
    echo "   mkdir build && cd build"
    echo "   cmake .."
    echo "   make -j\$(nproc)"
    echo
    echo "2. Or run the ubuntu setup script first:"
    echo "   chmod +x scripts/ubuntu.sh"
    echo "   ./scripts/ubuntu.sh"
    echo
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "Successfully built libfreenect2_w.so"
else
    echo "Build failed with $COMPILER"
    echo "Note: This requires libfreenect2 to be built from source"
    echo "See error message above for installation instructions"
    exit 1
fi

# Build C# wrapper library
echo
echo "Building C# wrapper library..."
dotnet build --configuration Release

if [ $? -eq 0 ]; then
    echo "Successfully built C# library"
else
    echo "C# build failed"
    exit 1
fi

# Copy native library to output directories
echo
echo "Copying native libraries to output directories..."
mkdir -p bin/Release/net9.0
mkdir -p wrapper
mkdir -p runtimes/linux-x64/native

# Copy our wrapper library
cp -f libfreenect2_w.so bin/Release/net9.0/
cp -f libfreenect2_w.so wrapper/
cp -f libfreenect2_w.so runtimes/linux-x64/native/
rm -f nupkg/libfreenect2sharp.*.nupkg

# Copy libfreenect2 dependencies first to current directory for testing
if [ -f ~/libfreenect2/build/lib/libfreenect2.so ]; then
    echo "Copying libfreenect2 dependencies to current directory..."
    cp ~/libfreenect2/build/lib/libfreenect2.so* ./
    
    # Create missing symlink in current directory
    if [ ! -f libfreenect2.so.0.2 ] && [ -f libfreenect2.so.0.2.0 ]; then
        ln -sf libfreenect2.so.0.2.0 libfreenect2.so.0.2
    fi
    
    echo "Testing libfreenect2_w.so dependencies..."
    ldd libfreenect2_w.so
fi

# Copy libfreenect2 dependencies if they exist
if [ -f ~/libfreenect2/build/lib/libfreenect2.so ]; then
    echo "Copying libfreenect2 dependencies..."
    cp ~/libfreenect2/build/lib/libfreenect2.so* bin/Release/net9.0/
    cp ~/libfreenect2/build/lib/libfreenect2.so* runtimes/linux-x64/native/
    
    # Create missing symlinks in target directories
    cd bin/Release/net9.0/
    if [ ! -f libfreenect2.so.0.2 ] && [ -f libfreenect2.so.0.2.0 ]; then
        ln -sf libfreenect2.so.0.2.0 libfreenect2.so.0.2
    fi
    cd ../../../
    
    cd runtimes/linux-x64/native/
    if [ ! -f libfreenect2.so.0.2 ] && [ -f libfreenect2.so.0.2.0 ]; then
        ln -sf libfreenect2.so.0.2.0 libfreenect2.so.0.2
    fi
    cd ../../../
    
    echo "libfreenect2 dependencies and symlinks copied"
fi

echo "Native libraries copied to output directories"

# Create NuGet package
echo
echo "Creating NuGet package..."
dotnet pack --configuration Release --output ./nupkg

if [ $? -eq 0 ]; then
    echo
    echo "BUILD SUCCESSFUL!"
    echo
    echo "libfreenect2sharp is ready:"
    echo "- C# library: bin/Release/net9.0/libfreenect2sharp.dll"
    echo "- Native library: bin/Release/net9.0/libfreenect2_w.so"
    echo "- NuGet package: nupkg/libfreenect2sharp.*.nupkg"
    echo
    echo "You can install the NuGet package or reference the DLL directly."
else
    echo "NuGet package creation failed"
    exit 1
fi

echo
echo "Build completed successfully!"
