# PowerShell
PowerShell Scripts
These script need PowerShell version 7.

# Installation
```
Install-Module -Name MDATP
Install-Module -Name MSAL.PS
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

