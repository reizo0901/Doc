#!/bin/bash
echo "研修環境構築スクリプト Ver0.1"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]研修環境構築スクリプト 開始" > ./result.txt

echo "過去研修環境を削除してから、新たに研修環境をセットアップします。"
echo "1) 研修環境の構築を開始する。"
echo "9) 処理を中断する。"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "研修環境をセットアップします。" && break;;
    9) echo "処理を中断しました。" && echo `date '+%y/%m/%d %H:%M:%S'` "[Info]処理を中断しました。" >> ./result.txt && exit;;
    *) echo "正しい番号を選択して下さい。" ;;
    esac
done

#ホストOS更新処理
echo "ホストOSのアップデートを行います。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]ホストOSのアップデートを行います。" >> ./result.txt
yum update -y
echo "ホストOSのアップグレードを行います。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]ホストOSのアップグレードを行います。" >> ./result.txt
yum upgrade -y

#Dockerインストール
yum list installed | grep docker
if [ $? -gt 0 ]; then
    echo "Dockerのインストールを開始します。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerのインストールを開始します。" >> ./result.txt
    curl -sSL https://get.docker.com/ | sh
    yum list installed | grep docker
    if [ $? -gt 0 ]; then
        echo "Dockerのインストールに成功しました。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Info]インストールが成功しました。" >> ./result.txt
    else
        echo "Dockerのインストールに失敗しました。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]インストールが失敗しました。" >> ./result.txt
        exit
    fi
    echo "Dockerを起動します。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerを起動します。" >> ./result.txt
    systemctl start docker
    echo "Dockerを永続化します。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerを永続化します。" >> ./result.txt
else
    echo "Dockerは既にインストールされています。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerは既にインストールされています。" >> ./result.txt
fi

#過去研修環境削除
echo "過去の研修環境を削除します。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]過去の研修環境を削除します。" >> ./result.txt

echo "Dockerコンテナ[webapp]を削除します。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerコンテナ[webapp]を削除します。" >> ./result.txt
docker ps -a | grep webapp
if [ $? -eq 0 ]; then
    docker stop webapp
    docker rm webapp
    if [ $? -gt 0 ]; then
        echo "[webapp]の削除が失敗したため、強制削除を実施します。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Info][webapp]の削除が失敗したため、強制削除を実施します。" >> ./result.txt
        docker rm --force webapp
    fi
fi
#過去研修ディレクトリ削除
echo "過去の構築ディレクトリを削除します。"
if [ -e "/home/ec2-user/docker/code/Dockerfile" ]; then
    rm -f -r /home/ec2-user/docker/code
    if [ -e "/home/ec2-user/docker/code/Dockerfile" ]; then
        echo "[Info]削除が成功しました。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Info]削除が成功しました。" >> ./result.txt
    else
        echo "[Info]削除が失敗しました。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]削除が失敗しました。" >> ./result.txt
        exit
    fi
else
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]過去の構築ディレクトリは存在しませんでした。" >> ./result.txt
fi

#Dockerイメージダウンロード
docker images | grep dockerfiles/django-uwsgi-nginx
if [ $? -gt 0 ]; then
    echo "Dockerイメージ[dockerfiles/django-uwsgi-nginx]をダウンロードします。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerイメージ[dockerfiles/django-uwsgi-nginx]をダウンロードします。" >> ./result.txt
    docker pull dockerfiles/django-uwsgi-nginx
    docker images | grep dockerfiles/django-uwsgi-nginx
    if [ $? -gt 0 ]; then
        echo "ダウンロードが成功しました。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Info]ダウンロードが成功しました。"
    else
        echo "ダウンロードが失敗しました。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]ダウンロードが失敗しました。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]Docker Hubに接続出来ることを確認してください。"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]研修環境構築スクリプトを終了します。"
        exit
    fi
else
    echo "Dockerイメージ[dockerfiles/django-uwsgi-nginx]はすでに存在します。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerイメージ[dockerfiles/django-uwsgi-nginx]はすでに存在します。" >> ./result.txt
fi

#Dockerイメージ内の環境を外出しするため、仮セットアップを実施
echo "Dockerコンテナをセットアップ後、環境を取り出し削除します。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerコンテナをセットアップ後、環境を取り出し削除します。" >> ./result.txt
docker run -it -d -p 80:80 --name webapp dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    echo "セットアップが成功しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]セットアップが成功しました。" >> ./result.txt
else
    echo "セットアップが失敗しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]セットアップが失敗しました。" >> ./result.txt
    exit
fi

