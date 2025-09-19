#include <libfreenect2/libfreenect2.hpp>
#include <libfreenect2/frame_listener_impl.h>
#include <libfreenect2/registration.h>
#include <libfreenect2/packet_pipeline.h>
#include <libfreenect2/logger.h>
#include <cstring>
#include <iostream>
using namespace std;

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
        result.mx_x0y2  = params.mx_x0y2;
        result.mx_x1y1 = params.mx_x1y1;
        result.mx_x1y0 = params.mx_x1y0;
        result.mx_x0y1 = params.mx_x0y1;
        result.mx_x0y0 = params.mx_x0y0;

        result.my_x3y0 = params.my_x3y0;
        result.my_x0y3 = params.my_x0y3;
        result.my_x2y1 = params.my_x2y1;
        result.my_x1y2 = params.my_x1y2;
        result.my_x2y0 = params.my_x2y0;
        result.my_x0y2  = params.my_x0y2;
        result.my_x1y1 = params.my_x1y1;
        result.my_x1y0 = params.my_x1y0;
        result.my_x0y1 = params.my_x0y1;
        result.my_x0y0 = params.my_x0y0;

        return result;
    }

    extern "C" void setIrCameraParams(libfreenect2::Freenect2Device* device, const IrCameraParamsInterop* params) {
        libfreenect2::Freenect2Device::IrCameraParams native;
        native.fx = params->fx;
        native.fy = params->fy;
        native.cx = params->cx;
        native.cy = params->cy;
        native.k1 = params->k1;
        native.k2 = params->k2;
        native.k3 = params->k3;
        native.p1 = params->p1;
        native.p2 = params->p2;
        device->setIrCameraParams(native);
    }

    extern "C" void setColorCameraParams(libfreenect2::Freenect2Device* device, const ColorCameraParams* params) {
        libfreenect2::Freenect2Device::ColorCameraParams native;
        native.fx = params->fx;
        native.fy = params->fy;
        native.cx = params->cx;
        native.cy = params->cy;
        native.shift_d = params->shift_d;
        native.shift_m = params->shift_m;

        native.mx_x3y0 = params->mx_x3y0;
        native.mx_x0y3 = params->mx_x0y3;
        native.mx_x2y1 = params->mx_x2y1;
        native.mx_x1y2 = params->mx_x1y2;
        native.mx_x2y0 = params->mx_x2y0;
        native.mx_x0y2 = params->mx_x0y2;
        native.mx_x1y1 = params->mx_x1y1;
        native.mx_x1y0 = params->mx_x1y0;
        native.mx_x0y1 = params->mx_x0y1;
        native.mx_x0y0 = params->mx_x0y0;

        native.my_x3y0 = params->my_x3y0;
        native.my_x0y3 = params->my_x0y3;
        native.my_x2y1 = params->my_x2y1;
        native.my_x1y2 = params->my_x1y2;
        native.my_x2y0 = params->my_x2y0;
        native.my_x0y2 = params->my_x0y2;
        native.my_x1y1 = params->my_x1y1;
        native.my_x1y0 = params->my_x1y0;
        native.my_x0y1 = params->my_x0y1;
        native.my_x0y0 = params->my_x0y0;

        device->setColorCameraParams(native);
    }

    extern "C" void setColorAutoExposure(libfreenect2::Freenect2Device* device, float exposure_compensation) {
        device->setColorAutoExposure(exposure_compensation);
    }

    extern "C" void setColorSemiAutoExposure(libfreenect2::Freenect2Device* device, float pseudo_exposure_time_ms) {
        device->setColorSemiAutoExposure(pseudo_exposure_time_ms);
    }

    extern "C" void setColorManualExposure(libfreenect2::Freenect2Device* device, float integration_time_ms, float analog_gain) {
        device->setColorManualExposure(integration_time_ms, analog_gain);
    }

    extern "C" {
        typedef struct {
            uint16_t LedId;
            uint16_t Mode;
            uint16_t StartLevel;
            uint16_t StopLevel;
            uint32_t IntervalInMs;
            uint32_t Reserved;
        } LedSettingsC;

        // Wrapper-Funktion
        void setLedStatus(libfreenect2::Freenect2Device* device, LedSettingsC led) {
            libfreenect2::LedSettings internalLed;
            internalLed.LedId = led.LedId;
            internalLed.Mode = led.Mode;
            internalLed.StartLevel = led.StartLevel;
            internalLed.StopLevel = led.StopLevel;
            internalLed.IntervalInMs = led.IntervalInMs;
            internalLed.Reserved = led.Reserved;

            device->setLedStatus(internalLed);
        }

    }

    extern "C" const char* getSerialNumber(libfreenect2::Freenect2Device* device) {
        std::string serial = device->getSerialNumber();
        char* result = new char[serial.size() + 1];
        std::strcpy(result, serial.c_str());
        return result;
    }


    struct DeviceConfig {
        float MinDepth;
        float MaxDepth;
        bool EnableBilateralFilter;
        bool EnableEdgeAwareFilter;
    };

    extern "C" void setDeviceConfig(libfreenect2::Freenect2Device* device, const DeviceConfig* cfg) {
        libfreenect2::Freenect2Device::Config native;
        native.MinDepth = cfg->MinDepth;
        native.MaxDepth = cfg->MaxDepth;
        native.EnableBilateralFilter = cfg->EnableBilateralFilter;
        native.EnableEdgeAwareFilter = cfg->EnableEdgeAwareFilter;
        device->setConfiguration(native);
    }
    
    



