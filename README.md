[![.github/workflows/ci.yml](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AdmiralLuke/libfreenect2sharp/actions/workflows/ci.yml)

# Libfreenect2Sharp

An actual (hopefully) working C# Wrapper for the libfreenect2 library.
It's necessary to build KinectV2-Applications. For KinectV1 see the official [C#-Wrapper](https://github.com/OpenKinect/libfreenect/tree/master/wrappers/csharp)

## Install Dependencies

1. Clone the original [libfreenect2](https://github.com/OpenKinect/libfreenect2)
2. Build with the following commands

```sh
mkdir build
cd build
cmake ..
make -j$(nproc)
```

or use one of the pre-created scripts in ``./scripts/`` (for Ubuntu, MacOs or Windows).

## Build ``.so`` from Wrapper-Class

Since we need the export

```sh
g++ -fPIC -shared freenect2_wrapper.cpp -o libfreenect2_w.so \
  -I ~/libfreenect2/include \
  -I ~/libfreenect2/build \
  -L ~/libfreenect2/build/lib \
  -lfreenect2
```
