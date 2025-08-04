namespace libfreenect2sharp;
using System.Runtime.InteropServices;

public class Freenect
{
    // Use standard library name without extension - .NET will find the right one
    private const string LibraryName = "libfreenect2_w";
    
    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern IntPtr createFreenect2();

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern void deleteFreenect2(IntPtr handle);

    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern int getDeviceCount(IntPtr handle);
    
    [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
    static extern IntPtr openDevice(IntPtr handle, int index);

    private IntPtr FreenectInstance {get; set;}
    private static Freenect? instance { get; set; }

    /// <summary>
    /// Creates a new Freenect Instance with the space of all possible Kinect devices
    /// </summary>
    /// <exception cref="Exception"></exception>
    Freenect()
    {
        FreenectInstance = createFreenect2();
        if (FreenectInstance == IntPtr.Zero)
        {
            throw new Exception("Failed to create freenect instance");
        }
    }
    
    /// <summary>
    /// Deletes the Freenect Instance and deletes the Pointer to the Kinect space
    /// </summary>
    ~Freenect()
    {
        deleteFreenect2(FreenectInstance);
    }

    /// <summary>
    /// Returns the amount of all connected KinectV2 devices
    /// </summary>
    /// <returns></returns>
    public int GetDeviceCount()
    {
        return getDeviceCount(FreenectInstance);
    }
    
    /// <summary>
    /// Creates a new Freenect Instance as a Singleton
    /// </summary>
    /// <returns>Current Freenect Instance</returns>
    public static Freenect CreateFreenect()
    {
        if (instance == null)
        {
            instance = new Freenect();
        }
        return instance;
    }

    /// <summary>
    /// Returns a Kinect object for the specific index
    /// </summary>
    /// <param name="idx">Auto uses idx = 0 (which should be the default Kinect) when no index given</param>
    /// <returns>Kinect at current Index</returns>
    public Kinect GetKinect(int idx = 0)
    {
        IntPtr handle = openDevice(FreenectInstance, idx);
        return new Kinect(handle, idx);
    }

 
    
}