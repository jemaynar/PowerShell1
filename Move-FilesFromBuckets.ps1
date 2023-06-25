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
Moves 1 file from the sub-folders of c:\files where sub-folder names are digits and file names match file mask *.txt if the source folder contains fewer than 100,000 files, then removes any empty sub-folders that matched the regex pattern.
.EXAMPLE
.\Move-FilesFromBuckets -numberOfFilesToMove 1 -bucketFolderRegex '^[\d]*$' -sourcePath 'C:\files' -destinationPath 'c:\files' -fileMask '*.txt' -threshold 100000 -removeEmptyFolders $false -Verbose
Moves 1 file from the sub-folders of c:\files where sub-folder names are digits and file names match file mask *.txt if the source folder contains fewer than 100,000 files, then does not remove any sub-folders even if they were empty.
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
    Write-Verbose 'Matching folders found.'

    $files = $folders | gci -Filter $fileMsk | Select-Object -First $numberOfFilesToMove

    $count = ($files | Measure-Object).Count
    if ($count -lt $threshold)
    {
        Write-Verbose "Move triggered -> count: $count < threshold: $threshold"

        $files | Select-Object $_.Name | Write-Verbose

        $files | Move-Item -Destination $destinationPath
    }
    else 
    {
        Write-Verbose "Move not triggered -> count: $count > threshold: $threshold"
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
    Write-Verbose 'No matching folders found.'
}