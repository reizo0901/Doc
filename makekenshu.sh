#!/bin/bash


#メッセージ出力用関数
msgoutput(){
    echo $1
    echo `date '+%y/%m/%d %H:%M:%S'` `$1` >> ./result2.txt
}


msgoutput "[Info]研修環境構築スクリプト Ver0.1"


echo "過去研修環境を削除してから、新たに研修環境をセットアップします。"
echo "1) 研修環境の構築を開始する。"
echo "9) 処理を中断する。"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "研修環境をセットアップします。" && break;;
    9) msgoutput "[Info]処理を中断しました。" && exit;;
    *) echo "正しい番号を選択して下さい。" ;;
    esac
done

#ホストOS更新処理
msgoutput "[Info]ホストOSのアップデートを行います。"
yum update -y
msgoutput "[Info]ホストOSのアップグレードを行います。"
yum upgrade -y

#Dockerインストール
yum list installed | grep docker
if [ $? -gt 0 ]; then
    msgoutput "[Info]Dockerのインストールを開始します。"
    curl -sSL https://get.docker.com/ | sh
    yum list installed | grep docker
    if [ $? -gt 0 ]; then
        msgoutput "[Success]インストールが成功しました。"
    else
        msgoutput "[Error]インストールが失敗しました。"
        exit
    fi
    msgoutput "[Info]Dockerを起動します。"

    systemctl start docker
    msgoutput "[Info]Dockerを永続化します。"
else
    msgoutput "[Info]Dockerは既にインストールされています。"
fi

#過去研修環境削除
msgoutput "[Info]過去の研修環境を削除します。"

msgoutput "[Info]Dockerコンテナ[webapp]を削除します。"
docker ps -a | grep webapp
if [ $? -eq 0 ]; then
    docker stop webapp
    docker rm webapp
    if [ $? -gt 0 ]; then
        msgoutput "[Info][webapp]の削除が失敗したため、強制削除を実施します。"
        docker rm --force webapp
    fi
fi

#過去研修ディレクトリ削除
echo "過去の構築ディレクトリを削除します。"
if [ -e "/home/ec2-user/docker/code" ]; then
    sudo rm -fr /home/ec2-user/docker/code
    if [ $? -eq 0 ]; then
        msgoutput "[Success]削除が成功しました。"
    else
        msgoutput "[Error]削除が失敗しました。"
        exit
    fi
else
    msgoutput "[Info]過去の構築ディレクトリは存在しませんでした。"
fi

#Dockerイメージダウンロード
docker images | grep dockerfiles/django-uwsgi-nginx
if [ $? -gt 0 ]; then
    msgoutput "[Info]Dockerイメージ[dockerfiles/django-uwsgi-nginx]をダウンロードします。"
    docker pull dockerfiles/django-uwsgi-nginx
    docker images | grep dockerfiles/django-uwsgi-nginx
    if [ $? -gt 0 ]; then
        msgoutput "[Success]ダウンロードが成功しました。"
    else
        msgoutput "[Error]ダウンロードが失敗しました。"
        msgoutput "[Error]Docker Hubに接続出来ることを確認してください。"
        exit
    fi
else
    msgoutput "[Info]Dockerイメージ[dockerfiles/django-uwsgi-nginx]はすでに存在します。"
fi

#将来的にこの処理は不要になるかもしれません。
#Dockerイメージ内の環境を外出しするため、仮セットアップを実施
msgoutput "[Info]Dockerコンテナをセットアップ後、環境を取り出し削除します。"
docker run -it -d -p 80:80 --name webapp dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    msgoutput "[Success]セットアップが成功しました。"
else
    msgoutput "[Error]セットアップが失敗しました。"
    exit
fi

