# PowerShell for Microsoft Defender ATP
PowerShell cmdlets for interacting with the Microsoft Defender ATP REST API.

# Installation
```
Install-Module -Repository Dalamar -Name MDATP
Install-Module -Repository PSGallery -Name MSAL.PS
```

# Updates
```
Get-Module -Name mdatp | Select Version
Update-module mdatp
```

# Getting Started
See what cmdlets are provided by the module:
```
Get-Command -Module MDATP
```

Authenticate and get a list of all machines in MDATP:
```
Connect-MDATP
Get-MDATPDevice
```

Get MDATP information for your own host:
```
Get-MDATPDevice -Name $env:COMPUTERNAME
```

# Examples

```
