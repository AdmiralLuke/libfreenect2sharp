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

extern "C" {
    struct ColorCameraParams
    {
        float fx, fy, cx, cy;
        float shift_d, shift_m;

        float mx_x3y0; // xxx
        float mx_x0y3; // yyy
        float mx_x2y1; // xxy
        float mx_x1y2; // yyx
        float mx_x2y0; // xx
        float mx_x0y2; // yy
        float mx_x1y1; // xy
        float mx_x1y0; // x
        float mx_x0y1; // y
        float mx_x0y0; // 1

        float my_x3y0; // xxx
        float my_x0y3; // yyy
        float my_x2y1; // xxy
        float my_x1y2; // yyx
        float my_x2y0; // xx
        float my_x0y2; // yy
        float my_x1y1; // xy
        float my_x1y0; // x
        float my_x0y1; // y
        float my_x0y0; // 1
    };

    ColorCameraParams getColorCameraParams(libfreenect2::Freenect2Device* device)
    {
        libfreenect2::Freenect2Device::ColorCameraParams params = device->getColorCameraParams();
        ColorCameraParams result;
        result.fx = params.fx;
        result.fy = params.fy;
        result.cx = params.cx;
        result.cy = params.cy;
        result.mx_x3y0 = params.mx_x3y0;
        result.mx_x0y3 = params.mx_x0y3;
        result.mx_x2y1 = params.mx_x2y1;
        result.mx_x1y2 = params.mx_x1y2;
        result.mx_x2y0 = params.mx_x2y0;
        result.mx_x0y2  = params.mx_0y2;
        result.mx_x1y1 = params.mx_x1y1;
        result.mx_x1y0 = params.mx_x1y0;
        result.mx_x0y1 = params.mx_x0y1;
        result.mx_x0y0 = params.mx_x0y0;

        result.my_x3y0 = params.my_x3y0;
        result.my_x0y3 = params.my_x0y3;
        result.my_x2y1 = params.my_x2y1;
        result.my_x1y2 = params.my_x1y2;
        result.my_x2y0 = params.my_x2y0;
        result.my_x0y2  = params.my_0y2;
        result.my_x1y1 = params.my_x1y1;
        result.my_x1y0 = params.my_x1y0;
        result.my_x0y1 = params.my_x0y1;
        result.my_x0y0 = params.my_x0y0;

        return result;
    }
}
