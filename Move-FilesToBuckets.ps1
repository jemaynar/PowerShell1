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
.\Move-FilesToBuckets -numberOfFilesToMove 6 -bucketCount 2 -bucketFolderPrefix 'bucket_' -sourcePath 'C:\files' -destinationPath 'c:\files' -fileMask '*.txt' -threshold 20 -Verbose
If threshold of 20 files exist in c:\files then 6 files will be distributed accross 2 sub-folders with prefix bucket_ into c:\Files, where all files that conform to the *.txt file mask will be moved, verbose flag will print out what script is doing.
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
$formattedCount = "{0:N0}" -f $count
$formattedThreshold = "{0:N0}" -f $threshold
$formattedNumberOfFilesToMove = "{0:N0}" -f $numberOfFilesToMove

Write-Verbose "File count: $formattedCount."

if ($count -gt $threshold) 
{
    Write-Verbose "Move triggered -> count: $formattedCount > threshold: $formattedThreshold."

    $files = (Get-ChildItem -File -Path $sourcePath -Filter $fileMask | 
        Select-Object -First $numberOfFilesToMove).FullName

    $i = 0
    $buckets = $files | % {$_ | Add-Member NoteProperty "B" ($i++ % $bucketCount) -PassThru} | group B
    $buckets.Name | % {
        $formattedBucketCount = "{0:N0}" -f ($buckets[$_].Count)
        Write-Verbose "Group: $_ Files in group: $formattedBucketCount."

        if (-not ([string]::IsNullOrWhiteSpace($bucketFolderPrefix))) { $bucketFolder = "$bucketFolderPrefix$_" }
        else { $bucketsFolder = $_ }

        $bucketsOutputFolder = Join-Path $destinationPath -ChildPath $bucketFolder

        if (-not (Test-Path $bucketsOutputFolder)) 
        {
            mkdir $bucketsOutputFolder
            Write-Host "Directory created: $bucketsOutputFolder."
        }
        Move-Item $buckets[$_].Group $bucketsOutputFolder
    }

    $formattedRemaining = "{0:N0}" -f ((Get-ChildItem -File -Path $sourcePath | Measure-Object).Count)
    Write-Verbose "$formattedRemaining files remaining in source."
}
else 
{
    Write-Verbose "Move not triggered -> count: $formattedCount < threshold: $formattedThreshold."
}