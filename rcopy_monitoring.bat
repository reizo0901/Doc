@echo off

@tasklist /v | findstr /i run_robocopy_batch
if %errorlevel%==0 (
    echo %date% %time% "rcopy_exec���쒆" >>  %~dp0tasklog.log
    exit /b 0
) else (
    echo %date% %time% "rcopy_exec��~��" >>  %~dp0tasklog.log
)
if not exist %~dp0stoperr.txt (
    rem �G���[�C�x���g���s
    eventcreate /T ERROR /L application /ID 123 /D "robocopy����~���Ă��܂��B�{�ݕ��f�[�^�]���T�[�o���m�F���Ă��������B"
    echo %date% %time% �G���[���ēx�o�͂�����ɂ́A���̃t�@�C�����폜���Ă��������B >> %~dp0stoperr.txt
)
exit /b 1 