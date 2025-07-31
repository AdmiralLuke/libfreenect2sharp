using System;
using System.Runtime.InteropServices;

namespace libfreenect2sharp
{
    internal delegate void NewFrameCallbackDelegate(
        int frameType,
        IntPtr data,
        int width,
        int height,
        int bytesPerPixel,
        uint timestamp,
        uint sequence,
        float exposure,
        float gain,
        float gamma
    );

    internal class FrameListener : IDisposable
    {
        private IntPtr nativeListener;

        private readonly NewFrameCallbackDelegate _callbackDelegate;

        private const string LibraryName = "libfreenect2_w";

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr createFrameListener(NewFrameCallbackDelegate callback);

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void deleteFrameListener(IntPtr listener);

        internal FrameListener(Action<Frame.FrameType, Frame> onNewFrame)
        {
            _callbackDelegate = (type, data, width, height, bpp, ts, seq, exp, gain, gamma) =>
            {
                var frame = new Frame
                {
                    Width = width,
                    Height = height,
                    BytesPerPixel = bpp,
                    Data = data,
                    Timestamp = ts,
                    Sequence = seq,
                    Exposure = exp,
                    Gain = gain,
                    Gamma = gamma
                };
                onNewFrame?.Invoke((Frame.FrameType)type, frame);
            };

            nativeListener = createFrameListener(_callbackDelegate);
        }

        internal IntPtr NativePointer => nativeListener;

        public void Dispose()
        {
            if (nativeListener != IntPtr.Zero)
            {
                deleteFrameListener(nativeListener);
                nativeListener = IntPtr.Zero;
            }
        }
    }
}
