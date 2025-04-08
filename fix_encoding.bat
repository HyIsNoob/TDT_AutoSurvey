@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

title Fix Encoding Issues
echo ===== Kiểm tra và sửa vấn đề encoding UTF-8 =====
echo.

REM Tạo file log
set "LOG_FILE=fix_encoding_log.txt"
echo Thời gian: %date% %time% > "%LOG_FILE%"
echo === BẮT ĐẦU KIỂM TRA ENCODING === >> "%LOG_FILE%"

REM Chuyển đến thư mục chứa script
cd /d "%~dp0"
echo Thư mục hiện tại: %CD%
echo Thư mục hiện tại: %CD% >> "%LOG_FILE%"

REM ==================================================
REM 1. Tạo file license.txt
REM ==================================================
echo.
echo 1. Đang tạo license.txt với encoding UTF-8...
echo 1. Đang tạo license.txt với encoding UTF-8... >> "%LOG_FILE%"

REM Kiểm tra file license.txt đã tồn tại chưa
if exist "license.txt" (
    echo License.txt đã tồn tại, đang tạo bản backup...
    copy "license.txt" "license.txt.bak" >nul 2>&1
    if errorlevel 1 (
        echo [LỖI] Không thể tạo bản backup của license.txt
        echo [LỖI] Không thể tạo bản backup của license.txt >> "%LOG_FILE%"
    ) else (
        echo Đã tạo bản backup license.txt.bak
        echo Đã tạo bản backup license.txt.bak >> "%LOG_FILE%"
    )
)

REM Tạo file license.txt với nội dung
echo Đang tạo license.txt mới...
(
echo GIẤY PHÉP SỬ DỤNG TDT SURVEY TOOL
echo Phần mềm này được phát triển và sở hữu bởi Hy.
echo.
echo ĐIỀU KHOẢN SỬ DỤNG:
echo.
echo Bạn được phép cài đặt và sử dụng phần mềm này cho mục đích cá nhân.
echo Bạn không được phép phân phối lại, sửa đổi, hoặc đảo ngược mã nguồn của phần mềm.
echo Phần mềm này chỉ được sử dụng với mục đích hỗ trợ sinh viên trong việc hoàn thành khảo sát.
echo Tác giả không chịu trách nhiệm với bất kỳ hậu quả nào phát sinh từ việc sử dụng phần mềm.
echo Bằng việc cài đặt và sử dụng phần mềm, bạn đã đồng ý với các điều khoản trên.
echo.
echo © 2025 Hy - Mọi quyền được bảo lưu
) > "license.txt" 2>nul

REM Kiểm tra nếu tạo thành công
if exist "license.txt" (
    echo Đã tạo license.txt thành công!
    echo Đã tạo license.txt thành công! >> "%LOG_FILE%"
) else (
    echo [LỖI] Không thể tạo file license.txt!
    echo [LỖI] Không thể tạo file license.txt! >> "%LOG_FILE%"
)

REM ==================================================
REM 2. Kiểm tra encoding trong các file batch
REM ==================================================
echo.
echo 2. Đang kiểm tra các file batch...
echo 2. Đang kiểm tra các file batch... >> "%LOG_FILE%"

REM Lưu tên file hiện tại
set "CURRENT_FILE=%~nx0"
echo File hiện tại: %CURRENT_FILE% >> "%LOG_FILE%"

