$AppInstallerPackage = "Microsoft.DesktopAppInstaller"
$MsixBundleUrl = "https://aka.ms/getwinget"
$DownloadPath = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"

# Function to check if winget is installed
function Is-AppInstalled {
    $installed = Get-AppxPackage -Name $AppInstallerPackage -ErrorAction SilentlyContinue
    return $null -ne $installed
}

# Function to download the winget installer efficiently
function Download-Winget {
    Write-Output "Downloading winget installer..."
    $ProgressPreference = 'SilentlyContinue'  # Speed up Invoke-WebRequest
    Invoke-WebRequest -Uri $MsixBundleUrl -OutFile $DownloadPath
    return Test-Path $DownloadPath
}

# Main logic
if (Is-AppInstalled) {
    Write-Output "Winget is already installed."
} else {
    Write-Output "Winget is not installed. Downloading and installing now..."

    if (Download-Winget) {
        Add-AppxPackage -Path $DownloadPath
        Write-Output "Installation complete."
    } else {
        Write-Output "Error: Failed to download winget installer."
    }
}