#ifdef _WIN32
#define CALLBACK __stdcall
#else
#define CALLBACK
#endif

    typedef void(CALLBACK *NewFrameCallback)(
        int frameType,
        unsigned char* data,
        int width,
        int height,
        int bytesPerPixel,
        uint32_t timestamp,
        uint32_t sequence,
        float exposure,
        float gain,
        float gamma
    );

    class CSharpFrameListener : public libfreenect2::FrameListener
    {
    public:
        explicit CSharpFrameListener(NewFrameCallback cb) : callback(cb) {}

        bool onNewFrame(libfreenect2::Frame::Type type, libfreenect2::Frame* frame) override
        {
            if (callback != nullptr && frame != nullptr)
            {
                callback(static_cast<int>(type),
                         frame->data,
                         static_cast<int>(frame->width),
                         static_cast<int>(frame->height),
                         static_cast<int>(frame->bytes_per_pixel),
                         frame->timestamp,
                         frame->sequence,
                         frame->exposure,
                         frame->gain,
                         frame->gamma);
            }
            return false; // We don't take ownership
        }

    private:
        NewFrameCallback callback;
    };

    extern "C" {

        CSharpFrameListener* createFrameListener(NewFrameCallback cb)
        {
            return new CSharpFrameListener(cb);
        }

        void deleteFrameListener(CSharpFrameListener* listener)
        {
            delete listener;
        }

        void setColorFrameListener(libfreenect2::Freenect2Device* device, libfreenect2::FrameListener* listener)
        {
            device->setColorFrameListener(listener);
        }

        void setIrAndDepthFrameListener(libfreenect2::Freenect2Device* device, libfreenect2::FrameListener* listener)
        {
            device->setIrAndDepthFrameListener(listener);
        }

    }

    extern "C" {
        struct FrameInterop {
            unsigned char* data;
            int width;
            int height;
            int bytes_per_pixel;
        };

        struct RegistrationInterop {
            libfreenect2::Registration* registration;
        };

        RegistrationInterop* createRegistration(libfreenect2::Freenect2Device* device) {
            auto depthParams = device->getIrCameraParams();
            auto colorParams = device->getColorCameraParams();
            RegistrationInterop* regInterop = new RegistrationInterop();
            regInterop->registration = new libfreenect2::Registration(depthParams, colorParams);
            return regInterop;
        }

        void deleteRegistration(RegistrationInterop* regInterop) {
            delete regInterop->registration;
            delete regInterop;
        }

        void applyRegistration(RegistrationInterop* regInterop, FrameInterop rgb, FrameInterop depth, FrameInterop* undistorted, FrameInterop* registered, bool enable_filter, FrameInterop* bigdepth) {
            // Create Frame objects with the correct parameters
            cout << "Registraion start\n";
            const libfreenect2::Frame rgbFrame(rgb.width, rgb.height, rgb.bytes_per_pixel, rgb.data);
            const libfreenect2::Frame depthFrame(depth.width, depth.height, depth.bytes_per_pixel, depth.data);
            cout << rgb.width << " " << rgb.height << " " << rgb.bytes_per_pixel << "\n";
            cout << depth.width << " " << depth.height << " " << depth.bytes_per_pixel << "\n";
            libfreenect2::Frame undistortedFrame(512, 424, 4, undistorted->data);
   
            unsigned char* registeredBuffer = new unsigned char[512 * 424 * 4];
            libfreenect2::Frame registeredFrame(512, 424, 4, registeredBuffer);
    
            
            libfreenect2::Frame bigdepthFrame(1920, 1082, 4, bigdepth->data);

            cout << "Created Frames\n";
        
            int* tmp;
            regInterop->registration->apply(&rgbFrame, &depthFrame, &undistortedFrame, &registeredFrame, enable_filter, &bigdepthFrame, tmp);
            
            undistorted->width = undistortedFrame.width;
            undistorted->height = undistortedFrame.height;
            undistorted->bytes_per_pixel = undistortedFrame.bytes_per_pixel;
            undistorted->data = undistortedFrame.data;
            
            bigdepth->width = bigdepthFrame.width;
            bigdepth->height = bigdepthFrame.height;
            bigdepth->bytes_per_pixel = bigdepthFrame.bytes_per_pixel;
            bigdepth->data = bigdepthFrame.data;
            delete[] registeredBuffer;
            cout << "Done" << endl;
        }

        void applyRegistrationPoint(RegistrationInterop* regInterop, int dx, int dy, float dz, float* cx, float* cy) {
            regInterop->registration->apply(dx, dy, dz, *cx, *cy);
        }

        void getPointXYZ(RegistrationInterop* regInterop, FrameInterop undistorted, int r, int c, float& x, float&y, float&z)
        {
            
            libfreenect2::Frame depth(undistorted.width, undistorted.height, undistorted.bytes_per_pixel, undistorted.data);
            regInterop->registration->getPointXYZ(&depth, r, c, x, y, z);
        }
    }

   





}
