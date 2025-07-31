@echo off
echo === Building libfreenect2sharp for Windows ===
echo.
echo This script will build the C# wrapper library and compile the native DLL.
echo.

REM Check for available C++ compilers
echo Checking for available C++ compilers...

REM Check for GCC (MinGW)
where gcc >nul 2>&1
if %errorlevel% == 0 (
    echo Found GCC MinGW compiler
    goto :build_with_gcc
)

REM Check for Visual Studio Build Tools cl.exe
where cl >nul 2>&1
if %errorlevel% == 0 (
    echo Found Visual Studio C++ compiler cl.exe
    goto :build_with_cl
)

REM Check for Clang
where clang >nul 2>&1
if %errorlevel% == 0 (
    echo Found Clang compiler
    goto :build_with_clang
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
pause
exit /b 1

:build_with_gcc
echo Building native library with GCC...
gcc -shared -o libfreenect2_w.dll wrapper\libfreenect2_w_standalone.c
if %errorlevel% == 0 (
    echo Successfully built libfreenect2_w.dll
    goto :build_csharp
) else (
    echo Build failed with GCC
    exit /b 1
)

:build_with_cl
echo Building native library with Visual Studio C++ compiler...
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat" 2>nul
if not %errorlevel% == 0 call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" 2>nul
cl /LD /EHsc wrapper\libfreenect2_w_standalone.c /Fe:libfreenect2_w.dll
if %errorlevel% == 0 (
    echo Successfully built libfreenect2_w.dll
    del libfreenect2_w.exp libfreenect2_w.lib libfreenect2_w.obj 2>nul
    goto :build_csharp
) else (
    echo Build failed with Visual Studio compiler
    exit /b 1
)

:build_with_clang
echo Building native library with Clang...
clang -shared -o libfreenect2_w.dll wrapper\libfreenect2_w_standalone.c
if %errorlevel% == 0 (
    echo Successfully built libfreenect2_w.dll
    goto :build_csharp
) else (
    echo Build failed with Clang
    exit /b 1
)

:build_csharp
echo.
echo Building C# wrapper library...
dotnet build --configuration Release
if %errorlevel% == 0 (
    echo Successfully built C# library
) else (
    echo C# build failed
    exit /b 1
)

echo.
echo Copying native library to output directories...
copy libfreenect2_w.dll bin\Release\net9.0\ >nul
copy libfreenect2_w.dll wrapper\ >nul
echo Native library copied to output directories

echo.
echo Creating NuGet package...
dotnet pack --configuration Release --output ./nupkg
if %errorlevel% == 0 (
    echo Successfully created NuGet package
    echo.
    echo BUILD SUCCESSFUL!
    echo.
    echo libfreenect2sharp is ready:
    echo - C# library: bin\Release\net9.0\libfreenect2sharp.dll
    echo - Native library: bin\Release\net9.0\libfreenect2_w.dll
    echo - NuGet package: nupkg\libfreenect2sharp.*.nupkg
    echo.
    echo You can install the NuGet package or reference the DLL directly.
) else (
    echo NuGet package creation failed
    exit /b 1
)

echo.
echo Build completed successfully!

