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
.\Move-FilesFromBuckets -numberOfFilesToMove 1 -bucketFolderRegex '^[\d]*$' -sourcePath 'C:\files' -destinationPath 'c:\files' -fileMask '*.txt' -threshold 100000 -removeEmptyFolders $True  -Verbose
Moves 1 file from the sub-folders of c:\files where sub-folder names are digits and file names match file mask *.txt if the source folder contains fewer than 100,000 files, then removes any empty sub-folders that matched the regex pattern.
.EXAMPLE
.\Move-FilesFromBuckets -numberOfFilesToMove 1 -bucketFolderRegex '^[\d]*$' -sourcePath 'C:\files' -destinationPath 'c:\files' -fileMask '*.txt' -threshold 100000 -Verbose
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
    [bool] $removeEmptyFolders = $False
)

$formattedThreshold = "{0:N0}" -f $threshold

$folders = gci -Path $sourcePath -Directory | Where-Object { $_.Name -match $bucketFolderRegex }
$matchingFolderCount = ($folders | Measure-Object).Count

if ($matchingFolderCount -gt 0) 
{
    Write-Verbose 'Matching folders found.'

    $triggerFileCount = (gci -Path $destinationPath $fileMask | Measure-Object).Count
    $formattedTriggerFileCount = "{0:N0}" -f $triggerFileCount
    if ($triggerFileCount -lt $threshold) 
    {
        Write-Verbose "Move triggered -> destination file count: $formattedTriggerFileCount < threshold: $formattedThreshold."

        $files = $folders | gci -File -Filter $fileMask
        $count = ($files | Measure-Object).Count
        $formattedCount = "{0:N0}" -f $count
        if ($count -gt 0)
        {
            $formattedNumberOfFileToMove = "{0:N0}" -f $numberOfFilesToMove
            Write-Verbose "Found $formattedCount files available to move. Moving up to $formattedNumberOfFileToMove of them."

            $files = $files | Select-Object -First $numberOfFilesToMove
            $files | Select-Object $_.Name | Write-Verbose
            $files | Move-Item -Destination $destinationPath
        }
        else 
        {
            Write-Verbose "Move cancelled: $formattedCount files available to move."
        }
    }
    else 
    {
        Write-Verbose "Move not triggered -> destination count: $formattedTriggerFileCount > threshold: $formattedThreshold."
    }

    if ($removeEmptyFolders) 
    {
        $emptyFolders = $folders | Where-Object { (gci $_.FullName).count -eq 0 } | select -expandproperty FullName
        $emptyFolderCount = ($emptyFolders | Measure-Object).Count
        if ($emptyFolders -gt 0)
        {
            Write-Verbose "Attempting to remove empty folders."
            $formattedEmptyFolderCount = "{0:N0}" -f $emptyFolderCount
            Write-Verbose "Removing the following $formattedEmptyFolderCount empty folders:"
            $emptyFolders | Select-Object $_.DirectoryName | Write-Verbose
            $emptyFolders | % {
                Remove-Item -Path $_
            }
        }
    }
}
else 
{
    Write-Verbose 'No matching folders found.'
}