<#
.SYNOPSIS
Move-FilesToBuckets
.DESCRIPTION
Move-FilesToBuckets evenly distributes files into groups of subfolders under the destination.
.PARAMETER numberOfFilesToMove
Will move this number of files if they are available to be moved.
.PARAMETER bucketCount
Number of sub-folders to place the files into.
.PARAMETER bucketFolderPrefix
Files will be placed into sub-folders named bucketFolderPrefix_{bucketIndex}
.PARAMETER sourcePath
The location to scan and move files from.
.PARAMETER destinationPath
The location to scan and move files to sub-folders in (can be the same as the sourcePath).
.PARAMETER fileMask
Filter off files using this file mask.
.PARAMETER threshold
The number of files that must be present to trigger a move.
.EXAMPLE
Move-FilesToBuckets -numberOfFilesToMove 1 -bucketCount 10 -bucketFolderPrefix 'bucket' -sourcePath 'C:\files' -destinationPath 'c:\files' -fileMask '*.txt' -threshold 20
#>
[cmdletbinding()]
Param (
    [int] $numberOfFilesToMove,
    [int] $bucketCount,
    [string] $bucketFolderPrefix,
    [string] $sourcePath,
    [string] $destinationPath,
    [string] $fileMask,
    [int] $threshold
)

[int] $count = (Get-ChildItem -File -Path $sourcePath | Measure-Object).Count

Write-Verbose "File Count: $count"

if ($count -gt $threshold) 
{
    Write-Verbose "Move Triggered -> Count: $count > Threshold: $threshold"

    $files = (Get-ChildItem -File -Path $sourcePath -Filter $fileMask | 
        Select-Object -First $numberOfFilesToMove).FullName

    $i = 0
    $buckets = $files | % {$_ | Add-Member NoteProperty "B" ($i++ % $bucketCount) -PassThru} | group B
    $buckets.Name | % {
        $count = ($buckets[$_].Count)
        Write-Host "Group: $_ Files in group: $count"
        $bucketsOutputFolder = "$destinationPath\$bucketFolderPrefix_$_"
        if (-not (Test-Path $bucketsOutputFolder)) 
        {
            mkdir $bucketsOutputFolder
        }
        Move-Item $buckets[$_].Group $bucketsOutputFolder
    }

    Write-Host (Get-ChildItem -File -Path $sourcePath | Measure-Object).Count " files remaining in source."
}
else 
{
    Write-Verbose "Move Not Triggered -> Count: $count < Threshold: $threshold"
}