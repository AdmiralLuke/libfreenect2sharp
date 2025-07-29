# libfreenect2sharp - Building and Installation Guide

This guide shows you how to build and use libfreenect2sharp on different platforms.

## Quick Start

### One-Command Build
```bash
# Linux
./scripts/build-linux.sh

# macOS  
./scripts/build-mac.sh

# Windows
scripts\build-windows.bat
```

### First-Time Setup
```bash
# Make scripts executable (Linux/macOS only)
chmod +x scripts/setup.sh
./scripts/setup.sh
```

## Windows

### Prerequisites

You need one of these C++ compilers:

1. **MinGW-w64** (Recommended for simplicity)
   - Download from: https://www.mingw-w64.org/downloads/
   - Or install via MSYS2: `pacman -S mingw-w64-x86_64-gcc`

2. **Visual Studio Build Tools**
   - Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/

3. **LLVM/Clang**
   - Download from: https://releases.llvm.org/download.html

### Building

1. **Automatic Build (Recommended)**
   ```cmd
   scripts\build-windows.bat
   ```
   This script will:
   - Detect your available compiler
   - Build the native library (`libfreenect2_w.dll`)
   - Build the C# wrapper (`libfreenect2sharp.dll`)
   - Run integration tests
   - Copy files to the correct locations

2. **Manual Build**
   ```cmd
   # Build native library
   gcc -shared -o libfreenect2_w.dll wrapper\libfreenect2_w_standalone.c
   
   # Build C# library
   dotnet build --configuration Release
   
   # Copy native library to output
   copy libfreenect2_w.dll bin\Release\net9.0\
   ```

### Testing
```cmd
# Run integration tests
dotnet run --project test\TestProject.csproj -c Release
```

## Linux

### Prerequisites
```bash
# Install dependencies
sudo apt-get install build-essential dotnet-sdk-9.0
```

### Building
```bash
# Run the build script
chmod +x scripts/test-linux.sh
./scripts/test-linux.sh
```

## macOS

### Prerequisites
```bash
# Install dependencies
brew install dotnet-sdk
```

### Building
```bash
# Run the build script
chmod +x scripts/test-mac.sh
./scripts/test-mac.sh
```

## Using the Library

After building, you'll have these files:
- `bin/Release/net9.0/libfreenect2sharp.dll` - The C# wrapper library
- `bin/Release/net9.0/libfreenect2_w.dll` (Windows) - The native library

### In Your Project

1. **Add Reference**
   ```xml
   <Reference Include="libfreenect2sharp">
     <HintPath>path\to\libfreenect2sharp.dll</HintPath>
   </Reference>
   ```

2. **Copy Native Library**
   Make sure `libfreenect2_w.dll` (Windows), `libfreenect2_w.so` (Linux), or `libfreenect2_w.dylib` (macOS) is in the same directory as your executable.

3. **Example Usage**
   ```csharp
   using libfreenect2sharp;
   
   // Create Freenect instance
   Freenect freenect = Freenect.CreateFreenect();
   
   // Get device count
   int deviceCount = freenect.GetDeviceCount();
   Console.WriteLine($"Found {deviceCount} devices");
   
   // If devices are available, get the first one
   if (deviceCount > 0)
   {
       Kinect kinect = freenect.GetKinect(0);
       string firmware = kinect.GetFirmwareVersion();
       Console.WriteLine($"Firmware: {firmware}");
       
       var irParams = kinect.GetIrCameraParams();
       Console.WriteLine($"IR Camera - fx: {irParams.fx}, fy: {irParams.fy}");
   }
   ```

## Continuous Integration (CI)

The project includes GitHub Actions CI that runs on all branches:

### Branch Behavior
- **All branches**: Build and test jobs run on Linux, Windows, and macOS
- **Main branch only**: Release job creates GitHub releases and publishes artifacts

### CI Jobs
1. **build-linux**: Runs on Ubuntu, builds and tests the library
2. **build-windows**: Runs on Windows, builds and tests the library  
3. **build-macos**: Runs on macOS, builds and tests the library
4. **release**: Only on main branch - creates releases and NuGet packages

This means you can safely develop and test on feature branches without triggering releases.

## Architecture

The library consists of:

1. **C# Wrapper** (`Freenect.cs`, `Kinect.cs`)
   - Provides .NET-friendly interface
   - Handles P/Invoke declarations
   - Manages memory and resources

2. **Native Library** (`libfreenect2_w_standalone.c`)
   - Implements the C interface for P/Invoke
   - For testing: Returns sensible defaults without hardware
   - For production: Should link to actual libfreenect2

3. **Integration Tests** (`test/TestLib.cs`)
   - Verifies P/Invoke integration works
   - Tests as external consumer
   - Validates cross-platform compatibility

## Troubleshooting

### "Unable to load DLL" Error
- Make sure the native library is in the same directory as your executable
- Check that you're using the correct architecture (x64/x86)
- Verify the library is built for your platform

### "BadImageFormatException"
- The native library was built for a different architecture
- Rebuild the native library with the correct compiler

### Device Count Returns 0
- This is normal when no Kinect hardware is connected
- The standalone implementation always returns 0 devices
- For actual hardware, use the real libfreenect2 implementation

## Development

To extend the library:

1. Add new functions to `wrapper/libfreenect2_w_standalone.c`
2. Declare them in `Freenect.cs` or `Kinect.cs` using `[DllImport]`
3. Add corresponding C# wrapper methods
4. Update tests in `test/TestLib.cs`
5. Rebuild with `scripts/build-windows.bat`
