@REM @echo off
@REM chcp 65001 > nul
@REM setlocal
@REM setlocal EnableDelayedExpansion

@REM REM 1. ADB 경로 설정
@REM set ADB_PATH=C:\Users\15U50P\AppData\Local\Android\Sdk\platform-tools
@REM set PATH=%ADB_PATH%;%PATH%

@REM REM 2. EXIFTool 경로 설정
@REM set EXIFTOOL_PATH=C:\exiftool
@REM set PATH=%EXIFTOOL_PATH%;%PATH%

@REM REM 3. 사진 파일 복사
@REM echo "사진 파일 복사 중..."

@REM REM 폴더가 없으면 새로 생성
@REM if not exist "C:\test\" (
@REM     echo "폴더가 존재하지 않습니다. 새 폴더를 생성합니다..."
@REM     mkdir "C:\test\"
@REM )

@REM REM adb로 사진 파일 복사
@REM adb pull /sdcard/DCIM/Camera/ C:\test\

@REM REM 에러 처리
@REM if errorlevel 1 (
@REM     echo "사진 파일 복사 실패"
@REM     pause
@REM     exit /b
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
@REM echo "휴지통 폴더 복사 중..."
@REM adb pull /sdcard/Android/data/com.sec.android.gallery3d/files/.Trash C:\test\

@REM if errorlevel 1 (
@REM     echo "휴지통 폴더 복사 실패"
@REM ) else (
@REM     REM 폴더 이름 변경
@REM     ren "C:\test\.Trash" "Trash"
@REM     echo "폴더명을 Trash로 변경하였습니다."
@REM )

@REM REM 파일을 .jpg로 변경
@REM echo "파일 확장자 변경 중..."
@REM for %%f in (C:\test\Trash\*) do (
@REM     ren "%%f" "%%~nf.jpg"
@REM )


@REM REM 8. 네이버 MYBOX 캐시파일 복사
@REM echo "네이버 MYBOX 캐시파일 복사 중..."
@REM adb pull /sdcard/Android/data/com.nhn.android.ndrive/cache/image_manager_disk_cache C:\test\ >nul 2>&1

@REM if errorlevel 1 (
@REM     echo "해당 어플을 찾을 수 없습니다: com.nhn.android.ndrive"
@REM ) else (
@REM     REM 폴더 이름 변경
@REM     ren "C:\test\image_manager_disk_cache" "MYBOX_cache"
@REM     echo "폴더명을 MYBOX_cache로 변경하였습니다."
@REM )

@REM REM 확장자가 .0로 끝나는 파일을 .jpg로 변경
@REM echo "파일 확장자 변경 중..."
@REM for %%f in (C:\test\MYBOX_cache\*.0) do (
@REM     ren "%%f" "%%~nf.jpg"
@REM )


@REM REM 9. 소다 앱 임시 사진 파일 복사
@REM echo "소다 앱 임시 사진 파일 복사 중..."
@REM adb pull /sdcard/Android/data/com.snowcorp.soda.android/files/temp C:\test\>nul 2>&1
@REM if errorlevel 1 (
@REM     echo "해당 어플을 찾을 수 없습니다: com.snowcorp.soda.android"
@REM ) else (
@REM     REM 폴더 이름 변경
@REM     ren "C:\test\temp" "Soda_cache"
@REM     echo "폴더명을 Soda_cache 변경하였습니다."
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
@REM     findstr "BSSID" temp_wifi.txt | findstr "wifiState=WIFI_ASSOCIATED" temp_wifi.txt > C:\test\wifi_log.txt
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


@REM @echo off
@REM chcp 65001 > nul

@REM  mkdir "C:\test\Camera"

@REM REM 파일 목록 가져오기
@REM FOR /F "tokens=*" %%A IN ('adb shell ls /sdcard/DCIM/Camera/*.jpg 2^>NUL') DO (
@REM     SET FILE=%%A
@REM     CALL :PROCESS_FILE
@REM )
@REM GOTO :EOF

@REM :PROCESS_FILE
@REM REM 파일 이름에서 CR(Carriage Return) 제거
@REM FOR /F "delims=" %%B IN ('echo %FILE%') DO (
@REM     SET FILE=%%B
@REM )

@REM for /f "tokens=2,3" %%i in ('adb shell stat "%FILE%" ^| findstr "Modify:"') do (
@REM     set MODIFY_DATE=%%i
@REM     set MODIFY_TIME=%%j
@REM )

@REM :: MODIFY_DATE에서 YYYYMMDD 추출
@REM set DATE_PART=%MODIFY_DATE:~0,4%%MODIFY_DATE:~5,2%%MODIFY_DATE:~8,2%

@REM :: MODIFY_TIME에서 HHMMSS 추출
@REM set TIME_PART=%MODIFY_TIME:~0,2%%MODIFY_TIME:~3,2%%MODIFY_TIME:~6,2%

@REM :: 최종 결과 생성
@REM set RESULT="%DATE_PART%_%TIME_PART%.jpg"
@REM adb pull "%FILE%" "C:\test\Camera"
@REM echo %RESULT%

@echo off
chcp 65001 > nul
SETLOCAL ENABLEDELAYEDEXPANSION


mkdir "C:\test\Camera"

REM 파일 목록 가져오기 및 파일 처리
FOR /F "tokens=*" %%A IN ('adb shell ls /sdcard/DCIM/Camera/*.jpg 2^>NUL') DO (

    SET FILE=%%A
    
    REM 파일 이름에서 CR(Carriage Return) 제거
    for /F "delims=" %%B in ('echo !FILE!') do (
        set FILE=%%B
    )
    echo "---"
    echo !FILE!
    echo "---"

    REM 수정 날짜와 시간을 가져오기
    for /f "tokens=2,3" %%i in ('adb shell stat "%FILE%" ^| findstr "Modify:"') do (
        set MODIFY_DATE=%%i
        set MODIFY_TIME=%%j
    )
    
    REM MODIFY_DATE에서 YYYYMMDD 추출
    set DATE_PART=%MODIFY_DATE:~0,4%%MODIFY_DATE:~5,2%%MODIFY_DATE:~8,2%

    REM MODIFY_TIME에서 HHMMSS 추출
    set TIME_PART=%MODIFY_TIME:~0,2%%MODIFY_TIME:~3,2%%MODIFY_TIME:~6,2%

    REM 최종 결과 생성
    set RESULT="%DATE_PART%_%TIME_PART%.jpg"
    echo %RESULT%

    REM 파일을 지정된 위치로 복사
    adb pull "%FILE%" "C:\test\Camera"
)

ENDLOCAL

