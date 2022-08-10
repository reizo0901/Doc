#!/bin/bash


#���b�Z�[�W�o�͗p�֐�
msgoutput(){
    echo $1
    echo `date '+%y/%m/%d %H:%M:%S'` `$1` >> ./result2.txt
}


msgoutput "[Info]���C���\�z�X�N���v�g Ver0.1"


echo "�ߋ����C�����폜���Ă���A�V���Ɍ��C�����Z�b�g�A�b�v���܂��B"
echo "1) ���C���̍\�z���J�n����B"
echo "9) �����𒆒f����B"
while :
do
    read -p: VAR
    case "$VAR" in
    1) echo "���C�����Z�b�g�A�b�v���܂��B" && break;;
    9) msgoutput "[Info]�����𒆒f���܂����B" && exit;;
    *) echo "�������ԍ���I�����ĉ������B" ;;
    esac
done

#�z�X�gOS�X�V����
msgoutput "[Info]�z�X�gOS�̃A�b�v�f�[�g���s���܂��B"
yum update -y
msgoutput "[Info]�z�X�gOS�̃A�b�v�O���[�h���s���܂��B"
yum upgrade -y

#Docker�C���X�g�[��
yum list installed | grep docker
if [ $? -gt 0 ]; then
    msgoutput "[Info]Docker�̃C���X�g�[�����J�n���܂��B"
    curl -sSL https://get.docker.com/ | sh
    yum list installed | grep docker
    if [ $? -gt 0 ]; then
        msgoutput "[Success]�C���X�g�[�����������܂����B"
    else
        msgoutput "[Error]�C���X�g�[�������s���܂����B"
        exit
    fi
    msgoutput "[Info]Docker���N�����܂��B"

    systemctl start docker
    msgoutput "[Info]Docker���i�������܂��B"
else
    msgoutput "[Info]Docker�͊��ɃC���X�g�[������Ă��܂��B"
fi

#�ߋ����C���폜
msgoutput "[Info]�ߋ��̌��C�����폜���܂��B"

msgoutput "[Info]Docker�R���e�i[webapp]���폜���܂��B"
docker ps -a | grep webapp
if [ $? -eq 0 ]; then
    docker stop webapp
    docker rm webapp
    if [ $? -gt 0 ]; then
        msgoutput "[Info][webapp]�̍폜�����s�������߁A�����폜�����{���܂��B"
        docker rm --force webapp
    fi
fi

#�ߋ����C�f�B���N�g���폜
echo "�ߋ��̍\�z�f�B���N�g�����폜���܂��B"
if [ -e "/home/ec2-user/docker/code" ]; then
    sudo rm -fr /home/ec2-user/docker/code
    if [ $? -eq 0 ]; then
        msgoutput "[Success]�폜���������܂����B"
    else
        msgoutput "[Error]�폜�����s���܂����B"
        exit
    fi
else
    msgoutput "[Info]�ߋ��̍\�z�f�B���N�g���͑��݂��܂���ł����B"
fi

#Docker�C���[�W�_�E�����[�h
docker images | grep dockerfiles/django-uwsgi-nginx
if [ $? -gt 0 ]; then
    msgoutput "[Info]Docker�C���[�W[dockerfiles/django-uwsgi-nginx]���_�E�����[�h���܂��B"
    docker pull dockerfiles/django-uwsgi-nginx
    docker images | grep dockerfiles/django-uwsgi-nginx
    if [ $? -gt 0 ]; then
        msgoutput "[Success]�_�E�����[�h���������܂����B"
    else
        msgoutput "[Error]�_�E�����[�h�����s���܂����B"
        msgoutput "[Error]Docker Hub�ɐڑ��o���邱�Ƃ��m�F���Ă��������B"
        exit
    fi
else
    msgoutput "[Info]Docker�C���[�W[dockerfiles/django-uwsgi-nginx]�͂��łɑ��݂��܂��B"
fi

#�����I�ɂ��̏����͕s�v�ɂȂ邩������܂���B
#Docker�C���[�W���̊����O�o�����邽�߁A���Z�b�g�A�b�v�����{
msgoutput "[Info]Docker�R���e�i���Z�b�g�A�b�v��A�������o���폜���܂��B"
docker run -it -d -p 80:80 --name webapp dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    msgoutput "[Success]�Z�b�g�A�b�v���������܂����B"
else
    msgoutput "[Error]�Z�b�g�A�b�v�����s���܂����B"
    exit
fi

