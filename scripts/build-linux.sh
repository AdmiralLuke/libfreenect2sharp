#!/bin/bash
echo "=== Building libfreenect2sharp for Linux ==="
echo
echo "This script will build the C# wrapper library and compile the native shared library."
echo

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
$COMPILER -shared -fPIC -o libfreenect2_w.so wrapper/libfreenect2_w_standalone.c

if [ $? -eq 0 ]; then
    echo "Successfully built libfreenect2_w.so"
else
    echo "Build failed with $COMPILER"
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
echo "Copying native library to output directories..."
mkdir -p bin/Release/net9.0
mkdir -p test/bin/Release/net9.0
mkdir -p wrapper

cp libfreenect2_w.so bin/Release/net9.0/
cp libfreenect2_w.so test/bin/Release/net9.0/
cp libfreenect2_w.so wrapper/

echo "Native library copied to output directories"

# Run integration tests
echo
echo "Running integration tests..."
dotnet run --project test/TestProject.csproj -c Release

if [ $? -eq 0 ]; then
    echo
    echo "BUILD SUCCESSFUL!"
    echo
    echo "libfreenect2sharp is ready to use:"
    echo "- C# library: bin/Release/net9.0/libfreenect2sharp.dll"
    echo "- Native library: bin/Release/net9.0/libfreenect2_w.so"
    echo
    echo "You can now reference libfreenect2sharp.dll in your projects."
    echo "Make sure to include libfreenect2_w.so in your application directory."
    echo
else
    echo "Integration tests failed"
    exit 1
fi

echo "Build completed successfully!"
