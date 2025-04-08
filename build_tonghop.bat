@echo off
chcp 65001 >nul
echo ===== Building TDTKhaoSatTongHop =====

echo 1. Cleaning old build files...
if exist build\tonghop rmdir /s /q build\tonghop
if exist dist\TDTKhaoSatTongHop.exe del /f /q dist\TDTKhaoSatTongHop.exe

echo 2. Running PyInstaller...
pyinstaller build_tonghop.spec

echo 3. Verifying build results...
if exist "dist\TDTKhaoSatTongHop.exe" (
    echo Build successful! Executable created.
    echo Location: %CD%\dist\TDTKhaoSatTongHop.exe
) else (
    echo Build may have failed. Check for errors above.
)

echo 4. Build process complete!
pause
