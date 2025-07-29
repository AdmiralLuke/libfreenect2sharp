// Simple implementation for testing P/Invoke integration
// This provides the minimum functions needed to test the C# wrapper

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

// Simple struct matching C# definition
struct IrCameraParams {
    float fx, fy, cx, cy;
    float k1, k2, k3, p1, p2;
};

// Function implementations
EXPORT void* createFreenect2() {
    return (void*)0x12345678; // Return dummy pointer
}

EXPORT void deleteFreenect2(void* handle) {
    // Nothing to do
}

EXPORT int getDeviceCount(void* handle) {
    return 0; // Return 0 devices - this is fine for testing
}

EXPORT void* openDevice(void* handle, int index) {
    return (void*)0x87654321; // Return dummy device pointer
}

EXPORT int startDevice(void* device) {
    return 1; // Return true (success)
}

EXPORT int stopDevice(void* device) {
    return 1; // Return true (success)
}

EXPORT int closeDevice(void* device) {
    return 1; // Return true (success)
}

EXPORT char* getFirmwareVersion(void* device) {
    static char version[] = "Test v1.0";
    return version;
}

EXPORT void freeString(char* str) {
    // Nothing to do for static string
}

EXPORT struct IrCameraParams getIrCameraParams(void* device) {
    struct IrCameraParams params = {100.0f, 100.0f, 320.0f, 240.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
    return params;
}
