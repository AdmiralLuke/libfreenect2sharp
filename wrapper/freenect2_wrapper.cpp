#include <libfreenect2/libfreenect2.hpp>
#include <libfreenect2/frame_listener_impl.h>
#include <libfreenect2/registration.h>
#include <libfreenect2/packet_pipeline.h>
#include <libfreenect2/logger.h>
#include <cstring>

extern "C" {
    libfreenect2::Freenect2* createFreenect2() {
        return new libfreenect2::Freenect2();
    }

    void deleteFreenect2(libfreenect2::Freenect2* ptr) {
        delete ptr;
    }

    int getDeviceCount(libfreenect2::Freenect2* ptr) {
        return ptr->enumerateDevices();
    }
    
    libfreenect2::Freenect2Device* openDevice(libfreenect2::Freenect2* ctx, int idx) {
        return ctx->openDevice(idx);
    }
    

    bool startDevice(libfreenect2::Freenect2Device* device) {
        return device->start();
    }

    bool stopDevice(libfreenect2::Freenect2Device* device) {
        return device->stop();
    }

    bool closeDevice(libfreenect2::Freenect2Device* device) {
        return device->close();
    }
    
    
}

extern "C" const char* getFirmwareVersion(libfreenect2::Freenect2Device* device) {
    std::string version = device->getFirmwareVersion();
    char* result = new char[version.size() + 1];
    std::strcpy(result, version.c_str());
    return result;
}

extern "C" void freeString(const char* str) {
    delete[] str;
}

extern "C" {

    struct IrCameraParamsInterop
    {
        float fx, fy, cx, cy;
        float k1, k2, k3, p1, p2;
    };

    IrCameraParamsInterop getIrCameraParams(libfreenect2::Freenect2Device* device)
    {
        libfreenect2::Freenect2Device::IrCameraParams params = device->getIrCameraParams();
        IrCameraParamsInterop result;
        result.fx = params.fx;
        result.fy = params.fy;
        result.cx = params.cx;
        result.cy = params.cy;
        result.k1 = params.k1;
        result.k2 = params.k2;
        result.k3 = params.k3;
        result.p1 = params.p1;
        result.p2 = params.p2;
        return result;
    }
}

