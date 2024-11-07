@echo off
chcp 65001 >nul

REM 1. ADB 경로 설정
set ADB_PATH=C:\Users\15U50P\AppData\Local\Android\Sdk\platform-tools
set PATH=%ADB_PATH%;%PATH%

REM 2. EXIFTool 경로 설정
set EXIFTOOL_PATH=C:\exiftool
set PATH=%EXIFTOOL_PATH%;%PATH%
REM 2. 사진 파일 복사
echo 사진 파일 복사 중...

REM Camera 폴더 복사
if not exist "C:\test\Camera" (
    echo "Camera 폴더 생성 중..."
    mkdir "C:\test\Camera"
)

REM Camera 폴더의 JPG 파일 복사
echo "Camera 폴더의 JPG 파일 복사 중..."
adb shell ls /sdcard/DCIM/Camera/*.jpg >nul 2>&1
if errorlevel 1 (
    echo "Camera 폴더에서 JPG 파일을 찾을 수 없습니다."
) else (
    for /f "tokens=*" %%F in ('adb shell ls /sdcard/DCIM/Camera/*.jpg') do (
        set FILE=%%F
        for /f "tokens=*" %%S in ('adb shell stat %%F ^| findstr "Modify"') do (
            for /f "tokens=2,3 delims= " %%A in ("%%S") do (
                set DATE=%%A
                set TIME=%%B
                set NEW_FILENAME=!DATE:~0,4!!DATE:~5,2!!DATE:~8,2!_!TIME:~0,2!!TIME:~3,2!!TIME:~6,2!.jpg
                adb pull %%F "C:\test\Camera\!NEW_FILENAME!" >nul
                echo 파일 다운로드 완료: !NEW_FILENAME!
            )
        )
    )
)

REM SNOW 폴더 확인 및 복사
echo "SNOW 폴더 확인 중..."
adb shell if exist /sdcard/DCIM/Camera/SNOW (
    echo "SNOW 폴더가 발견되었습니다. 파일 복사 중..."
    adb pull /sdcard/DCIM/Camera/SNOW/ "C:\test\Camera\SNOW" >nul
    if errorlevel 1 (
        echo "SNOW 폴더 파일 복사 실패"
    ) else (
        echo "SNOW 폴더 파일 복사 완료"
    )
) else (
    echo "SNOW 폴더가 존재하지 않습니다."
)

REM 4. EXIF 데이터 추출
echo "EXIF 데이터 추출 중..."
if not exist "C:\test\metadata" (
    mkdir "C:\test\metadata"
)
for %%f in (C:\test\Camera\*.jpg) do (
    exiftool -gps* "%%f" > "C:\test\metadata\%%~nf_metadata.txt"
)
echo "EXIF 데이터 추출 완료"

REM 5. 휴지통 파일 복사
echo "휴지통 파일 복사 중..."
adb shell ls /sdcard/Android/data/com.sec.android.gallery3d/files/.Trash >nul 2>&1
if errorlevel 1 (
    echo "휴지통 파일을 찾을 수 없습니다."
) else (
    if not exist "C:\test\Trash" mkdir "C:\test\Trash"
    for /f "tokens=*" %%F in ('adb shell ls /sdcard/Android/data/com.sec.android.gallery3d/files/.Trash') do (
        set FILE=%%F
        adb pull /sdcard/Android/data/com.sec.android.gallery3d/files/.Trash/%%F "C:\test\Trash\%%F.jpg" >nul
        echo 파일 다운로드 완료: Trash\%%F.jpg
    )
)

REM 8. 네이버 MYBOX 캐시 파일 복사
echo "네이버 MYBOX 캐시파일 복사 중..."
if not exist "C:\test\MYBOX_cache" mkdir "C:\test\MYBOX_cache"
adb pull /sdcard/Android/data/com.nhn.android.ndrive/cache/temp/ "C:\test\MYBOX_cache" >nul
if errorlevel 1 (
    echo "MYBOX 캐시파일 복사 실패"
) else (
    echo "MYBOX 캐시파일 복사 완료"
)

REM 9. 소다 앱 임시 사진 파일 복사
echo "소다 앱 캐시파일 복사 중..."
if not exist "C:\test\Soda_cache" mkdir "C:\test\Soda_cache"
adb pull /sdcard/Android/data/com.snowcorp.soda.android/files/temp/ "C:\test\Soda_cache" >nul
if errorlevel 1 (
    echo "Soda 캐시파일 복사 실패"
) else (
    echo "Soda 캐시파일 복사 완료"
)

REM 11. 카메라 촬영 로그 복사
adb logcat -d > "C:\test\picture_taken_log.txt"
findstr "onCaptureCompleted" "C:\test\picture_taken_log.txt" >nul
if errorlevel 1 (
    echo "촬영 완료 로그를 찾을 수 없습니다."
) else (
    echo "촬영 완료 로그가 저장되었습니다."
)

REM 13. Wi-Fi SSID/BSSID 로그 복사
adb shell dumpsys wifi > "C:\test\wifi_log.txt"
echo "Wi-Fi 로그가 wifi_log.txt에 저장되었습니다."

REM 14-17. 앱 실행 로그 추출
adb shell dumpsys usagestats > "C:\test\usagestats_log.txt"
apps=("com.campmobile.snow" "com.snowcorp.soda.android" "com.nhn.android.ndrive" "com.google.android.apps.docs")
for %%A in (%apps%) do (
    findstr %%A "C:\test\usagestats_log.txt" > "C:\test\%%~nA_usage_log.txt"
)
echo "모든 로그 복사 완료"

pause
