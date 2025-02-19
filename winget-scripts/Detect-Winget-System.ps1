# Function to get Winget version from installed winget.exe
function Get-WingetVersion {
    $WingetPath = Get-ChildItem "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_8wekyb3d8bbwe\winget.exe" -ErrorAction SilentlyContinue | Sort-Object -Property VersionInfo.FileVersionRaw -Descending | Select-Object -First 1
    if ($WingetPath) {
        $Version = (& $WingetPath.FullName -v).Replace("v", "").Trim()
        return $Version
    }
    return $null
}

# Desired version of Winget
$DesiredVersion = "1.7.11132"

# Get the installed version of Winget
$InstalledVersion = Get-WingetVersion

if ($InstalledVersion) {
    Write-Host "Winget is installed. Version: $InstalledVersion"
    if ($InstalledVersion -ge $DesiredVersion) {
        Write-Host "Winget version is sufficient: $InstalledVersion"
        exit 0  # Success
    } else {
        Write-Host "Installed Winget version is lower than the required version."
        exit 1  # Failure, version too low
    }
} else {
    Write-Host "Winget is not installed."
    exit 1  # Failure, winget not found
}
