# Winget Installer for MDM

This repository contains two PowerShell scripts: one for installing Winget and another for detecting its presence. These scripts run in the user context and are used in a deployment solution to resolve a known issue in Windows 11 24H2, where Winget is not installed by default in the user space.

## Scripts

### 1. Detection Script
The detection script checks whether Winget is installed and returns an appropriate exit code.

#### Usage:
Use this in your deployment solution as a detection script.

#### Behavior:
- If Winget is installed, it exits with code `0`.
- If Winget is not installed, it exits with code `1`.

### 2. Installation Script
The installation script downloads and installs Winget if it is not already present.

#### Usage:
```powershell
powershell.exe -ExecutionPolicy Bypass -File install-winget.ps1
```

#### Behavior:
- If Winget is already installed, the script outputs a confirmation message and exits.
- If Winget is not installed, the script downloads and installs it.

## Background
Due to a bug in Windows 11 24H2, Winget is not pre-installed for some users in userspace. These scripts ensure Winget is available in the userspace by manually downloading and installing the required package.

## Author
Per-Ole Fanuelsen and ChatGPT
