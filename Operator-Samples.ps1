# Type Conversion Example
1000 / 3 -as [int] # 333

# Type Test Examples
123.45 -is [int] # False
"SERVER-R2" -is [string] # True
$True -is [bool] # True
(Get-Date) -is [datetime] # True

# String replacement
"192.168.34.12" -replace "34","15" # 192.168.15.12