@echo off
REM Test script for Windows - Tests the built library as external dependency

echo Running libfreenect2sharp integration tests on Windows...

REM First, ensure the main library is built
echo Building main library...
dotnet build --configuration Release

if %ERRORLEVEL% neq 0 (
    echo Main library build failed!
    exit /b 1
)

REM Copy libfreenect2 native libraries to bin directory
echo Copying libfreenect2 native libraries...
set BIN_DIR=bin\Release\net9.0
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"

REM Check common installation paths for libfreenect2
set LIBFREENECT2_PATHS="C:\Program Files\libfreenect2\bin" "C:\libfreenect2\bin" "%USERPROFILE%\libfreenect2\bin" ".\libfreenect2\bin"

for %%P in (%LIBFREENECT2_PATHS%) do (
    if exist %%P (
        echo Checking %%P for libfreenect2 libraries...
        copy "%%P\libfreenect2*.dll" "%BIN_DIR%\" 2>nul && echo   Found and copied libfreenect2 libraries from %%P
        copy "%%P\freenect2*.dll" "%BIN_DIR%\" 2>nul
    )
)

REM Also copy any existing libraries from the build
if exist "wrapper\libfreenect2_w.dll" (
    copy "wrapper\libfreenect2_w.dll" "%BIN_DIR%\"
    echo Copied wrapper library
)

echo Contents of %BIN_DIR%:
dir "%BIN_DIR%\*.dll" 2>nul || echo No .dll files found

REM Now test as external consumer
cd test
echo Building test project (as external consumer)...
dotnet build --configuration Release

if %ERRORLEVEL% neq 0 (
    echo Test project build failed!
    exit /b 1
)

echo Running integration tests...
dotnet run --configuration Release

if %ERRORLEVEL% equ 0 (
    echo Integration tests passed successfully!
    exit /b 0
) else (
    echo Integration tests failed!
    exit /b 1
)
