# libfreenect2sharp

## Generate ``.so`` - Static Lib

1. Clone the original [libfreenect2](https://github.com/OpenKinect/libfreenect2)
2. Build with the following commands

```sh
mkdir build
cd build
cmake ..
make -j$(nproc)
```

## Build ``.so`` from Wrapper-Class

Since we need the export

```sh
g++ -fPIC -shared freenect2_wrapper.cpp -o libfreenect2_w.so \
  -I ~/libfreenect2/include \
  -I ~/libfreenect2/build \
  -L ~/libfreenect2/build/lib \
  -lfreenect2
```
