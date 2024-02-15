# �e�X�g�t�@�C���쐬�X�N���v�g

# �g����
# 
# tab��؂�̓ǂݍ��ݗp�t�@�C���umakefiles.csv�v���쐬���܂��B
# 1�s�ڂɍ��ڂ��쐬���܂��B
# path<tab>filename<tab>size<tab>maketime<tab>updatetime<tab>accesstime
# 2�s�ڂ���A�쐬�ɕK�v�ȏ�����͂��܂��B

# path:�t�@�C�����쐬����p�X��������\��t���Ȃ����ƁB
# filename:�쐬����t�@�C���̖���
# size:�쐬����t�@�C���̃T�C�Y(Byte)
# maketime:�쐬����
# updatetime:�X�V����
# accesstime:�A�N�Z�X����

# ���l�`�F�b�N�֐�
function IsNumeric([string]$check_date)
# ������{���x���������_���^�ɕϊ����A���������ꍇ�́uTrue�v�����s�����ꍇ�́uFalse�v��Ԃ��B
{
    try
    {
        [double]::Parse($check_date)
        $True
    }
    catch
    {
        $False
    }
}



# �����`�F�b�N�֐�
# ��������t�^�ɕϊ����A���������ꍇ�́uTrue�v�����s�����ꍇ�́uFalse�v��Ԃ��B
function IsDate([string]$check_date)
{
    try
    {
        [Datetime]::Parse($check_date)
        $True
    }
    catch
    {
        $False
    }
}

# ���s�X�N���v�g�̃p�X���擾
$Folder_Pass = Get-Location
# �]�v�ȕ�������폜
$Folder_Pass = $Folder_Pass -replace "Path`n---- "
# �X�N���v�g�̃p�X���i�[
Set-Location $Folder_Pass
# log�t�@�C���̒�`
$log_time = Get-Date -Format "yyyyMMddHHmmss"
$log_file = $Folder_Pass+"\makefiles_result_"+$log_time+".log"
# csv�t�@�C���̒�`
$csv_file = $Folder_Pass+"\makefiles.csv"
# csv�t�@�C���̓ǂݍ���
$csv_ary = Import-Csv $csv_file -Delimiter "`t" -Encoding Default


# log�t�@�C��������
$omsg = "[�J�n����"+[datetime]::Now+"]"
echo $omsg > $log_file


# �ϐ�������
$skip = 0
$mdir = 0
$cnt = 0
$omsg = ""

