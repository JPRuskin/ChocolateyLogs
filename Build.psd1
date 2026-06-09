@{
    ModuleManifest = "./src/Flake.psd1"
    Prefix = "Prefix.ps1"
    OutputDirectory = ".."
    VersionedOutputDirectory = $true
    CopyPaths = @(
        "data"
    )
}