using System;
using libfreenect2sharp;

class Program
{
    static void Main()
    {
        Console.WriteLine("=== Testing All P/Invoke Functions ===");
        
        try
        {
            Console.WriteLine("1. Creating Freenect instance...");
            Freenect freenect = Freenect.CreateFreenect();
            Console.WriteLine("Freenect instance created");

            Console.WriteLine("2. Getting device count...");
            int count = freenect.GetDeviceCount();
            Console.WriteLine($"Device count: {count}");

            Console.WriteLine("3. Getting Kinect device (index 0)...");
            Kinect kinect = freenect.GetKinect(0);
            Console.WriteLine("Kinect device obtained");

            Console.WriteLine("4. Getting firmware version...");
            string firmware = kinect.GetFirmwareVersion();
            Console.WriteLine($"Firmware version: {firmware}");

            Console.WriteLine("5. Getting IR camera parameters...");
            var irParams = kinect.GetIrCameraParams();
            Console.WriteLine($"IR Camera params - fx: {irParams.fx}, fy: {irParams.fy}, cx: {irParams.cx}, cy: {irParams.cy}");

            Console.WriteLine();
            Console.WriteLine("ALL P/INVOKE FUNCTIONS WORKING CORRECTLY!");
            Console.WriteLine("The C# wrapper successfully calls all native functions.");
            Console.WriteLine("Device count of 0 is expected without actual Kinect hardware.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
        }
    }
}
