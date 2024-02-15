@echo off

rem ################################################################################
rem �C�x���g���O�̃A�[�J�C�u�t�@�C�������L�f�B�X�N�ֈړ�
rem �ߋ��P�N�ȏ�O�̃C�x���g���O�̃A�[�J�C�u�t�@�C�������L�f�B�X�N����폜
rem ################################################################################

rem ################################################################################
rem ���ϐ�
rem ################################################################################

rem ���s���O�t�@�C���i�[�ꏊ(��Fc:\tool)
set logpath=c:\tool
rem ���s���O�t�@�C����(�擪)
set logfirst=evtxdel
rem ���s���O�t�@�C��������
set yyyyMMdd=%date:/=%
set hhmmss=%time::=%
set hhmmss=%hhmmss:~0,6%
set logfile=%logpath%\%logfirst%_%yyyyMMdd%_%hhmmss%.log

rem ���s���O�ێ�����[����](��F7)
set lperiod=7
rem net use�p�A�J�E���g
set nuser=jptransport\moveevtuser
rem net use�p�p�X���[�h
set npass=Passw0rd2402
rem pdn01 IP�A�h���X(��F192.168.2.171)
set pdn01ip=192.168.2.171
rem pdn02 IP�A�h���X(��F192.168.2.172)
set pdn02ip=192.168.2.172
rem �R�s�[��Windows�C�x���g���O�A�[�J�C�u�t�@�C���i�[�ꏊ(��Fc:\windows\system32\winevt\logs)
set localfd=c:\windows\system32\winevt\logs
rem �R�s�[��Windows�C�x���g���O�A�[�J�C�u�t�@�C���i�[�t�H���_��(��Fwinevt\logs)
set sharefd=winevt\logs
rem net use�p�h���C�u����(��Fz)
set mountdv=z
rem �R�s�[�拤�L�h���C�u����(��Fg)
set sharedv=g
rem �A�[�J�C�u���O�ێ�����[����](��F366)
set aperiod=366

rem ################################################################################
rem ���C������
rem ################################################################################

echo [%date% %time%][%computername%]�C�x���g���O�A�[�J�C�u�t�@�C���ړ��E�폜����[�������J�n���܂���]>>%logfile%

rem ################################################################################
rem ���s���O�폜����
rem ################################################################################

echo [%date% %time%][%computername%]���s���O�폜����[�J�n]>>%logfile%
forfiles /P %logpath% /D -%lperiod% /M %logfirst%_*.log /c "cmd /c del -f -q @path&&echo [�폜][����] @path>>%logfile%||echo [�폜][���s] @path>>%logfile%"
echo [%date% %time%][%computername%]���s�폜����[�I��]>>%logfile%

rem ################################################################################
rem Z�h���C�u�}�E���g����
rem ################################################################################

echo [%date% %time%][%computername%]�ړ��E�폜�Ώۃh���C�u�}�E���g����[�����J�n]>>%logfile%

rem ���T�[�o�ɋ��L�f�B�X�N���}�E���g����Ă��邩�m�F���A�R�s�[��T�[�o��I������
rem ���T�[�o�ɋ��L�f�B�X�N���}�E���g����Ă���
if not exist "%sharedv%:\" (
    rem ���T�[�o��pdn01
    if "%computername%"=="PDN01" (
        set trgsrv=%pdn02ip%
    ) else (
        set trgsrv=%pdn01ip%
    )
rem ���T�[�o�ɋ��L�f�B�X�N���}�E���g����Ă��Ȃ�
) else (
    rem ���T�[�o��pdn01
    if "%computername%"=="PDN01" (
        set trgsrv=%pdn01ip%
    ) else (
        set trgsrv=%pdn02ip%
    )
)

rem net use�p�ڑ�������
set trg_str=\\%trgsrv%\%sharedv%$\%sharefd%
echo [%date% %time%][%computername%]�ړ��E�폜�Ώۃh���C�u�}�E���g����[�A�[�J�C�u�t�@�C���ړ���T�[�o[%trgsrv%]]>>%logfile%

rem Z�h���C�u�����łɃ}�E���g����Ă���ꍇ�͍ă}�E���g����
if exist "%mountdv%:\" (
    echo [%date% %time%][%computername%]�ړ��E�폜�Ώۃh���C�u�}�E���g���������̃h���C�u�̃A���}�E���g>>%logfile%
    net use /d %mountdv%:>>%logfile%
    rem 
    ping 127.0.0.1 -n 2>>%logfile%
    echo [%date% %time%][%computername%]�ړ��E�폜�Ώۃh���C�u�}�E���g����[�ړ��E�폜�Ώۃh���C�u�̃}�E���g]>>%logfile%
    net use %mountdv%: %trg_str% /user:%nuser% %npass%>>%logfile%
    net use>>%logfile%
) else (
    echo [%date% %time%][%computername%]�ړ��E�폜�Ώۃh���C�u�}�E���g����[�ړ��E�폜�Ώۃh���C�u�̃}�E���g]>>%logfile%
    net use %mountdv%: %trg_str% /user:%nuser% %npass%>>%logfile%
    net use>>%logfile%
)

echo [%date% %time%][%computername%]�ړ��E�폜�Ώۃh���C�u�}�E���g����[�����I��]>>%logfile%

rem �ړ��E�폜�Ώۃh���C�u�̃}�E���g��Ԋm�F
if exist "%mountdv%:\" (
    echo [%date% %time%][%computername%]�A�[�J�C�u�t�@�C���ړ�����[�h���C�u�}�E���g][����]>>%logfile%
    rem �ړ��E�폜�Ώۃp�X�ݒ�
    set trgpath=%mountdv%:\%computername%
) else (
    echo [%date% %time%][%computername%]�A�[�J�C�u�t�@�C���ړ�����[�h���C�u�}�E���g][���s]>>%logfile%
    goto BADEND
)
echo %trgpath%>>%logfile%

rem ################################################################################
rem �A�[�J�C�u�t�@�C���폜����
rem ################################################################################

echo [%date% %time%][%computername%]�A�[�J�C�u�t�@�C���폜����[�J�n]>>%logfile%
forfiles /P %trgpath% /D -%aperiod% /M archive-*.evtx /C "cmd /c del -f -q @path&&echo [�폜][����]@file>>%logfile%||echo [�폜][����]@file>>%logfile%"
echo [%date% %time%][%computername%]�A�[�J�C�u�t�@�C���폜����[�I��]>>%logfile%

rem ################################################################################
rem �A�[�J�C�u�t�@�C���ړ�����
rem ################################################################################

echo [%date% %time%][%computername%]�A�[�J�C�u�t�@�C���ړ�����[�J�n]>>%logfile%
rem �Ώۂ̃t�H���_�̃A�[�J�C�u�t�@�C���݂̂�I�����A�������s��
dir /A-D /B %localfd%\archive-*.evtx | find /c /v "" | findstr /r "^0$">>%logfile% 
if "%errorlevel%"=="1" (
    forfiles /P %localfd% /M archive-*.evtx /C "cmd /c move /y @path %mountdv%:\%computername%\@file&&echo [�ړ�][����]@file>>%logfile%||echo [�ړ�][���s]@file>>%logfile%"
) else (
    echo �ړ��ΏۂƂȂ�A�[�J�C�u���O�����݂��܂���B
)

rem �}�E���g�����h���C�u������
net use /d %mountdv%:
net use>>%logfile%
echo [%date% %time%][%computername%]�A�[�J�C�u�t�@�C���ړ�����[�I��]>>%logfile%

goto BATEND

:BADEND
echo [%date% %time%][%computername%]�C�x���g���O�A�[�J�C�u�t�@�C���ړ��E�폜����[�ُ�I��]>>%logfile%
rem exit /b 1

:BATEND
echo [%date% %time%][%computername%]�C�x���g���O�A�[�J�C�u�t�@�C���ړ��E�폜����[�I��]>>%logfile%
rem exit /b 0
