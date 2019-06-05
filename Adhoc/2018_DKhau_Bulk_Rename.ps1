$Directory = "C:\Data\db\"
$OrigStr = ""
$NewStr = ""

Get-ChildItem $Directory -Recurse | 
Foreach-Object { Rename-Item $_.FullName ($_.FullName -Replace "$OrigStr","$NewStr")}
