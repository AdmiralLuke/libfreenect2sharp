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

    /**
     * Creates a new Freenect Instance with the space of all possible Kinect devices
     */
    Freenect()
    {
        FreenectInstance = createFreenect2();
        if (FreenectInstance == IntPtr.Zero)
        {
            throw new Exception("Failed to create freenect instance");
        }
    }
    
    /**
     * Deletes the Freenect Instance and deletes the Pointer to the Kinect space
     */
    ~Freenect()
    {
        deleteFreenect2(FreenectInstance);
    }

    /**
     * Returns the amount of all connected KinectV2 devices
     */
    public int GetDeviceCount()
    {
        return getDeviceCount(FreenectInstance);
    }
    
    /**
     * Creates a new Freenect Instance as a Singleton
     */
    public static Freenect CreateFreenect()
    {
        if (instance == null)
        {
            instance = new Freenect();
        }
        return instance;
    }

    /**
     * Returns a Kinect object for the specific index.
     * Auto uses idx = 0 (which should be the default Kinect) when no index given
     */
    public Kinect GetKinect(int idx = 0)
    {
        IntPtr handle = openDevice(FreenectInstance, idx);
        return new Kinect(handle, idx);
    }

    static void Main(string[] args)
    {
        Freenect freenect = CreateFreenect();
        Console.WriteLine(freenect.GetDeviceCount());
        Kinect kinect  = freenect.GetKinect();
        Console.WriteLine(kinect.GetFirmwareVersion());
        Console.WriteLine(kinect.GetIrCameraParams().fx);
    }
    
}