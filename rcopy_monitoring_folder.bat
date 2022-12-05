@echo off

@tasklist /v | findstr /i run_robocopy_folder_batch
if %errorlevel%==0 (
    echo %date% %time% "rcopy_exec_folder動作中" >>  %~dp0tasklog_folder.log
    exit /b 0
) else (
    echo %date% %time% "rcopy_exec_folder停止中" >>  %~dp0tasklog_folder.log
)
if not exist %~dp0stoperr_folder.txt (
    rem エラーイベント発行
    eventcreate /T ERROR /L application /ID 123 /D "robocopy_folderが停止しています。施設部データ転送サーバを確認してください。"
    echo %date% %time% エラーを再度出力させるには、このファイルを削除してください。 >> %~dp0stoperr_folder.txt
)
exit /b 1 