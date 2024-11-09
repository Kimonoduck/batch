# 배치파일
## 추출 데이터 저장 위치
### 윈도우
`C:\test`

### 맥
`/Users/Shared/test`

## 추출 데이터 폴더 구조
```
📂test
 └📂Camera
  └📜20241108_201942.jpg
  └ ...
 └📂Trash
  └📜20241109_201942.jpg
  └ ...
 └📂metadata
  └📜20241108_201942_metadata.txt
  └📜20241109_201942_metadata.txt
  └ ...
 └📂MYBOX_cache
  └📜20241110_201942.jpg
  └ ...
 └📂Soda_cache
  └📜20241111_201942.jpg
  └ ...
 └📜picture_taken_log.txt
 └📜wifi_log.txt
 └📜snow_usage_log.txt
 └📜soda_usage_log.txt
 └📜mybox_usage_log.txt
 └📜drive_usage_log.txt
```
## ❗️존재하지 않는 데이터 처리 방식❗️
### Camera / Trash / MYBOX_cache / Soda_cache
- 원인: 사진/캐시 파일 존재 X
- 처리: 폴더만 존재하고 jpg파일 존재 X

### metadata
- 원인: 스마트폰 GPS가 활성화되어 있지 않은 사진, 외부 카메라앱으로 찍은 사진, 스크린샷
- 처리: 해당 사진에 대한 txt 파일은 존재하지만 내용은 없음

### picture_taken_log.txt / wifi_log.txt
- 원인: 관련 데이터 존재 X
- 처리: txt 파일은 존재하지만 내용은 없음

### 앱_usage_log.txt
- 원인: 사용 기록 존재 X
- 처리: txt 파일 존재 X
