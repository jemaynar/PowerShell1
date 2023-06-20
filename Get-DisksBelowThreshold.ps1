<#
.Synopsis
Get drives below free space threshold
.Description
This command will get all local drives that have less than the specified percentage of free space available.
.Parameter ComputerNames
The names of the computers to check. The default is localhost.
.Parameter MinimumPercentFree
The minimum percent free diskspace. This is the threshhold. The default value is 10. Enter a number between 1 and 100.
.Example
Get-DisksBelowThreshold -minimum 20
Find all disks on the localhost with less than 20% free space.
.Example
.\Get-DisksBelowThreshold -comp="localhost","DESKTOP1" -minimum 99
Find all disks on localhost & DESKTOP1 with less than 99% free space.
.Example
.\Get-DisksBelowThreshold
Find all disks on localhost with less than 10% free space.
#>
Param (
    [String[]]$computerNames=@("localhost"),
    [int]$MinimumPercentFree=10
)

#Convert minimum percent free
$minpercent = $MinimumPercentFree / 100

function selectData {
    Param([string]$computerName);

    Get-WmiObject -class Win32_logicalDisk -ComputerName $computerName -filter "driveType=3" | 
        Where { $_.FreeSpace / $_.Size –lt $MinimumPercentFree } |
        Select –Property `
            @{ label = 'Computer Name'; expression = { $computerName } },
            DeviceId,
            @{ label = 'Size (GB)'; expression = { $_.Size / 1GB -as [int] } },
            @{ label = 'FreeSpace (GB)'; expression = { $_.FreeSpace / 1GB -as [int] } },
            @{ label = '% Free'; expression = { $_.FreeSpace / $_.Size * 100 -as [int] } }
}

$computerNames | Select-Object { selectData($_) } | Format-Table