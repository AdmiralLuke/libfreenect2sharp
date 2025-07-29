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
$COMPILER -shared -fPIC -o libfreenect2_w.dylib wrapper/libfreenect2_w_standalone.c

if [ $? -eq 0 ]; then
    echo "Successfully built libfreenect2_w.dylib"
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

cp libfreenect2_w.dylib bin/Release/net9.0/
cp libfreenect2_w.dylib test/bin/Release/net9.0/
cp libfreenect2_w.dylib wrapper/

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
    echo "- Native library: bin/Release/net9.0/libfreenect2_w.dylib"
    echo
    echo "You can now reference libfreenect2sharp.dll in your projects."
    echo "Make sure to include libfreenect2_w.dylib in your application directory."
    echo
else
    echo "Integration tests failed"
    exit 1
fi

echo "Build completed successfully!"
