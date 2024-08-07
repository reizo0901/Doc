@echo off

rem ################################################################################
rem イベントログのアーカイブファイルを共有ディスクへ移動
rem 過去１年以上前のイベントログのアーカイブファイルを共有ディスクから削除
rem ################################################################################

rem ################################################################################
rem 環境変数
rem ################################################################################

rem 実行ログファイル格納場所(例：c:\tool)
set logpath=c:\tool
rem 実行ログファイル名(先頭)
set logfirst=evtxdel
rem 実行ログファイル名生成
set yyyyMMdd=%date:/=%
set hhmmss=%time::=%
set hhmmss=%hhmmss:~0,6%
set logfile=%logpath%\%logfirst%_%yyyyMMdd%_%hhmmss%.log

rem 実行ログ保持期間[日数](例：7)
set lperiod=7
rem net use用アカウント
set nuser=jptransport\moveevtuser
rem net use用パスワード
set npass=Passw0rd2402
rem pdn01 IPアドレス(例：192.168.2.171)
set pdn01ip=192.168.2.171
rem pdn02 IPアドレス(例：192.168.2.172)
set pdn02ip=192.168.2.172
rem コピー元Windowsイベントログアーカイブファイル格納場所(例：c:\windows\system32\winevt\logs)
set localfd=c:\windows\system32\winevt\logs
rem コピー先Windowsイベントログアーカイブファイル格納フォルダ名(例：winevt\logs)
set sharefd=winevt\logs
rem net use用ドライブ文字(例：z)
set mountdv=z
rem コピー先共有ドライブ文字(例：g)
set sharedv=g
rem アーカイブログ保持期間[日数](例：366)
set aperiod=366

rem ################################################################################
rem メイン処理
rem ################################################################################

echo [%date% %time%][%computername%]イベントログアーカイブファイル移動・削除処理[処理を開始しました]>>%logfile%

rem ################################################################################
rem 実行ログ削除処理
rem ################################################################################

echo [%date% %time%][%computername%]実行ログ削除処理[開始]>>%logfile%
forfiles /P %logpath% /D -%lperiod% /M %logfirst%_*.log /c "cmd /c del -f -q @path&&echo [削除][成功] @path>>%logfile%||echo [削除][失敗] @path>>%logfile%"
echo [%date% %time%][%computername%]実行削除処理[終了]>>%logfile%

rem ################################################################################
rem Zドライブマウント処理
rem ################################################################################

echo [%date% %time%][%computername%]移動・削除対象ドライブマウント処理[処理開始]>>%logfile%

rem 自サーバに共有ディスクがマウントされているか確認し、コピー先サーバを選択する
rem 自サーバに共有ディスクがマウントされている
if not exist "%sharedv%:\" (
    rem 自サーバはpdn01
    if "%computername%"=="PDN01" (
        set trgsrv=%pdn02ip%
    ) else (
        set trgsrv=%pdn01ip%
    )
rem 自サーバに共有ディスクがマウントされていない
) else (
    rem 自サーバはpdn01
    if "%computername%"=="PDN01" (
        set trgsrv=%pdn01ip%
    ) else (
        set trgsrv=%pdn02ip%
    )
)

rem net use用接続文字列
set trg_str=\\%trgsrv%\%sharedv%$\%sharefd%
echo [%date% %time%][%computername%]移動・削除対象ドライブマウント処理[アーカイブファイル移動先サーバ[%trgsrv%]]>>%logfile%

rem Zドライブがすでにマウントされている場合は再マウントする
if exist "%mountdv%:\" (
    echo [%date% %time%][%computername%]移動・削除対象ドライブマウント処理既存のドライブのアンマウント>>%logfile%
    net use /d %mountdv%:>>%logfile%
    rem 
    ping 127.0.0.1 -n 2>>%logfile%
    echo [%date% %time%][%computername%]移動・削除対象ドライブマウント処理[移動・削除対象ドライブのマウント]>>%logfile%
    net use %mountdv%: %trg_str% /user:%nuser% %npass%>>%logfile%
    net use>>%logfile%
) else (
    echo [%date% %time%][%computername%]移動・削除対象ドライブマウント処理[移動・削除対象ドライブのマウント]>>%logfile%
    net use %mountdv%: %trg_str% /user:%nuser% %npass%>>%logfile%
    net use>>%logfile%
)

echo [%date% %time%][%computername%]移動・削除対象ドライブマウント処理[処理終了]>>%logfile%

rem 移動・削除対象ドライブのマウント状態確認
if exist "%mountdv%:\" (
    echo [%date% %time%][%computername%]アーカイブファイル移動処理[ドライブマウント][成功]>>%logfile%
    rem 移動・削除対象パス設定
    set trgpath=%mountdv%:\%computername%
) else (
    echo [%date% %time%][%computername%]アーカイブファイル移動処理[ドライブマウント][失敗]>>%logfile%
    goto BADEND
)
echo %trgpath%>>%logfile%

rem ################################################################################
rem アーカイブファイル削除処理
rem ################################################################################

echo [%date% %time%][%computername%]アーカイブファイル削除処理[開始]>>%logfile%
forfiles /P %trgpath% /D -%aperiod% /M archive-*.evtx /C "cmd /c del -f -q @path&&echo [削除][成功]@file>>%logfile%||echo [削除][成功]@file>>%logfile%"
echo [%date% %time%][%computername%]アーカイブファイル削除処理[終了]>>%logfile%

rem ################################################################################
rem アーカイブファイル移動処理
rem ################################################################################

echo [%date% %time%][%computername%]アーカイブファイル移動処理[開始]>>%logfile%
rem 対象のフォルダのアーカイブファイルのみを選択し、処理を行う
dir /A-D /B %localfd%\archive-*.evtx | find /c /v "" | findstr /r "^0$">>%logfile% 
if "%errorlevel%"=="1" (
    forfiles /P %localfd% /M archive-*.evtx /C "cmd /c move /y @path %mountdv%:\%computername%\@file&&echo [移動][成功]@file>>%logfile%||echo [移動][失敗]@file>>%logfile%"
) else (
    echo 移動対象となるアーカイブログが存在しません。
)

rem マウントしたドライブを解除
net use /d %mountdv%:
net use>>%logfile%
echo [%date% %time%][%computername%]アーカイブファイル移動処理[終了]>>%logfile%

goto BATEND

:BADEND
echo [%date% %time%][%computername%]イベントログアーカイブファイル移動・削除処理[異常終了]>>%logfile%
rem exit /b 1

:BATEND
echo [%date% %time%][%computername%]イベントログアーカイブファイル移動・削除処理[終了]>>%logfile%
rem exit /b 0
