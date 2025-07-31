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

    public struct ColorCameraParams
    {
        public float fx, fy, cx, cy;
        public float shift_d, shift_m;

        public float mx_x3y0; // xxx
        public float mx_x0y3; // yyy
        public float mx_x2y1; // xxy
        public float mx_x1y2; // yyx
        public float mx_x2y0; // xx
        public float mx_x0y2; // yy
        public float mx_x1y1; // xy
        public float mx_x1y0; // x
        public float mx_x0y1; // y
        public float mx_x0y0; // 1

        public float my_x3y0; // xxx
        public float my_x0y3; // yyy
        public float my_x2y1; // xxy
        public float my_x1y2; // yyx
        public float my_x2y0; // xx
        public float my_x0y2; // yy
        public float my_x1y1; // xy
        public float my_x1y0; // x
        public float my_x0y1; // y
        public float my_x0y0; // 1
    }

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern IrCameraParams getIrCameraParams(IntPtr device);

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern ColorCameraParams getColorCameraParams(IntPtr device);
    
    
    
    private int Index {get; set;}
    private IntPtr Device {get; set;}
    
    private float depth_q = 0.01f; // hardcoded see https://github.com/OpenKinect/libfreenect2/issues/41#issuecomment-72022111
    private float color_q = 0.002199f; // hardcoded see https://github.com/OpenKinect/libfreenect2/issues/41#issuecomment-72022111
    
    private FrameListener? colorListener;
    private FrameListener? irDepthListener;
    
    /// <summary>
    /// Instance from one Kinect Device
    /// </summary>
    /// <param name="device">RawPointer to the device</param>
    /// <param name="index">Index of the Kinect within the Freenect Space</param>
    /// <exception cref="Exception">Throws Exception if no Kinect was found</exception>
    internal Kinect(IntPtr device, int index)
    {
        Device = device;
        Index = index;
        if (!startDevice(Device))
        {
            throw new Exception("Could not start Kinect device");
        }
        SetLed(0, 1, 0, 1000, 500);
        SetLed(1, 0, 1000, 1000, 0);
    }

    /// <summary>
    /// Destructor, automatically stops Kinect when deleted
    /// </summary>
    ~Kinect()
    {
        SetLed(0, 0, 0, 0, 0);
        SetLed(1, 0, 0, 0, 0);
        stopDevice(Device);
        closeDevice(Device);
    }

    /// <summary>
    /// Returns the firmware version of the current Kinect device
    /// </summary>
    /// <returns>String containing firmware version</returns>
    public string GetFirmwareVersion()
    {
        IntPtr ptr = getFirmwareVersion(Device);
        string version = Marshal.PtrToStringAnsi(ptr) ?? string.Empty;
        freeString(ptr);
        return version;
    }

    /// <summary>
    /// Returns the intrinsic camera parameters (set by factory)
    /// </summary>
    /// <returns>Struct with camera parameters: fx, fy, cx, cy, k1, k2, k3, p1, p2;</returns>
    public IrCameraParams GetIrCameraParams()
    {
        return getIrCameraParams(Device);
    }

    /// <summary>
    /// Get the Intrinsic and Extrinsic Color Camera Parameters
    /// </summary>
    /// <returns>Struct with parameters, see https://github.com/OpenKinect/libfreenect2/blob/fd64c5d9b214df6f6a55b4419357e51083f15d93/include/libfreenect2/libfreenect2.hpp#L58</returns>
    public ColorCameraParams GetColorCameraParams()
    {
        return getColorCameraParams(Device);
    }

    /// <summary>
    /// Undistort Depth Map Point at dx, dy
    /// For details see https://github.com/OpenKinect/libfreenect2/issues/41#issuecomment-72022111
    /// </summary>
    /// <param name="dx">Depth-Map Point x</param>
    /// <param name="dy">Depth-Map Point y</param>
    /// <returns>Undistorted Point [mx, my]</returns>
    public float[] undistort(float dx, float dy)
    {
      ColorCameraParams colorCamera = GetColorCameraParams();
      IrCameraParams depth = getIrCameraParams(Device);
      
      float ps = (dx * dx) + (dy * dy);
      float qs = ((ps * depth.k3 + depth.k2) * ps + depth.k1) * ps + 1.0f;
      
      for (int i = 0; i < 9; i++) {
          float qd = ps / (qs * qs);
          qs = ((qd * depth.k3 + depth.k2) * qd + depth.k1) * qd + 1.0f;
      }

      return [dx / qs, dy / qs];
    }

    /// <summary>
    /// Projects a Depth-Map point to the ColorCamera Space
    /// For details see https://github.com/OpenKinect/libfreenect2/issues/41#issuecomment-72022111
    /// It only uses the pre-implemented ColorCameraParams. For own params, clone the function and use your own values
    /// </summary>
    /// <param name="mx">Undistorted Depth-Map Point x</param>
    /// <param name="my">Undistorted Depth-Map Point y</param>
    /// <param name="z">Depth-Map Value z</param>
    /// <returns>ColorCamera Point [rx, ry]</returns>
    public float[] depth_to_color(float mx, float my, float z)
    {
        ColorCameraParams c = GetColorCameraParams();
        IrCameraParams d = getIrCameraParams(Device);
        
        mx *= d.fx * depth_q;
        my *= d.fy * depth_q;
        
        float wx =
            (mx * mx * mx * c.mx_x3y0) + (my * my * my * c.mx_x0y3) +
            (mx * mx * my * c.mx_x2y1) + (my * my * mx * c.mx_x1y2) +
            (mx * mx * c.mx_x2y0) + (my * my * c.mx_x0y2) + (mx * my * c.mx_x1y1) +
            (mx * c.mx_x1y0) + (my * c.mx_x0y1) + (c.mx_x0y0);
        float wy =
            (mx * mx * mx * c.my_x3y0) + (my * my * my * c.my_x0y3) +
            (mx * mx * my * c.my_x2y1) + (my * my * mx * c.my_x1y2) +
            (mx * mx * c.my_x2y0) + (my * my * c.my_x0y2) + (mx * my * c.my_x1y1) +
            (mx * c.my_x1y0) + (my * c.my_x0y1) + (c.my_x0y0);

        float rx = wx / (c.fx * color_q);
        float ry = wy / (c.fy * color_q);

        rx += (c.shift_m / z) - (c.shift_m / c.shift_d);

        return [rx * c.fx + c.cx, ry * c.fy + c.cy];
    }
    
    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern IntPtr getSerialNumber(IntPtr device);

    /// <summary>
    /// Returns the serial number of the Kinect device.
    /// </summary>
    /// <returns>Serial number as string</returns>
    public string GetSerialNumber()
    {
        IntPtr ptr = getSerialNumber(Device);
        string serial = Marshal.PtrToStringAnsi(ptr) ?? string.Empty;
        freeString(ptr);
        return serial;
    }
    
    [StructLayout(LayoutKind.Sequential)]
    public struct DeviceConfig
    {
        public float MinDepth;
        public float MaxDepth;
        [MarshalAs(UnmanagedType.I1)]
        public bool EnableBilateralFilter;
        [MarshalAs(UnmanagedType.I1)]
        public bool EnableEdgeAwareFilter;
    }

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern void setDeviceConfig(IntPtr device, ref DeviceConfig config);


    /// <summary>
    /// Sets the depth processing configuration of the Kinect device.
    /// </summary>
    /// <param name="minDepth">Minimum depth in meters</param>
    /// <param name="maxDepth">Maximum depth in meters</param>
    /// <param name="enableBilateralFilter">Enables bilateral filter</param>
    /// <param name="enableEdgeAwareFilter">Enables edge-aware filter</param>
    public void SetDepthProcessingConfig(float minDepth = 0.5f, float maxDepth = 4.5f, bool enableBilateralFilter = true, bool enableEdgeAwareFilter = true)
    {
        DeviceConfig cfg = new DeviceConfig
        {
            MinDepth = minDepth,
            MaxDepth = maxDepth,
            EnableBilateralFilter = enableBilateralFilter,
            EnableEdgeAwareFilter = enableEdgeAwareFilter
        };
        setDeviceConfig(Device, ref cfg);
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct LedSettings
    {
        public ushort LedId;
        public ushort Mode;
        public ushort StartLevel;
        public ushort StopLevel;
        public uint IntervalInMs;
        public uint Reserved;
    }

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern void setLedStatus(IntPtr device, LedSettings led);

    
    /// <summary>
    /// Sets the LED behavior on the Kinect device.
    /// </summary>
    /// <param name="ledId">LED index (0 or 1)</param>
    /// <param name="mode">0 = constant, 1 = blink</param>
    /// <param name="startLevel">Start intensity (0-1000)</param>
    /// <param name="stopLevel">Stop intensity (0-1000)</param>
    /// <param name="intervalInMs">Blink interval in milliseconds (only for mode=1)</param>
    public void SetLed(ushort ledId, ushort mode, ushort startLevel, ushort stopLevel, uint intervalInMs)
    {
        LedSettings settings = new LedSettings
        {
            LedId = ledId,
            Mode = mode,
            StartLevel = startLevel,
            StopLevel = stopLevel,
            IntervalInMs = intervalInMs,
            Reserved = 0
        };
        setLedStatus(Device, settings);
    }
    
    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    private static extern void setColorFrameListener(IntPtr device, IntPtr listener);

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    private static extern void setIrAndDepthFrameListener(IntPtr device, IntPtr listener);



    /// <summary>
    /// Register Callback Delegate if a new ColorFrame was recieved
    /// </summary>
    /// <param name="callback">Action with FrameType=Color</param>
    public void OnColorFrame(Action<Frame.FrameType, Frame> callback)
    {
        colorListener?.Dispose(); 
        colorListener = new FrameListener(callback);
        setColorFrameListener(Device, colorListener.NativePointer);
    }

    /// <summary>
    /// Register Callback Delegate if a new IR/Depth was recieved
    /// </summary>
    /// <param name="callback">Action with FrameType=IR or Depth</param>
    public void OnIrAndDepthFrame(Action<Frame.FrameType, Frame> callback)
    {
        irDepthListener?.Dispose(); 
        irDepthListener = new FrameListener(callback);
        setIrAndDepthFrameListener(Device, irDepthListener.NativePointer);
    }


    
    
}