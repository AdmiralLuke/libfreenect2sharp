namespace libfreenect2sharp;
using System.Runtime.InteropServices;

public class Kinect
{
    // Determine library name at compile time based on platform
    private const string LibraryName = "libfreenect2_w";

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern bool startDevice(IntPtr device);
    
    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern bool stopDevice(IntPtr device);
    
    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern bool closeDevice(IntPtr device);
    
    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern IntPtr getFirmwareVersion(IntPtr device);

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern void freeString(IntPtr str);
    [StructLayout(LayoutKind.Sequential)]
    public struct IrCameraParams
    {
        public float fx, fy, cx, cy;
        public float k1, k2, k3, p1, p2;
    }

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern IrCameraParams getIrCameraParams(IntPtr device);

    
    
    
    private int Index {get; set;}
    private IntPtr Device {get; set;}
    
    internal Kinect(IntPtr device, int index)
    {
        Device = device;
        Index = index;
        if (!startDevice(Device))
        {
            throw new Exception("Could not start Kinect device");
        }
    }

    ~Kinect()
    {
        stopDevice(Device);
        closeDevice(Device);
    }

    public string GetFirmwareVersion()
    {
        IntPtr ptr = getFirmwareVersion(Device);
        string version = Marshal.PtrToStringAnsi(ptr) ?? string.Empty;
        freeString(ptr);
        return version;
    }

    public IrCameraParams GetIrCameraParams()
    {
        return getIrCameraParams(Device);
    }
    
    
}