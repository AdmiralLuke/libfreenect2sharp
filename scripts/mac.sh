# install libfreenect2
# follows https://github.com/OpenKinect/libfreenect2/blob/master/README.md#macos

cd ~
git clone https://github.com/OpenKinect/libfreenect2.git
cd libfreenect2

## install build tools
brew update
brew install libusb
brew install glfw3

## build 
mkdir build
cd build
cmake ..
make