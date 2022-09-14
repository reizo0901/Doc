#!/bin/bash

#result.txt初期化
echo > ./result_host.txt

#メッセージ出力用関数
msgoutput(){
    echo $1
    datetemp=`date "+%y/%m/%d %H:%M:%S"` 
    echo $datetemp $1 >> ./result_host.txt
}

clear
msgoutput "[Inf]研修環境構築スクリプトを開始します。"

echo "過去研修環境を削除してから、新たに研修環境をセットアップします。"
echo
echo "1) 研修環境の構築を開始する。"
echo "9) 処理を中断する。"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "研修環境をセットアップする。" && break;;
    9) msgoutput "[Inf]処理を中断しました。" && exit;;
    *) echo "正しい番号を選択して下さい。" ;;
    esac
done

#ホストOS更新処理
msgoutput "[Inf]ホストOSのインストール済みパッケージのアップデートを開始します。"
yum update -y
#msgoutput "[Inf]ホストOSのアップグレードを行います。"
#yum upgrade -y

#Dockerインストール
msgoutput "[Inf]Dockerのインストール状況を確認します。"
yum list installed | grep "docker-ce.x86_64"
if [ $? -gt 0 ]; then
    msgoutput "[Inf]Dockerのインストールを開始します。"
    curl -sSL https://get.docker.com/ | sh
    yum list installed | grep "docker-ce.x86_64"
    if [ $? -gt 0 ]; then
        msgoutput "[Suc]インストールが成功しました。"
    else
        msgoutput "[Err]インストールが失敗しました。"
        exit
    fi
    msgoutput "[Inf]Dockerを起動します。"
    sudo systemctl start docker
    msgoutput "[Inf]Dockerを永続化します。"
    sudo systemctl enable docker
else
    msgoutput "[Inf]Dockerは既にインストールされています。"
fi

#過去研修環境削除
msgoutput "[Inf]過去の研修環境の削除を開始します。"

msgoutput "[Inf]Dockerコンテナ[webapp]を削除します。"
docker ps -a | grep webapp
if [ $? -eq 0 ]; then
    docker stop webapp
    docker rm webapp
    if [ $? -gt 0 ]; then
        msgoutput "[Inf][webapp]の削除に失敗したため、強制削除を実施します。"
        docker rm --force webapp
    else
        msgoutput "[Suc][webapp]の削除に成功しました。"
    fi
else
    msgoutpu "[Inf]コンテナ[webapp]は存在しませんでした。"
fi

#過去研修ディレクトリ削除
msgoutput "[Inf]過去の構築ディレクトリを削除します。"
if [ -e "/home/ec2-user/docker/code" ]; then
    sudo rm -fr /home/ec2-user/docker/code
    if [ $? -eq 0 ]; then
        msgoutput "[Suc]削除が成功しました。"
    else
        msgoutput "[Err]削除が失敗しました。"
        exit
    fi
else
    msgoutput "[Inf]過去の構築ディレクトリは存在しませんでした。"
fi

#Dockerイメージダウンロード
msgout "[Inf]Dockerイメージ[dockerfiles/django-uwsgi-nginx]のダウンロードを開始します。"
docker images | grep dockerfiles/django-uwsgi-nginx
if [ $? -gt 0 ]; then
    docker pull dockerfiles/django-uwsgi-nginx
    docker images | grep dockerfiles/django-uwsgi-nginx
    if [ $? -gt 0 ]; then
        msgoutput "[Suc]ダウンロードが成功しました。"
    else
        msgoutput "[Err]ダウンロードが失敗しました。"
        msgoutput "[Err]Docker Hubに接続出来ることを確認してください。"
        exit
    fi
else
    msgoutput "[Inf]Dockerイメージはすでに存在しています。"
fi

#将来的にこの処理は不要になるかもしれません。
#Dockerイメージ内の環境を外出しするため、仮セットアップを実施
msgoutput "[Inf]Dockerコンテナをセットアップ後、環境を取り出し削除します。"
docker run -it -d -p 80:80 --name webapp dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    msgoutput "[Suc]セットアップ(1/2)が成功しました。"
else
    msgoutput "[Err]セットアップ(1/2)が失敗しました。"
    exit
fi

#Dockerコンテナ[webapp]の[/home/docker/code]配下をホストの[/home/ec2-user/docker/code]にコピー
msgoutput "[Inf]Dockerコンテナからホストへ環境をコピー[/home/ec2-user/docker/code/]開始"
docker cp webapp:/home/docker/code/. /home/ec2-user/docker/code
if [ $? -eq 0 ]; then
    msgoutput "[Suc]環境コピーが成功しました。"
