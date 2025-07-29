[![.github/workflows/ci.yml](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml)

# Libfreenect2Sharp

An actual (hopefully) working C# Wrapper for the libfreenect2 library.
It's necessary to build KinectV2-Applications. For KinectV1 see the official [C#-Wrapper](https://github.com/OpenKinect/libfreenect/tree/master/wrappers/csharp)

## Quick Start

### Using NuGet Package (Recommended)

Install the NuGet package:
```sh
dotnet add package libfreenect2sharp
```

Or via Package Manager:
```
Install-Package libfreenect2sharp
```


### Using Pre-built Releases
1. Download the latest release from [GitHub Releases](https://github.com/AdmiralLuke/libfreenect2sharp/releases)
2. Extract the platform-specific build (linux-x64, win-x64, or osx-x64)
3. Reference `libfreenect2sharp.dll` in your C# project
4. The native libraries are automatically included

### Building from Source

Use the platform-specific build scripts:

**Windows:**
```cmd
scripts\build-windows.bat
```

**Linux:**
```sh
chmod +x scripts/build-linux.sh
./scripts/build-linux.sh
```

**macOS:**
```sh
chmod +x scripts/build-mac.sh
./scripts/build-mac.sh
```

Each script will:
- Compile the native library (`libfreenect2_w`)
- Build the C# wrapper
- Create a NuGet package in the `nupkg/` directory

## Project Structure

```
libfreenect2sharp/
├── *.cs                    # C# wrapper classes
├── wrapper/                # C++ wrapper for P/Invoke
├── runtimes/              # Native libraries organized by platform
│   ├── linux-x64/native/
│   ├── win-x64/native/
│   └── osx-x64/native/
├── scripts/               # Build scripts for each platform
├── nupkg/                 # Generated NuGet packages
└── .github/workflows/     # CI/CD Pipeline
```

## CI/CD

The project uses GitHub Actions to:
- Build on Linux, Windows, and macOS
- Create platform-specific releases
- Generate NuGet packages automatically

## Usage Example

```csharp
using libfreenect2sharp;

// Create Freenect instance
Freenect freenect = Freenect.CreateFreenect();

// Get number of connected devices
int deviceCount = freenect.GetDeviceCount();
Console.WriteLine($"Found {deviceCount} Kinect devices");
```

## Native Libraries

This wrapper requires the original libfreenect2 native libraries to function. The NuGet package includes only the C# wrapper - you need to install libfreenect2 separately.
