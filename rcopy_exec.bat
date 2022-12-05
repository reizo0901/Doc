rem 遅延環境変数設定
setlocal enabledelayedexpansion
title=run_robocopy_batch
@echo off
rem バッチファイル内定数設定

rem タスク情報
set tsyst=fileserver
set tuser=administrator
set tpass=P@ssw0rd123

rem コピー情報ファイル
set copyinfo1=copytarget1.txt
set copyinfo2=copytarget2.txt

rem コピー元サーバ情報
set origin_srv=施設部NFSサーバ
set origin_ipa=192.168.2.174
set origin_pat=\\192.168.2.174\DATA2
set origin_drv=h:
set origin_usr=nfsikou
set origin_pas=nfsikou

rem コピー先サーバ情報
set copyto_srv=施設部設計DBサーバ
set copyto_ipa=192.168.2.173
set copyto_pat=\\192.168.2.173\c$\sharedfiles
set copyto_drv=i:
rem set copyto_use=cals.local\administrator
set copyto_usr=cals.local\administrator
set copyto_pas=p@ssw0rd2211

rem ROBOCOPYパラメータ
set robo_param=/E /XO /COPY:DT /MT:4 /R:0 /W:0 /NP
rem ROBOCOPYパラメータ フォルダのみ作成用
set robo_paraf=/E /NOCOPY
rem ROBOCOPYパラメータ デバッグ用
set robo_parad=/E /XO /COPY:DT /MT:4 /R:0 /W:0 /NP /L

rem エラーフラグ初期化
set errflg=0

rem 実行モード(0:off 1:フォルダのみコピー 2:デバッグモード)
rem 0:コピーが行われます。
rem 1:フォルダのみをコピーします。
rem 2:デバッグモードのため、コピーされませんがログを出力します。

set runmode=0
if %runmode%==0 (
    set copytarget=%copyinfo1%
    cls
    echo コピーモードで処理を行いますが、よろしいですか？
    echo 処理を中断したい場合は、[Ctrl]+[c]を押下して中断してください。
    echo .
    pause
)
if %runmode%==1 (
    set copytarget=%copyinfo2%
    cls
    echo フォルダのみコピーモードで処理を行いますが、よろしいですか？
    echo 処理を中断したい場合は、[Ctrl]+[c]を押下して中断してください。
    echo .
    pause
)
if %runmode%==2 (
    set copytarget=%copyinfo1%
    cls
    echo デバッグモードで処理を行いますが、よろしいですか？
    echo 処理を中断したい場合は、[Ctrl]+[c]を押下して中断してください。
    echo .
    pause
)

rem ログ日付表記用YYYYMMDDhhmm文字列作成
set sdate=%date:~0,4%%date:~5,2%%date:~8,2%
rem 時刻表示の頭の空白を0に置き換え
set time2=%time: =0%
set stime=%time2:~0,2%%time2:~3,2%%time2:~6,2%
set timestamp=%sdate%%stime%

echo %date% %time% [INF]rcopy.bat 処理開始 >> %~dp0log\robo_result_%timestamp%.log

rem バッチ2重起動禁止
if exist %~dp0runrobo.txt (
    echo 既にバッチファイルが実行されています。
    echo 現在コピー中のバッチに影響がでるため、バッチ処理を中断します。
    echo バッチファイルが動作していないことを確認したら、runrobo.txtを削除して再実行してください。
    echo %date% %time% [ERR]rcopy.bat ２重起動 >> %~dp0log\robo_result_%timestamp%.log
    rem ポーズ
    pause
    rem プログラム異常終了
    exit /b 1
) else (
    echo 起動していません。
    echo %date% %time% [INF]runrobo.txt作成 >> %~dp0log\robo_result_%timestamp%.log
    echo 前回起動日時：%date% %time% > %~dp0runrobo.txt
    echo このファイルが存在するとrcopy.batを実行することはできません。 >> %~dp0runrobo.txt
    echo rcopy.batが動いていないことを確認してファイルを削除し、再実行してください。 >> %~dp0runrobo.txt
)

echo %copytarget%
rem 存在チェック[%copytarget%]
if exist %~dp0%copytarget% (
    rem 実行ログに存在確認結果を書き出し
    echo %date% %time% [INF]%copytarget% OK! >> %~dp0log\robo_result_%timestamp%.log
) else (
    rem 標準出力にエラーメッセージを表示
    echo %date% %time% 「%~dp0%copytarget%」ファイルが存在しません。
    rem 実行ログに存在確認結果を書き出し
    echo %date% %time% [ERR]%copytarget% NG! >> %~dp0log\robo_result_%timestamp%.log
    rem ポーズ
    pause
    rem runrobo.txt 削除
    del %~dp0runrobo.txt
    echo %date% %time% [INF]runrobo.txt削除 >> %~dp0log\robo_result_%timestamp%.log
    rem プログラム異常終了
    exit /b 1
)

rem 監視タスク有効化
schtasks /tn rcopy_monitoring /change /enable
rem 監視タスク実行
schtasks /tn rcopy_monitoring /run