# �t�@�C������1�s���t�@�C���쐬�p���[���[�^���擾
foreach ($csv_line in $csv_ary){
    $cnt += 1
    $ocnt = ("00000" + $cnt).substring(("00000" + $cnt).length - 5)
    #write-host $ocnt:$csv_line[0].path $csv_line[0].filename $csv_line[0].size $csv_line[0].maketime $csv_line[0].updatetime $csv_line[0].accesstime

    # �t�@�C���T�C�Y�̐��l�`�F�b�N
    if ($skip -eq 0)
    {
        if (-not(IsNumeric $csv_line[0].size))
        {
            $omsg = ""+$ocnt+":[ERR]�t�@�C���T�C�Y�ɖ�肪����܂��B"
            $skip = 1
        }
    }

    # �h���C�u���݃`�F�b�N
    if ($skip -eq 0)
    {
        $temp_drv = Split-Path -Qualifier $csv_line[0].path
        if (-not(Test-Path $temp_drv))
        {
            $omsg = ""+$ocnt+":[ERR]�w�肳�ꂽ�p�X�̃h���C�u�͑��݂��܂���B"
            $skip = 1
        }
    }
    # �f�B�X�N�̋󂫗e�ʃ`�F�b�N���A�󂫗e�ʂ�30%�ȉ��̏ꍇ�͏������Ȃ��B
    # �������x���̂ŁA��x�̗e�ʎ擾�ȍ~�́A�v�Z���݂̂ŏ�������Α����Ȃ肻��...
    #if ($skip -eq 0)
    if (1 -eq 0)
    {
        $drive_letter = "c"
        # �h���C�u�����擾����.
        $drv = Get-PSDrive $drive_letter
        # �h���C�u�̋󂫗e�ʂƎg�p�ʂ����Z���đ��e�ʂ�m��.
        $total = ( $drv.Free + $drv.Used )
        # �쐬��̃h���C�u�̎g�p�ʂ����Z
        $temp_size = $drv.Used + $csv_line[0].size
        # �g�p�����v�Z����.
        $rate =  $temp_size  / $total
        # �󂫗e�ʂ�30%�ȉ��̏ꍇ
        if ($rate -le 0.3 -or $rate -gt 1.0)
        {
            $omsg = ""+$ocnt+":[ERR]�쐬��̃h���C�u�̋󂫗e�ʂ�30%��؂��Ă��܂��B"
            $skip = 1
        }
    }
    
    # �p�X�쐬�`�F�b�N
    if ($skip -eq 0)
    {
        if (Test-Path $csv_line[0].path)
        {
            $mdir = 0
        }
        else
        {
            $mdir = 1
        }
    }
    # �t�@�C�����݃`�F�b�N
    # write-host $skip
    if ($skip -eq 0)
    {
        $temp_path = Join-Path $csv_line[0].path $csv_line[0].filename
        if (Test-Path $temp_path)
        {
            $skip = 1
            $omsg = ""+$ocnt+":[WAR]���łɃt�@�C�������݂��Ă��܂��B"
        }
    }
    
    # �쐬�����`�F�b�N
    if ($skip -eq 0)
    {
        if (IsDate $csv_line[0].maketime = $True)
        {
            # ���t�^�ɕϊ�
            $maketime = [Datetime]::Parse($csv_line[0].maketime)
        }
        else
        {
            $omsg = ""+$ocnt+":[ERR]�̍쐬�����̋L�q�Ɍ�肪����܂��B"
            $skip = 1
        }
    }
    # �X�V�����`�F�b�N
    if ($skip -eq 0)
    {
        # �ǂݍ��񂾍X�V��������̏ꍇ
        if (($csv_line[0].updatetime).length -eq 0)
        {
            # �쐬�������X�V������
            $updatetime = $maketime
        }
        else
        {
            # �X�V�����̃G���[���`�F�b�N
            if (IsDate $csv_line[0].updatetime = $False)
            {
                # ���t�^�ɕϊ�
                $updatetime = [Datetime]::Parse($csv_line[0].updatetime)
            }
            else
           {
               $omsg = ""+$ocnt+":[ERR]�̍X�V�����̋L�q�Ɍ�肪����܂��B"
               $skip = 1
           }
        }
    }
    # �A�N�Z�X�����`�F�b�N
    if ($skip -eq 0)
    {
        # �ǂݍ��񂾍X�V��������̏ꍇ
        if (($csv_line[0].accesstime.length) -eq 0)
        {
            # �쐬�������X�V������
            $accesstime = $maketime
        }
        else
        {
            # �A�N�Z�X�����̃G���[���`�F�b�N
            if (IsDate $csv_line[0].accesstime = $False)
            {
                # ���t�^�ɕϊ�
                $accesstime = [Datetime]::Parse($csv_line[0].accesstime)
            }
            else
           {
               $omsg = ""+$ocnt+":[ERR]�A�N�Z�X�����̋L�q�Ɍ�肪����܂��B"
               $skip = 1
           }
        }
    }
    # ��肪�Ȃ���΃t�@�C�����쐬
    if ($skip -eq 0)
    {
        # �t�H���_���쐬
        # �w��̃t�H���_�܂ł̒��ԃt�H���_�̓������ύX�o����ƍō��ł���...
        if ($mdir -eq 1)
        {
            # ���݂��Ȃ������K�w�̃t�H���_���쐬���Ȃ���^�C���X�^���v��ύX����B
            for ($sel = 1;$sel -le ($csv_line[0].path).length;$sel++)
            {
                if ((($csv_line[0].path).substring($sel - 1,1) -eq "\") -or ($sel -ge ($csv_line[0].path).length))
                {
                    # �t�H���_�̋�؂肪�����o�����̂ŁA���݃`�F�b�N�Ō�����Ȃ���΃t�H���_�쐬
                    if (test-path ($csv_line[0].path).substring(0,$sel))
                    {
                    }
                    else
                    {
                        New-Item ($csv_line[0].path).substring(0,$sel) -ItemType Directory | out-null
                        Set-Itemproperty ($csv_line[0].path).substring(0,$sel) -name CreationTime -value $maketime
                        Set-Itemproperty ($csv_line[0].path).substring(0,$sel) -name LastWriteTime -value $updatetime
                        Set-Itemproperty ($csv_line[0].path).substring(0,$sel) -name LastAccessTime -value $accesstime
                        $omsg = $omsg+$ocnt+":[INF]["+($csv_line[0].path).substring(0,$sel)+"]�t�H���_���쐬���܂����B`n"
                    }
                }
            }
        }
        # �t�@�C�����쐬
        fsutil file createnew $temp_path $csv_line[0].size | out-null
        Set-Itemproperty $temp_path -name CreationTime -value $maketime
        Set-Itemproperty $temp_path -name LastWriteTime -value $updatetime
        Set-Itemproperty $temp_path -name LastAccessTime -value $accesstime
        $omsg = $omsg+""+$ocnt+":[INF]["+$temp_path+"]�t�@�C�����쐬���܂����B"
    }
    # ���b�Z�[�W��\��
    write-host $omsg
    echo $omsg >> $log_file
    write-host ""
    # ���[�v���ϐ�������
    $omsg = ""
    $temp_drv = ""
    $skip = 0
}

$omsg = "[�I������"+[datetime]::Now+"]"
echo $omsg >> $log_file



