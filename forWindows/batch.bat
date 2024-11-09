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

mkdir "C:\test\Camera"

REM SNOW 폴더 존재 여부 확인
adb shell if [ -d "/sdcard/DCIM/Camera/SNOW" ]; then echo exists; else echo not_exists; fi > temp_check.txt
set /p FOLDER_EXISTS=<temp_check.txt
del temp_check.txt

if "%FOLDER_EXISTS%"=="exists" (
    echo SNOW 폴더가 발견되었습니다. 파일 복사 중...

    REM SNOW 폴더의 모든 jpg 파일 목록 가져오기
    FOR /F "delims=" %%A IN ('adb shell ls /sdcard/DCIM/Camera/SNOW/*.jpg 2^>NUL') DO (
        SET "FILE=%%A"

        REM Windows 줄바꿈 제거
        FOR /F "delims=" %%B IN ('echo !FILE!') DO (
            SET "FILE=%%B"
        )

        REM 파일의 stat 정보 가져오기
        FOR /F "tokens=*" %%i IN ('adb shell stat "!FILE!"') DO (
            SET "STAT_OUTPUT=%%i"
        )

        REM Modify 날짜 추출
        FOR /F "tokens=1,2,3 delims= " %%a IN ('echo !STAT_OUTPUT! ^| findstr "Modify"') DO (
            SET "MODIFY_DATE=%%b"
            SET "MODIFY_TIME=%%c"
        )

        REM 날짜 포맷 변환: YYYY-MM-DD HH:MM:SS -> YYYYMMDD_HHMMSS
        SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"
        SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"
        SET "NEW_FILENAME=!DATE_PART!_!TIME_PART!.jpg"

        REM 파일 다운로드
        adb pull "!FILE!" "C:\test\Camera\!NEW_FILENAME!"

        IF %ERRORLEVEL% EQU 0 (
            echo 파일 다운로드 완료: !NEW_FILENAME!
        ) ELSE (
            echo 파일 다운로드 실패: !FILE!
        )
    )
) ELSE (
    echo SNOW 폴더가 존재하지 않습니다.
)

@REM REM jpg 파일 목록 가져오기 및 파일 처리
@REM FOR /F "tokens=*" %%A IN ('adb shell ls /sdcard/DCIM/Camera/*.jpg 2^>NUL') DO (
@REM     SET "FILE=%%A"
    
@REM     REM 파일 이름에서 CR(Carriage Return) 제거
@REM     FOR /F "delims=" %%B IN ('echo !FILE!') DO (
@REM         SET "FILE=%%B"
@REM     )
    
@REM     REM 수정 날짜와 시간을 가져오기
@REM     FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FILE!" ^| findstr "Modify:"') DO (
@REM         SET "MODIFY_DATE=%%i"
@REM         SET "MODIFY_TIME=%%j"
@REM     )

@REM     REM MODIFY_DATE에서 YYYYMMDD 추출
@REM     SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"

@REM     REM MODIFY_TIME에서 HHMMSS 추출
@REM     SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"

@REM     REM 최종 결과 생성
@REM     SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"
    
@REM     echo "파일 복사 중: !RESULT!"

@REM     REM 파일을 지정된 위치로 복사
@REM     adb pull "!FILE!" "C:\test\Camera\!RESULT!"
@REM )

@REM REM 4. EXIF GPS데이터 추출 (디렉토리 내 모든 JPEG 파일에 대해)

@REM REM 폴더 존재 확인 및 생성
@REM if not exist "C:\test\metadata" (
@REM     echo "metadata 폴더가 존재하지 않습니다. 새 폴더를 생성합니다..."
@REM     mkdir "C:\test\metadata"
@REM )

@REM echo "EXIF 데이터 추출 중..."

@REM REM 모든 JPEG 파일에 대해 EXIF GPS 데이터 추출
@REM for %%f in ("C:\test\Camera\*.jpg") do (
@REM     REM 파일 이름에서 경로 및 확장자 제거
@REM     set "filename=%%~nf"
@REM     REM exiftool을 사용하여 EXIF GPS 데이터를 추출하고 해당 파일로 저장
@REM     exiftool -gps* "%%f" > "C:\test\metadata\!filename!_metadata.txt"
@REM )