#Dockerコンテナ[webapp]の[/home/docker/code]配下をホストの[/home/ec2-user/docker/code]にコピー
msgoutput "[Info]Dockerコンテナからホストへ環境をコピー[/home/ec2-user/docker/code/]開始"
docker cp webapp:/home/docker/code/. /home/ec2-user/docker/code
if [ $? -eq 0 ]; then
    msgoutput "[Success]環境コピーが成功しました。"
else
    msgoutput "[Error]環境コピーが失敗しました。"
    exit
fi

#Dockerコンテナ[webapp]を削除
msgoutput "[Info]Docker停止[webapp]"
docker stop webapp
msgoutput "[Info]Docker削除[webapp]"
docker rm webapp
if [ $? -gt 0 ]; then
    msgoutput "[Info][webapp]の削除が失敗したため、強制削除を実施します。"
    docker rm --force webapp
fi

#Dockerコンテナ作成 ホストの/home/ec2-user/docker/codeとゲストの/home/docker/codeを紐づけ
msgoutput "[Info]Dockerコンテナの本セットアップを開始します。"
docker run -it -d -p 80:80 --name webapp -v /home/ec2-user/docker/code:/home/docker/code dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    msgoutput "[Success]本セットアップが成功しました。"
else
    msgoutput "[Success]本セットアップが失敗しました。"
    exit
fi

#Dockerコンテナ内のOSを更新します。
msgoutput "[Info]Dockerコンテナ[webapp]内のOSをアップデートします。"
#docker exec -it webapp apt-get update -y
msgoutput "[Info]Dockerコンテナ[webapp]内のOSをアップグレードします。"
#docker exec -it webapp apt-get upgrade -y

#Dockerコンテナ[webapp]へ[Vim]のインストール
msgoutput "[Info]Dockerコンテナ[webapp]への[Vim]のインストールを開始します。"
echo
#docker exec -it webapp apt-get install -y vim
if [ $? -eq 0 ]; then
    msgoutput "[Success][Vim]のインストールに成功しました。"
else
    msgoutput "[Error][Vim]のインストールに失敗しました。"
    exit
fi
echo

#Dockerコンテナ[webapp]内のDjangoプロジェクトファイル[settings.py]を修正
msgoutput "[Info]settings.pyをリネームします。"
mv /home/ec2-user/docker/code/app/website/settings.py /home/ec2-user/docker/code/app/website/settings_tmp.py
if [ $? -eq 0 ]; then
    msgoutput "[Success]リネームが成功しました。"
else
    msgoutput "[Error]リネームが失敗しました。"
    exit
fi
msgoutput "[Info]コンテナ内のDjangoプロジェクトファイル[settngs.py]の修正"
msgoutput "既存のALLOWED_HOSTSをコメントアウトします。"
sed -e "s/^ALLOWED_HOST/#ALLOWED_HOST/" /home/ec2-user/docker/code/app/website/settings_tmp.py > /home/ec2-user/docker/code/app/website/settings.py
if [ $? -eq 0 ]; then
    msgoutput "[Success]コメントアウトに成功しました。"
else
    msgoutput "[Error]コメントアウトに失敗しました。"
    exit
fi
msgoutput "[Info]新しいALLOWED_HOSTSを追記します。"
msgoutput "[Info]ALLOWED_HOSTS = ["\'"*"\'",]" >> /home/ec2-user/docker/code/app/website/settings.py
if [ $? -eq 0 ]; then
    msgoutput "[Success]追記に成功しました。"
else
    msgoutput "[Error]追記に失敗しました。"
    exit
fi
msgoutput "[Info]コンテナ[webapp]のuwsgiサービスを再起動します。"
docker exec -it webapp supervisorctl restart app-uwsgi
if [ $? -eq 0 ]; then
    msgoutput "[Success]再起動が成功しました。"
    msgoutput "[Info]ブラウザからサーバに接続して、Djangoのロケットが飛んでいることを確認してください。"
else
    msgoutput "[Error]再起動が失敗しました。"
    exit
fi

echo
msgoutput "[Info]研修環境構築スクリプトを終了します。" >> ./result.txt
