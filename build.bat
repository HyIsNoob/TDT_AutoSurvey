@echo off
chcp 65001 >nul
echo ===== Building TDT Survey Tool =====

echo 1. Cleaning old build files...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist

echo 2. Running PyInstaller...
pyinstaller build_app.spec

echo 3. Building installer...
"C:\Program Files (x86)\NSIS\makensis.exe" installer.nsi

echo 4. Build complete!
echo Installer is located at: %CD%\TDT_Survey_Tool_Setup.exe
pause
