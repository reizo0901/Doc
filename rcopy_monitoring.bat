@echo off

@tasklist /v | findstr /i run_robocopy_batch
if %errorlevel%==0 (
    echo %date% %time% "rcopy_exec動作中" >>  %~dp0tasklog.log
    exit /b 0
) else (
    echo %date% %time% "rcopy_exec停止中" >>  %~dp0tasklog.log
)
if not exist %~dp0stoperr.txt (
    rem エラーイベント発行
    eventcreate /T ERROR /L application /ID 123 /D "robocopyが停止しています。施設部データ転送サーバを確認してください。"
    echo %date% %time% エラーを再度出力させるには、このファイルを削除してください。 >> %~dp0stoperr.txt
)
exit /b 1 