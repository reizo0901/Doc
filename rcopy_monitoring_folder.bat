@echo off

@tasklist /v | findstr /i run_robocopy_folder_batch
if %errorlevel%==0 (
    echo %date% %time% "rcopy_exec_folder���쒆" >>  %~dp0tasklog_folder.log
    exit /b 0
) else (
    echo %date% %time% "rcopy_exec_folder��~��" >>  %~dp0tasklog_folder.log
)
if not exist %~dp0stoperr_folder.txt (
    rem �G���[�C�x���g���s
    eventcreate /T ERROR /L application /ID 123 /D "robocopy_folder����~���Ă��܂��B�{�ݕ��f�[�^�]���T�[�o���m�F���Ă��������B"
    echo %date% %time% �G���[���ēx�o�͂�����ɂ́A���̃t�@�C�����폜���Ă��������B >> %~dp0stoperr_folder.txt
)
exit /b 1 