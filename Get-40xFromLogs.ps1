get-childitem -filter *.log -recurse |
select-string -pattern "\s40[0-9]\s" |
format-table Filename,LineNumber,Line -wrap