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
if not exist "C:\test\" (
    echo "폴더가 존재하지 않습니다. 새 폴더를 생성합니다..."
    mkdir "C:\test\"
)

REM adb로 사진 파일 복사
adb pull /sdcard/DCIM/Camera/ C:\test\

REM 에러 처리
if errorlevel 1 (
    echo "사진 파일 복사 실패"
    pause
    exit /b
)

REM 4. EXIF GPS데이터 추출 (디렉토리 내 모든 JPEG 파일에 대해)

REM 폴더 존재 확인 및 생성
if not exist "C:\test\metadata" (
    echo "metadata 폴더가 존재하지 않습니다. 새 폴더를 생성합니다..."
    mkdir "C:\test\metadata"
)

echo "EXIF 데이터 추출 중..."

REM 모든 JPEG 파일에 대해 EXIF GPS 데이터 추출
for %%f in ("C:\test\Camera\*.jpg") do (
    REM 파일 이름에서 경로 및 확장자 제거
    set "filename=%%~nf"
    REM exiftool을 사용하여 EXIF GPS 데이터를 추출하고 해당 파일로 저장
    exiftool -gps* "%%f" > "C:\test\metadata\!filename!_metadata.txt"
)

if errorlevel 1 (
    echo "EXIF 데이터 추출 실패"
) else (
    echo "EXIF 데이터 추출 완료"
)

REM 5. 휴지통 폴더 복사
echo "휴지통 폴더 복사 중..."
adb pull /sdcard/Android/data/com.sec.android.gallery3d/files/.Trash C:\test\

if errorlevel 1 (
    echo "휴지통 폴더 복사 실패"
) else (
    REM 폴더 이름 변경
    ren "C:\test\.Trash" "Trash"
    echo "폴더명을 Trash로 변경하였습니다."
)

REM 파일을 .jpg로 변경
echo "파일 확장자 변경 중..."
for %%f in (C:\test\Trash\*) do (
    ren "%%f" "%%~nf.jpg"
)


REM 8. 네이버 MYBOX 캐시파일 복사
echo "네이버 MYBOX 캐시파일 복사 중..."
adb pull /sdcard/Android/data/com.nhn.android.ndrive/cache/image_manager_disk_cache C:\test\ >nul 2>&1

if errorlevel 1 (
    echo "해당 어플을 찾을 수 없습니다: com.nhn.android.ndrive"
) else (
    REM 폴더 이름 변경
    ren "C:\test\image_manager_disk_cache" "MYBOX_cache"
    echo "폴더명을 MYBOX_cache로 변경하였습니다."
)

REM 확장자가 .0로 끝나는 파일을 .jpg로 변경
echo "파일 확장자 변경 중..."
for %%f in (C:\test\MYBOX_cache\*.0) do (
    ren "%%f" "%%~nf.jpg"
)


REM 9. 소다 앱 임시 사진 파일 복사
echo "소다 앱 임시 사진 파일 복사 중..."
adb pull /sdcard/Android/data/com.snowcorp.soda.android/files/temp C:\test\>nul 2>&1
if errorlevel 1 (
    echo "해당 어플을 찾을 수 없습니다: com.snowcorp.soda.android"
) else (
    REM 폴더 이름 변경
    ren "C:\test\temp" "Soda_cache"
    echo "폴더명을 Soda_cache 변경하였습니다."
)


REM 11. 카메라 촬영 완료 로그 복사
echo "촬영 완료 로그 복사 중..."

REM adb logcat 출력을 임시 파일로 저장 (Powershell이 아닌 CMD 창에선 오류 발생하기 때문)
adb logcat -d > temp_log.txt

REM 임시 대기 시간 추가 (0.5초 대기)
timeout /t 1 /nobreak >nul

REM 임시 파일에서 'onCaptureCompleted' 문자열을 검색
findstr "onCaptureCompleted" temp_log.txt > C:\test\picture_taken_log.txt

REM 에러 처리
if errorlevel 1 (
    echo "촬영 완료 로그를 찾을 수 없습니다."
) else (
    echo "촬영 완료 로그를 picture_taken_log.txt에 저장하였습니다."

)

REM 임시 파일 삭제
del temp_log.txt


REM 13. Wi-Fi SSID/BSSID 로그 복사
echo "Wi-Fi SSID/BSSID 로그 복사 중..."

