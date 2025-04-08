; TDT Survey Tool Installer Script - Simplified version
Unicode true

!include "MUI2.nsh"
!include "LogicLib.nsh"

; Application Info
!define PRODUCT_NAME "TDTKhaoSatTongHop"
!define PRODUCT_VERSION "1.2"
!define PRODUCT_PUBLISHER "Hy"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

; Interface
!define MUI_ABORTWARNING
!define MUI_ICON "${__FILEDIR__}\tdt_icon.ico"
!define MUI_UNICON "${__FILEDIR__}\tdt_icon.ico"
!define MUI_WELCOMEPAGE_TITLE "Welcome to ${PRODUCT_NAME} Setup"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${PRODUCT_NAME}.$\r$\n$\r$\nIt is recommended to close all other applications before continuing."
!define MUI_FINISHPAGE_RUN "$INSTDIR\RunTDTKhaoSat.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Launch ${PRODUCT_NAME}"

; Installation pages
!insertmacro MUI_PAGE_WELCOME

; Use license.txt file
!define MUI_LICENSEPAGE_TEXT_BOTTOM "If you accept the terms of the agreement, click I Agree to continue."
!define MUI_LICENSEPAGE_BUTTON "I Agree"
!insertmacro MUI_PAGE_LICENSE "${__FILEDIR__}\license.txt"

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstall pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language
!insertmacro MUI_LANGUAGE "English"

; Output file info
OutFile "${__FILEDIR__}\TDTKhaoSatTongHop_Setup.exe"
InstallDir "$PROGRAMFILES\TDTKhaoSatTongHop"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "Install program" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite on
  
  ; Set correct code page
  System::Call 'kernel32::SetConsoleOutputCP(i 65001)'
  
  ; Check Microsoft Edge
  IfFileExists "$PROGRAMFILES\Microsoft\Edge\Application\msedge.exe" EdgeFound
  IfFileExists "$PROGRAMFILES (x86)\Microsoft\Edge\Application\msedge.exe" EdgeFound
  
  MessageBox MB_YESNO|MB_ICONQUESTION "Microsoft Edge was not found. The application requires Microsoft Edge to function properly.$\r$\n$\r$\nWould you like to open the Edge download page?" IDNO EdgeSkip
    ExecShell "open" "https://www.microsoft.com/en-us/edge"
  EdgeSkip:
  
  EdgeFound:
  ; Copy files
  File "${__FILEDIR__}\dist\TDTKhaoSatTongHop.exe"
  File "${__FILEDIR__}\tdt_logo.png"
  File "${__FILEDIR__}\license.txt"
  
  ; Create browser data directory
  CreateDirectory "$INSTDIR\EdgeUserData"
  
  ; Create batch file to launch app with browser data directory parameter
  FileOpen $0 "$INSTDIR\RunTDTKhaoSat.bat" w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "chcp 65001 >nul$\r$\n"
  FileWrite $0 'cmd /u /c start "" "$INSTDIR\TDTKhaoSatTongHop.exe" --edge-user-data-dir="$INSTDIR\EdgeUserData"$\r$\n'
  FileClose $0
  
  ; Create shortcuts
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\RunTDTKhaoSat.bat" "" "$INSTDIR\TDTKhaoSatTongHop.exe"
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\RunTDTKhaoSat.bat" "" "$INSTDIR\TDTKhaoSatTongHop.exe"
  
  ; Write registry info
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\TDTKhaoSatTongHop.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\TDTKhaoSatTongHop.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Section "Uninstall"
  ; Delete shortcuts
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  RMDir "$SMPROGRAMS\${PRODUCT_NAME}"
  
  ; Delete installed files
  Delete "$INSTDIR\TDTKhaoSatTongHop.exe"
  Delete "$INSTDIR\RunTDTKhaoSat.bat"
  Delete "$INSTDIR\tdt_logo.png"
  Delete "$INSTDIR\license.txt"
  Delete "$INSTDIR\uninstall.exe"
  RMDir /r "$INSTDIR\EdgeUserData"
  RMDir "$INSTDIR"
  
  ; Delete registry
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
SectionEnd
