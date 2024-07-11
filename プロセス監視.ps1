# 無限ループでプロセスを監視
while ($true) {
    # 現在のプロセスを取得
    $processes = Get-Process | Where-Object { $_.CPU -gt 10 }
    
    # フィルタリングされたプロセスをCSVファイルに出力
    if ($processes) {
        $processes | Select-Object Name, CPU | Export-Csv -Path "C:\path\to\output.csv" -NoTypeInformation -Append
    }
    
    # 監視間隔を設定（例：10秒）
    Start-Sleep -Seconds 10
}
