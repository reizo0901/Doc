rem ################################################################################
rem PostgreSQL/IIS�����N��
rem ################################################################################
@ECHO OFF
 set COUNT=1

:PGCHECK
  echo CHECK [postgresql-x64-13]
  if %COUNT%.==4. goto PGABORT
  net start | findstr "postgresql-x64-13" > NULL
  if "%ERRORLEVEL%"=="1" goto PGSTART
  echo ��RUNNING [postgresql-x64-13]
  set COUNT=1
  goto IISCHECK

:PGSTART
  echo �Znet start [postgresql-x64-13] try count %COUNT%
  net start "postgresql-x64-13" > NULL
  set /A COUNT=%COUNT% + 1
  Ping 127.0.0.1 -n 10 > NULL
  goto PGCHECK

:PGABORT
  eventcreate /id 999 /l application /t error /d "%computername% postgresql-x64-13�N���G���["
  �~ERROR [postgresql-x64-13]�N���G���[
  pause
  EXIT /B 1

:IISCHECK
  echo CHECK [World Wide Web ���s�T�[�r�X]
  if %COUNT%.==4. goto IISABORT
  net start | findstr /C:"World Wide Web ���s�T�[�r�X" > NULL
  if "%ERRORLEVEL%"=="1" goto IISSTART
  echo ��RUNNING [World Wide Web ���s�T�[�r�X]
  goto BATEND

:IISSTART
  echo �Znet start [World Wide Web ���s�T�[�r�X] try count %COUNT%
  net start "World Wide Web ���s�T�[�r�X" > NULL
  set /A COUNT=%COUNT% + 1
  Ping 127.0.0.1 -n 10 > NULL
  goto IISCHECK

:IISABORT
  eventcreate /id 999 /l application /t error /d "%computername% World Wide Web ���s�T�[�r�X�N���G���["
  echo �~ERROR [World Wide Web ���s�T�[�r�X]�N���G���[
  pause
  EXIT /B 1

:BATEND
  pause
  EXIT /B 0
