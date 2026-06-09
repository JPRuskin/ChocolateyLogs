function Get-ChocolateyCall {
    <#
        .Synopsis
            Shows all calls to Chocolatey in a given log file.

        .Description
            This function returns all parsed processes from the specified log file,
            showing the process id, start time, and command entered where possible
            (commands with sensitive parameters will be redacted).

        .Example
            Get-ChocolateyCall

            # Shows the calls in your current chocolatey log.

        .Example
            Get-ChocolateyCall ~\Downloads\chocolatey(13).log

            # Shows the calls in a provided chocolatey log.

        .Example
            (Get-ChocolateyCall).Where{$_.Command.StartsWith('choco install') -and $_.Result -ne 0}.Output

            # Displays the logs for installs that did not complete/succeed.

        .Example
            (Get-ChocolateyCall).Where{$_.Command.StartsWith('choco install') -and $_.Result -ne 0}[0].GetConfiguration()

            # Shows the configuration at the time of a failing install.

        .Example
            Get-ChocolateyCall -Last 3

            # Shows the last 3 calls made to Chocolatey.
    #>
    [OutputType([ChocolateyCall[]])]
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        # The path of the log(s) to parse.
        [Parameter(ValueFromPipeline)]
        [ArgumentCompleter({(Get-ChildItem $env:ChocolateyInstall\logs\ -Filter *.log).FullName})]
        [string[]]$Path = (Join-Path $env:ChocolateyInstall "logs\chocolatey.log"),

        # If provided, outputs the last X calls.
        [uint16]$Last
    )
    begin {
        $SelectLast = @{}
        if ($Last) {$SelectLast.Last = $Last}
    }
    process {
        Resolve-Path $Path | Get-ChocolateyLog | Group-Object ProcessID | ForEach-Object {
            [ChocolateyCall]@{
                StartTime = $_.Group[0].Timestamp
                ProcessID = $_.Name
                Command   = $_.Group.Message.Where({$_ -like "Command line*"}, 1) -replace "^Command line: (""$([regex]::Escape($env:ChocolateyInstall)))?\\(choco)(\.exe"")?",'$2'
                Output    = $_.Group
                Result    = if ($_.Group.Message[-1] -match "^Exiting with \d+$") {$_.Group.Message[-1] -replace "^Exiting with "} else {"E"}
            }
        } | Sort-Object StartTime | Select-Object @SelectLast
    }
}