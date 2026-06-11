Describe "ConvertTo-ChocolateyLog" {
    BeforeAll {
        Import-Module $PSScriptRoot\..\..\src\Flake.psd1
    }

    Context "Converting Strings" {
        It "Successfully converts a multiline record" {
            $Result = @"
2026-06-09 14:50:42,784 38664 [DEBUG] - 
NOTE: Hiding sensitive configuration data! Please double and triple
 check to be sure no sensitive data is shown, especially if copying
 output to a gist for review.

"@ | ConvertTo-ChocolateyLog

            $Result[0].PSObject.TypeNames | Should -Contain ChocolateyLog
            $Result.Count | Should -Be 1
        }

        It "Successfully converts a singleline record" {
            $Result = "2026-06-09 15:25:11,244 55496 [INFO ] - Chocolatey v2.7.2 Business`n" | ConvertTo-ChocolateyLog

            $Result[0].PSObject.TypeNames | Should -Contain ChocolateyLog
            $Result.Count | Should -Be 1
        }

        It "Successfully converts multiple singleline records" {
            $Result = @"
2026-06-09 14:50:41,609 38664 [DEBUG] - Registering new command 'apikey' in assembly 'choco'
2026-06-09 14:50:41,609 38664 [DEBUG] - Registering new command 'cache' in assembly 'choco'
2026-06-09 14:50:41,610 38664 [DEBUG] - Registering new command 'config' in assembly 'choco'
2026-06-09 14:50:41,611 38664 [DEBUG] - Registering new command 'export' in assembly 'choco'
2026-06-09 14:50:41,611 38664 [DEBUG] - Registering new command 'feature' in assembly 'choco'
2026-06-09 14:50:41,611 38664 [DEBUG] - Registering new command 'help' in assembly 'choco'
2026-06-09 14:50:41,613 38664 [DEBUG] - Registering new command 'info' in assembly 'choco'
2026-06-09 14:50:41,613 38664 [DEBUG] - Registering new command 'install' in assembly 'choco'
2026-06-09 14:50:41,614 38664 [DEBUG] - Registering new command 'license' in assembly 'choco'
2026-06-09 14:50:41,614 38664 [DEBUG] - Registering new command 'list' in assembly 'choco'
2026-06-09 14:50:41,615 38664 [DEBUG] - Registering new command 'new' in assembly 'choco'
2026-06-09 14:50:41,615 38664 [DEBUG] - Registering new command 'outdated' in assembly 'choco'
2026-06-09 14:50:41,616 38664 [DEBUG] - Registering new command 'pack' in assembly 'choco'
2026-06-09 14:50:41,617 38664 [DEBUG] - Registering new command 'pin' in assembly 'choco'
2026-06-09 14:50:41,617 38664 [DEBUG] - Registering new command 'push' in assembly 'choco'
2026-06-09 14:50:41,618 38664 [DEBUG] - Registering new command 'rule' in assembly 'choco'
2026-06-09 14:50:41,618 38664 [DEBUG] - Registering new command 'search' in assembly 'choco'
2026-06-09 14:50:41,619 38664 [DEBUG] - Registering new command 'source' in assembly 'choco'
2026-06-09 14:50:41,620 38664 [DEBUG] - Registering new command 'support' in assembly 'choco'
2026-06-09 14:50:41,621 38664 [DEBUG] - Registering new command 'template' in assembly 'choco'
2026-06-09 14:50:41,621 38664 [DEBUG] - Registering new command 'uninstall' in assembly 'choco'
2026-06-09 14:50:41,622 38664 [DEBUG] - Registering new command 'unpackself' in assembly 'choco'
2026-06-09 14:50:41,622 38664 [DEBUG] - Registering new command 'upgrade' in assembly 'choco'

"@ | ConvertTo-ChocolateyLog
            $Result.Count | Should -Be 23
            $Result.ForEach{
                $_.PSObject.TypeNames | Should -Contain ChocolateyLog
            }
        }

        It "Successfully converts multiple multiline records" {
            $Result = @"
2026-06-09 11:36:47,105 3444 [DEBUG] - User may be subject to UAC, checking for a split token (not 100%
 effective).
2026-06-09 11:36:47,794 3444 [DEBUG] - 
NOTE: Hiding sensitive configuration data! Please double and triple
 check to be sure no sensitive data is shown, especially if copying
 output to a gist for review.
2026-06-09 11:36:47,805 3444 [DEBUG] - Configuration: MaximumDownloadRateBitsPerSecond='0'|
MaximumDownloadRateBitsPerSecondAutoSet='False'|
ChocolateyVersion.Version='2.7.2.0'|
ChocolateyVersion.IsLegacyVersion='False'|
ChocolateyVersion.Revision='0'|ChocolateyVersion.IsSemVer2='False'|
ChocolateyVersion.OriginalVersion='2.7.2.0'|
ChocolateyVersion.Major='2'|
ChocolateyVersion.Minor='7'|ChocolateyVersion.Patch='2'|
ChocolateyVersion.IsPrerelease='False'|
ChocolateyVersion.HasMetadata='False'|
VirusConfiguration.VirusCheckMinimumPositives='4'|
VirusConfiguration.VirusScannerType='Generic'|
VirusConfiguration.GenericVirusScannerArgs=''[[File]]''|
VirusConfiguration.GenericVirusScannerValidExitCodes='0'|
VirusConfiguration.GenericVirusScannerTimeoutInSeconds='120'|
CommandName='search'|
CacheLocation='C:\ProgramData\chocolatey\choco-cache'|
CommandExecutionTimeoutSeconds='14400'|WebRequestTimeoutSeconds='30'|
Sources='https://community.chocolatey.org/api/v2/'|

SourceType='normal'|IncludeConfiguredSources='False'|
ShowOnlineHelp='False'|Debug='False'|Verbose='False'|Trace='False'|
Force='False'|Noop='False'|HelpRequested='False'|
UnsuccessfulParsing='False'|RegularOutput='True'|QuietOutput='False'|
PromptForConfirmation='True'|DisableCompatibilityChecks='False'|
AcceptLicense='False'|AllowUnofficialBuild='False'|Input='chocolatey'|
AllVersions='False'|SkipPackageInstallProvider='False'|
SkipHookScripts='False'|Prerelease='False'|ForceX86='False'|
OverrideArguments='False'|NotSilent='False'|
ApplyPackageParametersToDependencies='False'|
ApplyInstallArgumentsToDependencies='False'|IgnoreDependencies='False'|
UseHttpCache='True'|CacheExpirationInMinutes='30'|
AllowDowngrade='False'|ForceDependencies='False'|PinPackage='False'|
IncludeHeaders='False'|Information.PlatformType='Windows'|
Information.PlatformVersion='10.0.26200.0'|
Information.PlatformName='Windows 11'|
Information.ChocolateyVersion='2.7.2.0'|
Information.ChocolateyProductVersion='2.7.2'|
Information.FullName='choco, Version=2.7.2.0, Culture=neutral, PublicKeyToken=79d02ea9cad655eb'|

Information.Is64BitOperatingSystem='True'|
Information.Is64BitProcess='True'|Information.IsInteractive='True'|
Information.UserName='james'|Information.UserDomainName='TITAN'|
Information.IsUserAdministrator='True'|
Information.IsUserSystemAccount='False'|
Information.IsUserRemoteDesktop='False'|
Information.IsUserRemote='False'|Information.IsProcessElevated='False'|
Information.CurrentDirectory='C:\Users\james'|
Features.AutoUninstaller='True'|Features.ChecksumFiles='True'|
Features.AllowEmptyChecksums='False'|
Features.AllowEmptyChecksumsSecure='True'|
Features.FailOnAutoUninstaller='False'|
Features.FailOnStandardError='False'|Features.UsePowerShellHost='True'|
Features.LogEnvironmentValues='False'|Features.LogWithoutColor='False'|
Features.VirusCheck='False'|
Features.FailOnInvalidOrMissingLicense='False'|
Features.IgnoreInvalidOptionsSwitches='True'|
Features.UsePackageExitCodes='True'|
Features.UseEnhancedExitCodes='False'|
Features.UseFipsCompliantChecksums='False'|
Features.ShowNonElevatedWarnings='True'|
Features.ShowDownloadProgress='True'|
Features.StopOnFirstPackageFailure='False'|
Features.UseRememberedArgumentsForUpgrades='False'|
Features.IgnoreUnfoundPackagesOnUpgradeOutdated='False'|
Features.SkipPackageUpgradesWhenNotInstalled='False'|
Features.RemovePackageInformationOnUninstall='False'|
Features.ExitOnRebootDetected='False'|
Features.LogValidationResultsOnWarnings='True'|
Features.UsePackageRepositoryOptimizations='False'|
Features.UsePackageHashValidation='False'|
ListCommand.LocalOnly='False'|
ListCommand.IdOnly='False'|ListCommand.IncludeRegistryPrograms='False'|
ListCommand.PageSize='25'|ListCommand.Exact='True'|
ListCommand.ByIdOnly='False'|ListCommand.ByTagOnly='False'|
ListCommand.IdStartsWith='False'|ListCommand.IgnorePinned='False'|
ListCommand.OrderBy='Id'|ListCommand.OrderByPopularity='False'|
ListCommand.ApprovedOnly='False'|
ListCommand.DownloadCacheAvailable='False'|
ListCommand.NotBroken='False'|
ListCommand.IncludeVersionOverrides='False'|
ListCommand.ExplicitPageSize='False'|
ListCommand.ExplicitSource='False'|
UpgradeCommand.FailOnUnfound='False'|
UpgradeCommand.FailOnNotInstalled='False'|
UpgradeCommand.NotifyOnlyAvailableUpgrades='False'|
UpgradeCommand.ExcludePrerelease='False'|
UpgradeCommand.IgnorePinned='False'|
NewCommand.AutomaticPackage='False'|
NewCommand.UseOriginalTemplate='False'|SourceCommand.Command='unknown'|
SourceCommand.Priority='0'|SourceCommand.BypassProxy='False'|
SourceCommand.AllowSelfService='False'|
SourceCommand.VisibleToAdminsOnly='False'|
FeatureCommand.Command='unknown'|ConfigCommand.Command='Unknown'|
ApiKeyCommand.Command='Unknown'|PinCommand.Command='Unknown'|
OutdatedCommand.IgnorePinned='False'|
ExportCommand.IncludeVersionNumbers='False'|Proxy.BypassOnLocal='True'|
TemplateCommand.Command='unknown'|CacheCommand.Command='Unknown'|
CacheCommand.RemoveExpiredItemsOnly='False'|
2026-06-09 12:37:44,643 30592 [DEBUG] - User may be subject to UAC, checking for a split token (not 100%
 effective).

"@ | ConvertTo-ChocolateyLog
            $Result.Count | Should -Be 4
            $Result.ForEach{
                $_.PSObject.TypeNames | Should -Contain ChocolateyLog
            }
        }

        It "Successfully converts multiple mixed records" {
            $Result = @"
2026-06-09 11:36:45,903 3444 [DEBUG] - XmlConfiguration is now operational
2026-06-09 11:36:46,689 3444 [DEBUG] - Registering new command 'apikey' in assembly 'choco'
2026-06-09 11:36:46,690 3444 [DEBUG] - Registering new command 'cache' in assembly 'choco'
2026-06-09 11:36:46,690 3444 [DEBUG] - Registering new command 'config' in assembly 'choco'
2026-06-09 11:36:46,692 3444 [DEBUG] - Registering new command 'export' in assembly 'choco'
2026-06-09 11:36:46,692 3444 [DEBUG] - Registering new command 'feature' in assembly 'choco'
2026-06-09 11:36:46,693 3444 [DEBUG] - Registering new command 'help' in assembly 'choco'
2026-06-09 11:36:46,693 3444 [DEBUG] - Registering new command 'info' in assembly 'choco'
2026-06-09 11:36:46,694 3444 [DEBUG] - Registering new command 'install' in assembly 'choco'
2026-06-09 11:36:46,694 3444 [DEBUG] - Registering new command 'license' in assembly 'choco'
2026-06-09 11:36:46,695 3444 [DEBUG] - Registering new command 'list' in assembly 'choco'
2026-06-09 11:36:46,696 3444 [DEBUG] - Registering new command 'new' in assembly 'choco'
2026-06-09 11:36:46,696 3444 [DEBUG] - Registering new command 'outdated' in assembly 'choco'
2026-06-09 11:36:46,697 3444 [DEBUG] - Registering new command 'pack' in assembly 'choco'
2026-06-09 11:36:46,697 3444 [DEBUG] - Registering new command 'pin' in assembly 'choco'
2026-06-09 11:36:46,698 3444 [DEBUG] - Registering new command 'push' in assembly 'choco'
2026-06-09 11:36:46,698 3444 [DEBUG] - Registering new command 'rule' in assembly 'choco'
2026-06-09 11:36:46,699 3444 [DEBUG] - Registering new command 'search' in assembly 'choco'
2026-06-09 11:36:46,700 3444 [DEBUG] - Registering new command 'source' in assembly 'choco'
2026-06-09 11:36:46,700 3444 [DEBUG] - Registering new command 'support' in assembly 'choco'
2026-06-09 11:36:46,701 3444 [DEBUG] - Registering new command 'template' in assembly 'choco'
2026-06-09 11:36:46,701 3444 [DEBUG] - Registering new command 'uninstall' in assembly 'choco'
2026-06-09 11:36:46,702 3444 [DEBUG] - Registering new command 'unpackself' in assembly 'choco'
2026-06-09 11:36:46,706 3444 [DEBUG] - Registering new command 'upgrade' in assembly 'choco'
2026-06-09 11:36:47,019 3444 [INFO ] - ============================================================
2026-06-09 11:36:47,105 3444 [DEBUG] - User may be subject to UAC, checking for a split token (not 100%
 effective).
2026-06-09 11:36:47,794 3444 [DEBUG] - 
NOTE: Hiding sensitive configuration data! Please double and triple
 check to be sure no sensitive data is shown, especially if copying
 output to a gist for review.
2026-06-09 11:36:47,805 3444 [DEBUG] - Configuration: MaximumDownloadRateBitsPerSecond='0'|
MaximumDownloadRateBitsPerSecondAutoSet='False'|
ChocolateyVersion.Version='2.7.2.0'|
ChocolateyVersion.IsLegacyVersion='False'|
ChocolateyVersion.Revision='0'|ChocolateyVersion.IsSemVer2='False'|
ChocolateyVersion.OriginalVersion='2.7.2.0'|
ChocolateyVersion.Major='2'|
ChocolateyVersion.Minor='7'|ChocolateyVersion.Patch='2'|
ChocolateyVersion.IsPrerelease='False'|
ChocolateyVersion.HasMetadata='False'|
VirusConfiguration.VirusCheckMinimumPositives='4'|
VirusConfiguration.VirusScannerType='Generic'|
VirusConfiguration.GenericVirusScannerArgs=''[[File]]''|
VirusConfiguration.GenericVirusScannerValidExitCodes='0'|
VirusConfiguration.GenericVirusScannerTimeoutInSeconds='120'|
CommandName='search'|
CacheLocation='C:\ProgramData\chocolatey\choco-cache'|
CommandExecutionTimeoutSeconds='14400'|WebRequestTimeoutSeconds='30'|
Sources='https://community.chocolatey.org/api/v2/'|

SourceType='normal'|IncludeConfiguredSources='False'|
ShowOnlineHelp='False'|Debug='False'|Verbose='False'|Trace='False'|
Force='False'|Noop='False'|HelpRequested='False'|
UnsuccessfulParsing='False'|RegularOutput='True'|QuietOutput='False'|
PromptForConfirmation='True'|DisableCompatibilityChecks='False'|
AcceptLicense='False'|AllowUnofficialBuild='False'|Input='chocolatey'|
AllVersions='False'|SkipPackageInstallProvider='False'|
SkipHookScripts='False'|Prerelease='False'|ForceX86='False'|
OverrideArguments='False'|NotSilent='False'|
ApplyPackageParametersToDependencies='False'|
ApplyInstallArgumentsToDependencies='False'|IgnoreDependencies='False'|
UseHttpCache='True'|CacheExpirationInMinutes='30'|
AllowDowngrade='False'|ForceDependencies='False'|PinPackage='False'|
IncludeHeaders='False'|Information.PlatformType='Windows'|
Information.PlatformVersion='10.0.26200.0'|
Information.PlatformName='Windows 11'|
Information.ChocolateyVersion='2.7.2.0'|
Information.ChocolateyProductVersion='2.7.2'|
Information.FullName='choco, Version=2.7.2.0, Culture=neutral, PublicKeyToken=79d02ea9cad655eb'|

Information.Is64BitOperatingSystem='True'|
Information.Is64BitProcess='True'|Information.IsInteractive='True'|
Information.UserName='james'|Information.UserDomainName='TITAN'|
Information.IsUserAdministrator='True'|
Information.IsUserSystemAccount='False'|
Information.IsUserRemoteDesktop='False'|
Information.IsUserRemote='False'|Information.IsProcessElevated='False'|
Information.CurrentDirectory='C:\Users\james'|
Features.AutoUninstaller='True'|Features.ChecksumFiles='True'|
Features.AllowEmptyChecksums='False'|
Features.AllowEmptyChecksumsSecure='True'|
Features.FailOnAutoUninstaller='False'|
Features.FailOnStandardError='False'|Features.UsePowerShellHost='True'|
Features.LogEnvironmentValues='False'|Features.LogWithoutColor='False'|
Features.VirusCheck='False'|
Features.FailOnInvalidOrMissingLicense='False'|
Features.IgnoreInvalidOptionsSwitches='True'|
Features.UsePackageExitCodes='True'|
Features.UseEnhancedExitCodes='False'|
Features.UseFipsCompliantChecksums='False'|
Features.ShowNonElevatedWarnings='True'|
Features.ShowDownloadProgress='True'|
Features.StopOnFirstPackageFailure='False'|
Features.UseRememberedArgumentsForUpgrades='False'|
Features.IgnoreUnfoundPackagesOnUpgradeOutdated='False'|
Features.SkipPackageUpgradesWhenNotInstalled='False'|
Features.RemovePackageInformationOnUninstall='False'|
Features.ExitOnRebootDetected='False'|
Features.LogValidationResultsOnWarnings='True'|
Features.UsePackageRepositoryOptimizations='False'|
Features.UsePackageHashValidation='False'|
ListCommand.LocalOnly='False'|
ListCommand.IdOnly='False'|ListCommand.IncludeRegistryPrograms='False'|
ListCommand.PageSize='25'|ListCommand.Exact='True'|
ListCommand.ByIdOnly='False'|ListCommand.ByTagOnly='False'|
ListCommand.IdStartsWith='False'|ListCommand.IgnorePinned='False'|
ListCommand.OrderBy='Id'|ListCommand.OrderByPopularity='False'|
ListCommand.ApprovedOnly='False'|
ListCommand.DownloadCacheAvailable='False'|
ListCommand.NotBroken='False'|
ListCommand.IncludeVersionOverrides='False'|
ListCommand.ExplicitPageSize='False'|
ListCommand.ExplicitSource='False'|
UpgradeCommand.FailOnUnfound='False'|
UpgradeCommand.FailOnNotInstalled='False'|
UpgradeCommand.NotifyOnlyAvailableUpgrades='False'|
UpgradeCommand.ExcludePrerelease='False'|
UpgradeCommand.IgnorePinned='False'|
NewCommand.AutomaticPackage='False'|
NewCommand.UseOriginalTemplate='False'|SourceCommand.Command='unknown'|
SourceCommand.Priority='0'|SourceCommand.BypassProxy='False'|
SourceCommand.AllowSelfService='False'|
SourceCommand.VisibleToAdminsOnly='False'|
FeatureCommand.Command='unknown'|ConfigCommand.Command='Unknown'|
ApiKeyCommand.Command='Unknown'|PinCommand.Command='Unknown'|
OutdatedCommand.IgnorePinned='False'|
ExportCommand.IncludeVersionNumbers='False'|Proxy.BypassOnLocal='True'|
TemplateCommand.Command='unknown'|CacheCommand.Command='Unknown'|
CacheCommand.RemoveExpiredItemsOnly='False'|
2026-06-09 12:37:44,643 30592 [DEBUG] - User may be subject to UAC, checking for a split token (not 100%
 effective).
2026-06-09 11:36:47,811 3444 [DEBUG] - Searching for package information
2026-06-09 11:36:47,817 3444 [DEBUG] - Running list with the following filter = 'chocolatey'
2026-06-09 11:36:47,818 3444 [DEBUG] - --- Start of List ---
2026-06-09 11:36:47,908 3444 [DEBUG] - Process Tree: Chocolatey CLI => Chocolatey CLI => pwsh => WindowsTerminal => explorer
"@ | ConvertTo-ChocolateyLog
            $Result.Count | Should -Be 32
            $Result.ForEach{
                $_.PSObject.TypeNames | Should -Contain ChocolateyLog
            }
        }
    }
}