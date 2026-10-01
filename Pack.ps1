[CmdletBinding()]
param(
    $SemVer = $(
        if (Get-Command gitversion -EA 0) {
            gitversion /showvariable MajorMinorPatch
        } else {
            "0.0.1"
        }
    )
)

choco pack $PSScriptRoot\chocolatey\flake.nuspec --Version $SemVer --OutputDirectory $PSScriptRoot --limit-output | Write-Verbose

Get-Item "$PSScriptRoot\flake.powershell.$SemVer.nupkg"