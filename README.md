[![.github/workflows/ci.yml](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml)

# Libfreenect2Sharp

An actual (hopefully) working C# Wrapper for the libfreenect2 library.
It's necessary to build KinectV2-Applications. For KinectV1 see the official [C#-Wrapper](https://github.com/OpenKinect/libfreenect/tree/master/wrappers/csharp)

## Quick Start & Usage

### 1. Install libfreenect2

*Automatic Installation Scripts*

- Ubuntu
```sh
chmod +x ./scripts/ubuntu.sh
./scripts/ubuntu.sh
```
- Windows & MacOS: see ``./scripts/windows.bat`` or ``./scripts/mac.sh`` (Experimental)

*Manual Installation* see the [official Repo](https://github.com/OpenKinect/libfreenect2/)

### 2. Clone this Project

```sh
git clone https://www.github.com/admiralluke/libfreenect2sharp/
cd libfreenect2sharp
```

### 3. Build the Project

*Linux:*

```sh 
chmod +x ./scripts/build-linux.sh
./scripts/build-linux.sh
```

*Windows* and *MacOS* are untested yet and experimental!

This should generate (when success) the following:
- in ``./nupkg/`` a ``libfreenect2sharp.1.0.0.nupkg`` and ``libfreenect2sharp.1.0.0.snupkg`` (see Releases (TODO))
- in the current main folder a ``libfreenect2_w.so`` and three linked files (copied from ~/libfreenect2)
```sh 
libfreenect2.so
libfreenect2.so.0.2
libfreenect2.so.0.2.0
```

### 4. Usage

- Setup a C#-Project (recommended: .NET 9.0)
- Build it a first time, so the project can generate all necessary files
- create a folder e.g. ``mkdir ./Native/`` and copy ``libfreenect2sharp.1.0.0.nupkg`` into it
- add the local nuget package
- 
```sh
dotnet add package libfreenect2sharp --version 1.0.4 --source ./Native
```


- copy the following files from the main folder of the libfreenect2sharp project into ``./bin/Debug/netX.Y/`` :
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

