namespace libfreenect2sharp;

class Frame
{
    internal enum FrameType
    {
        Color = 1, //< 1920x1080. BGRX or RGBX.
        Ir = 2,    //< 512x424 float. Range is [0.0, 65535.0].
        Depth = 4  //< 512x424 float, unit: millimeter. Non-positive, NaN, and infinity are invalid or missing data.
    }

    internal enum FrameFormat
    {
        Invalid = 0, //< Invalid format.
        Raw = 1, //< Raw bitstream. 'bytes_per_pixel' defines the number of bytes
        Float = 2, //< A 4-byte float per pixel
        BGRX = 4, //< 4 bytes of B, G, R, and unused per pixel
        RGBX = 5, //< 4 bytes of R, G, B, and unused per pixel
        Gray = 6, //< 1 byte of gray per pixel
    }
    
    private int width {get; set;}
    private int height {get; set;}
    private int bytes_per_pixel {get; set;}
    private char[] data {get; set;}
    private UInt32 timestamp {get; set;}
    private UInt32 sequence {get; set;}
    private float exposure {get; set;}
    private float gain {get; set;}
    private float gamma {get; set;}

    internal Frame()
    {
        
    }
}