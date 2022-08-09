#!/bin/bash
echo "���C���\�z�X�N���v�g Ver0.1"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]���C���\�z�X�N���v�g �J�n" > ./result.txt

echo "�ߋ����C�����폜���Ă���A�V���Ɍ��C�����Z�b�g�A�b�v���܂��B"
echo "1) ���C���̍\�z���J�n����B"
echo "9) �����𒆒f����B"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "���C�����Z�b�g�A�b�v���܂��B" && break;;
    9) echo "�����𒆒f���܂����B" && echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�����𒆒f���܂����B" >> ./result.txt && exit;;
    *) echo "�������ԍ���I�����ĉ������B" ;;
    esac
done

#�z�X�gOS�X�V����
echo "�z�X�gOS�̃A�b�v�f�[�g���s���܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�z�X�gOS�̃A�b�v�f�[�g���s���܂��B" >> ./result.txt
yum update -y
echo "�z�X�gOS�̃A�b�v�O���[�h���s���܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�z�X�gOS�̃A�b�v�O���[�h���s���܂��B" >> ./result.txt
yum upgrade -y

#Docker�C���X�g�[��
yum list installed | grep docker
if [ $? -gt 0 ]; then
    echo "Docker�̃C���X�g�[�����J�n���܂��B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�̃C���X�g�[�����J�n���܂��B" >> ./result.txt
    curl -sSL https://get.docker.com/ | sh
    yum list installed | grep docker
    if [ $? -gt 0 ]; then
        echo "Docker�̃C���X�g�[���ɐ������܂����B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�C���X�g�[�����������܂����B" >> ./result.txt
    else
        echo "Docker�̃C���X�g�[���Ɏ��s���܂����B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]�C���X�g�[�������s���܂����B" >> ./result.txt
        exit
    fi
    echo "Docker���N�����܂��B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker���N�����܂��B" >> ./result.txt
    systemctl start docker
    echo "Docker���i�������܂��B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker���i�������܂��B" >> ./result.txt
else
    echo "Docker�͊��ɃC���X�g�[������Ă��܂��B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�͊��ɃC���X�g�[������Ă��܂��B" >> ./result.txt
fi

#�ߋ����C���폜
echo "�ߋ��̌��C�����폜���܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�ߋ��̌��C�����폜���܂��B" >> ./result.txt

echo "Docker�R���e�i[webapp]���폜���܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�R���e�i[webapp]���폜���܂��B" >> ./result.txt
docker ps -a | grep webapp
if [ $? -eq 0 ]; then
    docker stop webapp
    docker rm webapp
    if [ $? -gt 0 ]; then
        echo "[webapp]�̍폜�����s�������߁A�����폜�����{���܂��B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Info][webapp]�̍폜�����s�������߁A�����폜�����{���܂��B" >> ./result.txt
        docker rm --force webapp
    fi
fi
#�ߋ����C�f�B���N�g���폜
echo "�ߋ��̍\�z�f�B���N�g�����폜���܂��B"
if [ -e "/home/ec2-user/docker/code/Dockerfile" ]; then
    rm -f -r /home/ec2-user/docker/code
    if [ -e "/home/ec2-user/docker/code/Dockerfile" ]; then
        echo "[Info]�폜���������܂����B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�폜���������܂����B" >> ./result.txt
    else
        echo "[Info]�폜�����s���܂����B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]�폜�����s���܂����B" >> ./result.txt
        exit
    fi
else
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�ߋ��̍\�z�f�B���N�g���͑��݂��܂���ł����B" >> ./result.txt
fi

#Docker�C���[�W�_�E�����[�h
docker images | grep dockerfiles/django-uwsgi-nginx
if [ $? -gt 0 ]; then
    echo "Docker�C���[�W[dockerfiles/django-uwsgi-nginx]���_�E�����[�h���܂��B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�C���[�W[dockerfiles/django-uwsgi-nginx]���_�E�����[�h���܂��B" >> ./result.txt
    docker pull dockerfiles/django-uwsgi-nginx
    docker images | grep dockerfiles/django-uwsgi-nginx
    if [ $? -gt 0 ]; then
        echo "�_�E�����[�h���������܂����B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�_�E�����[�h���������܂����B"
    else
        echo "�_�E�����[�h�����s���܂����B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]�_�E�����[�h�����s���܂����B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]Docker Hub�ɐڑ��o���邱�Ƃ��m�F���Ă��������B"
        echo `date '+%y/%m/%d %H:%M:%S'` "[Error]���C���\�z�X�N���v�g���I�����܂��B"
        exit
    fi
else
    echo "Docker�C���[�W[dockerfiles/django-uwsgi-nginx]�͂��łɑ��݂��܂��B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�C���[�W[dockerfiles/django-uwsgi-nginx]�͂��łɑ��݂��܂��B" >> ./result.txt
fi

#Docker�C���[�W���̊����O�o�����邽�߁A���Z�b�g�A�b�v�����{
echo "Docker�R���e�i���Z�b�g�A�b�v��A�������o���폜���܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�R���e�i���Z�b�g�A�b�v��A�������o���폜���܂��B" >> ./result.txt
docker run -it -d -p 80:80 --name webapp dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    echo "�Z�b�g�A�b�v���������܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�Z�b�g�A�b�v���������܂����B" >> ./result.txt
else
    echo "�Z�b�g�A�b�v�����s���܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]�Z�b�g�A�b�v�����s���܂����B" >> ./result.txt
    exit
fi

