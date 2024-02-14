# テストファイル作成スクリプト

# 使い方
# 
# tab区切りの読み込み用ファイル「makefiles.csv」を作成します。
# 1行目に項目を作成します。
# path<tab>filename<tab>size<tab>maketime<tab>updatetime<tab>accesstime
# 2行目から、作成に必要な情報を入力します。

# path:ファイルを作成するパス※末尾に\を付けないこと。
# filename:作成するファイルの名称
# size:作成するファイルのサイズ(Byte)
# maketime:作成日時
# updatetime:更新日時
# accesstime:アクセス日時

# 数値チェック関数
function IsNumeric([string]$check_date)
# 引数を倍精度浮動小数点数型に変換し、成功した場合は「True」を失敗した場合は「False」を返す。
{
    try
    {
        [double]::Parse($check_date)
        $True
    }
    catch
    {
        $False
    }
}



# 日時チェック関数
# 引数を日付型に変換し、成功した場合は「True」を失敗した場合は「False」を返す。
function IsDate([string]$check_date)
{
    try
    {
        [Datetime]::Parse($check_date)
        $True
    }
    catch
    {
        $False
    }
}

# 実行スクリプトのパスを取得
$Folder_Pass = Get-Location
# 余計な文字列を削除
$Folder_Pass = $Folder_Pass -replace "Path`n---- "
# スクリプトのパスを格納
Set-Location $Folder_Pass
# logファイルの定義
$log_time = Get-Date -Format "yyyyMMddHHmmss"
$log_file = $Folder_Pass+"\makefiles_result_"+$log_time+".log"
# csvファイルの定義
$csv_file = $Folder_Pass+"\makefiles.csv"
# csvファイルの読み込み
$csv_ary = Import-Csv $csv_file -Delimiter "`t" -Encoding Default


# logファイル初期化
$omsg = "[開始日時"+[datetime]::Now+"]"
echo $omsg > $log_file


# 変数初期化
$skip = 0
$mdir = 0
$cnt = 0
$omsg = ""

