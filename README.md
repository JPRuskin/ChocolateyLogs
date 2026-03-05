# Flake (a module for viewing Chocolatey logs)

## Installation

Download the files from this gist and put them in a folder on your machine.

You should then be able to run `Import-Module .\path\to\Flake.psd1`.

## Usage

### Get-ChocolateyCall

<img width="958" height="419" alt="image" src="https://gist.github.com/user-attachments/assets/65bc6f10-7457-48c5-8cc6-89e5524963c6" />

This should produce a list of commands that you have run, along with their start time and exit code. `E` represents a command that threw an exception, was killed mid-task, or is otherwise incomplete.

You can see all configuration at the time of a given command by using the `GetConfiguration()` method.

You can access the full log for a given call by expanding `Output`.

### Get-ChocolateyLog

This somewhat colourised, trimmed down, output can also be displayed by using `Get-ChocolateyLog`. This will output everything in your log in a slightly formatted way. The main differences are that multi-line logs only show up as one line (so you don't see all of the settings unless you dig into them), and it only displays a formatted timestamp and a colourised message by default.

<img width="1453" height="705" alt="image" src="https://gist.github.com/user-attachments/assets/1f75575f-702c-49cf-8b5e-3116e9573131" />

Debug is in purple, errors are in red, warnings are in yellow, and info (stdout) is in white. NuGet and Verbose lines are coloured in gray, because they are infrequently helpful but take up a lot of space. You can filter against the stream property as follows:

```
Get-ChocolateyLog | Where Stream -eq 'Error'
```
