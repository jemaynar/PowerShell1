# -contains intended to be used with collections not strings.
'this' -contains '*his*' #False

# -like is for string wildcards
'this' -like '*his' #True

# -contains correct usage
$collection = 'abc','def','ghi'
$collection -contains 'abc' #True
$collection -contains 'pop-tarts' #False