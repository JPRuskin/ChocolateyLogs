function Get-ChocolateyCall {
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$Path = (Join-Path $env:ChocolateyInstall "logs\chocolatey.log"),

        [uint16]$Last
    )
    process {
        #Get-Content $Path | ConvertTo-ChocolateyLog
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

class ChocolateyCall {
    [datetime]$StartTime
    hidden [uint32]$ProcessID
    [string]$Command
    $Result
    [ChocolateyLog[]]$Output

    hidden [hashtable] $configValues

    [hashtable] GetConfiguration () {
        if ($this.configValues) {return $this.configValues}

        $Configuration = @{}

        $StringConfiguration = $this.Output.Where{$_.Stream -eq 'Debug' -and $_.Message.StartsWith('Configuration: ')}.Message
        $StringConfiguration.TrimStart("Configuration: ").Split("|").Where{-not [string]::IsNullOrWhiteSpace($_)}.Trim().ForEach{
            if ($_ -match "(?<Key>.+)='(?<Value>.+)'") {

                foreach ($Segment in $Matches.Key.Split('.')) {

                }
                $Configuration[$Matches.Key] = $Matches.Value
            }
        }

        $this.configValues = $Configuration
        return $this.configValues
    }
}

class ChocolateyLog {
    [datetime]$Timestamp
    [uint32]$ProcessID
    hidden [string]$Stream
    [string]$Message

    hidden [string]$Line
    hidden [string]$File
    hidden [uint16]$Index

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
        # Can't rely on these, but equally don't love hardcoded indexes from the regex. Hm.
        # $this.Timestamp = [datetime]::ParseExact($Match.Timestamp, 'yyyy-MM-dd HH:mm:ss,fff', [CultureInfo]::CurrentCulture)
        # $this.ProcessID = $Match.ProcessID
        # $this.Stream = $Match.Stream
        # $this.Message = $Match.Message
        # $this.Line = $Match.Value

        $this.Timestamp = [ChocolateyLog]::DateTimeFromTimestamp($Match.Groups.Value[1])
        $this.ProcessID = $Match.Groups.Value[2]
        $this.Stream    = $Match.Groups.Value[3]
        $this.Message   = $Match.Groups.Value[4].Trim()
        $this.Line      = $Match.Groups.Value[0]
    }

    # ChocolateyLog ([Microsoft.PowerShell.Commands.MatchInfo]$Match) {}

    ChocolateyLog ([string]$Line) {
        $this.Line = $Line

        if ($this.Line -match $script:Pattern) {
            $this.Timestamp = [ChocolateyLog]::DateTimeFromTimestamp($Matches.Timestamp)
            $this.ProcessID = $Matches.ProcessID
            $this.Stream    = $Matches.Stream
            $this.Message   = $Matches.Message.Trim()
            $this.Line      = $Matches[0]
        }
    }
}

$script:Pattern = -join @(
    "^"
    "(?<Timestamp>\d{4}-\d{2}-\d{2}\W+\d{2}:\d{2}:\d{2},\d{3})\W+"
    "(?<ProcessID>\d+)\W+"
    "\[(?<Stream>INFO|DEBUG|WARN|ERROR) ?\]"
    " - "
    "(?<Message>.*)"
    '$'
)

# function ConvertTo-ChocolateyLog {
#     [CmdletBinding()]
#     param(
#         [Parameter(Mandatory, ValueFromPipeline)]
#         [AllowEmptyString()]
#         [string[]]$InputObject
#     )
#     process {
#         foreach ($Line in $InputObject) {
#             if ($Line -match $Pattern) {
#                 if ($Result) {$Result}
#                 $Result = [ChocolateyLog]::new($Matches)
#             } else {
#                 $Result.Message += $Line
#             }
#         }
#     }
#     end {
#         $Result
#     }
# }

# function ConvertTo-ChocolateyLog {
#     [CmdletBinding()]
#     param(
#         [Parameter(Mandatory, ValueFromPipeline)]
#         [AllowEmptyString()]
#         [string[]]$InputObject
#     )
#     begin {
#         if (-not $script:Regex) {
#             $script:Regex = [regex]::new($Pattern, "Compiled, IgnoreCase, CultureInvariant")
#         }
#     }
#     process {
#         foreach ($Line in $InputObject) {
#             $MatchResult = $Regex.Matches($Line)
#             if ($MatchResult.Success) {
#                 if ($Result) {$Result}
#                 $Result = [ChocolateyLog]@{
#                     Timestamp = $MatchResult.Groups.Value[1]
#                     ProcessID = $MatchResult.Groups.Value[2]
#                     Stream    = $MatchResult.Groups.Value[3]
#                     Message   = $MatchResult.Groups.Value[4]
#                     Line      = $MatchResult.Groups.Value[0]
#                 }
#             } else {
#                 $Result.Message += $Line
#             }
#         }
#     }
#     end {
#         $Result
#     }
# }

function Get-ChocolateyLog {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$Path = (Join-Path $env:ChocolateyInstall "logs\chocolatey.log")
    )
    begin {
        $MultilinePattern = -join @(
            "(?m)"  # Multiline
            "^"  # We want to match from the start of a log line
            "(?<Timestamp>\d{4}-\d{2}-\d{2}\W+\d{2}:\d{2}:\d{2},\d{3})\W+"  # There should be a timestamp, in a known format
            "(?<ProcessID>\d+)\W+"  # Then a string of digits (processId)
            "\[(?<Stream>INFO|DEBUG|WARN|ERROR) ?\]"  # Then whichever stream the command was on
            " - "  # a separator
            "(?<Message>(?:.|\n)*?)\n"  # and then a message that can span multiple lines
            "(?=^\d{4}-\d{2}-\d{2}\W+\d{2}:\d{2}:\d{2},\d{3}\W+\d+\W+\[|\Z)"  # Finally, we should see the next log, or the end of the file
        )
    }
    process {
        # We use Get-Content -Raw instead of Select-String -Path to be able to match multiline
        [ChocolateyLog[]](Get-Content -Path $Path -Raw | Select-String -Pattern $MultilinePattern -AllMatches).Matches
    }
}