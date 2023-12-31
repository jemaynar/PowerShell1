﻿#Get-PhysicalAdapters.ps1
<#
.Synopsis
Get physical network adapters
.Description
Display all physical adapters from the Win32_NetworkAdapter class.
.Parameter Computername
The name of the computer to check.
.Example
c:\scripts\Get-PhysicalAdapters -computer SERVER01
#>
[cmdletbinding()]
Param (
[Parameter(Mandatory=$True,HelpMessage="Enter a computername to query")]

[alias('hostname')]
[string]$Computername
)

Write-Verbose "Getting physical network adapters from $computername"

Get-Wmiobject -class win32_networkadapter –computername $computername |
 where { $_.PhysicalAdapter } |
 select MACAddress,AdapterType,DeviceID,Name,Speed

Write-Verbose "Script finished."