#Docker�R���e�i[webapp]��[/home/docker/code]�z�����z�X�g��[/home/ec2-user/docker/code]�ɃR�s�[
msgoutput "[Info]Docker�R���e�i����z�X�g�֊����R�s�[[/home/ec2-user/docker/code/]�J�n"
docker cp webapp:/home/docker/code/. /home/ec2-user/docker/code
if [ $? -eq 0 ]; then
    msgoutput "[Success]���R�s�[���������܂����B"
else
    msgoutput "[Error]���R�s�[�����s���܂����B"
    exit
fi

#Docker�R���e�i[webapp]���폜
msgoutput "[Info]Docker��~[webapp]"
docker stop webapp
msgoutput "[Info]Docker�폜[webapp]"
docker rm webapp
if [ $? -gt 0 ]; then
    msgoutput "[Info][webapp]�̍폜�����s�������߁A�����폜�����{���܂��B"
    docker rm --force webapp
fi

#Docker�R���e�i�쐬 �z�X�g��/home/ec2-user/docker/code�ƃQ�X�g��/home/docker/code��R�Â�
msgoutput "[Info]Docker�R���e�i�̖{�Z�b�g�A�b�v���J�n���܂��B"
docker run -it -d -p 80:80 --name webapp -v /home/ec2-user/docker/code:/home/docker/code dockerfiles/django-uwsgi-nginx
docker ps | grep webapp
if [ $? -eq 0 ]; then
    msgoutput "[Success]�{�Z�b�g�A�b�v���������܂����B"
else
    msgoutput "[Success]�{�Z�b�g�A�b�v�����s���܂����B"
    exit
fi

#Docker�R���e�i����OS���X�V���܂��B
msgoutput "[Info]Docker�R���e�i[webapp]����OS���A�b�v�f�[�g���܂��B"
#docker exec -it webapp apt-get update -y
msgoutput "[Info]Docker�R���e�i[webapp]����OS���A�b�v�O���[�h���܂��B"
#docker exec -it webapp apt-get upgrade -y

#Docker�R���e�i[webapp]��[Vim]�̃C���X�g�[��
msgoutput "[Info]Docker�R���e�i[webapp]�ւ�[Vim]�̃C���X�g�[�����J�n���܂��B"
echo
#docker exec -it webapp apt-get install -y vim
if [ $? -eq 0 ]; then
    msgoutput "[Success][Vim]�̃C���X�g�[���ɐ������܂����B"
else
    msgoutput "[Error][Vim]�̃C���X�g�[���Ɏ��s���܂����B"
    exit
fi
echo

#Docker�R���e�i[webapp]����Django�v���W�F�N�g�t�@�C��[settings.py]���C��
msgoutput "[Info]settings.py�����l�[�����܂��B"
mv /home/ec2-user/docker/code/app/website/settings.py /home/ec2-user/docker/code/app/website/settings_tmp.py
if [ $? -eq 0 ]; then
    msgoutput "[Success]���l�[�����������܂����B"
else
    msgoutput "[Error]���l�[�������s���܂����B"
    exit
fi
msgoutput "[Info]�R���e�i����Django�v���W�F�N�g�t�@�C��[settngs.py]�̏C��"
msgoutput "������ALLOWED_HOSTS���R�����g�A�E�g���܂��B"
sed -e "s/^ALLOWED_HOST/#ALLOWED_HOST/" /home/ec2-user/docker/code/app/website/settings_tmp.py > /home/ec2-user/docker/code/app/website/settings.py
if [ $? -eq 0 ]; then
    msgoutput "[Success]�R�����g�A�E�g�ɐ������܂����B"
else
    msgoutput "[Error]�R�����g�A�E�g�Ɏ��s���܂����B"
    exit
fi
msgoutput "[Info]�V����ALLOWED_HOSTS��ǋL���܂��B"
msgoutput "[Info]ALLOWED_HOSTS = ["\'"*"\'",]" >> /home/ec2-user/docker/code/app/website/settings.py
if [ $? -eq 0 ]; then
    msgoutput "[Success]�ǋL�ɐ������܂����B"
else
    msgoutput "[Error]�ǋL�Ɏ��s���܂����B"
    exit
fi
msgoutput "[Info]�R���e�i[webapp]��uwsgi�T�[�r�X���ċN�����܂��B"
docker exec -it webapp supervisorctl restart app-uwsgi
if [ $? -eq 0 ]; then
    msgoutput "[Success]�ċN�����������܂����B"
    msgoutput "[Info]�u���E�U����T�[�o�ɐڑ����āADjango�̃��P�b�g�����ł��邱�Ƃ��m�F���Ă��������B"
else
    msgoutput "[Error]�ċN�������s���܂����B"
    exit
fi

echo
msgoutput "[Info]���C���\�z�X�N���v�g���I�����܂��B" >> ./result.txt
