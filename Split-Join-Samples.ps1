#declare an array
$array = "one","two","three","four","five"
$array

#combine array to single string using join 
$array = $array -join "|"
$array

#inverse: split the string back into array
$array = $array -split "\|"
$array