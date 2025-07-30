namespace libfreenect2sharp;

/*
 * Possible frame types
 */
public class Frame
{
    enum TYPE
    {
        Color = 1, // 1920x1080. BGRX or RGBX.
        Ir = 2,    // 512x424 float. Range is [0.0, 65535.0].
        Depth = 4  // 512x424 float, unit: millimeter. Non-positive, NaN, and infinity are invalid or missing data. why
                   // is depth 4 :sob:
    }
    /** Pixel format. */
    enum FORMAT
    {
        Invalid = 0, // Invalid format.
        Raw = 1, // Raw bitstream. 'bytes_per_pixel' defines the number of bytes
        Float = 2, // A 4-byte float per pixel
        BGRX = 4, // 4 bytes of B, G, R, and unused per pixel
        RGBX = 5, // 4 bytes of R, G, B, and unused per pixel
        Gray = 6, // 1 byte of gray per pixel
    };

    /// <summary>
    /// creates a new frame
    /// </summary>
    /// <param name="width">Width in pixels</param>
    /// <param name="height">Height in pixels</param>
    /// <param name="bytesPerPixel">Bytes per pixel</param>
    /// <param name="type"></param>
    /// <param name="depthData"></param>
    Frame(nint width, nint height, nint bytesPerPixel, TYPE type, Array depthData)
    {
        _width = width;
        _height = height;
        _bytesPerPixel = bytesPerPixel;
    }

    private nint _width; //length of a line
    private nint _height; //number of lines in a frame
    private nint _bytesPerPixel; // number of bytes in a pixel
    private nint _timestamp;
    private nint _sequence;
    private float _exposure;
    private float _gain;
    private float _gamma; 
    private UInt32 _status; // zero indicates no errors
    private FORMAT _format; // byte format. For information
    private Array _depthData; // data
}

/*
 * Callback interface to receive new frames
 */
public class FrameListener
{
    
}