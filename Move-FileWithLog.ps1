<#
.SYNOPSIS
Move-FileWithLog - Grabs the specified number of files from a folder and moves them to another folder and creates a log.
.DESCRIPTION
Grabs the specified number of files from a folder and moves them to another folder and creates a log.
.PARAMETER sourcePath
The source folder for the move operation.
.PARAMETER destination
The destination folder to place the files.
.PARAMETER fileMask
The file mask to filter files from source when performing move.
.PARAMETER logPath
The path to write the move logs.
.PARAMETER fileCount
The maximum number of files to move.
.EXAMPLE
.\Move-FileWithLog -sourcePath "c:\files" -destination "c:\files\bucket_1" -logPath "c:\MoveLog" -FileCount 10 -Verbose
Moves up to 10 files (if they exist) from c:\files to c:\files\bucket_1 and writes a log to c:\MoveLog.
#>
[CmdletBinding()]
Param (
    [string] $sourcePath = "C:\Files",
    [string] $destination = "C:\Files\bucket_1",
    [string] $fileMask = "*",
    [string] $logPath = "C:\MoveLog",
    [int] $fileCount = 10
)

$files = gci -Filter $fileMask -Path $sourcePath -Attributes !Directory | Select-Object -First $fileCount

$numberOfFiles = ($Files | Measure-Object).Count
if ($numberOfFiles -gt 0) 
{
    Write-Verbose "Moving files."

    $Date = Get-Date -Format "yyyy-MM-ddTHH.mm.ss.fff";
    $Name = "Move_" + $Date + "z.log"

    if (-not (Test-Path $logPath))
    {
        mkdir $MoveLogDir
        Write-Host "Directory created: $MoveLogDir"
    }

    $logFilePath = Join-Path -Path $logPath -childPath $Name

    if (-not (Test-Path $destination))
    {
        mkdir $destination
        Write-Host "Directory created $destination"
    }

    $Files | Move-Item -Destination $destination -Verbose *> $logFilePath
}
else 
{
    Write-Verbose "No files moved."
}