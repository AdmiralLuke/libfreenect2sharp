namespace libfreenect2sharp
{
    using System;
    using System.Runtime.InteropServices;

    public class RegistrationInterop
    {
        private const string LibraryName = "libfreenect2_w";

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern IntPtr createRegistration(IntPtr device);

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void deleteRegistration(IntPtr registration);

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void applyRegistrationPoint(IntPtr registration, int dx, int dy, float dz, out float cx, out float cy);

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void getPointXYZ(IntPtr registration, FrameInterop frame, int r, int c, out float x, out float y, out float z);


        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void applyRegistration(IntPtr regInterop, FrameInterop rgb, FrameInterop depth,
            out FrameInterop undistorted, out FrameInterop registered, bool enable_filter, out FrameInterop bigdepth); 
        
        private IntPtr RegistrationInstance { get; set; }

        public struct FrameInterop
        {
            public IntPtr data;
            public int width;
            public int height;
            public int bytes_per_pixel;
        }

        internal RegistrationInterop(IntPtr device)
        {
            RegistrationInstance = createRegistration(device);
            if (RegistrationInstance == IntPtr.Zero)
            {
                throw new Exception("Failed to create registration instance");
            }
        }

        ~RegistrationInterop()
        {
            deleteRegistration(RegistrationInstance);
        }

        internal void Apply(int dx, int dy, float dz, out float cx, out float cy)
        {
            applyRegistrationPoint(RegistrationInstance, dx, dy, dz, out cx, out cy);
        }

        internal void ApplyRegistration(FrameInterop color, FrameInterop depth, out FrameInterop registered, out FrameInterop undistorted, out FrameInterop bigdepth)
        {
            applyRegistration(RegistrationInstance, color, depth, out undistorted, out registered, true, out bigdepth);
        }

        internal void GetPointXYZ(FrameInterop frame, int r, int c, out float x, out float y, out float z)
        {
            getPointXYZ(RegistrationInstance, frame, r, c, out x, out y, out z);
        }
    }
}