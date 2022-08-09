#!/bin/bash
echo "研修環境構築スクリプト Ver0.1"

echo "1) 研修環境の構築を開始する。"
echo "9) 処理を中断する。"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "現在の環境をチェックします。" && break;;
    9) echo "処理を中断しました。" && exit;;
    *) echo "正しい番号を選択して下さい。" ;;
    esac
done

echo "過去の研修環境を削除します。"
echo "Dockerコンテナ削除[WEBAPP]"
echo "ディレクトリ削除[/home/ec2-user/dokcer/code/.]"
echo "1) 削除して続行する。"
echo "9) 処理を中断する。"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "過去構築を削除します。" && break;;
    9) echo "処理を中断しました。" && exit;;
    *) echo "正しい番号を選択して下さい。" ;;
    esac
done
echo "Dockerコンテナを削除します。"
dockor stop webapp
docker rm webapp
if [ $? -gt 0 ]; then
    echo "[webapp]の削除が失敗したため、強制削除を実施します。"
    docker rm --force webapp
fi
echo "過去の構築ディレクトリを削除します。"
rm -f -r /home/ec2-user/docker/code/.
echo "Dockerコンテナをセットアップ後、環境を取り出し削除します。"
docker run -it -d -p 80:80 --name webapp dockerfiles/django-uwsgi-nginx
echo "Dockerコンテナからホストへ環境をコピー[/home/ec2-user/docker/code/]"
docker cp webapp:/home/docker/code/. /home/ec2-user/docker/code
echo "Docker停止[webapp]"
docker stop webapp
echo "Docker削除[webapp]"
docker rm webapp
if [ $? -gt 0 ]; then
    echo "[webapp]の削除が失敗したため、強制削除を実施します。"
    docker rm --force webapp
fi
echo "Dockerコンテナ再セットアップします。"
docker run -it -d -p 80:80 --name webapp -v /home/ec2-user/docker/code:/home/docker/code dockerfiles/django-uwsgi-nginx
echo "Dockerコンテナ[webapp]内のOSをアップデートします。"
docker exec -it webapp apt-get update -y
echo "Dockerコンテナ[webapp]内のOSをアップグレードします。"
docker exec -it webapp apt-get upgrade -y
echo "Dockerコンテナ[webapp]に[Vim]をインストールします。"
docker exec -it webapp apt-get install -y vim

