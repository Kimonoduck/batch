@echo off
chcp 65001 > nul
setlocal
setlocal EnableDelayedExpansion

REM 1. ADB 경로 설정
set ADB_PATH=C:\Users\15U50P\AppData\Local\Android\Sdk\platform-tools
set PATH=%ADB_PATH%;%PATH%

REM 2. EXIFTool 경로 설정
set EXIFTOOL_PATH=C:\exiftool
set PATH=%EXIFTOOL_PATH%;%PATH%

REM 3. 사진 파일 복사
echo "사진 파일 복사 중..."

REM 폴더가 없으면 새로 생성
if not exist "C:\test" (
    echo "폴더가 존재하지 않습니다. 새 폴더를 생성합니다..."
    mkdir "C:\test"
)

REM 하위 폴더 생성
mkdir "C:\test\Camera"
mkdir "C:\test\Trash"
mkdir "C:\test\MYBOX_cache"
mkdir "C:\test\Soda_cache"
mkdir "C:\test\metadata"

REM 4. 사진 파일 복사 및 EXIF 데이터 추출
echo "Camera 폴더의 파일 복사 중..."
FOR /F "tokens=" %%A IN ('adb shell ls /sdcard/DCIM/Camera/*.jpg 2^>NUL') DO (
    SET "FILE=%%A"
    FOR /F "delims=" %%B IN ('echo !FILE!') DO (
        SET "FILE=%%B"
    )

    REM 수정 날짜와 시간을 가져오기
    FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FILE!" ^| findstr "Modify:"') DO (
        SET "MODIFY_DATE=%%i"
        SET "MODIFY_TIME=%%j"
    )

    SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"
    SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"
    SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"

    echo "전송 시작: !RESULT!"
    adb pull "!FILE!" "C:\test\Camera\!RESULT!"
    echo "전송 완료: !RESULT!"

    REM 웹 서버에 폴더 경로 정보 전송
    curl -X POST http://localhost/api/signal ^
    -F "file=@C:\test\Camera\!RESULT!" ^
    -F "parentDir=\"/Camera\""
)

REM SNOW 폴더 존재 여부 확인
adb shell if [ -d "/sdcard/DCIM/Camera/SNOW" ]; then echo exists; else echo not_exists; fi > temp_check.txt
set /p FOLDER_EXISTS=<temp_check.txt
del temp_check.txt

if "%FOLDER_EXISTS%"=="exists" (
    echo "SNOW 폴더가 발견되었습니다. 파일 복사 중..."
    FOR /F "tokens=" %%A IN ('adb shell ls /sdcard/DCIM/Camera/SNOW/*.jpg 2^>NUL') DO (
        SET "FILE=%%A"
        FOR /F "delims=" %%B IN ('echo !FILE!') DO (
            SET "FILE=%%B"
        )
        FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FILE!" ^| findstr "Modify:"') DO (
            SET "MODIFY_DATE=%%i"
            SET "MODIFY_TIME=%%j"
        )
        SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"
        SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"
        SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"
        echo "전송 시작: !RESULT!"
        adb pull "!FILE!" "C:\test\Camera\!RESULT!"
        echo "전송 완료: !RESULT!"

        REM 웹 서버에 폴더 경로 정보 전송
        curl -X POST http://localhost/api/signal ^
        -F "file=@C:\test\Camera\!RESULT!" ^
        -F "parentDir=\"/Camera/SNOW\""
    )
) ELSE (
    echo "SNOW 폴더가 존재하지 않습니다."
)

REM 5. 휴지통 폴더 복사
echo "휴지통 폴더 복사 중..."
FOR /F "tokens=" %%A IN ('adb shell ls /sdcard/Android/data/com.sec.android.gallery3d/files/.Trash/*.jpg 2^>NUL') DO (
    SET "FILE=%%A"
    FOR /F "delims=" %%B IN ('echo !FILE!') DO (
        SET "FILE=%%B"
    )
    SET "FULL_PATH=/sdcard/Android/data/com.sec.android.gallery3d/files/.Trash/!FILE!"
    FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FULL_PATH!" ^| findstr "Modify:"') DO (
        SET "MODIFY_DATE=%%i"
        SET "MODIFY_TIME=%%j"
    )
    SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"
    SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"
    SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"
    echo "전송 시작: !RESULT!"
    adb pull "!FULL_PATH!" "C:\test\Trash\!RESULT!"
    echo "전송 완료: !RESULT!"

    REM 웹 서버에 폴더 경로 정보 전송
    curl -X POST http://localhost/api/signal ^
    -F "file=@C:\test\Trash\!RESULT!" ^
    -F "parentDir=\"/Trash\""
)

