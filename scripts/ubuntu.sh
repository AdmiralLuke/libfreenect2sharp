# install libfreenect2
# follows https://github.com/OpenKinect/libfreenect2/blob/master/README.md#linux
cd ~
git clone https://github.com/OpenKinect/libfreenect2.git
cd libfreenect2

## install build tools
sudo apt-get install build-essential cmake pkg-config

## install libusb (Ubuntu > 14.04)
sudo apt-get install libusb-1.0-0-dev

## install TurboJPEG
sudo apt-get install libturbojpeg0-dev

## Install OpenGL
sudo apt-get install libglfw3-dev

## build
mkdir build
cd build
cmake ..
make -j$(nproc)