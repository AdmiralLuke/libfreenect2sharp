namespace libfreenect2sharp;
using System.Runtime.InteropServices;

public class Freenect
{
    
    [DllImport("freenect2_w", CallingConvention = CallingConvention.Cdecl)]
    static extern IntPtr createFreenect2();

    [DllImport("freenect2_w", CallingConvention = CallingConvention.Cdecl)]
    static extern void deleteFreenect2(IntPtr handle);

    [DllImport("freenect2_w", CallingConvention = CallingConvention.Cdecl)]
    static extern int getDeviceCount(IntPtr handle);

    private IntPtr FreenectInstance {get; set;}
    private static Freenect instance { get; set; }

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

    static void Main(string[] args)
    {
        Freenect freenect = CreateFreenect();
        Console.WriteLine(freenect.GetDeviceCount());
        
    }
    
}