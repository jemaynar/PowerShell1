$Check = gci -Path "c:\Files" -Recurse

if ($Check.count -lt 1000) 
{
    $SourcePath = "C:\Files"
    $SourcePath
    $Date = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fff";
    $Name = "Move_" + $Date + "z.log"
    $Name
    $MoveLogDir = "C:\MoveLog"
    if (-not (Test-Path $MoveLogDir))
    {
        Write-Host "Directory Created"
        mkdir $MoveLogDir
    }
    $MoveLogDir
    $LogFilePath = Join-Path -Path $MoveLogDir -childPath $Name
    $LogFilePath
    $Destination = "C:\Destination"
    $Destination
    if (-not (Test-Path $Destination))
    {
        Write-Host "Directory Created"
        mkdir $Destination
    }
    $Files = gci -filter *.txt -Path $SourcePath -Recurse
    # $files
    $Count = 1000
    $Files | Select-ObJect -First $Count |
        Move-Item -Destination $Destination # -Verbose *>&1 | 
        # Out-File -FilePath $LogFilePath
}