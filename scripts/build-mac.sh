#!/bin/bash
echo "=== Building libfreenect2sharp for macOS ==="
echo
echo "This script will build the C# wrapper library and compile the native dynamic library."
echo

# Check for available C++ compilers
echo "Checking for available C++ compilers..."

# Check for Clang (default on macOS)
if command -v clang &> /dev/null; then
    echo "Found Clang compiler"
    COMPILER="clang"
elif command -v gcc &> /dev/null; then
    echo "Found GCC compiler"
    COMPILER="gcc"
else
    echo
    echo "No C++ compiler found!"
    echo
    echo "To build libfreenect2sharp, you need Xcode Command Line Tools:"
    echo
    echo "Install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    echo
    echo "Or install via Homebrew:"
    echo "  brew install gcc"
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
    echo "To install .NET SDK on macOS:"
    echo
    echo "Using Homebrew (recommended):"
    echo "  brew install --cask dotnet"
    echo
    echo "Or download from:"
    echo "  https://dotnet.microsoft.com/download"
    echo
    exit 1
fi

echo "Found .NET SDK"

# Build native library
echo
echo "Building native library with $COMPILER..."

# Get the absolute path to the project root
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# Path to the wrapper source file
WRAPPER_SRC="$PROJECT_ROOT/wrapper/freenect2_wrapper.cpp"
WRAPPERLIB_SRC="$PROJECT_ROOT/wrapper/libfreenect2_wrapper.dylib"

if [ ! -f "$WRAPPER_SRC" ]; then
    echo "Error: Could not find wrapper source at $WRAPPER_SRC"
    exit 1
fi

#$COMPILER -shared -fPIC -o "$WRAPPERLIB_SRC" "$WRAPPER_SRC"

# For some reason only clang++ works $COMPILER finds clang and it doesnt work
clang++ -std=c++11 -shared -fPIC \
    -I/usr/local/include \
    -L/usr/local/lib -lfreenect2 \
    -o "$WRAPPERLIB_SRC" "$WRAPPER_SRC"
    
if [ $? -eq 0 ]; then
    echo "Successfully built libfreenect2_w.dylib"
else
    echo "Build failed with $COMPILER"
    exit 1
fi

# Build C# wrapper library
echo
echo "Building C# wrapper library..."
#dotnet build --configuration Release
dotnet build "$PROJECT_ROOT/libfreenect2sharp.csproj" --configuration Release

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
mkdir -p wrapper

cp libfreenect2_w.dylib bin/Release/net9.0/
cp libfreenect2_w.dylib wrapper/

echo "Native library copied to output directories"

# Create NuGet package
echo
echo "Creating NuGet package..."
dotnet pack "$PROJECT_ROOT/libfreenect2sharp.csproj" --configuration Release --output ./nupkg

if [ $? -eq 0 ]; then
    echo
    echo "BUILD SUCCESSFUL!"
    echo
    echo "libfreenect2sharp is ready:"
    echo "- C# library: bin/Release/net9.0/libfreenect2sharp.dll"
    echo "- Native library: bin/Release/net9.0/libfreenect2_w.dylib"
    echo "- NuGet package: nupkg/libfreenect2sharp.*.nupkg"
    echo
    echo "You can install the NuGet package or reference the DLL directly."
else
    echo "NuGet package creation failed"
    exit 1
fi

echo "Build completed successfully!"