else
    msgoutput "[Err]環境コピーが失敗しました。"
    exit
fi

#Dockerコンテナ[webapp]を削除
msgoutput "[Inf]Docker停止[webapp]"
docker stop webapp
msgoutput "[Inf]Docker削除[webapp]"
docker rm webapp
if [ $? -gt 0 ]; then
    msgoutput "[Inf][webapp]の削除に失敗したため、強制削除を実施します。"
    docker rm --force webapp
fi

#Dockerコンテナ作成 ホストの/home/ec2-user/docker/codeとゲストの/home/docker/codeを紐づけ
msgoutput "[Inf]Dockerコンテナの本セットアップを開始します。"
docker run -it -d -p 80:80 --name webapp -v /home/ec2-user/docker/code:/home/docker/code dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    msgoutput "[Suc]セットアップ(2/2)が成功しました。"
else
    msgoutput "[Suc]セットアップ(2/2)が失敗しました。"
    exit
fi
#Dockerコンテナ内のOSを更新します。
msgoutput "[Inf]Dockerコンテナ[webapp]内のOSをアップデートします。"
docker exec -it webapp apt-get update -y
#msgoutput "[Inf]Dockerコンテナ[webapp]内のOSをアップグレードします。"
#docker exec -it webapp apt-get upgrade -y

#Dockerコンテナ[webapp]構築スクリプト実行
msgoutput "[Inf]コンテナ内に02-guest_inst.shを格納します。"
docker cp ./02-guest_inst.sh webapp:/home/docker/code/
if [ $? -eq 0 ]; then
    msgoutput "[Suc]スクリプトの格納に成功しました。"
else
    msgoutput "[Err]スクリプトの格納に失敗しました。"
    exit
fi
msgoutput "[Inf]コンテナ内に03-django_set.shを格納します。"
docker cp ./03-django_set.sh webapp:/home/docker/code/
if [ $? -eq 0 ]; then
    msgoutput "[Suc]スクリプトの格納に成功しました。"
else
    msgoutput "[Err]スクリプトの格納に失敗しました。"
    exit
fi
msgoutput "[Inf]スクリプトに実行権限を付与します。"
docker exec -it webapp chmod 777 /home/docker/code/02-guest_inst.sh
if [ $? -eq 0 ]; then
    msgoutput "[Suc]スクリプトの実行権限付与に成功しました。"
else
    msgoutput "[Err]スクリプトの実行権限付与に失敗しました。"
    exit
fi
msgoutput "[Inf]スクリプトに実行権限を付与します。"
docker exec -it webapp chmod 777 /home/docker/code/03-django_set.sh
if [ $? -eq 0 ]; then
    msgoutput "[Suc]スクリプトの実行権限付与に成功しました。"
else
    msgoutput "[Err]スクリプトの実行権限付与に失敗しました。"
    exit
fi
msgoutput "[Inf]スクリプトを実行します。"
docker exec -it -d webapp /home/docker/code/02-guest_inst.sh
if [ $? -eq 0 ]; then
    msgoutput "[Suc]スクリプトの実行に成功しました。"
else
    msgoutput "[Err]スクリプトの実行に失敗しました。"
    exit
fi

echo "スクリプトの終了を待っています。"
tail -n0 --pid=$(($BASHPID+1)) -F ./code/result_guest.txt | sed '/Script End!/q'
#コンテナ内の実行ログをコンテナ外の実行ログとマージします。
cat ./code/result_guest.txt >> ./result_host.txt

msgoutput "[Inf]uwsgi.iniをコンテナ内にコピーを開始します。"
\cp -f ./04-uwsgi.ini ./code/uwsgi.ini
if [ $? -eq 0 ]; then
    msgoutput "[Suc]コピーに成功しました。"
else
    msgoutput "[Err]コピーに失敗しました。"
    exit
fi

msgoutput "[Inf]コンテナ[webapp]のuwsgiサービスを再起動します。"
docker exec -it webapp supervisorctl restart app-uwsgi
if [ $? -eq 0 ]; then
    msgoutput "[Suc]再起動が成功しました。"
    msgoutput "[Inf]ブラウザからサーバに接続して、Djangoのロケットが飛んでいることを確認してください。"
else
    msgoutput "[Err]再起動が失敗しました。"
    exit
fi
msgoutput "[Inf]研修環境構築スクリプトを終了します。"

