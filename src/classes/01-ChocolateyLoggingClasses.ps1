class ChocolateyLog {
    [datetime]$Timestamp
    [uint32]$ProcessID
    hidden [string]$Stream
    [string]$Message

    hidden [string]$Line
    hidden [string]$File
    hidden [uint32]$Index

    static [datetime] DateTimeFromTimestamp ([string]$Timestamp) {
        return [datetime]::ParseExact($Timestamp, 'yyyy-MM-dd HH:mm:ss,fff', [CultureInfo]::CurrentCulture)
    }

    ChocolateyLog ([hashtable]$Match) {
        $this.Timestamp = [ChocolateyLog]::DateTimeFromTimestamp($Match.Timestamp)
        $this.ProcessID = $Match.ProcessID
        $this.Stream = $Match.Stream
        $this.Message = $Match.Message.Trim()
        $this.Line = $Match[0]
    }

    ChocolateyLog ([System.Text.RegularExpressions.Match]$Match) {
        $this.Timestamp = [ChocolateyLog]::DateTimeFromTimestamp($Match.Groups.Value[1])
        $this.ProcessID = $Match.Groups.Value[2]
        $this.Stream    = $Match.Groups.Value[3]
        $this.Message   = $Match.Groups.Value[4].Trim()
        $this.Line      = $Match.Groups.Value[0]

        $this.Index = $Match.Index
    }

    ChocolateyLog ([System.Text.RegularExpressions.Match]$Match, [string]$File) {
        $this.Timestamp = [ChocolateyLog]::DateTimeFromTimestamp($Match.Groups.Value[1])
        $this.ProcessID = $Match.Groups.Value[2]
        $this.Stream    = $Match.Groups.Value[3]
        $this.Message   = $Match.Groups.Value[4].Trim()
        $this.Line      = $Match.Groups.Value[0]

        $this.File = $File
        $this.Index = $Match.Index
    }

    ChocolateyLog ([string]$Line) {
        $this.Line = $Line

        if ($this.Line -match $(-join @(  # Could use the multiline, if we wanted to strip out and actual multiline bits...
            "^"
            "(?<Timestamp>\d{4}-\d{2}-\d{2}\W+\d{2}:\d{2}:\d{2},\d{3})\W+"
            "(?<ProcessID>\d+)\W+"
            "\[(?<Stream>INFO|DEBUG|WARN|ERROR) ?\]"
            " - "
            "(?<Message>.*)"
            '$'
        ))) {
            $this.Timestamp = [ChocolateyLog]::DateTimeFromTimestamp($Matches.Timestamp)
            $this.ProcessID = $Matches.ProcessID
            $this.Stream    = $Matches.Stream
            $this.Message   = $Matches.Message.Trim()
            $this.Line      = $Matches[0]
        }
    }
}

class ChocolateyCall {
    [datetime]$StartTime
    hidden [uint32]$ProcessID
    [string]$Command
    $Result
    [ChocolateyLog[]]$Output

    hidden [hashtable] $configValues

    [hashtable] GetConfiguration () {
        if ($this.configValues) {return $this.configValues}

        $Configuration = [ordered]@{}

        if ($StringConfiguration = $this.Output.Where{$_.Stream -eq 'Debug' -and $_.Message.StartsWith('Configuration: ')}.Message) {
            $StringConfiguration.TrimStart("Configuration: ").Split("|").Where{-not [string]::IsNullOrWhiteSpace($_)}.Trim().ForEach{
                if ($_ -match "(?<Key>.+)='(?<Value>.+)'") {
                    $Level = '$Configuration'
                    foreach ($Segment in $Matches.Key.Split('.')) {
                        $Level += ".$Segment"
                        if (-not $(Invoke-Expression $Level)) {
                            Invoke-Expression "$Level = @{}"
                        }
                    }
                    Invoke-Expression "$Level = '$($Matches.Value.Trim(' ''"'))'"
                }
            }

            $this.configValues = $Configuration
        } else {
            Write-Debug "No Configuration Found on Log Stamped at $($this.StartTime)"
        }

        return $this.configValues
    }
}