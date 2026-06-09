filter ConvertTo-ChocolateyLog {
    <#
        .Synopsis
            This filter parses a given string and converts it to ChocolateyLog objects.

        .Description
            This filter is used in multiple places throughout the module, and converts
            a given string into ChocolateyLog objects.

        .Example
            Get-Content $Path -Raw | ConvertTo-ChocolateyLog

        .Example
            $StreamReader.ReadToEnd() | ConvertTo-ChocolateyLog
    #>
    [OutputType([ChocolateyLog[]])]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $String
    )
    [ChocolateyLog[]]($String | Select-String -Pattern $script:MultilinePattern -AllMatches).Matches
}