@REM if errorlevel 1 (
@REM     echo "EXIF 데이터 추출 실패"
@REM ) else (
@REM     echo "EXIF 데이터 추출 완료"
@REM )

@REM REM 5. 휴지통 폴더 복사
@REM mkdir "C:\test\Trash"

@REM REM 파일 목록 가져오기 및 파일 처리
@REM FOR /F "tokens=*" %%A IN ('adb shell ls /sdcard/Android/data/com.sec.android.gallery3d/files/.Trash 2^>NUL') DO (
@REM     SET "FILE=%%A"
    
@REM     REM 파일 이름에서 CR(Carriage Return) 제거
@REM     FOR /F "delims=" %%B IN ('echo !FILE!') DO (
@REM         SET "FILE=%%B"
@REM     )
    
@REM     REM 전체 파일 경로 설정
@REM     SET "FULL_PATH=/sdcard/Android/data/com.sec.android.gallery3d/files/.Trash/!FILE!"
    
@REM     REM 수정 날짜와 시간을 가져오기
@REM     FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FULL_PATH!" ^| findstr "Modify:"') DO (
@REM         SET "MODIFY_DATE=%%i"
@REM         SET "MODIFY_TIME=%%j"
@REM     )

@REM     REM MODIFY_DATE에서 YYYYMMDD 추출
@REM     SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"

@REM     REM MODIFY_TIME에서 HHMMSS 추출
@REM     SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"

@REM     REM 최종 결과 생성
@REM     SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"
    
@REM     echo "파일 복사 중: !RESULT!"

@REM     REM 파일을 지정된 위치로 복사
@REM     adb pull "!FULL_PATH!" "C:\test\Trash\!RESULT!"
@REM )


@REM REM 8. 네이버 MYBOX 캐시파일 복사
@REM REM ADB Temp 폴더 경로
@REM SET "TEMP_FOLDER=/sdcard/Android/data/com.nhn.android.ndrive/cache/temp"
@REM SET "LOCAL_SAVE_PATH=C:\test\MYBOX_cache"

@REM REM 폴더가 없으면 생성
@REM if not exist "C:\test\MYBOX_cache" (
@REM     echo "폴더가 존재하지 않습니다. 새 폴더를 생성합니다..."
@REM     mkdir "C:\test\MYBOX_cache"
@REM )

@REM REM ADB로 Temp 폴더에서 모든 파일 및 하위 폴더 목록 가져오기
@REM echo Temp 폴더의 모든 파일 탐색 중...
@REM FOR /F "delims=" %%A IN ('adb shell find "%TEMP_FOLDER%" -type f -name "*.jpg" 2^>NUL') DO (
@REM     SET "FILE=%%A"

@REM     echo 파일 이름: %FILE%

@REM     REM Windows 줄바꿈 제거
@REM     FOR /F "delims=" %%B IN ('echo !FILE!') DO (
@REM         SET "FILE=%%B"
@REM     )

@REM     IF "!FILE!"=="" (
@REM         REM 빈 값이면 다음으로 이동
@REM         CONTINUE
@REM     )

@REM     REM 수정 날짜와 시간을 가져오기
@REM     FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FILE!" ^| findstr "Modify:"') DO (
@REM         SET "MODIFY_DATE=%%i"
@REM         SET "MODIFY_TIME=%%j"
@REM     )

@REM     REM MODIFY_DATE에서 YYYYMMDD 추출
@REM     SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"

@REM     REM MODIFY_TIME에서 HHMMSS 추출
@REM     SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"

@REM     REM 최종 결과 생성
@REM     SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"
    
@REM     echo "파일 복사 중: !RESULT!"

@REM     REM 파일을 지정된 위치로 복사
@REM     adb pull "!FILE!" "C:\test\MYBOX_cache\!RESULT!"
@REM )

@REM echo 네이버 MYBOX 캐시파일 복사 완료!


@REM REM 9. 소다 앱 임시 사진 파일 복사
@REM echo "소다 앱 임시 사진 파일 복사 중..."
@REM mkdir "C:\test\Soda_cache"


