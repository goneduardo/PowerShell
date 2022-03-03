# PowerShell for Microsoft Defender ATP
PowerShell cmdlets for interacting with the Microsoft Defender ATP REST API.

*Note: Currently a work in progress and developed as a tactical solution for helping to migrate machines in D2C from SEP and HX over to MDATP.*

# Installation
If you're on the Cyber Secure Operations Team, the easiest way to install this module is to grab it from AUSYDCSEC.
```
Register-PSRepository -Name CyberOps -SourceLocation \\AUSYDCSEC1\PowerShell
Install-Module -Repository CyberOps -Name MDATP
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
Comparing what's running in the `RioTinto-AU-Non-Production` Direct to Cloud (D2C) subscription against what's in Microsoft Defender ATP:
```
Set-AzContext RioTinto-AU-Non-Production
$NonProdAU = Get-AzVM
$MDATPDevices = Get-MDATPDevice
$NonProdAU | Measure-Object
```

Get a list of machines in AU Non-Prod that are NOT active. These are machines that were working and have now stopped reporting.
```
$MDATPDevices | ? { $_.Name -in ($NonProdAU | Select -ExpandProperty Name) } | ? { $_.Status -ne 'Active' }
```

List all connected machines by Domain. It's a good idea to keep an eye on any unknown / unexpected domains.
```
$MDATPDevices | Group-Object Domain | Select Name, Count

Name                      Count
----                      -----
                             70
ae.riotinto.org               1
corp.nprovision.com           1
corp.riotinto.org           756
eriotinto.org                 3
fyres.net                     1
little_Android_Pixel 3 XL     1
pioneer.riotinto.org         20
riotinto.org                  2
```