rem ################################################################################
rem PostgreSQL/IIS自動停止
rem ################################################################################
@ECHO OFF
 set COUNT=1

:IISCHECK
  echo CHECK [World Wide Web 発行サービス]
  if %COUNT%.==4. goto IISABORT
  net start | findstr /C:"World Wide Web 発行サービス" > NULL
  if "%ERRORLEVEL%"=="0" goto IISSTOP
  echo ●STOPPING [World Wide Web 発行サービス]
  set COUNT=1
  goto PGCHECK

:IISSTOP
  echo 〇NET STOP [World Wide Web 発行サービス] try count %COUNT%
  net stop "W3SVC" > NULL
  set /A COUNT=%COUNT% + 1
  Ping 127.0.0.1 -n 10 > NULL
  goto IISCHECK

:IISABORT
  eventcreate /id 999 /l application /t error /d "%computername% World Wide Web 発行サービス停止エラー"
  echo ×ERROR [World Wide Web 発行サービス]停止エラー
  pause
  EXIT /B 1

:PGCHECK
  echo CHECK [postgresql-x64-13]
  if %COUNT%.==4. goto PGABORT
  net start | findstr "postgresql-x64-13" > NULL
  if "%ERRORLEVEL%"=="0" goto PGSTOP
  echo ●STOPPING [postgresql-x64-13]
  goto BATEND

:PGSTOP
  echo 〇NET STOP [postgresql-x64-13] try count %COUNT%
  net stop "postgresql-x64-13" > NULL
  set /A COUNT=%COUNT% + 1
  Ping 127.0.0.1 -n 10 > NULL
  goto PGCHECK

:PGABORT
  eventcreate /id 999 /l application /t error /d "%computername% postgresql-x64-13停止エラー"
  echo ×ERROR [postgresql-x64-13]停止エラー
  pause
  EXIT /B 1

:BATEND
  pause
  EXIT /B 0
