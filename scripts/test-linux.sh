#!/bin/bash
# Test script for Linux - Tests the built library as external dependency

echo "Running libfreenect2sharp integration tests on Linux..."

# First, ensure the main library is built
echo "Building main library..."
dotnet build --configuration Release

if [ $? -ne 0 ]; then
    echo "Main library build failed!"
    exit 1
fi

# Copy libfreenect2 native libraries to bin directory
echo "Copying libfreenect2 native libraries..."
LIBFREENECT2_PATHS=(
    "/usr/local/lib"
    "/usr/lib/x86_64-linux-gnu" 
    "/usr/lib"
    "$HOME/libfreenect2/lib"
    "./libfreenect2/lib"
)

BIN_DIR="bin/Release/net9.0"
mkdir -p "$BIN_DIR"

for path in "${LIBFREENECT2_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "Checking $path for libfreenect2 libraries..."
        # Copy all libfreenect2 related files
        find "$path" -name "libfreenect2*" -type f \( -name "*.so*" \) -exec cp {} "$BIN_DIR/" \; 2>/dev/null && echo "  Found and copied libfreenect2 libraries from $path"
    fi
done

# Also copy any existing libraries from the build
if [ -f "wrapper/libfreenect2_w.so" ]; then
    cp wrapper/libfreenect2_w.so "$BIN_DIR/"
    echo "Copied wrapper library"
fi

echo "Contents of $BIN_DIR:"
ls -la "$BIN_DIR/"*.so* 2>/dev/null || echo "No .so files found"

# Now test as external consumer
cd test
echo "Building test project (as external consumer)..."
dotnet build --configuration Release

if [ $? -ne 0 ]; then
    echo "Test project build failed!"
    exit 1
fi

echo "Running integration tests..."
dotnet run --configuration Release

if [ $? -eq 0 ]; then
    echo "Integration tests passed successfully!"
    exit 0
else
    echo "Integration tests failed!"
    exit 1
fi
