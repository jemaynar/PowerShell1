<#
.SYNOPSIS
Move-FilesFromBuckets
.DESCRIPTION
Move-FilesFromBuckets grabs a batch of files from sub-folders of a source directory and places them in target directory.
.PARAMETER numberOfFilesToMove
Will move this number of files if they are available to be moved.
.PARAMETER bucketFolderPrefix
Subfolders will be searched that match this pattern.
.PARAMETER sourcePath
The location to scan for subfolders to move files from.
.PARAMETER destinationPath
The location place the files.
.PARAMETER fileMask
Filter off files using this file mask.
.PARAMETER threshold
The fewer than this number of tiles are in the target directory trigger a move to the target directory.
.PARAMETER removeEmptyFolders
Removes empty folders after execution complete.
.EXAMPLE
.\Move-FilesFromBuckets -numberOfFilesToMove 1 -bucketFolderRegex '^[\d]*$' -sourcePath 'C:\files' -destinationPath 'c:\files' -fileMask '*.txt' -threshold 100000 -Verbose
#>
[cmdletbinding()]
Param (
    [int] $numberOfFilesToMove,
    [string] $bucketFolderRegex,
    [string] $sourcePath,
    [string] $destinationPath,
    [string] $fileMask,
    [int] $threshold,
    [bool] $removeEmptyFolders = $True
)

$folders = gci -Path c:\Files -Directory | Where-Object { $_.DirectoryName -match $bucketFolderRegex }
$matchingFolderCount = ($folders | Measure-Object).Count

if ($matchingFolderCount -gt 0) 
{
    Write-Verbose 'Matching Folders Found.'

    $files = $folders | gci -Filter $fileMsk | Select-Object -First $numberOfFilesToMove

    $count = ($files | Measure-Object).Count
    if ($count -lt $threshold)
    {
        Write-Verbose "Move Triggered -> Count: $count < Threshold: $threshold"

        $files | Select-Object $_.Name | Write-Verbose

        $files | Move-Item -Destination $destinationPath
    }
    else 
    {
        Write-Verbose "Move Not Triggered -> Count: $count > Threshold: $threshold"
    }

    $emptyFolders = $folders | Where-Object { (gci $_.FullName).count -eq 0 } | select -expandproperty FullName
    $emptyFolderCount = ($emptyFolders | Measure-Object).Count
    if ($removeEmptyFolders -AND $emptyFolders -gt 0)
    {
        Write-Verbose "Removing the following $emptyFolderCount folders:"
        $emptyFolders | Select-Object $_.DirectoryName | Write-Verbose
        $emptyFolders | % {
            Remove-Item -Path $_
        }
    }
}
else 
{
    Write-Verbose 'No Matching Folders Found.'
}