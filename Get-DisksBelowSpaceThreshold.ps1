<#
.Synopsis
Get drives below free space threshold
.Description
This command will get all local drives that have less than the specified percentage of free space available.
.Parameter ComputerNames
The names of the computer to check. The default is localhost.
.Parameter MinimumPercentFree
The minimum percent free diskspace. This is the threshhold. The default value is 10. Enter a number between 1 and 100.
.Example
Get-DisksBelowSpaceThreshold -minimum 20
Find all disks on the localhost with less than 20% free space.
.Example
.\Get-DisksBelowSpaceThreshold.ps1 -comp="localhost","DESKTOP1" -minimum 99
Find all local disks on localhost & DESKTOP1 with less than 99% free space.
.Example
.\Get-DisksBelowSpaceThreshold
Find all disks on localhost with less than 10% free space.
#>

Param (
    [String[]]$computerNames=@('localhost'),
    [int]$MinimumPercentFree=10
)

#Convert minimum percent free
$minpercent = $MinimumPercentFree / 100

$computerNames | Select-Object -Property @{
    name='Name';
    expression={
        Get-WmiObject -class Win32_logicalDisk -ComputerName $_ -filter "driveType=3" | 
        Where { $_.FreeSpace / $_.Size –lt $minpercent } |
        Select –Property `
            DeviceId,
            @{ label = 'FreeSpace (GB)'; expression = { $_.FreeSpace / 1GB -as [int] } },
            @{ label = 'Size (GB)'; expression = { $_.Size / 1GB -as [int] } },
            @{ label = '% Free'; expression = { $_.FreeSpace / $_.Size * 100 -as [int] } } } };