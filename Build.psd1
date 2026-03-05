@{
    ModuleManifest = "./src/Flake.psd1"
    OutputDirectory = ".."
    VersionedOutputDirectory = $true
    CopyPaths = @(
        "data"
    )
}