# install libfreenect2
# follows https://github.com/OpenKinect/libfreenect2/blob/master/README.md#macos

cd ~ || exit
git clone https://github.com/OpenKinect/libfreenect2.git
cd libfreenect2 || exit

## install build tools
brew update
brew install libusb
brew install glfw3

## build 
mkdir build
cd build || exit
cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make
make install 