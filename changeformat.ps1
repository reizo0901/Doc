$targetfile="C:\Users\hlemo\OneDrive\デスクトップ\20221219_allinfo.txt"
$outputdir="C:\Users\hlemo\OneDrive\デスクトップ\"
$outputfile="C:\Users\hlemo\OneDrive\デスクトップ\chg_allinfo.txt"
$i=1
foreach ($l in Get-Content $targetfile) {
    if ($l){
        if ($l.Substring(0,1) -eq "/" -and $l.substring($l.length - 1,1) -eq ":"){
            $dirname = $l.substring(0 , $l.length -1) + "/"
            #write-host $i : $dirname
        }
        else
        {
            if ($l.substring($l.length - 1,1) -ne "/"){
                write-output $dirname$l | out-file $outputfile -append -encoding utf8
            }
        }
    } 
    $i++
}

