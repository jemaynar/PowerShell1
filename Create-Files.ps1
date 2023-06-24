<#
.SYNOPSIS
Create-Files
.DESCRIPTION
Creates the specified number of files in a path.
.PARAMETER path
Where to output the files.
.PARAMETER count
The number of files to create.
.EXAMPLE
.\Create-Files.ps1 -path 'C:\Files' -count 100 -Verbose
Creates 100 files in the directory C:\Files.
#>
[CmdletBinding()]
Param (
    [string] $path,
    [int] $count
)

if ($count -gt 0) 
{
    $fileName = "$(New-Guid).txt"
    $firstFileName = Join-Path $path -ChildPath "\$fileName"
    $firstFileName

    New-Item -Path $firstFileName -ItemType File
    
    if ($count -gt 1) 
    {
        Write-Verbose "Count: $count"

        1..$count | % {
            $outputFile = "$Path\$(New-Guid).txt"
            Copy-Item -Path $firstFileName -Destination $outputFile 
            Write-Verbose $outputFile
        }
    }
    
    Write-Verbose "Created $count files."
}
