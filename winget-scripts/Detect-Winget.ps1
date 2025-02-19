$AppInstallerPackage = "Microsoft.DesktopAppInstaller"

# Function to check if winget is installed
function Is-AppInstalled {
    $installed = Get-AppxPackage -Name $AppInstallerPackage -ErrorAction SilentlyContinue
    return $null -ne $installed
}

# Check and output result
if (Is-AppInstalled) {
    Write-Output "Winget is installed."
    exit 0  # Exit code 0 means success (installed)
} else {
    Write-Output "Winget is NOT installed."
    exit 1  # Exit code 1 means failure (not installed)
}