#Docker�R���e�i[webapp]��[/home/docker/code]�z�����z�X�g��[/home/ec2-user/docker/code]�ɃR�s�[
echo "Docker�R���e�i����z�X�g�֊����R�s�[[/home/ec2-user/docker/code/]�J�n"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�R���e�i����z�X�g�֊����R�s�[[/home/ec2-user/docker/code/]�J�n" >> ./result.txt
docker cp webapp:/home/docker/code/. /home/ec2-user/docker/code
if [ $? -eq 0 ]; then
    echo "���R�s�[���������܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]���R�s�[���������܂����B" >> ./result.txt
else
    echo "���R�s�[�����s���܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]���R�s�[�����s���܂����B" >> ./result.txt
    exit
fi

#Docker�R���e�i[webapp]���폜
echo "Docker��~[webapp]"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker��~[webapp]" >> ./result.txt
docker stop webapp
echo "Docker�폜[webapp]"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�폜[webapp]" >> ./result.txt
docker rm webapp
if [ $? -gt 0 ]; then
    echo "[webapp]�̍폜�����s�������߁A�����폜�����{���܂��B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info][webapp]�̍폜�����s�������߁A�����폜�����{���܂��B" >> ./result.txt
    docker rm --force webapp
fi

#Docker�R���e�i�쐬 �z�X�g��/home/ec2-user/docker/code�ƃQ�X�g��/home/docker/code��R�Â�
echo "Docker�R���e�i�̖{�Z�b�g�A�b�v���J�n���܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�R���e�i�̖{�Z�b�g�A�b�v���J�n���܂��B" >> ./result.txt
docker run -it -d -p 80:80 --name webapp -v /home/ec2-user/docker/code:/home/docker/code dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    echo "�{�Z�b�g�A�b�v���������܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�{�Z�b�g�A�b�v���������܂����B" >> ./result.txt
else
    echo "�{�Z�b�g�A�b�v�����s���܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�{�Z�b�g�A�b�v�����s���܂����B" >> ./result.txt
    exit
fi

#Docker�R���e�i����OS���X�V���܂��B
echo "Docker�R���e�i[webapp]����OS���A�b�v�f�[�g���܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�R���e�i[webapp]����OS���A�b�v�f�[�g���܂��B" >> ./result.txt
docker exec -it webapp apt-get update -y
echo "Docker�R���e�i[webapp]����OS���A�b�v�O���[�h���܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�R���e�i[webapp]����OS���A�b�v�O���[�h���܂��B" >> ./result.txt
docker exec -it webapp apt-get upgrade -y

#Docker�R���e�i[webapp]��[Vim]�̃C���X�g�[��
echo "Docker�R���e�i[webapp]��[Vim]���C���X�g�[�����܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]Docker�R���e�i[webapp]�ւ�[Vim]�̃C���X�g�[�����J�n���܂��B" >> ./result.txt
docker exec -it webapp apt-get install -y vim
if [ $? -eq 0 ]; then
    echo "[Vim]�̃C���X�g�[���ɐ������܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info][Vim]�̃C���X�g�[���ɐ������܂����B" >> ./result.txt
else
    echo "[Vim]�̃C���X�g�[���Ɏ��s���܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error][Vim]�̃C���X�g�[���Ɏ��s���܂����B" >> ./result.txt
    exit
fi
echo

#Docker�R���e�i[webapp]����Django�v���W�F�N�g�t�@�C��[settings.py]���C��
echo "�R���e�i����Django�v���W�F�N�g�t�@�C��[settings.py]���C�����܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�R���e�i����Django�v���W�F�N�g�t�@�C��[settngs.py]�̏C��" >> result.txt
echo "������ALLOWED_HOSTS���R�����g�A�E�g���܂��B"
sed -e "s/^ALLOWED_HOST/#ALLOWED_HOST/" /home/ec2-user/docker/code/app/website/settings.py
if [ $? -eq 0 ]; then
    echo "�R�����g�A�E�g�ɐ������܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�R�����g�A�E�g�ɐ������܂����B" >> ./result.txt
else
    echo "�R�����g�A�E�g�Ɏ��s���܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]�R�����g�A�E�g�Ɏ��s���܂����B" >> ./result.txt
    exit
fi
echo "�V����ALLOWED_HOSTS��ǋL���܂��B"
echo "ALLOWED_HOSTS = ["\'"*"\'",]" >> /home/ec2-user/docker/code/app/website/settings.py
if [ $? -eq 0 ]; then
    echo "�ǋL�ɐ������܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�ǋL�ɐ������܂����B" >> ./result.txt
else
    echo "�ǋL�Ɏ��s���܂����B"
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]�ǋL�Ɏ��s���܂����B" >> ./result.txt
    exit
fi
echo "�R���e�i[webapp]��uwsgi�T�[�r�X���ċN�����܂��B"
docker exec -it webapp supervisorctl restart app-uwsgi
if [ $? -eq 0 ]; then
    echo "�ċN�����������܂����B
    echo `date '+%y/%m/%d %H:%M:%S'` "[Info]�ċN�����������܂����B" >> ./result.txt
    echo "�u���E�U����T�[�o�ɐڑ����āADjango�̃��P�b�g�����ł��邱�Ƃ��m�F���Ă��������B"
else
    echo "�ċN�������s���܂����B
    echo `date '+%y/%m/%d %H:%M:%S'` "[Error]�ċN�������s���܂����B" >> ./result.txt
    exit
fi

echo

echo "���C���\�z�X�N���v�g���I�����܂��B"
echo `date '+%y/%m/%d %H:%M:%S'` "[Info]���C���\�z�X�N���v�g���I�����܂��B" >> ./result.txt

