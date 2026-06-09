function Show-ChocolateyLogTail {
    <#
        .Synopsis
            Streams the Chocolatey log, as it is written.

        .Description
            Monitors the Chocolatey log for changes, and outputs ChocolateyLog objects
            when it is written to.

        .Example
            Show-ChocolateyLogTail

            # Starts tailing the logfile.

        .Example
            Show-ChocolateyLogTail -Path \\someserver\c$\ProgramData\chocolatey\logs\chocolatey.log

            # Starts tailing a specified logfile.

        .Example
            Show-ChocolateyLogTail -Last 10

            # Shows the last ten lines of a logfile, and then starts tailing it.
    #>
    [OutputType([ChocolateyLog[]])]
    [CmdletBinding()]
    param(
        # The path of the log to tail.
        [ArgumentCompleter({(Get-ChildItem $env:ChocolateyInstall\logs\ -Filter *.log).FullName})]
        [string]$Path = $(Join-Path $env:ChocolateyInstall "logs\chocolatey.log"),

        # If provided, outputs the last X loglines before tailing.
        [uint16]$Last
    )
    begin {
        $FileStream = [System.IO.FileStream]::new($Path, "Open", "Read","ReadWrite")
        $StreamReader = [System.IO.StreamReader]::new($FileStream)

        if ($Last) {
            ($StreamReader.ReadToEnd() | ConvertTo-ChocolateyLog)[-$Last..-1]
        } else {
            $null = $StreamReader.ReadToEnd()  # Would it be cleaner to set FileStream Position?
        }
    }
    process {
        while ($true) {
            if (-not $StreamReader.EndOfStream) {
                $StreamReader.ReadToEnd() | ConvertTo-ChocolateyLog
            }
            Start-Sleep -Milliseconds 50
        }
    }
    end {  # This could be a clean block, if we didn't want to support PS5
        if ($StreamReader) {
            $StreamReader.Close()
            $StreamReader.Dispose()
        }
        if ($FileStream) {
            $FileStream.Close()
            $FileStream.Dispose()
        }
    }
}