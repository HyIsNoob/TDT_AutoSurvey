; TDT Survey Tool Installer Script

!include "MUI2.nsh"

; Định nghĩa thông tin ứng dụng
!define PRODUCT_NAME "TDT Survey Tool"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "Hy"
!define PRODUCT_WEB_SITE "https://github.com/HyIsNoob"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

; Giao diện
!define MUI_ABORTWARNING
!define MUI_ICON "${__FILEDIR__}\tdt_icon.ico"
!define MUI_UNICON "${__FILEDIR__}\tdt_icon.ico"
!define MUI_WELCOMEPAGE_TITLE "Chào mừng đến với trình cài đặt ${PRODUCT_NAME}"
!define MUI_WELCOMEPAGE_TEXT "Trình cài đặt sẽ hướng dẫn bạn cài đặt ${PRODUCT_NAME}.$\r$\n$\r$\nKhuyến nghị đóng các ứng dụng khác trước khi tiếp tục."
!define MUI_FINISHPAGE_RUN "$INSTDIR\TDT Survey Tool.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Khởi động ${PRODUCT_NAME}"

; Trang cài đặt
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Trang gỡ cài đặt
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Ngôn ngữ
!insertmacro MUI_LANGUAGE "Vietnamese"

; Thông tin output file
OutFile "${__FILEDIR__}\TDT_Survey_Tool_Setup.exe"
InstallDir "$PROGRAMFILES\TDT Survey Tool"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "Cài đặt chương trình" SEC01
  SetOutPath "$INSTDIR"
  
  ; Sao chép các file
  File /r "${__FILEDIR__}\dist\*.*"
  
  ; Tạo shortcut
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\TDT Survey Tool.exe"
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\TDT Survey Tool.exe"
  
  ; Ghi thông tin vào registry
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\TDT Survey Tool.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\TDT Survey Tool.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Section "Uninstall"
  ; Xóa shortcut
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  RMDir "$SMPROGRAMS\${PRODUCT_NAME}"
  
  ; Xóa file cài đặt
  RMDir /r "$INSTDIR"
  
  ; Xóa registry
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
SectionEnd