for %%f in (*.bat) do (
    REM Chỉ xử lý các file khác với file hiện tại
    if /I not "%%~nxf"=="%CURRENT_FILE%" (
        echo Đang kiểm tra: %%~nxf
        echo Đang kiểm tra: %%~nxf >> "%LOG_FILE%"
        
        REM Kiểm tra xem file có chứa chcp 65001 không
        findstr /i /c:"chcp 65001" "%%~f" >nul
        if errorlevel 1 (
            echo   [CẢNH BÁO] File %%~nxf không có lệnh chcp 65001 >> "%LOG_FILE%"
            echo   [CẢNH BÁO] File %%~nxf không có lệnh chcp 65001
            
            REM Cố gắng thêm chcp 65001 vào đầu file
            echo   - Đang thêm chcp 65001...
            
            set "TEMP_FILE=%%~nf_temp.bat"
            
            REM Tạo file tạm với lệnh chcp ở đầu
            echo @echo off > "!TEMP_FILE!"
            echo chcp 65001 ^>nul >> "!TEMP_FILE!"
            
            REM Thêm nội dung gốc (bỏ qua dòng đầu nếu là @echo off)
            for /f "skip=1 delims=" %%l in ('type "%%~f"') do (
                echo %%l >> "!TEMP_FILE!"
            )
            
            REM Sao lưu file gốc
            copy "%%~f" "%%~f.bak" >nul 2>&1
            if errorlevel 1 (
                echo   [LỖI] Không thể tạo file backup
                echo   [LỖI] Không thể tạo file backup cho %%~nxf >> "%LOG_FILE%"
            ) else (
                REM Thay thế file gốc bằng file tạm
                copy "!TEMP_FILE!" "%%~f" >nul 2>&1
                if errorlevel 1 (
                    echo   [LỖI] Không thể cập nhật file
                    echo   [LỖI] Không thể cập nhật file %%~nxf >> "%LOG_FILE%"
                ) else (
                    echo   [FIXED] Đã thêm chcp 65001
                    echo   [FIXED] Đã thêm chcp 65001 vào %%~nxf >> "%LOG_FILE%"
                )
                
                REM Xóa file tạm
                del "!TEMP_FILE!" >nul 2>&1
            )
        ) else (
            echo   [OK] File đã có lệnh chcp 65001
            echo   [OK] File %%~nxf đã có lệnh chcp 65001 >> "%LOG_FILE%"
        )
    )
)

REM ==================================================
REM 3. Kiểm tra các file NSIS
REM ==================================================
echo.
echo 3. Đang kiểm tra các file NSIS...
echo 3. Đang kiểm tra các file NSIS... >> "%LOG_FILE%"

set "NSI_FILES_FOUND=0"

for %%f in (*.nsi) do (
    set /a "NSI_FILES_FOUND+=1"
    echo Đang kiểm tra: %%~nxf
    echo Đang kiểm tra: %%~nxf >> "%LOG_FILE%"
    
    REM Kiểm tra xem file có chứa "Unicode true" không
    findstr /i /c:"Unicode true" "%%~f" >nul
    if errorlevel 1 (
        echo   [CẢNH BÁO] File %%~nxf không có khai báo Unicode true
        echo   [CẢNH BÁO] File %%~nxf không có khai báo Unicode true >> "%LOG_FILE%"
        
        REM Sao lưu file gốc
        copy "%%~f" "%%~f.bak" >nul 2>&1
        if errorlevel 1 (
            echo   [LỖI] Không thể tạo file backup
            echo   [LỖI] Không thể tạo file backup cho %%~nxf >> "%LOG_FILE%"
        ) else (
            echo   [OK] Đã tạo backup %%~nxf.bak
            
            REM Tạo file tạm với thêm Unicode true
            set "TEMP_NSI=%%~nf_temp.nsi"
            echo ; TDT Khảo Sát Installer Script > "!TEMP_NSI!"
            echo Unicode true >> "!TEMP_NSI!"
            echo. >> "!TEMP_NSI!"
            
            REM Thêm nội dung của file gốc
            type "%%~f" | findstr /v /i /c:"; TDT" >> "!TEMP_NSI!"
            
            REM Thay thế file gốc
            copy "!TEMP_NSI!" "%%~f" >nul 2>&1
            if errorlevel 1 (
                echo   [LỖI] Không thể cập nhật file
                echo   [LỖI] Không thể cập nhật file %%~nxf >> "%LOG_FILE%"
            ) else (
                echo   [FIXED] Đã thêm Unicode true
                echo   [FIXED] Đã thêm Unicode true vào %%~nxf >> "%LOG_FILE%"
            )
            
            REM Xóa file tạm
            del "!TEMP_NSI!" >nul 2>&1
        )
        
        REM Kiểm tra và sửa lỗi LICENSE_TEXT trong file NSIS
        findstr /i /c:"LICENSE_TEXT" "%%~f" >nul
        if not errorlevel 1 (
            echo   - Kiểm tra LICENSE_TEXT trong %%~nxf
            echo   - Kiểm tra LICENSE_TEXT trong %%~nxf >> "%LOG_FILE%"
            
            set "TEMP_NSI=%%~nf_no_lictext.nsi"
            type "%%~f" | findstr /v /i /c:"LICENSE_TEXT" > "!TEMP_NSI!"
            
            copy "!TEMP_NSI!" "%%~f" >nul 2>&1
            if errorlevel 1 (
                echo   [LỖI] Không thể sửa LICENSE_TEXT
                echo   [LỖI] Không thể sửa LICENSE_TEXT trong %%~nxf >> "%LOG_FILE%"
            ) else (
                echo   [FIXED] Đã xóa LICENSE_TEXT
                echo   [FIXED] Đã xóa LICENSE_TEXT từ %%~nxf >> "%LOG_FILE%"
            )
            
            del "!TEMP_NSI!" >nul 2>&1
        )
    ) else (
        echo   [OK] File đã có Unicode true
        echo   [OK] File %%~nxf đã có Unicode true >> "%LOG_FILE%"
    )
)