#Dockerコンテナ[webapp]の[/home/docker/code]配下をホストの[/home/ec2-user/docker/code]にコピー
echo "Dockerコンテナからホストへ環境をコピー[/home/ec2-user/docker/code/]開始"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerコンテナからホストへ環境をコピー[/home/ec2-user/docker/code/]開始" >> ./result.txt
docker cp webapp:/home/docker/code/. /home/ec2-user/docker/code
if [ $? -eq 0 ]; then
    echo "環境コピーが成功しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]環境コピーが成功しました。" >> ./result.txt
else
    echo "環境コピーが失敗しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]環境コピーが失敗しました。" >> ./result.txt
    exit
fi

#Dockerコンテナ[webapp]を削除
echo "Docker停止[webapp]"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker停止[webapp]" >> ./result.txt
docker stop webapp
echo "Docker削除[webapp]"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker削除[webapp]" >> ./result.txt
docker rm webapp
if [ $? -gt 0 ]; then
    echo "[webapp]の削除が失敗したため、強制削除を実施します。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info][webapp]の削除が失敗したため、強制削除を実施します。" >> ./result.txt
    docker rm --force webapp
fi

#Dockerコンテナ作成 ホストの/home/ec2-user/docker/codeとゲストの/home/docker/codeを紐づけ
echo "Dockerコンテナの本セットアップを開始します。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerコンテナの本セットアップを開始します。" >> ./result.txt
docker run -it -d -p 80:80 --name webapp -v /home/ec2-user/docker/code:/home/docker/code dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    echo "本セットアップが成功しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]本セットアップが成功しました。" >> ./result.txt
else
    echo "本セットアップが失敗しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]本セットアップが失敗しました。" >> ./result.txt
    exit
fi

#Dockerコンテナ内のOSを更新します。
echo "Dockerコンテナ[webapp]内のOSをアップデートします。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerコンテナ[webapp]内のOSをアップデートします。" >> ./result.txt
docker exec -it webapp apt-get update -y
echo "Dockerコンテナ[webapp]内のOSをアップグレードします。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerコンテナ[webapp]内のOSをアップグレードします。" >> ./result.txt
docker exec -it webapp apt-get upgrade -y

#Dockerコンテナ[webapp]へ[Vim]のインストール
echo "Dockerコンテナ[webapp]に[Vim]をインストールします。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Dockerコンテナ[webapp]への[Vim]のインストールを開始します。" >> ./result.txt
docker exec -it webapp apt-get install -y vim
if [ $? -eq 0 ]; then
    echo "[Vim]のインストールに成功しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info][Vim]のインストールに成功しました。" >> ./result.txt
else
    echo "[Vim]のインストールに失敗しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error][Vim]のインストールに失敗しました。" >> ./result.txt
    exit
fi
echo

#Dockerコンテナ[webapp]内のDjangoプロジェクトファイル[settings.py]を修正
echo "コンテナ内のDjangoプロジェクトファイル[settings.py]を修正します。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]コンテナ内のDjangoプロジェクトファイル[settngs.py]の修正" >> result.txt
echo "既存のALLOWED_HOSTSをコメントアウトします。"
sed -e "s/^ALLOWED_HOST/#ALLOWED_HOST/" /home/ec2-user/docker/code/app/website/settings.py
if [ $? -eq 0 ]; then
    echo "コメントアウトに成功しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]コメントアウトに成功しました。" >> ./result.txt
else
    echo "コメントアウトに失敗しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]コメントアウトに失敗しました。" >> ./result.txt
    exit
fi
echo "新しいALLOWED_HOSTSを追記します。"
echo "ALLOWED_HOSTS = ["\'"*"\'",]" >> /home/ec2-user/docker/code/app/website/settings.py
if [ $? -eq 0 ]; then
    echo "追記に成功しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]追記に成功しました。" >> ./result.txt
else
    echo "追記に失敗しました。"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]追記に失敗しました。" >> ./result.txt
    exit
fi
echo "コンテナ[webapp]のuwsgiサービスを再起動します。"
docker exec -it webapp supervisorctl restart app-uwsgi
if [ $? -eq 0 ]; then
    echo "再起動が成功しました。
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]再起動が成功しました。" >> ./result.txt
    echo "ブラウザからサーバに接続して、Djangoのロケットが飛んでいることを確認してください。"
else
    echo "再起動が失敗しました。
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]再起動が失敗しました。" >> ./result.txt
    exit
fi

echo

echo "研修環境構築スクリプトを終了します。"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]研修環境構築スクリプトを終了します。" >> ./result.txt