@REM REM jpg 파일 목록 가져오기 및 파일 처리
@REM FOR /F "tokens=*" %%A IN ('adb shell ls /sdcard/Android/data/com.snowcorp.soda.android/files/temp/*.jpg 2^>NUL') DO (
@REM     SET "FILE=%%A"
    
@REM     REM 파일 이름에서 CR(Carriage Return) 제거
@REM     FOR /F "delims=" %%B IN ('echo !FILE!') DO (
@REM         SET "FILE=%%B"
@REM     )
    
@REM     REM 수정 날짜와 시간을 가져오기
@REM     FOR /F "tokens=2,3" %%i IN ('adb shell stat "!FILE!" ^| findstr "Modify:"') DO (
@REM         SET "MODIFY_DATE=%%i"
@REM         SET "MODIFY_TIME=%%j"
@REM     )

@REM     REM MODIFY_DATE에서 YYYYMMDD 추출
@REM     SET "DATE_PART=!MODIFY_DATE:~0,4!!MODIFY_DATE:~5,2!!MODIFY_DATE:~8,2!"

@REM     REM MODIFY_TIME에서 HHMMSS 추출
@REM     SET "TIME_PART=!MODIFY_TIME:~0,2!!MODIFY_TIME:~3,2!!MODIFY_TIME:~6,2!"

@REM     REM 최종 결과 생성
@REM     SET "RESULT=!DATE_PART!_!TIME_PART!.jpg"
    
@REM     echo "파일 복사 중: !RESULT!"

@REM     REM 파일을 지정된 위치로 복사
@REM     adb pull "!FILE!" "C:\test\Soda_cache\!RESULT!"
@REM )

@REM REM 11. 카메라 촬영 완료 로그 복사
@REM echo "촬영 완료 로그 복사 중..."

@REM REM adb logcat 출력을 임시 파일로 저장 (Powershell이 아닌 CMD 창에선 오류 발생하기 때문)
@REM adb logcat -d > temp_log.txt

@REM REM 임시 대기 시간 추가 (0.5초 대기)
@REM timeout /t 1 /nobreak >nul

@REM REM 임시 파일에서 'onCaptureCompleted' 문자열을 검색
@REM findstr "onCaptureCompleted" temp_log.txt > C:\test\picture_taken_log.txt

@REM REM 에러 처리
@REM if errorlevel 1 (
@REM     echo "촬영 완료 로그를 찾을 수 없습니다."
@REM ) else (
@REM     echo "촬영 완료 로그를 picture_taken_log.txt에 저장하였습니다."

@REM )

@REM REM 임시 파일 삭제
@REM del temp_log.txt


@REM REM 13. Wi-Fi SSID/BSSID 로그 복사
@REM echo "Wi-Fi SSID/BSSID 로그 복사 중..."

@REM REM adb shell dumpsys wifi 출력을 임시 파일로 저장
@REM adb shell dumpsys wifi > temp_wifi.txt

@REM REM 임시 대기 시간 추가 (0.5초 대기)
@REM timeout /t 1 /nobreak >nul

@REM REM 임시 파일에서 BSSID와 wifiState=WIFI_ASSOCIATED 문자열을 검색
@REM findstr "BSSID" temp_wifi.txt | findstr "wifiState=WIFI_ASSOCIATED" >nul 2>&1

@REM REM 에러 처리
@REM if errorlevel 1 (
@REM     echo "Wi-Fi SSID/BSSID 로그를 찾을 수 없습니다."
@REM ) else (
@REM     findstr "BSSID" temp_wifi.txt | findstr "wifiState=WIFI_ASSOCIATED wifiState=WIFI_DISCONNECTED" temp_wifi.txt > C:\test\wifi_log.txt
@REM     echo "Wi-Fi SSID/BSSID 로그를 wifi_log.txt에 저장하였습니다."
@REM )

@REM REM 임시 파일 삭제
@REM del temp_wifi.txt

@REM REM 14. 스노우 앱 실행 로그 추출
@REM echo "스노우 앱 실행 로그 추출 중..."

@REM REM adb shell dumpsys usagestats 출력 결과를 임시 파일로 저장
@REM adb shell dumpsys usagestats > "C:\test\temp_usagestats.txt"

