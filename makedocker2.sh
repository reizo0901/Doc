#!/bin/bash
echo "研修環境構築スクリプト Ver0.1"
echo `date '+%y/%m/%d %H:%M:%S'` "研修環境構築スクリプト 開始" > ./result.txt

echo "過去研修環境を削除してから、新たに研修環境をセットアップします。"
echo "1) 研修環境の構築を開始する。"
echo "9) 処理を中断する。"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "研修環境をセットアップします。" && break;;
    9) echo "処理を中断しました。" && echo `date '+%y/%m/%d %H:%M:%S'` "処理を中断しました。" >> ./result.txt && exit;;
    *) echo "正しい番号を選択して下さい。" ;;
    esac
done

#ホストOS更新処理
echo "ホストOSのアップデートを行います。"
echo `date '+%y/%m/%d %H:%M:%S'` "ホストOSのアップデートを行います。" >> ./result.txt
yum update -y
echo "ホストOSのアップグレードを行います。"
echo `date '+%y/%m/%d %H:%M:%S'` "ホストOSのアップグレードを行います。" >> ./result.txt
yum upgrade -y

#Dockerインストール
yum list installed | grep docker
if [ $? -gt 0]; then
    echo "Dockerをインストールします。"
    echo `date '+%y/%m/%d %H:%M:%S'` "Dockerをインストールします。" >> ./result.txt
    curl -sSL https://get.docker.com/ | sh
else
    echo "Dockerは既にインストールされています。"
    echo `date '+%y/%m/%d %H:%M:%S'` "Dockerは既にインストールされています。" >> ./result.txt
fi

#過去研修環境削除
echo "過去の研修環境を削除します。"
echo `date '+%y/%m/%d %H:%M:%S'` "過去の研修環境を削除します。" >> ./result.txt

echo "Dockerコンテナ[webapp]を削除します。"
echo `date '+%y/%m/%d %H:%M:%S'` "Dockerコンテナ[webapp]を削除します。" >> ./result.txt
docker ps -a | grep webapp
if [ $? -gt 0 ]; then
    docker stop webapp
    docker rm webapp
    if [ $? -gt 0 ]; then
        echo "[webapp]の削除が失敗したため、強制削除を実施します。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[webapp]の削除が失敗したため、強制削除を実施します。" >> ./result.txt
        docker rm --force webapp
    fi
fi
#過去研修ディレクトリ削除
echo "過去の構築ディレクトリを削除します。"
if [ -e "/home/ec2-user/docker/code/Dockerfile" ]
    rm -f -r /home/ec2-user/docker/code/.
    echo `date '+%y/%m/%d %H:%M:%S'` "過去の構築ディレクトリを削除しました。" >> ./result.txt
else
    echo `date '+%y/%m/%d %H:%M:%S'` "過去の構築ディレクトリは存在しませんでした。" >> ./result.txt
fi

#Dockerイメージダウンロード
docker images | grep dockerfiles/django-uwsgi-nginx
if [ $? -gt 0 ]; then
    echo "Dockerイメージ[dockerfiles/django-uwsgi-nginx]をダウンロードします。"
    echo `date '+%y/%m/%d %H:%M:%S'` "Dockerイメージ[dockerfiles/django-uwsgi-nginx]をダウンロードします。" >> ./result.txt
    docker pull dockerfiles/django-uwsgi-nginx
else
    echo "Dockerイメージ[dockerfiles/django-uwsgi-nginx]はすでに存在します。"
    echo `date '+%y/%m/%d %H:%M:%S'` "Dockerイメージ[dockerfiles/django-uwsgi-nginx]はすでに存在します。" >> ./result.txt
fi

#Dockerイメージ内の環境を外出しするため、仮セットアップを実施
echo "Dockerコンテナをセットアップ後、環境を取り出し削除します。"
echo `date '+%y/%m/%d %H:%M:%S'` "Dockerコンテナをセットアップ後、環境を取り出し削除します。" >> ./result.txt
docker run -it -d -p 80:80 --name webapp dockerfiles/django-uwsgi-nginx

#Dockerコンテナ[webapp]の[/home/docker/code]配下をホストの[/home/ec2-user/docker/code]にコピー
echo "Dockerコンテナからホストへ環境をコピー[/home/ec2-user/docker/code/]"
echo `date '+%y/%m/%d %H:%M:%S'` "Dockerコンテナからホストへ環境をコピー[/home/ec2-user/docker/code/]" >> ./result.txt
docker cp webapp:/home/docker/code/. /home/ec2-user/docker/code

#Dockerコンテナ[webapp]を削除
echo "Docker停止[webapp]"
echo `date '+%y/%m/%d %H:%M:%S'` "Docker停止[webapp]" >> ./result.txt
docker stop webapp
echo "Docker削除[webapp]"
echo `date '+%y/%m/%d %H:%M:%S'` "Docker削除[webapp]" >> ./result.txt
docker rm webapp
if [ $? -gt 0 ]; then
    echo "[webapp]の削除が失敗したため、強制削除を実施します。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[webapp]の削除が失敗したため、強制削除を実施します。" >> ./result.txt
    docker rm --force webapp
fi

#Dockerコンテナ作成 ホストの/home/ec2-user/docker/codeとゲストの/home/docker/codeを紐づけ
echo "Dockerコンテナ再セットアップします。"
echo `date '+%y/%m/%d %H:%M:%S'` "Dockerコンテナ再セットアップします。" >> ./result.txt
docker run -it -d -p 80:80 --name webapp -v /home/ec2-user/docker/code:/home/docker/code dockerfiles/django-uwsgi-nginx

#Dockerコンテナ内のOSを更新します。
echo "Dockerコンテナ[webapp]内のOSをアップデートします。"
echo `date '+%y/%m/%d %H:%M:%S'` "Dockerコンテナ[webapp]内のOSをアップデートします。" >> ./result.txt
docker exec -it webapp apt-get update -y
echo "Dockerコンテナ[webapp]内のOSをアップグレードします。"
echo `date '+%y/%m/%d %H:%M:%S'` "Dockerコンテナ[webapp]内のOSをアップグレードします。" >> ./result.txt
docker exec -it webapp apt-get upgrade -y
echo "Dockerコンテナ[webapp]に[Vim]をインストールします。"
echo `date '+%y/%m/%d %H:%M:%S'` "Dockerコンテナ[webapp]に[Vim]をインストールします。" >> ./result.txt
docker exec -it webapp apt-get install -y vim
echo "研修環境構築スクリプトを終了します。"
echo `date '+%y/%m/%d %H:%M:%S'` "研修環境構築スクリプトを終了します。" >> ./result.txt
echo
echo "コンテナ内のDjangoプロジェクトにアクセスするには以下のファイルの編集が必要です。"
echo "/home/ec2-user/docker/code/app/mysite/mysite/settings.py"
echo
echo "ALLOWED_HOSTS = []
echo "↓"
echo "ALOOWED_HOSTS = ['''*''',]"
