using System.Runtime.InteropServices;

namespace libfreenect2sharp;

public class Frame
{
    public enum FrameType
    {
        Color = 1, //< 1920x1080. BGRX or RGBX.
        Ir = 2,    //< 512x424 float. Range is [0.0, 65535.0].
        Depth = 4  //< 512x424 float, unit: millimeter. Non-positive, NaN, and infinity are invalid or missing data.
    }

    public enum FrameFormat
    {
        Invalid = 0, //< Invalid format.
        Raw = 1, //< Raw bitstream. 'bytes_per_pixel' defines the number of bytes
        Float = 2, //< A 4-byte float per pixel
        BGRX = 4, //< 4 bytes of B, G, R, and unused per pixel
        RGBX = 5, //< 4 bytes of R, G, B, and unused per pixel
        Gray = 6, //< 1 byte of gray per pixel
    }
    
    public int Width {get; internal set;}
    public int Height {get; internal set;}
    public int BytesPerPixel {get; internal set;}
    public IntPtr Data {get; internal set;}
    public uint Timestamp {get; internal set;}
    public uint Sequence {get; internal set;}
    public float Exposure {get; internal set;}
    public float Gain {get; internal set;}
    public float Gamma {get; internal set;}

    

    public byte[] GetData()
    {
        int length = Width * Height * BytesPerPixel;
        byte[] result = new byte[length];
        Marshal.Copy(Data, result, 0, length);
        return result;
    }
    
    
}