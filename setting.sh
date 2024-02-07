echo Make Directorys

mkdir /home/ec2-user/containers
mkdir /home/ec2-user/containers/django
mkdir /home/ec2-user/containers/django/startup
mkdir /home/ec2-user/containers/django/uwsgi
mkdir /home/ec2-user/containers/nginx
mkdir /home/ec2-user/containers/nginx/conf

targetpath=/home/ec2-user/containers/docker-compose.yml
echo make file[$targetpath]

echo version: '2.23.3' > $targetpath
echo services: >> $targetpath
echo \ \ \ \ nginx: >> $targetpath
echo \ \ \ \ \ \ \ \ container_name: nginx >> $targetpath
echo \ \ \ \ \ \ \ \ image: nginx:latest >> $targetpath
echo \ \ \ \ \ \ \ \ ports: >> $targetpath
echo \ \ \ \ \ \ \ \ \ \ \ \ - 80:80 >> $targetpath

targetpath=/home/ec2-user/containers/nginx/conf/nginx.conf
echo makefile[$targetpath]

echo upstream django { > $targetpath
echo \ \ \ \ server django:8000\; >> $targetpath
echo } >> $targetpath
echo  >> $targetpath
echo server { >> $targetpath
echo \ \ \ \ listen 80\; >> $targetpath
echo \ \ \ \ location / { >> $targetpath
echo \ \ \ \ \ \ \ \ uwsgi_pass django/\; >> $targetpath
echo \ \ \ \ \ \ \ \ include /etc/nginx/uwsgi_params/\; >> $targetpath
echo \ \ \ \ } >> $targetpath
echo } >> $targetpath

targetpath=/home/ec2-user/containers/nginx/uwsgi_params
echo makefile[$targetpath]

echo uwsgi_param QUERY_STRING \$query_string\; > $targetpath
echo uwsgi_param REQUEST_METHOD \$request_method\; >> $targetpath
echo uwsgi_param CONTENT_TYPE \$content_type\; >> $targetpath
echo uwsgi_param CONTENT_LENGTH \$content_length\; >> $targetpath
echo uwsgi_param REQUEST_URI \$request_uri\; >> $targetpath
echo uwsgi_param PATH_INFO \$document_uri\; >> $targetpath
echo uwsgi_param DOCUMENT_ROOT \$document_root\; >> $targetpath
echo uwsgi_param SERVER_PROTOCOL \$server_protocol\; >> $targetpath
echo uwsgi_param REMOTE_ADDR \$remote_addr\; >> $targetpath
echo uwsgi_param REMOTE_PORT \$remote_port\; >> $targetpath
echo uwsgi_param SERVER_ADDR \$server_addr\; >> $targetpath
echo uwsgi_param SERVER_PORT \$server_port\; >> $targetpath
echo uwsgi_param SERVER_NAME \$server_name\; >> $targetpath

targetpath=/home/ec2-user/containers/django/uwsgi/uwsgi.ini
echo makefile[$targetpath]

echo [uwsgi] > $targetpath
echo socket = :8000 >> $targetpath
echo module = djangoapp.wsgi >> $targetpath
echo wsgi-file = /app/app/wsgi.py >> $targetpath
echo logto = /wsgi/wsgi.log >> $targetpath
echo py-autoreload = 1 >> $targetpath

targetpath=/home/ec2-user/containers/django/Dockerfile
echo makefile[$targetpath]

echo FROM python:3 > $targetpath
echo RUN apt-get update \&\& apt-get install -y tree vim >> $targetpath
echo WORKDIR /django >> $targetpath
echo COPY requirements.txt /django >> $targetpath
echo RUN pip install -r requirements.txt >> $targetpath
echo COPY . /django >> $targetpath

targetpath=/home/ec2-user/containers/django/requirements.txt
echo makefile[$targetpath]

echo django > $targetpath
echo psycopg2 >> $targetpath
echo uwsgi >> $targetpath
echo django-bootstrap-datepicker-plus==5.0.3 >> $targetpath
echo django-bootstrap4==22.3 >> $targetpath

targetpath=/home/ec2-user/containers/django/startup/startup.sh
echo makefile[$targetpath]

echo source /startup/setuser.sh \# setuser.sh を実行する > $targetpath
echo uwsgi --ini /wsgi/uwsgi.ini \# uwsgi.ini の設定をもとに uwsgi を実行する >> $targetpath

targetpath=/home/ec2-user/containers/django/startup/setuser.sh
echo makefile[$targetpath]

echo \#!/bin/bash -e > $targetpath
echo SHELL_NAME=\'setuser.sh\' >> $targetpath
echo echo \"[\$SHELL_NAME] START\" >> $targetpath
echo  >> $targetpath
echo \# setup group >> $targetpath
echo if getent group \"\$GROUP_ID\" \> /dev/null 2\>\&1\; then >> $targetpath
echo \ \ \ \ echo \"[\$SHELL_NAME] GROUP_ID \'\$GROUP_ID\' already exists.\" >> $targetpath
echo else >> $targetpath
echo \ \ \ \ echo \"[\$SHELL_NAME] GROUP_ID \'\$GROUP_ID\' does NOT exist. So execute [groupadd -g \$GROUP_ID \$GROUP_NAME].\" >> $targetpath
echo \ \ \ \ groupadd -g \$GROUP_ID \$GROUP_NAME >> $targetpath
echo fi >> $targetpath
echo  >> $targetpath
echo \# setup user >> $targetpath
echo if getent passwd \"\$USER_ID\" \> /dev/null 2\>\&1\; then >> $targetpath
echo \ \ \ \ echo \"[\\$SHELL_NAME] USER_ID \'\$USER_ID\' already exists.\" >> $targetpath
echo else >> $targetpath
echo \ \ \ \ echo \"[\$SHELL_NAME] USER_ID \'\$USER_ID\' does NOT exist. So execute [useradd -m -s /bin/bash -u \$USER_ID -g \$GROUP_ID \$USER_NAME].\" >> $targetpath
echo \ \ \ \ useradd -m -s /bin/bash -u \$USER_ID -g \$GROUP_ID \$USER_NAME >> $targetpath
echo fi >> $targetpath
echo  >> $targetpath
echo echo \"[\$SHELL_NAME] FINISH\" >> $targetpath

echo file chmod[$targetpath]
sudo chmod +x -R /home/ec2-user/containers/django/startup/*

