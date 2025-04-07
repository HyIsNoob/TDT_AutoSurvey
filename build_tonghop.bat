@echo off
echo ===== Building TDT Khao Sat Tong Hop =====

echo 1. Cleaning old build files...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist

echo 2. Building TDT Khao Sat Tong Hop...
pyinstaller build_tonghop.spec

echo 3. Building installer...
"C:\Program Files (x86)\NSIS\makensis.exe" installer_tonghop.nsi

echo 4. Build complete!
echo Installer is located at: %CD%\TDT_KhaoSatTongHop_Setup.exe
pause
