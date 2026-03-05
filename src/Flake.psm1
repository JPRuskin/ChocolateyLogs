# This should never be shipped, and is only for development.
Get-ChildItem $PSScriptRoot -Recurse -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}