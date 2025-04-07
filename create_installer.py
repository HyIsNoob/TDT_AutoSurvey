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
            
            draw.text((80, 85), "TDT", fill=(255, 255, 255, 255), font=font)
            
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
        if not os.path.exists("build_app.spec"):
            spec_content = """# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['ToolKhaoSatTDT.py'],
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
    name='TDT Survey Tool',
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
            with open("build_app.spec", "w") as f:
                f.write(spec_content)
            print("✅ Tạo file build_app.spec thành công")
        
        # Xóa build cũ để đảm bảo build mới không bị ảnh hưởng
        if os.path.exists("build"):
            shutil.rmtree("build")
        if os.path.exists("dist"):
            shutil.rmtree("dist")
        
        # Chạy PyInstaller với file spec
        subprocess.run(["pyinstaller", "build_app.spec"], check=True)
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
        
        # Chạy NSIS để tạo installer
        subprocess.run([nsis_path, "installer.nsi"], check=True)
        print("✅ Tạo installer thành công!")
        
        # Xác định đường dẫn đến file installer
        installer_path = os.path.abspath("TDT_Survey_Tool_Setup.exe")
        
        if os.path.exists(installer_path):
            print(f"\n✅ Installer đã được tạo tại: {installer_path}")
            return True
        else:
            print("❌ Không tìm thấy file installer sau khi build.")
            return False
            
    except subprocess.CalledProcessError as e:
        print(f"❌ Lỗi khi chạy NSIS: {e}")
        return False
    except Exception as e:
        print(f"❌ Lỗi không xác định khi tạo installer: {e}")
        return False

def main():
    """Hàm chính để chạy quá trình tạo installer"""
    print("=== Bắt đầu quá trình tạo installer cho TDT Survey Tool ===\n")
    
    # Kiểm tra xem file chính có tồn tại không
    if not os.path.exists("ToolKhaoSatTDT.py"):
        print("❌ Không tìm thấy file ToolKhaoSatTDT.py!")
        print("Vui lòng đảm bảo bạn đang chạy script này trong cùng thư mục với ToolKhaoSatTDT.py")
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
