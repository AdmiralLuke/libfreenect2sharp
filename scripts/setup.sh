#!/bin/bash
# Setup script to make all build scripts executable

echo "Setting up libfreenect2sharp build scripts..."

# Make all shell scripts executable
chmod +x scripts/*.sh

echo "✓ Made all .sh scripts executable"

# List the available build scripts
echo
echo "Available build scripts:"
echo "- scripts/build-linux.sh   - Complete Linux build"
echo "- scripts/build-mac.sh     - Complete macOS build"  
echo "- scripts/build-windows.bat - Complete Windows build"
echo
echo "Test scripts (for external dependency testing):"
echo "- scripts/test-linux.sh"
echo "- scripts/test-mac.sh"
echo "- scripts/test-windows.bat"
echo
echo "Usage examples:"
echo "  ./scripts/build-linux.sh    # Build everything on Linux"
echo "  ./scripts/build-mac.sh      # Build everything on macOS"
echo "  scripts\\build-windows.bat   # Build everything on Windows"
echo
echo "Setup completed!"
