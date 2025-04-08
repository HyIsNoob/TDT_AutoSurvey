import os
import subprocess
import sys
import shutil
from PIL import Image, ImageDraw, ImageFont

def create_icon():
    """Tạo file icon nếu chưa có"""
    if not os.path.exists("tdt_icon.ico"):
        print("Tạo file icon...")
        try:
            # Tạo hình ảnh trắng kích thước 256x256
            img = Image.new('RGBA', (256, 256), color=(18, 17, 48, 255))  # Màu nền #121130
            draw = ImageDraw.Draw(img)
            
            # Vẽ vòng tròn
            draw.ellipse((48, 48, 208, 208), fill=(79, 80, 138, 255))  # Màu #4F508A
            
            # Thêm chữ TDT
            try:
                font = ImageFont.truetype("arial.ttf", 80)
            except:
                font = ImageFont.load_default()
            
            draw.text((80, 85), "KHY", fill=(255, 255, 255, 255), font=font)
            
            # Lưu dưới dạng icon
            img.save('tdt_icon.ico', format='ICO', sizes=[(256, 256)])
            print("✅ Tạo icon thành công!")
        except Exception as e:
            print(f"❌ Lỗi khi tạo icon: {e}")
            print("Tiếp tục sử dụng icon mặc định nếu có...")

def check_resources():
    """Kiểm tra và chuẩn bị các tài nguyên cần thiết"""
    # Kiểm tra logo TDT
    if not os.path.exists("tdt_logo.png"):
        print("⚠️ Không tìm thấy file tdt_logo.png")
        print("Đang tìm logo...")
        # Tìm trong các thư mục phổ biến
        potential_paths = [
            os.path.join("assets", "tdt_logo.png"),
            os.path.join("..", "assets", "tdt_logo.png"),
            os.path.join("resources", "tdt_logo.png"),
            os.path.join("images", "tdt_logo.png")
        ]
        
        for path in potential_paths:
            if os.path.exists(path):
                print(f"Tìm thấy logo tại: {path}")
                shutil.copy(path, "tdt_logo.png")
                break
        else:
            print("❌ Không thể tìm thấy file logo, installer có thể không hoạt động đúng!")
            user_input = input("Bạn có muốn tiếp tục không? (y/n): ").strip().lower()
            if user_input != 'y':
                print("Hủy tiến trình build.")
                sys.exit(1)
    else:
        print("✅ Đã tìm thấy file tdt_logo.png")

def run_pyinstaller():
    """Chạy PyInstaller để đóng gói ứng dụng"""
    print("\n--- Đang build ứng dụng bằng PyInstaller ---")
    try:
        # Tạo file spec nếu chưa có
        if not os.path.exists("build_tonghop.spec"):
            spec_content = """# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['ToolKhaoSatTongHop.py'],
    pathex=[],
    binaries=[],
    datas=[('tdt_logo.png', '.')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='TDT Khảo Sát Tổng Hợp',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='tdt_icon.ico',
)
"""
            with open("build_tonghop.spec", "w") as f:
                f.write(spec_content)
            print("✅ Tạo file build_tonghop.spec thành công")
        
        # Xóa build cũ để đảm bảo build mới không bị ảnh hưởng
        if os.path.exists("build"):
            shutil.rmtree("build")
        if os.path.exists("dist"):
            shutil.rmtree("dist")
        
        # Chạy PyInstaller với file spec
        subprocess.run(["pyinstaller", "build_tonghop.spec"], check=True)
        print("✅ Build PyInstaller thành công!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Lỗi khi chạy PyInstaller: {e}")
        return False
    except Exception as e:
        print(f"❌ Lỗi không xác định khi build: {e}")
        return False