REM adb shell dumpsys wifi 출력을 임시 파일로 저장
adb shell dumpsys wifi > temp_wifi.txt

REM 임시 대기 시간 추가 (0.5초 대기)
timeout /t 1 /nobreak >nul

REM 임시 파일에서 BSSID와 wifiState=WIFI_ASSOCIATED 문자열을 검색
findstr "BSSID" temp_wifi.txt | findstr "wifiState=WIFI_ASSOCIATED" >nul 2>&1

REM 에러 처리
if errorlevel 1 (
    echo "Wi-Fi SSID/BSSID 로그를 찾을 수 없습니다."
) else (
    findstr "BSSID" temp_wifi.txt | findstr "wifiState=WIFI_ASSOCIATED" temp_wifi.txt > C:\test\wifi_log.txt
    echo "Wi-Fi SSID/BSSID 로그를 wifi_log.txt에 저장하였습니다."
)

REM 임시 파일 삭제
del temp_wifi.txt

REM 14. 스노우 앱 실행 로그 추출
echo "스노우 앱 실행 로그 추출 중..."

REM adb shell dumpsys usagestats 출력 결과를 임시 파일로 저장
adb shell dumpsys usagestats > "C:\test\temp_usagestats.txt"

REM 임시 대기 시간 추가 (0.5초 대기)
timeout /t 1 /nobreak >nul

REM 각각의 조건을 만족하는지 확인
findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
set ACTIVITY_RESUMED_FOUND=%errorlevel%

findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
set ACTIVITY_PAUSED_FOUND=%errorlevel%

REM 두 조건을 모두 만족하는 경우에만 결과 저장
if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
    echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
    findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\snow_usage_log.txt
    findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\snow_usage_log.txt
    echo "로그가 snow_usage_log.txt에 저장되었습니다."
) else (
    echo "스노우 앱 실행 로그를 찾을 수 없습니다."
)

REM 15. 소다 앱 실행 로그 추출
echo "소다 앱 실행 로그 추출 중..."

REM 임시 대기 시간 추가 (0.5초 대기)
timeout /t 1 /nobreak >nul

REM 각각의 조건을 만족하는지 확인
findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
set ACTIVITY_RESUMED_FOUND=%errorlevel%

findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
set ACTIVITY_PAUSED_FOUND=%errorlevel%

REM 두 조건을 모두 만족하는 경우에만 결과 저장
if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
    echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
    findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\soda_usage_log.txt
    findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\soda_usage_log.txt
    echo "로그가 soda_usage_log.txt에 저장되었습니다."
) else (
    echo "소다 앱 실행 로그를 찾을 수 없습니다."
)

REM 16. MYBOX 앱 실행 로그 추출
echo "MYBOX 앱 실행 로그 추출 중..."

REM 임시 대기 시간 추가 (0.5초 대기)
timeout /t 1 /nobreak >nul

REM 각각의 조건을 만족하는지 확인
findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
set ACTIVITY_RESUMED_FOUND=%errorlevel%

findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
set ACTIVITY_PAUSED_FOUND=%errorlevel%

REM 두 조건을 모두 만족하는 경우에만 결과 저장
if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
    echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
    findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\mybox_usage_log.txt
    findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\mybox_usage_log.txt
    echo "로그가 soda_usage_log.txt에 저장되었습니다."
) else (
    echo "MYBOX 앱 실행 로그를 찾을 수 없습니다."
)

REM 17. 구글 Drive 앱 실행 로그 추출
echo "Drive 앱 실행 로그 추출 중..."

REM 임시 대기 시간 추가 (0.5초 대기)
timeout /t 1 /nobreak >nul

REM 각각의 조건을 만족하는지 확인
findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
set ACTIVITY_RESUMED_FOUND=%errorlevel%

findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
set ACTIVITY_PAUSED_FOUND=%errorlevel%

REM 두 조건을 모두 만족하는 경우에만 결과 저장
if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
    echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
    findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\drive_usage_log.txt
    findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\drive_usage_log.txt
    echo "로그가 soda_usage_log.txt에 저장되었습니다."
) else (
    echo "Drive 앱 실행 로그를 찾을 수 없습니다."
)

REM 임시 파일 삭제
del "C:\test\temp_usagestats.txt"


echo "작업 완료!"
endlocal