rem �x�����ϐ��ݒ�
setlocal enabledelayedexpansion
title=run_robocopy_folder_batch
@echo off

rem �o�b�`�t�@�C�����萔�ݒ�

rem �R�s�[���t�@�C��
set copyinfo1=copytarget1.txt
set copyinfo2=copytarget2.txt

rem �R�s�[���T�[�o���
set origin_srv=�{�ݕ�NFS�T�[�o
set origin_ipa=192.168.2.174
set origin_pat=\\192.168.2.174\DATA2
set origin_drv=j:
set origin_usr=nfsikou
set origin_pas=nfsikou

rem �R�s�[��T�[�o���
set copyto_srv=�{�ݕ��݌vDB�T�[�o
set copyto_ipa=192.168.2.173
set copyto_pat=\\192.168.2.173\c$\sharedfiles2
set copyto_drv=k:
rem set copyto_use=cals.local\administrator
set copyto_usr=cals.local\administrator
set copyto_pas=p@ssw0rd2211

rem ROBOCOPY�p�����[�^
set robo_param=/E /XO /COPY:DT /MT:4 /R:0 /W:0 /NP
rem ROBOCOPY�p�����[�^ �t�H���_�̂ݍ쐬�p
set robo_paraf=/E /NOCOPY
rem ROBOCOPY�p�����[�^ �f�o�b�O�p
set robo_parad=/E /XO /COPY:DT /MT:4 /R:0 /W:0 /NP /L

rem �G���[�t���O������
set errflg=0

rem ���s���[�h(0:off 1:�t�H���_�̂݃R�s�[ 2:�f�o�b�O���[�h)
rem 0:�R�s�[���s���܂��B
rem 1:�t�H���_�݂̂��R�s�[���܂��B
rem 2:�f�o�b�O���[�h�̂��߁A�R�s�[����܂��񂪃��O���o�͂��܂��B

set runmode=1

if %runmode%==0 (
    set copytarget=%copyinfo1%
    cls
    echo �R�s�[���[�h�ŏ������s���܂����A��낵���ł����H
    echo �����𒆒f�������ꍇ�́A[Ctrl]+[c]���������Ē��f���Ă��������B
    echo .
    pause
)
if %runmode%==1 (
    set copytarget=%copyinfo2%
    cls
    echo �t�H���_�̂݃R�s�[���[�h�ŏ������s���܂����A��낵���ł����H
    echo �����𒆒f�������ꍇ�́A[Ctrl]+[c]���������Ē��f���Ă��������B
    echo .
    pause
)
if %runmode%==2 (
    set copytarget=%copyinfo1%
    cls
    echo �f�o�b�O���[�h�ŏ������s���܂����A��낵���ł����H
    echo �����𒆒f�������ꍇ�́A[Ctrl]+[c]���������Ē��f���Ă��������B
    echo .
    pause
)

rem ���O���t�\�L�pYYYYMMDDhhmm������쐬
set sdate=%date:~0,4%%date:~5,2%%date:~8,2%
rem �����\���̓��̋󔒂�0�ɒu������
set time2=%time: =0%
set stime=%time2:~0,2%%time2:~3,2%%time2:~6,2%
set timestamp=%sdate%%stime%

echo %date% %time% [INF]rcopy_exec_folder.bat �����J�n >> %~dp0log\robo_result_%timestamp%.log

rem �o�b�`2�d�N���֎~
if exist %~dp0runrobo_folder.txt (
    echo ���Ƀo�b�`�t�@�C�������s����Ă��܂��B
    echo ���݃R�s�[���̃o�b�`�ɉe�����ł邽�߁A�o�b�`�����𒆒f���܂��B
    echo �o�b�`�t�@�C�������삵�Ă��Ȃ����Ƃ��m�F������Arunrobo_folder.txt���폜���čĎ��s���Ă��������B
    echo %date% %time% [ERR]rcopy_exec_folder.bat �Q�d�N�� >> %~dp0log\robo_result_%timestamp%.log
    rem �|�[�Y
    pause
    rem �v���O�����ُ�I��
    exit /b 1
) else (
    echo �N�����Ă��܂���B
    echo %date% %time% [INF]runrobo_folder.txt�쐬 >> %~dp0log\robo_result_%timestamp%.log
    echo �O��N�������F%date% %time% > %~dp0runrobo_folder.txt
    echo ���̃t�@�C�������݂����rcopy_exec_folcer.bat�����s���邱�Ƃ͂ł��܂���B >> %~dp0runrobo_folder.txt
    echo rcopy_exec_folder.bat�������Ă��Ȃ����Ƃ��m�F���ăt�@�C�����폜���A�Ď��s���Ă��������B >> %~dp0runrobo_folder.txt
)

echo %copytarget%
rem ���݃`�F�b�N[%copytarget%]
if exist %~dp0%copytarget% (
    rem ���s���O�ɑ��݊m�F���ʂ������o��
    echo %date% %time% [INF]%copytarget% OK! >> %~dp0log\robo_result_%timestamp%.log
) else (
    rem �W���o�͂ɃG���[���b�Z�[�W��\��
    echo %date% %time% �u%~dp0%copytarget%�v�t�@�C�������݂��܂���B
    rem ���s���O�ɑ��݊m�F���ʂ������o��
    echo %date% %time% [ERR]%copytarget% NG! >> %~dp0log\robo_result_%timestamp%.log
    rem �|�[�Y
    pause
    rem runrobo.txt �폜
    del %~dp0runrobo.txt
    echo %date% %time% [INF]runrobo.txt�폜 >> %~dp0log\robo_result_%timestamp%.log
    rem �v���O�����ُ�I��
    exit /b 1
)

rem �Ď��^�X�N�L����
schtasks /tn rcopy_monitoring_folder /change /enable
rem �Ď��^�X�N���s
schtasks /tn rcopy_monitoring_folder /run

rem �l�b�g���[�N�h���C�u�ڑ��m�F
rem �R�s�[���l�b�g���[�N�h���C�u�m�F
if exist %origin_drv% (
    echo %date% %time% [INF]%origin_srv%�p�l�b�g���[�N�h���C�u�L�� >> %~dp0log\robo_result_%timestamp%.log
) else (
    echo %date% %time% [INF]%origin_srv%�p�l�b�g���[�N�h���C�u�����݂��Ȃ����ߍ쐬���܂��B >> %~dp0log\robo_result_%timestamp%.log
    net use %origin_drv% %origin_pat% %origin_pas% /user:%origin_usr% /yes
    if %ERRORLEVEL% == 0 (
        echo %date% %time% [INF]%origin_srv%�p�l�b�g���[�N�h���C�u���쐬���܂����B >> %~dp0log\robo_result_%timestamp%.log
    ) else (
        echo %date% %time% [ERR]%origin_srv%�p�l�b�g���[�N�h���C�u�̍쐬�Ɏ��s���܂����B >> %~dp0log\robo_result_%timestamp%.log
    )
)
rem �R�s�[��l�b�g���[�N�h���C�u�m�F
if exist %copyto_drv% (
    echo %date% %time% [INF]%copyto_srv%�p�l�b�g���[�N�h���C�u�L�� >> %~dp0log\robo_result_%timestamp%.log
) else (
    echo %date% %time% [INF]%copyto_srv%�p�l�b�g���[�N�h���C�u�����݂��Ȃ����ߍ쐬���܂��B >> %~dp0log\robo_result_%timestamp%.log
    net use  %copyto_drv% %copyto_pat% %copyto_pas% /user:%copyto_usr% /yes
    if %ERRORLEVEL% == 0 (
        echo %date% %time% [INF]%copyto_srv%�p�l�b�g���[�N�h���C�u���쐬���܂����B >> %~dp0log\robo_result_%timestamp%.log
    ) else (
        echo %date% %time% [ERR]%copyto_srv%�p�l�b�g���[�N�h���C�u�̍쐬�Ɏ��s���܂����B >> %~dp0log\robo_result_%timestamp%.log
    )
)

rem pause
rem echo %date% %time% [INF]runrobo.txt�폜 >> %~dp0log\robo_result_%timestamp%.log
rem del %~dp0runrobo.txt
rem exit

rem ��JPiT PC�ŃC�x���g���s�R�}���h�͎g���܂���B
eventcreate /T INFORMATION /L application /ID 122 /D "rcopy_exec_folder.bat���J�n���܂����B"

rem copytarget.txt�t�@�C�������ǂݍ���
for /f "tokens=1,2,3 delims=," %%a in (%~dp0%copytarget%) do (
    echo %%a
    echo %%b
    echo %%c
    echo -------

    rem copytarget.txt����̏ꍇ�͏I��
    rem �R�s�[���f�B���N�g�����݊m�F
    if exist %%b (
        rem ���s���O�ɑ��݊m�F���ʂ������o��
        echo ���s���O�ɑ��݊m�F���ʂ������o�� [INF]�R�s�[��[%%a][%%b] ���݂��� >> %~dp0log\robo_result_%timestamp%.log
    ) else (
        rem �C�x���g���O�ɃG���[���o��
        rem ��JPiT PC�ŃC�x���g���s�R�}���h�͎g���܂���B
        eventcreate /T ERROR /L application /ID 123 /D "[%%a]��robocopy���s�Ɏ��s���܂����B�R�s�[��[%%b]�����݂��܂���B"
        rem ���s���O�ɑ��݊m�F���ʂ������o��
        echo %date% %time% [ERR]�R�s�[��[%%a][%%b] ���݂��Ȃ����߃X�L�b�v���܂��B >> %~dp0log\robo_result_%timestamp%.log
        set errflg=1
    )
    rem �R�s�[��t�H���_���݊m�F
    if exist %%c (
        rem ���s���O�ɑ��݊m�F���ʂ������o��
        echo %date% %time% [INF]�R�s�[��[%%a][%%c] ���݂��� >> %~dp0log\robo_result_%timestamp%.log
    ) else (
        rem �C�x���g���O�ɃG���[���o��
        rem ��JPiT PC�ŃC�x���g���s�R�}���h�͎g���܂���B
        eventcreate /T ERROR /L application /ID 123 /D "[%%a]��robocopy���s�Ɏ��s���܂����B�R�s�[��[%%c]�����݂��܂���B"
        rem ���s���O�ɑ��݊m�F���ʂ������o��
        echo %date% %time% [ERR]�R�s�[��[%%a][%%c] ���݂��Ȃ����߃X�L�b�v���܂��B >> %~dp0log\robo_result_%timestamp%.log
        set errflg=1
    )
    rem �G���[���Ȃ����robocopy�J�n
    if !errflg!==0 (
        rem ���s���O��robocopy�J�n�������o��
        echo %date% %time% [INF]robocopy_folder�J�n[%%a] >> %~dp0log\robo_result_%timestamp%.log
        if %runmode%==0 (
            echo robocopy %robo_param% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log >> %~dp0log\robo_result_%timestamp%.log
            robocopy %robo_param% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log
        )
        if %runmode%==1 (
        echo robocopy %robo_paraf% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log >> %~dp0log\robo_result_%timestamp%.log
            robocopy %robo_paraf% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log
        )
        if %runmode%==2 (
        echo robocopy %robo_parad% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log >> %~dp0log\robo_result_%timestamp%.log
            robocopy %robo_parad% %%b %%c /LOG:%~dp0log\robo_%%a_%timestamp%.log
        )
        if !errorlevel! lss 7 (
            echo OK %%a %%b
            rem ���s���O�ɐ���I���������o��
            echo %date% %time% [INF]robocopy_folder����I��[%%a] >> %~dp0log\robo_result_%timestamp%.log
            rem OK���X�g�ɏ����o��
            echo %%a,%%b,%%c >> %~dp0copy_ok_folder_%timestamp%.txt
        ) else (
            rem �C�x���g���O�ɃG���[���o��
            rem ��JPiT PC�ŃC�x���g���s�R�}���h�͎g���܂���B
            eventcreate /T ERROR /L application /ID 123 /D "[%%a]��robocopy���s�Ɏ��s���܂����Brobocopy�ŃG���[���������܂����B"
            rem ���s���O�Ɉُ�I���������o��
            echo %date% %time% [ERR]robocopy�ُ�I��[%%a] >> %~dp0log\robo_result_%timestamp%.log
            rem NG���X�g�ɏ����o��
            echo %%a,%%b,%%c >> %~dp0copy_ng_folder_%timestamp%.txt
        )
    ) else (
        echo NG %%a %%b
        echo %%a,%%b,%%c >> %~dp0copy_ng_folder_%timestamp%.txt
        rem �G���[�t���O������
        set errflg=0
    )
    rem �E�G�C�g
    ping 127.0.0.1 -n 1 > nul
)
pause
del %~dp0runrobo_folder.txt
echo %date% %time% [INF]runrobo_folder.txt�폜 >> %~dp0log\robo_result_%timestamp%.log
rem �v���O��������I��
echo %date% %time% [INF]rcopy_exec_folder.bat ����I�� >> %~dp0log\robo_result_%timestamp%.log
rem ��JPiT PC�ŃC�x���g���s�R�}���h�͎g���܂���B
eventcreate /T INFORMATION /L application /ID 124 /D "rcopy_exec_folder.bat������I�����܂����B"
rem �Ď��^�X�N������
schtasks /tn rcopy_monitoring_folder /change /disable

rem �x�����ϐ��ݒ����
endlocal
rem ����I��
exit /b 0