def run_nsis():
    """Chạy NSIS để tạo installer"""
    print("\n--- Đang tạo installer bằng NSIS ---")
    try:
        # Xác định đường dẫn NSIS
        nsis_paths = [
            r"C:\Program Files (x86)\NSIS\makensis.exe",
            r"C:\Program Files\NSIS\makensis.exe"
        ]
        
        nsis_path = None
        for path in nsis_paths:
            if os.path.exists(path):
                nsis_path = path
                break
        
        if not nsis_path:
            print("❌ Không tìm thấy NSIS. Vui lòng cài đặt NSIS và thử lại.")
            print("Bạn có thể tải NSIS tại: https://nsis.sourceforge.io/Download")
            return False
        
        # Thử tạo installer với installer_tonghop.nsi trước
        print("Đang thử sử dụng installer_tonghop.nsi...")
        try:
            subprocess.run([nsis_path, "installer_tonghop.nsi"], check=True)
            print("✅ Tạo installer thành công!")
            installer_path = os.path.abspath("TDT_KhaoSatTongHop_Setup.exe")
            print(f"\n✅ Installer đã được tạo tại: {installer_path}")
            return True
        except subprocess.CalledProcessError:
            print("⚠️ Không thể sử dụng installer_tonghop.nsi, đang thử simplified_installer.nsi...")
            
            # Nếu không có simplified_installer.nsi, tạo file
            if not os.path.exists("simplified_installer.nsi"):
                print("Đang tạo file simplified_installer.nsi...")
                with open("simplified_installer.nsi", "w", encoding="utf-8") as f:
                    f.write("""
; TDT Khảo Sát Tổng Hợp Installer Script - Simplified version
Unicode true

!include "MUI2.nsh"
!include "LogicLib.nsh"

; Định nghĩa thông tin ứng dụng
!define PRODUCT_NAME "TDT Khảo Sát Tổng Hợp"
!define PRODUCT_VERSION "1.2"
!define PRODUCT_PUBLISHER "Hy"
!define PRODUCT_DIR_REGKEY "Software\\Microsoft\\Windows\\CurrentVersion\\App Paths\\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${PRODUCT_NAME}"

; Giao diện
!define MUI_ABORTWARNING
!define MUI_ICON "${__FILEDIR__}\\tdt_icon.ico"
!define MUI_UNICON "${__FILEDIR__}\\tdt_icon.ico"
!define MUI_WELCOMEPAGE_TITLE "Chào mừng đến với trình cài đặt ${PRODUCT_NAME}"
!define MUI_WELCOMEPAGE_TEXT "Trình cài đặt sẽ hướng dẫn bạn cài đặt ${PRODUCT_NAME}.$\\r$\\n$\\r$\\nKhuyến nghị đóng các ứng dụng khác trước khi tiếp tục."
!define MUI_FINISHPAGE_RUN "$INSTDIR\\RunTDTKhaoSat.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Khởi động ${PRODUCT_NAME}"

; Trang cài đặt
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${__FILEDIR__}\\license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Trang gỡ cài đặt
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Ngôn ngữ
!insertmacro MUI_LANGUAGE "Vietnamese"

; Thông tin output file
OutFile "${__FILEDIR__}\\TDT_KhaoSatTongHop_Setup.exe"
InstallDir "$PROGRAMFILES\\TDT Khao Sat Tong Hop"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "Cài đặt chương trình" SEC01
  SetOutPath "$INSTDIR"
  
  ; Kiểm tra Microsoft Edge
  IfFileExists "$PROGRAMFILES\\Microsoft\\Edge\\Application\\msedge.exe" EdgeFound
  IfFileExists "$PROGRAMFILES (x86)\\Microsoft\\Edge\\Application\\msedge.exe" EdgeFound
  
  MessageBox MB_YESNO|MB_ICONQUESTION "Microsoft Edge không được tìm thấy. Phần mềm yêu cầu Microsoft Edge để hoạt động chính xác.$\\r$\\n$\\r$\\nBạn có muốn mở trang tải Edge không?" IDNO EdgeSkip
    ExecShell "open" "https://www.microsoft.com/vi-vn/edge"
  EdgeSkip:
  
  EdgeFound:
  ; Sao chép các file
  File "${__FILEDIR__}\\dist\\TDTKhaoSatTongHop.exe"
  File "${__FILEDIR__}\\tdt_logo.png"
  File "${__FILEDIR__}\\license.txt"
  
  ; Tạo thư mục dữ liệu cho trình duyệt
  CreateDirectory "$INSTDIR\\EdgeUserData"
  
  ; Tạo file batch để khởi chạy ứng dụng với tham số browser data directory
  FileOpen $0 "$INSTDIR\\RunTDTKhaoSat.bat" w
  FileWrite $0 "@echo off$\\r$\\n"
  FileWrite $0 'start "" "$INSTDIR\\TDTKhaoSatTongHop.exe" --edge-user-data-dir="$INSTDIR\\EdgeUserData"$\\r$\\n'
  FileClose $0
  
  ; Tạo shortcut
  CreateDirectory "$SMPROGRAMS\\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\\${PRODUCT_NAME}\\${PRODUCT_NAME}.lnk" "$INSTDIR\\RunTDTKhaoSat.bat" "" "$INSTDIR\\TDTKhaoSatTongHop.exe"
  CreateShortCut "$DESKTOP\\${PRODUCT_NAME}.lnk" "$INSTDIR\\RunTDTKhaoSat.bat" "" "$INSTDIR\\TDTKhaoSatTongHop.exe"
  
  ; Ghi thông tin vào registry
  WriteUninstaller "$INSTDIR\\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\\TDTKhaoSatTongHop.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\\TDTKhaoSatTongHop.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Section "Uninstall"
  ; Xóa shortcut
  Delete "$SMPROGRAMS\\${PRODUCT_NAME}\\${PRODUCT_NAME}.lnk"
  Delete "$DESKTOP\\${PRODUCT_NAME}.lnk"
  RMDir "$SMPROGRAMS\\${PRODUCT_NAME}"
  
  ; Xóa file cài đặt
  Delete "$INSTDIR\\TDTKhaoSatTongHop.exe"
  Delete "$INSTDIR\\RunTDTKhaoSat.bat"
  Delete "$INSTDIR\\tdt_logo.png"
  Delete "$INSTDIR\\license.txt"
  Delete "$INSTDIR\\uninstall.exe"
  RMDir /r "$INSTDIR\\EdgeUserData"
  RMDir "$INSTDIR"
  
  ; Xóa registry
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
SectionEnd
""")
            
            # Thử chạy với simplified_installer.nsi
            try:
                subprocess.run([nsis_path, "simplified_installer.nsi"], check=True)
                print("✅ Tạo installer thành công với simplified_installer.nsi!")
                installer_path = os.path.abspath("TDT_KhaoSatTongHop_Setup.exe")
                print(f"\n✅ Installer đã được tạo tại: {installer_path}")
                return True
            except subprocess.CalledProcessError as e:
                print(f"❌ Không thể tạo installer: {e}")
                return False
                
    except Exception as e:
        print(f"❌ Lỗi không xác định khi tạo installer: {e}")
        return False

def main():
    """Hàm chính để chạy quá trình tạo installer"""
    print("=== Bắt đầu quá trình tạo installer cho TDT Khảo Sát Tổng Hợp ===\n")
    
    # Kiểm tra xem file chính có tồn tại không
    if not os.path.exists("ToolKhaoSatTongHop.py"):
        print("❌ Không tìm thấy file ToolKhaoSatTongHop.py!")
        print("Vui lòng đảm bảo bạn đang chạy script này trong cùng thư mục với ToolKhaoSatTongHop.py")
        return
    
    # Tạo icon nếu cần
    create_icon()
    
    # Kiểm tra tài nguyên
    check_resources()
    
    # Chạy PyInstaller
    if run_pyinstaller():
        # Chạy NSIS nếu PyInstaller thành công
        run_nsis()
    
    print("\n=== Quá trình tạo installer hoàn tất ===")

if __name__ == "__main__":
    main()
