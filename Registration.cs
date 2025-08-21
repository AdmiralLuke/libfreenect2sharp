namespace libfreenect2sharp
{
    using System;
    using System.Runtime.InteropServices;

    internal class RegistrationInterop
    {
        private const string LibraryName = "libfreenect2_w";

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern IntPtr createRegistration(IntPtr device);

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void deleteRegistration(IntPtr registration);

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void applyRegistrationPoint(IntPtr registration, int dx, int dy, float dz, out float cx, out float cy);

        private IntPtr RegistrationInstance { get; set; }

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
    }
}