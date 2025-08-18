[![.github/workflows/ci.yml](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml)

# Libfreenect2Sharp

An actual (hopefully) working C# Wrapper for the libfreenect2 library.
It's necessary to build KinectV2-Applications. For KinectV1 see the official [C#-Wrapper](https://github.com/OpenKinect/libfreenect/tree/master/wrappers/csharp)

## Quick Start & Usage

### 0. Clone this Project

```sh
git clone https://www.github.com/admiralluke/libfreenect2sharp/
cd libfreenect2sharp
```

### 1. Install libfreenect2

**Automatic Installation Scripts**

- Ubuntu
```sh
chmod +x ./scripts/ubuntu.sh
./scripts/ubuntu.sh
```
- Windows & MacOS: see ``./scripts/windows.bat`` or ``./scripts/mac.sh`` (Experimental)

:wrench: **Manual Installation or other Linux versions** see the [official Repo](https://github.com/OpenKinect/libfreenect2/)



### 2. Build the Project

**Linux:**

```sh 
chmod +x ./scripts/build-linux.sh
./scripts/build-linux.sh
```

**Windows:**

```sh
./scripts/build-windows.bat
```

:exclamation: **Windows** and **MacOS** are rather untested yet and experimental!

This should generate (when success) the following:
- in ``./nupkg/`` a ``libfreenect2sharp.1.0.4.nupkg`` and ``libfreenect2sharp.1.0.4.snupkg`` (see Releases (TODO))
- in the current main folder a ``libfreenect2_w.so`` and three linked files (copied from ~/libfreenect2)
```sh 
libfreenect2.so
libfreenect2.so.0.2
libfreenect2.so.0.2.0
```

:exclamation: On Windows and MacOS the naming or generation can be different.

### 4. Usage

- Setup a C#-Project (recommended: .NET 9.0)
    - if you need a lower version, change the ``<TargetVersion>net9.0<\TargetFramework>`` in ``libfreenect2sharp.csproj`` to your specific version (this is also untested, but it'll work on net8.0) 
- Build it a first time, so the project can generate all necessary files
- create a folder e.g. ``mkdir ./Native/`` and copy ``libfreenect2sharp.1.0.0.nupkg`` into it
- add the local nuget package

```sh
dotnet add package libfreenect2sharp --version 1.0.4 --source ./Native
```

:question: If the build of the project failes with an DLLNotFoundException, try to add the following .so files to ``./bin/Debug/netX.Y/`` or (if not available) to the same folder as the ``.nupkg`` file: 
```sh
libfreenect2_w.so
libfreenect2.so
libfreenect2.so.0.2
libfreenect2.so.0.2.0
```

- Enjoy :)

## Usage Example

```csharp
using libfreenect2sharp;

// Create Freenect instance
Freenect freenect = Freenect.CreateFreenect();

// Get number of connected devices
int deviceCount = freenect.GetDeviceCount();
Console.WriteLine($"Found {deviceCount} Kinect devices");

Kinect kinect = freenect.GetKinect();

// Get Frames
void SubscribeAndLogFrames(Kinect kinect)
{
    kinect.OnColorFrame((type, frame) =>
    {
        Console.WriteLine($"[Color] {type}: {frame.Width}x{frame.Height}, Timestamp={frame.Timestamp}");
    });

    kinect.OnIrAndDepthFrame((type, frame) =>
    {
        Console.WriteLine($"[IR/Depth] {type}: {frame.Width}x{frame.Height}, Exposure={frame.Exposure}, Timestamp={frame.Timestamp}");
    });
}

SubscribeAndLogFrames(kinect);

while (true)
{
    Thread.Sleep(100); 
}
// [...]
// [IR/Depth] Ir: 512x424, Exposure=0, Timestamp=8653032
// [IR/Depth] Depth: 512x424, Exposure=0, Timestamp=8653032
// [Color] Color: 1920x1080, Timestamp=8653212
// [...]
```

## Trouble Shooting

### Permission Denied

If this error occurs, you might not have the permission to access the USB-device. For **Linux**:

1. Create the file ``/etc/udev/rules.d/99-usb.rules``
2. Place the following rules into the file:

```sh
# ATTR{product}=="Xbox NUI Motor"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02d8", MODE="0666"
# ATTR{product}=="Xbox NUI Audio"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02d9", MODE="0666"
# ATTR{product}=="Xbox NUI Camera"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02d9", MODE="0666"
```

3. Reload the udev-rules:

```sh
sudo udevadm control --reload-rules
sudo udevadm trigger
```
