<#
.Synopsis
Transform a collection to lowercase
.Description
Returns lowercase version of passed in array
.Parameter strings
The strings to be transformed
.Example
c:\Map-LowerCase.ps1 -strings "HELLO","heLlO","Hello"
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)]
    [string[]]$strings
)

Write-Verbose "Passed in strings were $strings"

$strings | Select-Object -Property @{name='Name';expression = {$_.ToLower()} } | Select-Object -ExpandProperty Name

Write-Verbose "Finished processing strings"