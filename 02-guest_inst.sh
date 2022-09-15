#!/bin/bash

#実行ログ初期化
echo > /home/docker/code/result_guest.txt
#メッセージ出力用関数
msgoutput(){
    echo $1
    datetemp=`date "+%y/%m/%d %H:%M:%S"` 
    echo $datetemp $1 >> /home/docker/code/result_guest.txt
}

msgoutput "[Inf]コンテナ内設定スクリプトを実行します。"
#[sudo]のインストール
apt-get install -y sudo
if [ $? -eq 0 ]; then
    msgoutput "[Suc][sudo]のインストールに成功しました。"
else
    msgoutput "[Err][sudo]のインストールに失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

#[vim]のインストール
apt-get install -y vim
if [ $? -eq 0 ]; then
    msgoutput "[Suc][vim]のインストールに成功しました。"
else
    msgoutput "[Err][vim]のインストールに失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

#[sed]のインストール
apt-get install -y sudo
if [ $? -eq 0 ]; then
    msgoutput "[Suc][sed]のインストールに成功しました。"
else
    msgoutput "[Err][sed]のインストールに失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

#[visudo]のインストール
apt-get install -y sudo
if [ $? -eq 0 ]; then
    msgoutput "[Suc][visudo]のインストールに成功しました。"
else
    msgoutput "[Err][visudo]のインストールに失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

#ホストとのpermission問題を解決します。
msgoutput "ホストとのpermission問題を解決します。"
#ubuntuにはwheelが存在しないため作成します。
msgoutput "ubuntuにはwheelが存在しないため作成します。"
#[/etc/pam.d/su]を修正
msgoutput "[Inf]新しいauthを追記します。"
echo "auth sufficient pam_wheel.so trust group=wheel" >> /etc/pam.d/su 
if [ $? -eq 0 ]; then
    msgoutput "[Suc]追記に成功しました。"
else
    msgoutput "[Err]追記に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

msgoutput "[Inf]sudoersに[wheel]の設定を追記します。"
echo "%wheel ALL=(ALL) ALL" | EDITOR='tee -a' visudo > /dev/null
if [ $? -eq 0 ]; then
    msgoutput "[Suc]追記に成功しました。"
else
    msgoutput "[Err]追記に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi
msgoutput "[Inf]ゲストにグループ[ec2-user]を追加します。"
addgroup --gid 1000 ec2-user
cat /etc/group | grep ec2-user:x:1000:
if [ $? -eq 0 ]; then
    msgoutput "[Suc]にグループ[ec2-user]の追加に成功しました。"
else
    msgoutput "[Err]にグループ[ec2-user]の追加に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

msgoutput "[Inf]ゲストにグループ[wheel]を追加します。"
addgroup wheel
cat /etc/group | grep wheel:x:
if [ $? -eq 0 ]; then
    msgoutput "[Suc]にグループ[wheel]の追加に成功しました。"
else
    msgoutput "[Err]にグループ[wheel]の追加に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi
msgoutput "[Inf]ユーザ[ec2-user]をgid：1000のグループに追加します。"
adduser --gid 1000 ec2-user << "EOF"
P@ssword
P@ssword





Y
EOF
cat /etc/passwd | grep ec2-user:x:1000:1000:
if [ $? -eq 0 ]; then
    msgoutput "[Suc]グループ[ec2-user]へのユーザ[ec2-user]の追加に成功しました。"
else
    msgoutput "[Err]グループ[ec2-user]へのユーザ[ec2-user]の追加に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

msgoutput "[Inf]wheelグループにec2-userを追加します。"
usermod -aG wheel ec2-user
groups ec2-user | grep wheel
if [ $? -eq 0 ]; then
    msgoutput "[Suc]グループ[wheel]へのユーザ[ec2-user]の追加に成功しました。"
else
    msgoutput "[Err]グループ[wheel]へのユーザ[ec2-user]の追加に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

msgoutput "cd /home/docker/code"
cd /home/docker/code/
msgoutput "[Inf]Defaultのプロジェクトを削除します。"
rm -rf /home/docker/code/app
if [ $? -eq 0 ]; then
    msgoutput "[Suc]プロジェクトの削除に成功しました。"
else
    msgoutput "[Err]プロジェクトの削除に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

#プロジェクトをec2-userで作成する。

msgoutput "[Inf]スクリプト[03-django_set.sh]を実行します。"
su - ec2-user -c /home/docker/code/03-django_set.sh
if [ $? -eq 0 ]; then
    msgoutput "[Suc]スクリプト[03-django_set.sh]の実行に成功しました。"
else
    msgoutput "[Err]スクリプト[03-django_set.sh]の実行に失敗しました。"
    msgoutput "[Inf]Script End!"
    exit 1
fi

msgoutput "[Inf]コンテナ内設定スクリプトを終了します。"
msgoutput "[Inf]Script End!"
exit 0