@REM REM 임시 대기 시간 추가 (0.5초 대기)
@REM timeout /t 1 /nobreak >nul

@REM REM 각각의 조건을 만족하는지 확인
@REM findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
@REM set ACTIVITY_RESUMED_FOUND=%errorlevel%

@REM findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
@REM set ACTIVITY_PAUSED_FOUND=%errorlevel%

@REM REM 두 조건을 모두 만족하는 경우에만 결과 저장
@REM if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
@REM     echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
@REM     findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\snow_usage_log.txt
@REM     findstr "com.campmobile.snow" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\snow_usage_log.txt
@REM     echo "로그가 snow_usage_log.txt에 저장되었습니다."
@REM ) else (
@REM     echo "스노우 앱 실행 로그를 찾을 수 없습니다."
@REM )

@REM REM 15. 소다 앱 실행 로그 추출
@REM echo "소다 앱 실행 로그 추출 중..."

@REM REM 임시 대기 시간 추가 (0.5초 대기)
@REM timeout /t 1 /nobreak >nul

@REM REM 각각의 조건을 만족하는지 확인
@REM findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
@REM set ACTIVITY_RESUMED_FOUND=%errorlevel%

@REM findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
@REM set ACTIVITY_PAUSED_FOUND=%errorlevel%

@REM REM 두 조건을 모두 만족하는 경우에만 결과 저장
@REM if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
@REM     echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
@REM     findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\soda_usage_log.txt
@REM     findstr "com.snowcorp.soda.android" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\soda_usage_log.txt
@REM     echo "로그가 soda_usage_log.txt에 저장되었습니다."
@REM ) else (
@REM     echo "소다 앱 실행 로그를 찾을 수 없습니다."
@REM )

@REM REM 16. MYBOX 앱 실행 로그 추출
@REM echo "MYBOX 앱 실행 로그 추출 중..."

@REM REM 임시 대기 시간 추가 (0.5초 대기)
@REM timeout /t 1 /nobreak >nul

@REM REM 각각의 조건을 만족하는지 확인
@REM findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
@REM set ACTIVITY_RESUMED_FOUND=%errorlevel%

@REM findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
@REM set ACTIVITY_PAUSED_FOUND=%errorlevel%

@REM REM 두 조건을 모두 만족하는 경우에만 결과 저장
@REM if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
@REM     echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
@REM     findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\mybox_usage_log.txt
@REM     findstr "com.nhn.android.ndrive" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\mybox_usage_log.txt
@REM     echo "로그가 soda_usage_log.txt에 저장되었습니다."
@REM ) else (
@REM     echo "MYBOX 앱 실행 로그를 찾을 수 없습니다."
@REM )

@REM REM 17. 구글 Drive 앱 실행 로그 추출
@REM echo "Drive 앱 실행 로그 추출 중..."

@REM REM 임시 대기 시간 추가 (0.5초 대기)
@REM timeout /t 1 /nobreak >nul

@REM REM 각각의 조건을 만족하는지 확인
@REM findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" >nul
@REM set ACTIVITY_RESUMED_FOUND=%errorlevel%

@REM findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >nul
@REM set ACTIVITY_PAUSED_FOUND=%errorlevel%

@REM REM 두 조건을 모두 만족하는 경우에만 결과 저장
@REM if %ACTIVITY_RESUMED_FOUND% equ 0 if %ACTIVITY_PAUSED_FOUND% equ 0 (
@REM     echo "ACTIVITY_RESUMED와 ACTIVITY_PAUSED 상태를 찾았습니다. 로그를 저장합니다."
@REM     findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_RESUMED" > C:\test\drive_usage_log.txt
@REM     findstr "com.google.android.apps.docs" "C:\test\temp_usagestats.txt" | findstr "ACTIVITY_PAUSED" >> C:\test\drive_usage_log.txt
@REM     echo "로그가 soda_usage_log.txt에 저장되었습니다."
@REM ) else (
@REM     echo "Drive 앱 실행 로그를 찾을 수 없습니다."
@REM )

@REM REM 임시 파일 삭제
@REM del "C:\test\temp_usagestats.txt"


@REM echo "작업 완료!"
@REM endlocal

