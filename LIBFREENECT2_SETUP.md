# Libfreenect2 Native Libraries Setup

This document explains how to set up the actual libfreenect2 native libraries that are required for this wrapper to function properly.

## Overview

The `libfreenect2sharp` wrapper provides the C# interface, but it still requires the original `libfreenect2` native libraries to communicate with the Kinect v2 hardware. These libraries are **not included** in the NuGet package due to licensing and size constraints.

## Required Native Libraries

### Windows
- `freenect2.dll` - Main libfreenect2 library
- `glfw.dll` - Graphics library (if using OpenGL pipeline)
- `turbojpeg.dll` - JPEG decompression library
- `libusb-1.0.dll` - USB communication library

### Linux
- `libfreenect2.so` - Main libfreenect2 library
- `libglfw.so.3` - Graphics library (if using OpenGL pipeline)  
- `libturbojpeg.so` - JPEG decompression library
- `libusb-1.0.so` - USB communication library

### macOS
- `libfreenect2.dylib` - Main libfreenect2 library
- `libglfw.3.dylib` - Graphics library (if using OpenGL pipeline)
- `libturbojpeg.dylib` - JPEG decompression library
- `libusb-1.0.dylib` - USB communication library

## Installation Methods

### Method 1: Build from Source (Recommended)

1. **Clone the original libfreenect2 repository:**
   ```bash
   git clone https://github.com/OpenKinect/libfreenect2.git
   cd libfreenect2
   ```

2. **Install dependencies:**
   - **Ubuntu/Debian:** Run `./scripts/ubuntu.sh`
   - **macOS:** Run `./scripts/mac.sh`
   - **Windows:** Run `./scripts/windows.bat`

3. **Build libfreenect2:**
   ```bash
   mkdir build
   cd build
   cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
   make -j$(nproc)
   sudo make install
   ```

4. **Copy libraries to your project:**
   ```bash
   # Linux
   cp /usr/local/lib/libfreenect2.so* /path/to/your/project/
   
   # Windows
   copy "C:\Program Files\libfreenect2\bin\*.dll" "C:\path\to\your\project\"
   
   # macOS
   cp /usr/local/lib/libfreenect2.dylib /path/to/your/project/
   ```

### Method 2: Package Managers

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get install libfreenect2-dev
```

#### macOS (Homebrew)
```bash
brew install libfreenect2
```

#### Windows (vcpkg)
```cmd
vcpkg install libfreenect2
```

### Method 3: Download Pre-built Releases

1. Go to [libfreenect2 releases](https://github.com/OpenKinect/libfreenect2/releases)
2. Download the appropriate build for your platform
3. Extract the native libraries to your application directory

## Deployment Strategies

### Option 1: Application Directory
Place the native libraries in the same directory as your executable:
```
YourApp/
├── YourApp.exe
├── libfreenect2sharp.dll
├── freenect2.dll           # The actual libfreenect2 library
├── libusb-1.0.dll
└── turbojpeg.dll
```

### Option 2: System Installation
Install libfreenect2 system-wide so it's available to all applications:
```bash
# Linux/macOS
sudo make install

# Windows (add to PATH or place in System32)
```

### Option 3: Runtime Subdirectories
Organize by platform (useful for cross-platform deployment):
```
YourApp/
├── YourApp.exe
├── libfreenect2sharp.dll
├── runtimes/
│   ├── win-x64/native/
│   │   ├── freenect2.dll
│   │   └── libusb-1.0.dll
│   ├── linux-x64/native/
│   │   ├── libfreenect2.so
│   │   └── libusb-1.0.so
│   └── osx-x64/native/
│       ├── libfreenect2.dylib
│       └── libusb-1.0.dylib
```

## Troubleshooting

### Library Not Found Errors
If you get `DllNotFoundException` or similar errors:

1. **Verify library location:** Ensure native libraries are in the correct directory
2. **Check dependencies:** Use dependency walker tools:
   - Windows: `dumpbin /dependents freenect2.dll`
   - Linux: `ldd libfreenect2.so`
   - macOS: `otool -L libfreenect2.dylib`

3. **Update library search paths:**
   ```csharp
   // Add this before using libfreenect2sharp
   Environment.SetEnvironmentVariable("PATH", 
       Environment.GetEnvironmentVariable("PATH") + ";" + @"C:\path\to\your\libs");
   ```

### Version Compatibility
- Ensure libfreenect2 version compatibility
- libfreenect2sharp is tested with libfreenect2 v0.2.0+
- Check release notes for breaking changes

### Permissions
- **Linux:** Ensure udev rules are set up for Kinect access
- **Windows:** Install Kinect drivers
- **macOS:** Grant camera permissions in System Preferences

## Alternative: Mock Implementation

For development/testing without hardware, you can use the standalone implementation that doesn't require libfreenect2:

```csharp
// This will work without actual libfreenect2 libraries
// but returns mock data
var freenect = Freenect.CreateFreenect();
var deviceCount = freenect.GetDeviceCount(); // Returns 0
```

The wrapper automatically falls back to the standalone implementation if libfreenect2 libraries are not found.

## CI/CD Integration

For automated builds, the CI scripts in `./scripts/` handle libfreenect2 installation:
- `ubuntu.sh` - Installs dependencies and builds libfreenect2 on Linux
- `mac.sh` - Installs via Homebrew on macOS  
- `windows.bat` - Installs via vcpkg on Windows

These scripts ensure the build environment has the required native libraries.