if %NSI_FILES_FOUND% equ 0 (
    echo   [INFO] Không tìm thấy file .nsi nào
    echo   [INFO] Không tìm thấy file .nsi nào >> "%LOG_FILE%"
)

REM Chuyển đổi các file .nsi sang UTF-8 nếu cần
for %%f in (*.nsi) do (
    echo Đang kiểm tra encoding của %%f...
    findstr /R /C:"Unicode true" "%%f" >nul
    if errorlevel 1 (
        echo   [CẢNH BÁO] File %%f không có khai báo Unicode true. Đang thêm...
        echo Unicode true > temp.nsi
        type "%%f" >> temp.nsi
        move /Y temp.nsi "%%f" >nul
        echo   [OK] Đã thêm Unicode true vào %%f
    )
)

REM ==================================================
REM 4. Kiểm tra simplified_installer.nsi đặc biệt
REM ==================================================
if exist simplified_installer.nsi (
    echo.
    echo 4. Kiểm tra đặc biệt cho simplified_installer.nsi...
    echo 4. Kiểm tra đặc biệt cho simplified_installer.nsi... >> "%LOG_FILE%"
    
    REM Đếm số Section "Uninstall"
    set "UNINSTALL_COUNT=0"
    for /f "usebackq delims=" %%i in (`findstr /c:"Section \"Uninstall\"" simplified_installer.nsi`) do (
        set /a "UNINSTALL_COUNT+=1"
    )
    
    echo   Số lượng Section "Uninstall": !UNINSTALL_COUNT!
    echo   Số lượng Section "Uninstall": !UNINSTALL_COUNT! >> "%LOG_FILE%"
    
    if !UNINSTALL_COUNT! gtr 1 (
        echo   [CẢNH BÁO] Phát hiện nhiều Section "Uninstall"
        echo   [CẢNH BÁO] Phát hiện nhiều Section "Uninstall" trong simplified_installer.nsi >> "%LOG_FILE%"
        
        REM Tạo bản sao lưu
        copy simplified_installer.nsi simplified_installer.bak >nul 2>&1
        echo   [INFO] Đã tạo bản backup simplified_installer.bak
        echo   [INFO] Đã tạo bản backup simplified_installer.bak >> "%LOG_FILE%"
        
        echo   [THÔNG BÁO] Vui lòng sửa thủ công file simplified_installer.nsi để chỉ có 1 Section "Uninstall"
        echo   [THÔNG BÁO] Vui lòng sửa thủ công file simplified_installer.nsi >> "%LOG_FILE%"
    ) else (
        echo   [OK] File simplified_installer.nsi chỉ có 1 Section "Uninstall"
        echo   [OK] File simplified_installer.nsi chỉ có 1 Section "Uninstall" >> "%LOG_FILE%"
    )
) else (
    echo   [INFO] Không tìm thấy file simplified_installer.nsi
    echo   [INFO] Không tìm thấy file simplified_installer.nsi >> "%LOG_FILE%"
)

REM ==================================================
REM 5. Kết thúc và hiển thị thông báo
REM ==================================================
echo.
echo === Quá trình kiểm tra hoàn tất ===
echo Thông tin chi tiết được lưu trong file: %LOG_FILE%
echo.
echo === Quá trình kiểm tra hoàn tất === >> "%LOG_FILE%"

echo Hãy chạy build_tonghop.bat để build ứng dụng với encoding đúng
echo.
echo Nhấn phím bất kỳ để thoát...
pause >nul
