# libfreenect2sharp Integration Test

This test project simulates how an external consumer would use the libfreenect2sharp library.

## What it tests:

1. **Library Loading**: Verifies that the DLL can be loaded properly
2. **Basic API**: Tests core functionality like Freenect creation and device counting
3. **Native Dependencies**: Ensures native libraries (.so, .dll, .dylib) are found and loaded
4. **Error Handling**: Tests that exceptions are properly handled

## Usage:

This test is designed to run against the **built library**, not the source code. It:

- References the compiled `libfreenect2sharp.dll` from `../bin/Release/net9.0/`
- Automatically copies native dependencies from system libfreenect2 installations
- Runs as a standalone console application

This approach ensures that the library works correctly when distributed.

## Native Library Discovery:

The test scripts automatically search for and copy libfreenect2 native libraries from common installation paths:

### Linux:
- `/usr/local/lib/`
- `/usr/lib/x86_64-linux-gnu/`
- `/usr/lib/`
- `$HOME/libfreenect2/lib/`
- `./libfreenect2/lib/`

### Windows:
- `C:\Program Files\libfreenect2\bin\`
- `C:\libfreenect2\bin\`
- `%USERPROFILE%\libfreenect2\bin\`
- `.\libfreenect2\bin\`

### macOS:
- `/usr/local/lib/` (Intel Macs)
- `/opt/homebrew/lib/` (Apple Silicon Macs)
- `/usr/lib/`
- `$HOME/libfreenect2/lib/`
- `./libfreenect2/lib/`

## Running locally:

```bash
# The test scripts handle everything automatically:

# Linux/macOS:
chmod +x scripts/test-linux.sh   # or test-mac.sh
./scripts/test-linux.sh

# Windows:
scripts/test-windows.bat
```

Or manually:
```bash
# Build the main library first
dotnet build --configuration Release

# Then run the integration test
cd test
dotnet run --configuration Release
```
