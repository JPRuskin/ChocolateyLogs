# Functions for rendering the content of each panel
function Get-TitlePanel {
    return "Chocolatey Log Browser [gray]↑/↓ (Browse Files), → (Expand), Esc (Exit)[/]" | Format-SpectreAligned -HorizontalAlignment Left -VerticalAlignment Middle | Format-SpectrePanel -Expand
}

function Get-FileListPanel {
    param (
        $Files,
        $SelectedFile
    )
    $fileList = $Files | ForEach-Object {
        $name = $_.Name
        if ($_.Name -eq $SelectedFile.Name) {
            $name = "[Turquoise2]$($name)[/]"
        }
        return $name
    } | Out-String
    return Format-SpectrePanel -Header "[white]File List[/]" -Data $fileList.Trim() -Expand
}

function Get-CallPanel {
    param (
        $SelectedFile,

        $Height,

        $Width,

        $Scroll = 0
    )
    if (-not $script:CachedCalls) {$script:CachedCalls = @{}}
    $item = Get-Item -Path $SelectedFile.FullName
    $result = ""
    if ($item -is [System.IO.DirectoryInfo]) {
        $result = "[grey]$($SelectedFile.Name) is a directory. Hit Enter to list files in the directory:[/]`n'$(Resolve-Path $SelectedFile.FullName)'" | Format-SpectrePanel -Header "[white]Calls[/]" -Expand
    } else {
        try {
            $Hash = (Get-FileHash $item.FullName -Algorithm MD5).Hash
            if (-not $script:CachedCalls[$Hash]) {
                $script:CachedCalls[$Hash] = Get-ChocolateyCall -Path $item.FullName
            }
            $result = $script:CachedCalls[$Hash] | Select-Object -First $(
                $Height
            ) -Skip $Scroll | Format-SpectreTable -Property @(
                @{
                    Name = 'Time'
                    Expression = {
                        Get-Date $_.StartTime -Format "HH:mm:ss"
                    }
                    Width = 8
                }
                @{
                    Name = 'X'
                    Expression = {
                        switch ($_.Result) {
                            "0" {"$_"}
                            default {"[yellow]$(
                                if ("$_".Length -eq 1) {
                                    $_
                                } else {
                                    ">"
                                }
                            )[/]"}
                            "E" {"[red]$_[/]"}
                        }
                    }
                    Width = 1
                }
                @{
                    Name = 'Command'
                    Expression = {
                        if ($_.Command.Length -gt ($Width - 17)) {
                            $_.Command.SubString(0, ($Width - 20)) + '...'
                        } else {
                            $_.Command
                        }
                    }
                    Width = $Width - 16
                }
            ) -AllowMarkup
        } catch {
            $result = "[red]Error reading file content: $($_.Exception.Message | Get-SpectreEscapedText)[/]" | Format-SpectrePanel -Header "[white]Calls[/]" -Expand
        }
    }
    return $result
}

function Get-LastKeyPressed {
    $lastKeyPressed = $null
    while ([Console]::KeyAvailable) {
        $lastKeyPressed = [Console]::ReadKey($true)
    }
    return $lastKeyPressed
}