# ファイルから1行ずつファイル作成パラーメータを取得
foreach ($csv_line in $csv_ary){
    $cnt += 1
    $ocnt = ("00000" + $cnt).substring(("00000" + $cnt).length - 5)
    #write-host $ocnt:$csv_line[0].path $csv_line[0].filename $csv_line[0].size $csv_line[0].maketime $csv_line[0].updatetime $csv_line[0].accesstime

    # ファイルサイズの数値チェック
    if ($skip -eq 0)
    {
        if (-not(IsNumeric $csv_line[0].size))
        {
            $omsg = ""+$ocnt+":[ERR]ファイルサイズに問題があります。"
            $skip = 1
        }
    }

    # ドライブ存在チェック
    if ($skip -eq 0)
    {
        $temp_drv = Split-Path -Qualifier $csv_line[0].path
        if (-not(Test-Path $temp_drv))
        {
            $omsg = ""+$ocnt+":[ERR]指定されたパスのドライブは存在しません。"
            $skip = 1
        }
    }
    # ディスクの空き容量チェックし、空き容量が30%以下の場合は処理しない。
    # 処理が遅いので、一度の容量取得以降は、計算式のみで処理すれば早くなりそう...
    if ($skip -eq 0)
    {
        $drive_letter = "c"
        # ドライブ情報を取得する.
        $drv = Get-PSDrive $drive_letter
        # ドライブの空き容量と使用量を加算して総容量を知る.
        $total = ( $drv.Free + $drv.Used )
        # 作成語のドライブの使用量を試算
        $temp_size = $drv.Used + $csv_line[0].size
        # 使用率を計算する.
        $rate =  $temp_size  / $total
        # 空き容量が30%以下の場合
        if ($rate -le 0.3 -or $rate -gt 1.0)
        {
            $omsg = ""+$ocnt+":[ERR]作成後のドライブの空き容量が30%を切っています。"
            $skip = 1
        }
    }
    
    # パス作成チェック
    if ($skip -eq 0)
    {
        if (Test-Path $csv_line[0].path)
        {
            $mdir = 0
        }
        else
        {
            $mdir = 1
        }
    }
    # ファイル存在チェック
    # write-host $skip
    if ($skip -eq 0)
    {
        $temp_path = Join-Path $csv_line[0].path $csv_line[0].filename
        if (Test-Path $temp_path)
        {
            $skip = 1
            $omsg = ""+$ocnt+":[WAR]すでにファイルが存在しています。"
        }
    }
    
    # 作成日時チェック
    if ($skip -eq 0)
    {
        if (IsDate $csv_line[0].maketime = $True)
        {
            # 日付型に変換
            $maketime = [Datetime]::Parse($csv_line[0].maketime)
        }
        else
        {
            $omsg = ""+$ocnt+":[ERR]の作成日時の記述に誤りがあります。"
            $skip = 1
        }
    }
    # 更新日時チェック
    if ($skip -eq 0)
    {
        # 読み込んだ更新日時が空の場合
        if (($csv_line[0].updatetime).length -eq 0)
        {
            # 作成日時を更新日時に
            $updatetime = $maketime
        }
        else
        {
            # 更新日時のエラーをチェック
            if (IsDate $csv_line[0].updatetime = $False)
            {
                # 日付型に変換
                $updatetime = [Datetime]::Parse($csv_line[0].updatetime)
            }
            else
           {
               $omsg = ""+$ocnt+":[ERR]の更新日時の記述に誤りがあります。"
               $skip = 1
           }
        }
    }
    # アクセス日時チェック
    if ($skip -eq 0)
    {
        # 読み込んだ更新日時が空の場合
        if (($csv_line[0].accesstime.length) -eq 0)
        {
            # 作成日時を更新日時に
            $accesstime = $maketime
        }
        else
        {
            # アクセス日時のエラーをチェック
            if (IsDate $csv_line[0].accesstime = $False)
            {
                # 日付型に変換
                $accesstime = [Datetime]::Parse($csv_line[0].accesstime)
            }
            else
           {
               $omsg = ""+$ocnt+":[ERR]アクセス日時の記述に誤りがあります。"
               $skip = 1
           }
        }
    }
    # 問題がなければファイルを作成
    if ($skip -eq 0)
    {
        # フォルダを作成
        # 指定のフォルダまでの中間フォルダの日時も変更出来ると最高ですが...
        if ($mdir -eq 1)
        {
            # 存在しない複数階層のフォルダを作成しながらタイムスタンプを変更する。
            for ($sel = 1;$sel -le ($csv_line[0].path).length;$sel++)
            {
                if ((($csv_line[0].path).substring($sel - 1,1) -eq "\") -or ($sel -ge ($csv_line[0].path).length))
                {
                    # フォルダの区切りが発見出来たので、存在チェックで見つからなければフォルダ作成
                    if (test-path ($csv_line[0].path).substring(0,$sel))
                    {
                    }
                    else
                    {
                        New-Item ($csv_line[0].path).substring(0,$sel) -ItemType Directory | out-null
                        Set-Itemproperty ($csv_line[0].path).substring(0,$sel) -name CreationTime -value $maketime
                        Set-Itemproperty ($csv_line[0].path).substring(0,$sel) -name LastWriteTime -value $updatetime
                        Set-Itemproperty ($csv_line[0].path).substring(0,$sel) -name LastAccessTime -value $accesstime
                        $omsg = $omsg+$ocnt+":[INF]["+($csv_line[0].path).substring(0,$sel)+"]フォルダを作成しました。`n"
                    }
                }
            }
        }
        # ファイルを作成
        fsutil file createnew $temp_path $csv_line[0].size | out-null
        Set-Itemproperty $temp_path -name CreationTime -value $maketime
        Set-Itemproperty $temp_path -name LastWriteTime -value $updatetime
        Set-Itemproperty $temp_path -name LastAccessTime -value $accesstime
        $omsg = $omsg+""+$ocnt+":[INF]["+$temp_path+"]ファイルを作成しました。"
    }
    # メッセージを表示
    write-host $omsg
    echo $omsg >> $log_file
    write-host ""
    # ループ内変数初期化
    $omsg = ""
    $temp_drv = ""
    $skip = 0
}

$omsg = "[終了日時"+[datetime]::Now+"]"
echo $omsg >> $log_file



path	filename	size	maketime	updatetime	accesstime
c:\tmp\	dneodb.pgdmp	1200	2023/10/25 0:00		
c:\tmp\	dneoftsdb.pgdmp	1200	2023/10/25 0:00		
c:\tmp\	dneologdb.pgdmp	1200	2023/10/25 0:00		
g:\pgdump\	dneodb_20231019.pgdmp	1393	2023/10/19 0:00		
g:\pgdump\	dneodb_20231020.pgdmp	1394	2023/10/20 0:00		
g:\pgdump\	dneodb_20231021.pgdmp	1395	2023/10/21 0:00		
g:\pgdump\	dneodb_20231022.pgdmp	1396	2023/10/22 0:00		
g:\pgdump\	dneodb_20231023.pgdmp	1397	2023/10/23 0:00		
g:\pgdump\	dneodb_20231024.pgdmp	1398	2023/10/24 0:00		
g:\pgdump\	dneodb_20231025.pgdmp	1399	2023/10/25 0:00		
g:\pgdump\	dneoftsdb_20231019.pgdmp	1393	2023/10/19 0:00		
g:\pgdump\	dneoftsdb_20231020.pgdmp	1394	2023/10/20 0:00		
g:\pgdump\	dneoftsdb_20231021.pgdmp	1395	2023/10/21 0:00		
g:\pgdump\	dneoftsdb_20231022.pgdmp	1396	2023/10/22 0:00		
g:\pgdump\	dneoftsdb_20231023.pgdmp	1397	2023/10/23 0:00		
g:\pgdump\	dneoftsdb_20231024.pgdmp	1398	2023/10/24 0:00		
g:\pgdump\	dneoftsdb_20231025.pgdmp	1399	2023/10/25 0:00		
g:\pgdump\	dneologdb_20231019.pgdmp	1393	2023/10/19 0:00		
g:\pgdump\	dneologdb_20231020.pgdmp	1394	2023/10/20 0:00		
g:\pgdump\	dneologdb_20231021.pgdmp	1395	2023/10/21 0:00		
g:\pgdump\	dneologdb_20231022.pgdmp	1396	2023/10/22 0:00		
g:\pgdump\	dneologdb_20231023.pgdmp	1397	2023/10/23 0:00		
g:\pgdump\	dneologdb_20231024.pgdmp	1398	2023/10/24 0:00		
g:\pgdump\	dneologdb_20231025.pgdmp	1399	2023/10/25 0:00		
