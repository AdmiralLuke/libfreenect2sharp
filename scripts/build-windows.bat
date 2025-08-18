@echo off
echo === Building libfreenect2sharp for Windows ===
echo.
echo This script will build the C# wrapper library and compile the native DLL.
echo.

REM Clean up old files
for /f %%i in ('dir /b libfreenect2_w.dll 2^>nul') do del "%%i"

REM Check for available C++ compilers
echo Checking for available C++ compilers...

REM Check for GCC (MinGW)
where gcc >nul 2>&1
if %errorlevel% == 0 (
    echo Found GCC MinGW compiler
    set COMPILER=gcc
    goto :compiler_found
)

REM Check for Visual Studio Build Tools cl.exe
where cl >nul 2>&1
if %errorlevel% == 0 (
    echo Found Visual Studio C++ compiler cl.exe
    set COMPILER=cl
    goto :compiler_found
)

REM Check for Clang
where clang >nul 2>&1
if %errorlevel% == 0 (
    echo Found Clang compiler
    set COMPILER=clang
    goto :compiler_found
)

echo.
echo No C++ compiler found!
echo.
echo To build libfreenect2sharp, you need one of these compilers:
echo.
echo 1. MinGW-w64 recommended for simple setup:
echo    Download from: https://www.mingw-w64.org/downloads/
echo    Or install via MSYS2: pacman -S mingw-w64-x86_64-gcc
echo.
echo 2. Visual Studio Build Tools:
echo    Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
echo.
echo 3. LLVM/Clang:
echo    Download from: https://releases.llvm.org/download.html
echo.
echo After installing a compiler, run this script again.
echo.
exit /b 1

:compiler_found

REM Check for .NET SDK
where dotnet >nul 2>&1
if not %errorlevel% == 0 (
    echo.
    echo .NET SDK not found!
    echo.
    echo To install .NET SDK:
    echo.
    echo Download from: https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    exit /b 1
)

echo Found .NET SDK

REM Build native library
echo.
echo Building native library with %COMPILER%...

REM Check for local libfreenect2 build
if exist "%USERPROFILE%\libfreenect2\build\lib\libfreenect2.dll" if exist "%USERPROFILE%\libfreenect2\include" (
    echo Using local libfreenect2 build...
    if "%COMPILER%" == "gcc" (
        gcc -shared -fPIC -o libfreenect2_w.dll wrapper\freenect2_wrapper.cpp -I "%USERPROFILE%\libfreenect2\include" -I "%USERPROFILE%\libfreenect2\build" -L "%USERPROFILE%\libfreenect2\build\lib" -lfreenect2
    ) else if "%COMPILER%" == "cl" (
        call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat" 2>nul
        if not %errorlevel% == 0 call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" 2>nul
        cl /LD /EHsc wrapper\freenect2_wrapper.cpp /I "%USERPROFILE%\libfreenect2\include" /I "%USERPROFILE%\libfreenect2\build" /LIBPATH:"%USERPROFILE%\libfreenect2\build\lib" libfreenect2.lib /Fe:libfreenect2_w.dll
        del libfreenect2_w.exp libfreenect2_w.lib libfreenect2_w.obj 2>nul
    ) else if "%COMPILER%" == "clang" (
        clang -shared -o libfreenect2_w.dll wrapper\freenect2_wrapper.cpp -I "%USERPROFILE%\libfreenect2\include" -I "%USERPROFILE%\libfreenect2\build" -L "%USERPROFILE%\libfreenect2\build\lib" -lfreenect2
    )
) else (
    echo libfreenect2 not found!
    echo.
    echo libfreenect2 needs to be built from source:
    echo.
    echo 1. Clone and build libfreenect2:
    echo    git clone https://github.com/OpenKinect/libfreenect2.git %USERPROFILE%\libfreenect2
    echo    cd %USERPROFILE%\libfreenect2
    echo    mkdir build && cd build
    echo    cmake ..
    echo    cmake --build . --config Release
    echo.
    exit /b 1
)

if %errorlevel% == 0 (
    echo Successfully built libfreenect2_w.dll
) else (
    echo Build failed with %COMPILER%
    echo Note: This requires libfreenect2 to be built from source
    echo See error message above for installation instructions
    exit /b 1
)

REM Build C# wrapper library
echo.
echo Building C# wrapper library...
dotnet build --configuration Release

if %errorlevel% == 0 (
    echo Successfully built C# library
) else (
    echo C# build failed
    exit /b 1
)

REM Copy native library to output directories
echo.
echo Copying native libraries to output directories...
if not exist bin\Release\net8.0 mkdir bin\Release\net8.0
if not exist wrapper mkdir wrapper
if not exist runtimes\win-x64\native mkdir runtimes\win-x64\native

REM Copy our wrapper library
copy libfreenect2_w.dll bin\Release\net8.0\ >nul
copy libfreenect2_w.dll wrapper\ >nul
copy libfreenect2_w.dll runtimes\win-x64\native\ >nul
if exist nupkg\libfreenect2sharp.*.nupkg del nupkg\libfreenect2sharp.*.nupkg

REM Copy libfreenect2 dependencies if they exist
if exist "%USERPROFILE%\libfreenect2\build\lib\libfreenect2.dll" (
    echo Copying libfreenect2 dependencies...
    copy "%USERPROFILE%\libfreenect2\build\lib\libfreenect2.*" bin\Release\net8.0\ >nul
    copy "%USERPROFILE%\libfreenect2\build\lib\libfreenect2.*" runtimes\win-x64\native\ >nul
    
    echo libfreenect2 dependencies copied
)

echo.
echo Creating NuGet package...
dotnet pack --configuration Release --output ./nupkg
if %errorlevel% == 0 (
    echo Successfully created NuGet package
    echo.
    echo BUILD SUCCESSFUL!
    echo.
    echo libfreenect2sharp is ready:
    echo - C# library: bin\Release\net8.0\libfreenect2sharp.dll
    echo - Native library: bin\Release\net8.0\libfreenect2_w.dll
    echo - NuGet package: nupkg\libfreenect2sharp.*.nupkg
    echo.
    echo You can install the NuGet package or reference the DLL directly.
) else (
    echo NuGet package creation failed
    exit /b 1
)

echo.
echo Build completed successfully!
pause