REM 6. EXIF GPS데이터 추출 (Camera 폴더의 JPEG 파일에 대해)
echo "EXIF 데이터 추출 중...1"
for %%f in ("C:\test\Camera\*.jpg") do (
    set "filename=%%~nf"
    exiftool -gps* "%%f" > "C:\test\metadata\!filename!_metadata.txt"
    
    REM 웹 서버에 메타데이터 파일 정보 전송
    curl -X POST http://localhost/api/signal ^
    -F "file=@C:\test\metadata\!filename!_metadata.txt" ^
    -F "parentDir=\"/metadata\""
)
if errorlevel 1 (
    echo "EXIF 데이터 추출 실패1"
) else (
    echo "EXIF 데이터 추출 완료1"
)

REM 7. EXIF GPS데이터 추출 (Trash 폴더의 JPEG 파일에 대해)
echo "EXIF 데이터 추출 중...2"
for %%f in ("C:\test\Trash\*.jpg") do (
    set "filename=%%~nf"
    exiftool -gps* "%%f" > "C:\test\metadata\!filename!_metadata.txt"
    
    REM 웹 서버에 메타데이터 파일 정보 전송
    curl -X POST http://localhost/api/signal ^
    -F "file=@C:\test\metadata\!filename!_metadata.txt" ^
    -F "parentDir=\"/metadata\""
)
if errorlevel 1 (
    echo "EXIF 데이터 추출 실패2"
) else (
    echo "EXIF 데이터 추출 완료2"
)

REM 8. MYBOX 캐시파일 복사
echo "MYBOX 캐시파일 복사 중..."
SET "TEMP_FOLDER=/sdcard/Android/data/com.nhn.android.ndrive/cache/temp"
FOR /F "delims=" %%A IN ('adb shell find "%TEMP_FOLDER%" -type f -name "*.jpg" 2^>NUL') DO (
    SET "FILE=%%A"
    FOR /F "delims=" %%B IN ('echo !FILE!') DO (
        SET "FILE=%%B"
    )
    FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FILE!" ^| findstr "Modify:"') DO (
        SET "MODIFY_DATE=%%i"
        SET "MODIFY_TIME=%%j"
    )
    SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"
    SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"
    SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"
    echo "전송 시작: !RESULT!"
    adb pull "!FILE!" "C:\test\MYBOX_cache\!RESULT!"
    echo "전송 완료: !RESULT!"

    REM 웹 서버에 폴더 경로 정보 전송
    curl -X POST http://localhost/api/signal ^
    -F "file=@C:\test\MYBOX_cache\!RESULT!" ^
    -F "parentDir=\"/MYBOX_cache\""
)

REM 9. 소다 앱 임시 사진 파일 복사
echo "소다 앱 임시 사진 파일 복사 중..."
FOR /F "tokens=" %%A IN ('adb shell ls /sdcard/Android/data/com.snowcorp.soda.android/files/temp/*.jpg 2^>NUL') DO
    SET "FILE=%%A"
    FOR /F "delims=" %%B IN ('echo !FILE!') DO (
        SET "FILE=%%B"
    )
    FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FILE!" ^| findstr "Modify:"') DO (
        SET "MODIFY_DATE=%%i"
        SET "MODIFY_TIME=%%j"
    )
    SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"
    SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"
    SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"
    echo "전송 시작: !RESULT!"
    adb pull "!FILE!" "C:\test\Soda_cache\!RESULT!"
    echo "전송 완료: !RESULT!"

    REM 웹 서버에 폴더 경로 정보 전송
    curl -X POST http://localhost/api/signal ^
    -F "file=@C:\test\Soda_cache\!RESULT!" ^
    -F "parentDir=\"/Soda_cache\""
)

