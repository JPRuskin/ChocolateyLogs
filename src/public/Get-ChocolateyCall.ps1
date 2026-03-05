function Get-ChocolateyCall {
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$Path = (Join-Path $env:ChocolateyInstall "logs\chocolatey.log"),

        [uint16]$Last
    )
    process {
        Resolve-Path $Path | Get-ChocolateyLog | Group-Object ProcessID | ForEach-Object {
            [ChocolateyCall]@{
                StartTime = $_.Group[0].Timestamp
                ProcessID = $_.Name
                Command   = $_.Group.Message.Where({$_ -like "Command line*"}, 1) -replace "^Command line: (""$([regex]::Escape($env:ChocolateyInstall)))?\\(choco)(\.exe"")?",'$2'
                Output    = $_.Group
                Result    = if ($_.Group.Message[-1] -match "^Exiting with \d+$") {$_.Group.Message[-1] -replace "^Exiting with "} else {"E"}
            }
        } | Sort-Object StartTime
    }
}