; TDT Survey Tool Installer Script
Unicode true

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"
!include "FileFunc.nsh"

; Application Info
!define PRODUCT_NAME "TDTKhaoSatTongHop"
!define PRODUCT_VERSION "1.2"
!define PRODUCT_PUBLISHER "Hy"
!define PRODUCT_WEB_SITE "https://github.com/HyIsNoob"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define EDGE_URL "https://www.microsoft.com/en-us/edge"

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

Page custom EdgeCheckPage EdgeCheckPageLeave
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstall pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language - still using English even for Vietnamese users
!insertmacro MUI_LANGUAGE "English"

; Global variables
Var Dialog
Var EdgeCheckbox
Var EdgeInstalled
Var InstallEdge

; Output file info
OutFile "${__FILEDIR__}\TDTKhaoSatTongHop_Setup.exe"
InstallDir "$PROGRAMFILES\TDTKhaoSatTongHop"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

; Function to check if Microsoft Edge is installed
Function DetectEdge
  ${If} ${FileExists} "$PROGRAMFILES\Microsoft\Edge\Application\msedge.exe"
    StrCpy $EdgeInstalled "1"
  ${ElseIf} ${FileExists} "$PROGRAMFILES (x86)\Microsoft\Edge\Application\msedge.exe"
    StrCpy $EdgeInstalled "1"
  ${Else}
    ; Check if Windows 10/11 (usually has Edge pre-installed)
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentBuild"
    ${If} $0 >= "10240"
      StrCpy $EdgeInstalled "1" ; Assume Windows 10/11 has Edge
    ${Else}
      StrCpy $EdgeInstalled "0"
    ${EndIf}
  ${EndIf}
FunctionEnd

; Edge check page
Function EdgeCheckPage
  ; Check if Edge is installed
  Call DetectEdge
  
  ${If} $EdgeInstalled == "1"
    ; If Edge is already installed, skip this page
    Abort
  ${EndIf}

  ; Create dialog page
  !insertmacro MUI_HEADER_TEXT "Microsoft Edge Check" "${PRODUCT_NAME} requires Microsoft Edge."
  
  nsDialogs::Create 1018
  Pop $Dialog
  
  ${If} $Dialog == error
    Abort
  ${EndIf}
  
  ; Add message
  ${NSD_CreateLabel} 0 0 100% 40u "Microsoft Edge was not found on your computer. ${PRODUCT_NAME} needs Microsoft Edge to work correctly.$\r$\n$\r$\nWould you like to download Microsoft Edge?"
  Pop $0
  
  ; Add checkbox
  ${NSD_CreateCheckbox} 0 50u 100% 10u "Open Microsoft Edge download page (Recommended)"
  Pop $EdgeCheckbox
  ${NSD_Check} $EdgeCheckbox ; Checked by default
  
  nsDialogs::Show
FunctionEnd

Function EdgeCheckPageLeave
  ${NSD_GetState} $EdgeCheckbox $InstallEdge
FunctionEnd

Section "Download Microsoft Edge" SEC_EDGE
  ${If} $EdgeInstalled == "0"
    ${If} $InstallEdge == ${BST_CHECKED}
      DetailPrint "Opening Microsoft Edge download page..."
      ExecShell "open" "${EDGE_URL}"
      MessageBox MB_OK|MB_ICONINFORMATION "Microsoft Edge download page has been opened in your default browser.$\r$\n$\r$\nPlease download and install Microsoft Edge before using the application."
    ${Else}
      MessageBox MB_OK|MB_ICONEXCLAMATION "Microsoft Edge is not installed. For the application to work properly, please download and install it manually from: ${EDGE_URL}"
    ${EndIf}
  ${EndIf}
SectionEnd

Section "Install program" SEC01
  SetOutPath "$INSTDIR"
  
  ; Copy files
  File "${__FILEDIR__}\dist\TDTKhaoSatTongHop.exe"
  File "${__FILEDIR__}\tdt_logo.png"
  File "${__FILEDIR__}\license.txt"
  
  ; Create browser data directory with separate structure
  CreateDirectory "$INSTDIR\EdgeUserData"
  CreateDirectory "$INSTDIR\EdgeUserData\gv"
  CreateDirectory "$INSTDIR\EdgeUserData\cdr"
  
  ; Create batch file to launch app with browser data directory parameter
  FileOpen $0 "$INSTDIR\RunTDTKhaoSat.bat" w
  FileWrite $0 "@echo off$\r$\n"
  FileWrite $0 "chcp 65001 >nul$\r$\n"
  FileWrite $0 'start "" "$INSTDIR\TDTKhaoSatTongHop.exe" --edge-user-data-dir="$INSTDIR\EdgeUserData"$\r$\n'
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
  
  ; Delete registry entries
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
SectionEnd