REM 10. 카메라 촬영 완료 로그 복사
echo "촬영 완료 로그 복사 중..."
adb logcat -d > temp_log.txt
timeout /t 1 /nobreak >nul
findstr "onCaptureCompleted" temp_log.txt > C:\test\picture_taken_log.txt
if errorlevel 1 (
    echo "촬영 완료 로그를 찾을 수 없습니다."
) else (
    echo "촬영 완료 로그를 picture_taken_log.txt에 저장하였습니다."
    REM 웹 서버에 로그 파일 정보 전송
    curl -X POST http://localhost/api/signal ^
    -F "file=@C:\test\picture_taken_log.txt" ^
    -F "parentDir=\"/logs\""
)
del temp_log.txt

REM 11. Wi-Fi SSID/BSSID 로그 복사
echo "Wi-Fi SSID/BSSID 로그 복사 중..."
adb shell dumpsys wifi > temp_wifi.txt
timeout /t 1 /nobreak >nul
findstr "BSSID" temp_wifi.txt | findstr "wifiState=WIFI_ASSOCIATED wifiState=WIFI_DISCONNECTED" >nul 2>&1
if errorlevel 1 (
    echo "Wi-Fi SSID/BSSID 로그를 찾을 수 없습니다."
) else (
    findstr "BSSID" temp_wifi.txt | findstr "wifiState=WIFI_ASSOCIATED wifiState=WIFI_DISCONNECTED" > C:\test\wifi_log.txt
    echo "Wi-Fi SSID/BSSID 로그를 wifi_log.txt에 저장하였습니다."
    REM 웹 서버에 로그 파일 정보 전송
    curl -X POST http://localhost/api/signal ^
    -F "file=@C:\test\wifi_log.txt" ^
    -F "parentDir=\"/logs\""
)
del temp_wifi.txt

REM 12. 스노우 앱 실행 로그 추출
echo "스노우 앱 실행 로그 추출 중..."
adb shell dumpsys usagestats > "C:\test\temp_usagestats.txt"
timeout /t 1 /nobreak >nul
findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
set ACTIVITY_RESUMED_FOUND=%errorlevel%
findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
set ACTIVITY_PAUSED_FOUND=%errorlevel%
if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
    echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
    findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\snow_usage_log.txt
    findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\snow_usage_log.txt
    echo "로그가 snow_usage_log.txt에 저장되었습니다."
) else (
    echo "스노우 앱 실행 로그를 찾을 수 없습니다."
)

REM 13. 소다 앱 실행 로그 추출
echo "소다 앱 실행 로그 추출 중..."
timeout /t 1 /nobreak >nul
findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
set ACTIVITY_RESUMED_FOUND=%errorlevel%
findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
set ACTIVITY_PAUSED_FOUND=%errorlevel%
if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
    echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
    findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\soda_usage_log.txt
    findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\soda_usage_log.txt
    echo "로그가 soda_usage_log.txt에 저장되었습니다."
) else (
    echo "소다 앱 실행 로그를 찾을 수 없습니다."
)

REM 14. MYBOX 앱 실행 로그 추출
echo "MYBOX 앱 실행 로그 추출 중..."
timeout /t 1 /nobreak >nul
findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
set ACTIVITY_RESUMED_FOUND=%errorlevel%
findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
set ACTIVITY_PAUSED_FOUND=%errorlevel%
if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
    echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
    findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\mybox_usage_log.txt
    findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\mybox_usage_log.txt
    echo "로그가 mybox_usage_log.txt에 저장되었습니다."
) else (
    echo "MYBOX 앱 실행 로그를 찾을 수 없습니다."
)

REM 15. 구글 Drive 앱 실행 로그 추출
echo "Drive 앱 실행 로그 추출 중..."
timeout /t 1 /nobreak >nul
findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
set ACTIVITY_RESUMED_FOUND=%errorlevel%
findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
set ACTIVITY_PAUSED_FOUND=%errorlevel%
if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
    echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
    findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\drive_usage_log.txt
    findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\drive_usage_log.txt
    echo "로그가 drive_usage_log.txt에 저장되었습니다."
) else (
    echo "Drive 앱 실행 로그를 찾을 수 없습니다."
)

REM 임시 파일 삭제
del "C:\test\temp_usagestats.txt"

echo "작업 완료!"
endlocal