rem ネットワークドライブ接続確認
rem コピー元ネットワークドライブ確認
if exist %origin_drv% (
    echo %date% %time% [INF]%origin_srv%用ネットワークドライブ有り >> %~dp0log\robo_result_%timestamp%.log
) else (
    echo %date% %time% [INF]%origin_srv%用ネットワークドライブが存在しないため作成します。 >> %~dp0log\robo_result_%timestamp%.log
    net use %origin_drv% %origin_pat% %origin_pas% /user:%origin_usr% /yes
    if %ERRORLEVEL% == 0 (
        echo %date% %time% [INF]%origin_srv%用ネットワークドライブを作成しました。 >> %~dp0log\robo_result_%timestamp%.log
    ) else (
        echo %date% %time% [ERR]%origin_srv%用ネットワークドライブの作成に失敗しました。 >> %~dp0log\robo_result_%timestamp%.log
    )
)
rem コピー先ネットワークドライブ確認
if exist %copyto_drv% (
    echo %date% %time% [INF]%copyto_srv%用ネットワークドライブ有り >> %~dp0log\robo_result_%timestamp%.log
) else (
    echo %date% %time% [INF]%copyto_srv%用ネットワークドライブが存在しないため作成します。 >> %~dp0log\robo_result_%timestamp%.log
    net use  %copyto_drv% %copyto_pat% %copyto_pas% /user:%copyto_usr% /yes
    if %ERRORLEVEL% == 0 (
        echo %date% %time% [INF]%copyto_srv%用ネットワークドライブを作成しました。 >> %~dp0log\robo_result_%timestamp%.log
    ) else (
        echo %date% %time% [ERR]%copyto_srv%用ネットワークドライブの作成に失敗しました。 >> %~dp0log\robo_result_%timestamp%.log
    )
)

rem pause
rem echo %date% %time% [INF]runrobo.txt削除 >> %~dp0log\robo_result_%timestamp%.log
rem del %~dp0runrobo.txt
rem exit


rem copytarget.txtファイル順次読み込み
for /f "tokens=1,2,3 delims=," %%a in (%~dp0%copytarget%) do (
    echo %%a
    echo %%b
    echo %%c
    echo -------

    rem copytarget.txtが空の場合は終了
    rem コピー元ディレクトリ存在確認
    if exist %%b (
        rem 実行ログに存在確認結果を書き出し
        echo 実行ログに存在確認結果を書き出し [INF]コピー元[%%a][%%b] 存在あり >> %~dp0log\robo_result_%timestamp%.log
    ) else (
        rem イベントログにエラーを出力
        rem ※JPiT PCでイベント発行コマンドは使えません。
        eventcreate /T ERROR /L application /ID 123 /D "[%%a]のrobocopy実行に失敗しました。コピー元[%%b]が存在しません。"
        rem 実行ログに存在確認結果を書き出し
        echo %date% %time% [ERR]コピー元[%%a][%%b] 存在しないためスキップします。 >> %~dp0log\robo_result_%timestamp%.log
        set errflg=1
    )
    rem コピー先フォルダ存在確認
    if exist %%c (
        rem 実行ログに存在確認結果を書き出し
        echo %date% %time% [INF]コピー先[%%a][%%c] 存在あり >> %~dp0log\robo_result_%timestamp%.log
    ) else (
        rem イベントログにエラーを出力
        rem ※JPiT PCでイベント発行コマンドは使えません。
        eventcreate /T ERROR /L application /ID 123 /D "[%%a]のrobocopy実行に失敗しました。コピー先[%%c]が存在しません。"
        rem 実行ログに存在確認結果を書き出し
        echo %date% %time% [ERR]コピー先[%%a][%%c] 存在しないためスキップします。 >> %~dp0log\robo_result_%timestamp%.log
        set errflg=1
    )
    rem エラーがなければrobocopy開始
    if !errflg!==0 (
        rem 実行ログにrobocopy開始を書き出し
        echo %date% %time% [INF]robocopy開始[%%a] >> %~dp0log\robo_result_%timestamp%.log
        echo %runmode%
        if %runmode%==0 (
            echo robocopy %robo_param% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log >> %~dp0log\robo_result_%timestamp%.log
            robocopy %robo_param% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log
        )
        if %runmode%==1 (
        echo robocopy %robo_paraf% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log >> %~dp0log\robo_result_%timestamp%.log
            robocopy %robo_paraf% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log
        )
        if %runmode%==2 (
        echo robocopy %robo_parad% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log >> %~dp0log\robo_result_%timestamp%.log
            robocopy %robo_parad% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log
        )
        if !errorlevel!==0 (
            echo OK %%a %%b
            rem 実行ログに正常終了を書き出し
            echo %date% %time% [INF]robocopy正常終了[%%a] >> %~dp0log\robo_result_%timestamp%.log
            rem OKリストに書き出し
            echo %%a,%%b,%%c >> %~dp0copy_ok_%timestamp%.txt
        ) else (
            rem イベントログにエラーを出力
            rem ※JPiT PCでイベント発行コマンドは使えません。
            rem eventcreate /T ERROR /L application /ID 123 /D "[%%a]のrobocopy実行に失敗しました。robocopyでエラーが発生しました。"
            rem 実行ログに異常終了を書き出し
            echo %date% %time% [ERR]robocopy異常終了[!errorlevel!][%%a] >> %~dp0log\robo_result_%timestamp%.log
            rem NGリストに書き出し
            echo %%a,%%b,%%c >> %~dp0copy_ng_%timestamp%.txt
        )
    ) else (
        echo NG %%a %%b
        echo %%a,%%b,%%c >> %~dp0copy_ng_%timestamp%.txt
        rem エラーフラグ初期化
        set errflg=0
    )
    rem ウエイト
    ping 127.0.0.1 -n 1 > nul
)
pause
del %~dp0runrobo.txt
echo %date% %time% [INF]runrobo.txt削除 >> %~dp0log\robo_result_%timestamp%.log
rem プログラム正常終了
echo %date% %time% [INF]rcopy.bat 正常終了 >> %~dp0log\robo_result_%timestamp%.log
rem 監視タスク無効化
schtasks /tn rcopy_monitoring /change /disable

rem 遅延環境変数設定解除
endlocal
rem 正常終了
exit /b 0
