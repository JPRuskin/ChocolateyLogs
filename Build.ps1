#requires -Modules ModuleBuilder
[CmdletBinding()]
param(
    $SemVer = $(if (Get-Command gitversion -ErrorAction SilentlyContinue) {
        gitversion /showvariable FullSemVer /nofetch
    } else {0.0.1}),

    [switch]$Passthru
)

Build-Module -SemVer $SemVer -Passthru:$Passthru