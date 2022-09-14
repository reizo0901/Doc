#!/bin/bash

#メッセージ出力用関数
msgoutput(){
    echo $1
    datetemp=`date "+%y/%m/%d %H:%M:%S"` 
    echo $datetemp $1 >> /home/docker/code/result_guest.txt
}

msgoutput "cd /home/docker/code"
cd /home/docker/code/
msgoutput "[Inf]プロジェクト[kenshu]を作成します。"
django-admin startproject kenshu
cd /home/docker/code/kenshu
msgoutput "[Inf]プロジェクト[kenshu]に[janken]アプリのディレクトリを作成します。"
python3 manage.py startapp janken
if [ $? -eq 0 ]; then
    msgoutput "[Suc][janken]アプリのディレクトリの作成に成功しました。"
else
    msgoutput "[Err][janken]アプリのディレクトリの作成に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit
fi

#kenshuプロジェクトの[settings.py]を修正
msgoutput "[Inf]settings.pyをsettings_tmp.pyにリネームします。"
mv /home/docker/code/kenshu/kenshu/settings.py /home/docker/code/kenshu/kenshu/settings_tmp.py
if [ $? -eq 0 ]; then
    msgoutput "[Suc]リネームが成功しました。"
else
    msgoutput "[Err]リネームが失敗しました。"
    msgoutput "[Inf]Script End!"
    exit
fi
msgoutput "[Inf][kenshu]プロジェクトの[settngs.py]の修正"
msgoutput "[Inf]既存のALLOWED_HOSTSをコメントアウトします。"
sed -e "s/^ALLOWED_HOST/#ALLOWED_HOST/" /home/docker/code/kenshu/kenshu/settings_tmp.py > /home/docker/code/kenshu/kenshu/settings.py
if [ $? -eq 0 ]; then
    msgoutput "[Suc]コメントアウトに成功しました。"
else
    msgoutput "[Err]コメントアウトに失敗しました。"
    msgoutput "[Inf]Script End!"
    exit
fi
msgoutput "[Inf]新しいALLOWED_HOSTSを追記します。"
echo "ALLOWED_HOSTS = ["\'"*"\'",]" >> /home/docker/code/kenshu/kenshu/settings.py
if [ $? -eq 0 ]; then
    msgoutput "[Suc]追記に成功しました。"
else
    msgoutput "[Err]追記に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit
fi

