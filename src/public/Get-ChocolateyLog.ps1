function Get-ChocolateyLog {
    <#
        .Synopsis
            Returns formatted ChocolateyLog objects from the specified log(s).

        .Description
            Returns ChocolateyLog objects from any specifed logs. These should output
            in a more readable format, though some entries that have multiple lines
            (or longer lines) may not be readable without looking at the object or
            opening the log.

        .Example
            Get-ChocolateyLog

            # Returns the current Chocolatey log.

        .Example
            Get-ChocolateyLog -Path ~\Downloads\chocolatey(13).log

            # Returns the content of the provided Chocolatey log.

    #>
    [OutputType([ChocolateyLog[]])]
    [CmdletBinding()]
    param(
        # The path of the log(s) to parse.
        [Parameter(ValueFromPipeline)]
        [ArgumentCompleter({(Get-ChildItem $env:ChocolateyInstall\logs\ -Filter *.log).FullName})]
        [string[]]$Path = (Join-Path $env:ChocolateyInstall "logs\chocolatey.log")
    )
    process {
        # We use Get-Content -Raw instead of Select-String -Path to be able to match multiline
        Get-Content -Path $Path -Raw | ConvertTo-ChocolateyLog
    }
}