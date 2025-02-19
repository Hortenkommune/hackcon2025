# Ensure script runs with admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires admin privileges. Please run as Administrator."
    exit 1
}

$ProgressPreference = 'SilentlyContinue' # Speed up Invoke-Webrequest

# Determine architecture
$OSArch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } elseif ($env:PROCESSOR_ARCHITECTURE -like "*64*") { "x64" } else { "x86" }

# Install Visual C++ Redistributable 2015-2022
$VCVersion = "14.40.0.0"
$VCInstalled = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
    | Where-Object { $_.DisplayName -like "Microsoft Visual C++ 2015-2022 Redistributable*" -and $_.DisplayVersion -ge $VCVersion }

if (-not $VCInstalled) {
    $VCUrl = "https://aka.ms/vs/17/release/VC_redist.$OSArch.exe"
    $VCInstaller = "$env:TEMP\VC_redist.$OSArch.exe"
    Invoke-WebRequest -Uri $VCUrl -OutFile $VCInstaller -UseBasicParsing
    Start-Process -FilePath $VCInstaller -ArgumentList "/quiet /norestart" -Wait
    Remove-Item -Path $VCInstaller -Force -ErrorAction SilentlyContinue
}

# Install UWP Dependencies
$Packages = @(
    @{ Name = "Microsoft.VCLibs.140.00.UWPDesktop"; Url = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" }
    @{ Name = "Microsoft.UI.Xaml.2.8"; Url = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" }
)

foreach ($Package in $Packages) {
    if (-not (Get-AppxPackage -Name $Package.Name -AllUsers)) {
        $AppxFile = "$env:TEMP\$($Package.Name).appx"
        Invoke-WebRequest -Uri $Package.Url -OutFile $AppxFile -UseBasicParsing
        Add-AppxProvisionedPackage -Online -PackagePath $AppxFile -SkipLicense | Out-Null
        Remove-Item -Path $AppxFile -Force -ErrorAction SilentlyContinue
    }
}

# Install WinGet
try {
    $WinGetUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
    $LatestWinGetVersion = ((Invoke-WebRequest -Uri $WinGetUrl -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace("v", "")
} catch {
    $LatestWinGetVersion = "1.7.11132"
}

$WingetPath = Get-ChildItem "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_8wekyb3d8bbwe\winget.exe" -ErrorAction SilentlyContinue | Sort-Object -Property VersionInfo.FileVersionRaw -Descending | Select-Object -First 1

if ($WingetPath) {
    $InstalledWinGetVersion = (& $WingetPath.FullName -v).Replace("v", "").Trim()
} else {
    $InstalledWinGetVersion = "0.0.0.0"
}

if ($LatestWinGetVersion -gt $InstalledWinGetVersion) {
    $WingetInstaller = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
    $WingetDownloadUrl = "https://github.com/microsoft/winget-cli/releases/download/v$LatestWinGetVersion/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Invoke-WebRequest -Uri $WingetDownloadUrl -OutFile $WingetInstaller -UseBasicParsing
    Add-AppxProvisionedPackage -Online -PackagePath $WingetInstaller -SkipLicense | Out-Null
    Remove-Item -Path $WingetInstaller -Force -ErrorAction SilentlyContinue

    # Reset WinGet sources
    $WingetPath = Get-ChildItem "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_8wekyb3d8bbwe\winget.exe" -ErrorAction SilentlyContinue | Sort-Object -Property VersionInfo.FileVersionRaw -Descending | Select-Object -First 1
    & $WingetPath.FullName source reset --force
}
