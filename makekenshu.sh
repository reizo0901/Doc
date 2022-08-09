#!/bin/bash
echo "研修環境構築スクリプト Ver0.1"

echo "1) 研修環境の構築を開始する。"
echo "9) 処理を中断する。"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "現在の環境をチェックします。" && break;;
    9) echo "処理を中断しました。" && exit;;
    *) echo "正しい番号を選択して下さい。" ;;
    esac
done

echo "過去の研修環境を削除します。"
echo "Dockerコンテナ削除[WEBAPP]"
echo "ディレクトリ削除[/home/ec2-user/dokcer/code/.]"
echo "1) 削除して続行する。"
echo "9) 処理を中断する。"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "過去構築を削除します。" && break;;
    9) echo "処理を中断しました。" && exit;;
    *) echo "正しい番号を選択して下さい。" ;;
    esac
done
echo "Dockerコンテナを削除します。"
dockor stop webapp
docker rm webapp
if [ $? -gt 0 ]; then
    echo "[webapp]の削除が失敗したため、強制削除を実施します。"
    docker rm --force webapp
fi
echo "過去の構築ディレクトリを削除します。"
rm -f -r /home/ec2-user/docker/code/.
echo "Dockerコンテナをセットアップ後、環境を取り出し削除します。"
docker run -it -d -p 80:80 --name webapp dockerfiles/django-uwsgi-nginx
echo "Dockerコンテナからホストへ環境をコピー[/home/ec2-user/docker/code/]"
docker cp webapp:/home/docker/code/. /home/ec2-user/docker/code
echo "Docker停止[webapp]"
docker stop webapp
echo "Docker削除[webapp]"
docker rm webapp
if [ $? -gt 0 ]; then
    echo "[webapp]の削除が失敗したため、強制削除を実施します。"
    docker rm --force webapp
fi
echo "Dockerコンテナ再セットアップします。"
docker run -it -d -p 80:80 --name webapp -v /home/ec2-user/docker/code:/home/docker/code dockerfiles/django-uwsgi-nginx
echo "Dockerコンテナ[webapp]内のOSをアップデートします。"
docker exec -it webapp apt-get update -y
echo "Dockerコンテナ[webapp]内のOSをアップグレードします。"
docker exec -it webapp apt-get upgrade -y
echo "Dockerコンテナ[webapp]に[Vim]をインストールします。"
docker exec -it webapp apt-get install -y vim