function Show-ChocolateyLog {
    param(
        [string]$Path = $(Join-Path $env:ChocolateyInstall "logs")
    )

    $layout = New-SpectreLayout -Name "root" -Rows @(
        # Row 1
        (
            New-SpectreLayout -Name "header" -MinimumSize 5 -Ratio 1 -Data ("empty")
        ),
        # Row 2
        (
            New-SpectreLayout -Name "content" -Ratio 10 -Columns @(
                (
                    New-SpectreLayout -Name "filelist" -Ratio 10 -Data "empty"
                ),
                (
                    New-SpectreLayout -Name "calls" -Ratio 40 -Data "empty"
                )
            )
        )
    )

    $script:TableHeight = $Host.UI.RawUI.WindowSize.Height - 9
    $script:TableWidth = 4*($Host.UI.RawUI.WindowSize.Width / 5) - 2

    # Start live rendering the layout
    # Type "↓", "↓", "↓" to navigate the file list, and press "Enter" to open a file in Notepad
    Invoke-SpectreLive -Data $layout -ScriptBlock {
        param (
            [Spectre.Console.LiveDisplayContext]$Context
        )

        # State
        $fileList = @(@{Name = ".."; Fullname = ".."}) + (Get-ChildItem $Path | Where-Object {
            $_.Extension -in @('.zip', '.7z', '.txt', '.log', '')
        } | Sort-Object LastWriteTime -Descending)
        $selectedFile = $fileList.Where{$_.Name -eq 'chocolatey.log'}
        $Screen = @{
            FullScreen = $false
            Expanded = $false
            LogScroll = 0
        }

        while ($true) {
            if ($lastKeyPressed = Get-LastKeyPressed) {
                if ($lastKeyPressed.Key -eq "DownArrow") {
                    if ($Screen.Expanded) {
                        $Screen.LogScroll++
                    } else {
                        $selectedFile = $fileList[($fileList.IndexOf($selectedFile) + 1) % $fileList.Count]
                        $Screen.LogScroll = 0
                    }
                } elseif ($lastKeyPressed.Key -eq "UpArrow") {
                    if ($Screen.Expanded) {
                        $Screen.LogScroll = [Math]::Max(0, $Screen.LogScroll - 1)
                    } else {
                        $selectedFile = $fileList[($fileList.IndexOf($selectedFile) - 1 + $fileList.Count) % $fileList.Count]
                        $Screen.LogScroll = 0
                    }
                } elseif ($lastKeyPressed.Key -eq "RightArrow") {
                    if (-not $Screen.Expanded) {
                        $Screen.Expanded = $true
                        $layout["filelist"].IsVisible = $false
                        $script:TableWidth = $Host.UI.RawUI.WindowSize.Width - 2
                    }
                } elseif ($lastKeyPressed.Key -eq "LeftArrow") {
                    if ($Screen.Expanded) {
                        $Screen.Expanded = $false
                        $layout["filelist"].IsVisible = $true
                        $script:TableWidth = 4*($Host.UI.RawUI.WindowSize.Width / 5) - 2
                    }
                } elseif ($lastKeyPressed.Key -eq "Enter") {
                    if ($selectedFile -is [System.IO.DirectoryInfo] -or $selectedFile.Name -eq "..") {
                        $fileList = @(@{Name = ".."; Fullname = ".."}) + (Get-ChildItem $selectedFile.FullName | Where-Object {
                            $_.Extension -in @('.zip', '.txt', '.log', '')
                        } | Sort-Object LastWriteTime -Descending)
                        $selectedFile = $fileList[0]
                    } else {
                        notepad $selectedFile.FullName
                        return
                    }
                } elseif ($lastKeyPressed.Key -eq "Escape") {
                    if ($Screen.Expanded) {
                        $Screen.Expanded = $false
                        $layout["filelist"].IsVisible = $true
                        $script:TableWidth = 4*($Host.UI.RawUI.WindowSize.Width / 5) - 2
                    } else {
                        return
                    }
                }
            }

            # Generate new data
            $titlePanel = Get-TitlePanel
            $fileListPanel = Get-FileListPanel -Files $fileList -SelectedFile $selectedFile
            $viewPanel = Get-CallPanel -SelectedFile $selectedFile -Width $script:TableWidth -Height $script:TableHeight -Scroll $Screen.LogScroll

            # Update layout
            $layout["header"].Update($titlePanel) | Out-Null
            $layout["filelist"].Update($fileListPanel) | Out-Null
            $layout["calls"].Update($viewPanel) | Out-Null

            # Draw changes
            $Context.Refresh()
            Start-Sleep -Milliseconds 50
        }
    }
}

function Show-ChocolateyCall {}