; TDT Survey Tool Installer Script
Unicode true

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"
!include "FileFunc.nsh"

; Định nghĩa thông tin ứng dụng
!define PRODUCT_NAME "TDT Survey Tool"
!define PRODUCT_VERSION "1.2"
!define PRODUCT_PUBLISHER "Hy"
!define PRODUCT_WEB_SITE "https://github.com/HyIsNoob"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define EDGE_URL "https://go.microsoft.com/fwlink/?linkid=2108834&Channel=Stable&language=vi"
!define EDGE_INSTALLER "$PLUGINSDIR\edge_installer.exe"

; Giao diện
!define MUI_ABORTWARNING
!define MUI_ICON "${__FILEDIR__}\tdt_icon.ico"
!define MUI_UNICON "${__FILEDIR__}\tdt_icon.ico"
!define MUI_WELCOMEPAGE_TITLE "Chào mừng đến với trình cài đặt ${PRODUCT_NAME}"
!define MUI_WELCOMEPAGE_TEXT "Trình cài đặt sẽ hướng dẫn bạn cài đặt ${PRODUCT_NAME}.$\r$\n$\r$\nKhuyến nghị đóng các ứng dụng khác trước khi tiếp tục."
!define MUI_FINISHPAGE_RUN "$INSTDIR\TDT Survey Manager.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Khởi động ${PRODUCT_NAME}"

; Trang cài đặt
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${__FILEDIR__}\license.txt"
Page custom EdgeCheckPage EdgeCheckPageLeave
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Trang gỡ cài đặt
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Ngôn ngữ
!insertmacro MUI_LANGUAGE "Vietnamese"

; Biến toàn cục
Var Dialog
Var EdgeCheckbox
Var EdgeInstalled
Var InstallEdge

; Thông tin output file
OutFile "${__FILEDIR__}\TDT_Survey_Tool_Setup.exe"
InstallDir "$PROGRAMFILES\TDT Survey Tool"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

; Hàm kiểm tra Edge đã được cài đặt chưa
Function DetectEdge
  ${If} ${FileExists} "$PROGRAMFILES\Microsoft\Edge\Application\msedge.exe"
    StrCpy $EdgeInstalled "1"
  ${ElseIf} ${FileExists} "$PROGRAMFILES (x86)\Microsoft\Edge\Application\msedge.exe"
    StrCpy $EdgeInstalled "1"
  ${Else}
    ; Kiểm tra xem có phải Windows 10/11 không (thường có Edge được cài đặt sẵn)
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentBuild"
    ${If} $0 >= "10240"
      StrCpy $EdgeInstalled "1" ; Giả định là Windows 10/11 đã có Edge
    ${Else}
      StrCpy $EdgeInstalled "0"
    ${EndIf}
  ${EndIf}
FunctionEnd

; Trang kiểm tra Edge
Function EdgeCheckPage
  ; Kiểm tra Edge đã cài đặt chưa
  Call DetectEdge
  
  ${If} $EdgeInstalled == "1"
    ; Nếu Edge đã được cài đặt, bỏ qua trang này
    Abort
  ${EndIf}

  ; Tạo trang dialog
  !insertmacro MUI_HEADER_TEXT "Kiểm tra Microsoft Edge" "TDT Survey Tool yêu cầu Microsoft Edge để hoạt động."
  
  nsDialogs::Create 1018
  Pop $Dialog
  
  ${If} $Dialog == error
    Abort
  ${EndIf}
  
  ; Thêm thông báo
  ${NSD_CreateLabel} 0 0 100% 40u "Không tìm thấy Microsoft Edge trên máy tính của bạn. TDT Survey Tool cần Microsoft Edge để hoạt động chính xác.$\r$\n$\r$\nBạn có muốn cài đặt Microsoft Edge không?"
  Pop $0
  
  ; Thêm checkbox
  ${NSD_CreateCheckbox} 0 50u 100% 10u "Tải và cài đặt Microsoft Edge (Khuyến nghị)"
  Pop $EdgeCheckbox
  ${NSD_Check} $EdgeCheckbox ; Mặc định được chọn
  
  nsDialogs::Show
FunctionEnd

Function EdgeCheckPageLeave
  ${NSD_GetState} $EdgeCheckbox $InstallEdge
FunctionEnd

Section "Cài đặt Microsoft Edge" SEC_EDGE
  ${If} $EdgeInstalled == "0"
  ${AndIf} $InstallEdge == ${BST_CHECKED}
    ; Tạo thư mục tạm
    InitPluginsDir
    
    ; Hiện thông báo đang tải Edge
    DetailPrint "Đang tải Microsoft Edge... Vui lòng chờ"
    inetc::get /CAPTION "Tải Microsoft Edge" /POPUP "" "${EDGE_URL}" "${EDGE_INSTALLER}" /END
    Pop $0
    
    ${If} $0 == "OK"
      DetailPrint "Tải Microsoft Edge thành công. Bắt đầu cài đặt..."
      ExecWait '"${EDGE_INSTALLER}" /silent /install'
      DetailPrint "Đã cài đặt Microsoft Edge"
    ${Else}
      DetailPrint "Không thể tải Microsoft Edge: $0"
      MessageBox MB_OK|MB_ICONEXCLAMATION "Không thể tải Microsoft Edge. Bạn có thể cài đặt thủ công từ: https://www.microsoft.com/vi-vn/edge"
    ${EndIf}
  ${EndIf}
SectionEnd

Section "Cài đặt chương trình" SEC01
  SetOutPath "$INSTDIR"
  
  ; Sao chép các file
  File /r "${__FILEDIR__}\dist\*.*"
  
  ; Tạo shortcut
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME} Manager.lnk" "$INSTDIR\TDT Survey Manager.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Khảo Sát Giảng Viên.lnk" "$INSTDIR\TDT Survey Tool.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Khảo Sát Chuẩn Đầu Ra.lnk" "$INSTDIR\TDT KS Chuẩn Đầu Ra.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Khảo Sát Tổng Hợp.lnk" "$INSTDIR\TDT Khảo Sát Tổng Hợp.exe"
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\TDT Survey Manager.exe"
  
  ; Ghi thông tin vào registry
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\TDT Survey Manager.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\TDT Survey Manager.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Section "Uninstall"
  ; Xóa shortcut
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME} Manager.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Khảo Sát Giảng Viên.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Khảo Sát Chuẩn Đầu Ra.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Khảo Sát Tổng Hợp.lnk"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  RMDir "$SMPROGRAMS\${PRODUCT_NAME}"
  
  ; Xóa file cài đặt
  RMDir /r "$INSTDIR"
  
  ; Xóa registry
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
SectionEnd
