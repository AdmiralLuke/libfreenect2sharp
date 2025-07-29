[![.github/workflows/ci.yml](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml)

# Libfreenect2Sharp

An actual (hopefully) working C# Wrapper for the libfreenect2 library.
It's necessary to build KinectV2-Applications. For KinectV1 see the official [C#-Wrapper](https://github.com/OpenKinect/libfreenect/tree/master/wrappers/csharp)

## Quick Start

### Using Pre-built Releases
1. Download the latest release from [GitHub Releases](https://github.com/AdmiralLuke/libfreenect2sharp/releases)
2. Extract the platform-specific build (linux-x64, win-x64, or osx-x64)
3. Reference `libfreenect2sharp.dll` in your C# project
4. The native libraries are automatically included

### Building from Source

## Install Dependencies

1. Clone the original [libfreenect2](https://github.com/OpenKinect/libfreenect2)
2. Build with the following commands

```sh
mkdir build
cd build
cmake ..
make -j$(nproc)
```

or use one of the pre-created scripts in `./scripts/` (for Ubuntu, MacOs or Windows).

## Build `.so/.dll` from Wrapper-Class

Since we need the export symbols for P/Invoke:

**Linux/macOS:**
```sh
g++ -fPIC -shared wrapper/freenect2_wrapper.cpp -o wrapper/libfreenect2_w.so \
  -I ~/libfreenect2/include \
  -I ~/libfreenect2/build \
  -L ~/libfreenect2/build/lib \
  -lfreenect2
```

**Windows:**
```cmd
cl /LD wrapper/freenect2_wrapper.cpp /Fe:wrapper/libfreenect2_w.dll ^
  /I"%USERPROFILE%\libfreenect2\include" ^
  /I"%USERPROFILE%\libfreenect2\build" ^
  /LIBPATH:"%USERPROFILE%\libfreenect2\build\lib" ^
  freenect2.lib
```

## Build the C# Library

```sh
dotnet build --configuration Release
```

## Testing

The project includes integration tests that verify the library works correctly as an external dependency:

```sh
# Linux/macOS
chmod +x scripts/test-linux.sh    # or test-mac.sh
./scripts/test-linux.sh

# Windows  
scripts/test-windows.bat
```

The test scripts automatically:
- Build the main library
- Search for and copy libfreenect2 native libraries from system paths
- Build the test project as an external consumer
- Run comprehensive integration tests

## Project Structure

```
libfreenect2sharp/
├── *.cs                    # C# wrapper classes
├── wrapper/                # C++ wrapper for P/Invoke
├── runtimes/              # Native libraries organized by platform
│   ├── linux-x64/native/
│   ├── win-x64/native/
│   └── osx-x64/native/
├── test/                  # Integration tests (external simulation)
├── scripts/               # Build and test scripts for each platform
└── .github/workflows/     # CI/CD Pipeline
```

## CI/CD

The project uses GitHub Actions to:
- Build on Linux, Windows, and macOS
- Run integration tests on all platforms  
- Create releases with platform-specific builds
- Generate NuGet packages

## Usage Example

```csharp
using libfreenect2sharp;

// Create Freenect instance
Freenect freenect = Freenect.CreateFreenect();

// Get number of connected devices
int deviceCount = freenect.GetDeviceCount();
Console.WriteLine($"Found {deviceCount} Kinect devices");
```
