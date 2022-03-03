Function Get-MDATPDevice {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [array]$Name,

        [Parameter(Mandatory=$false)]
        [array]$Identity
    )

    Begin {
        Connect-MDATP        
    }

    Process {
        if ($Name) {
            $Devices = $Name
        } elseif ($Identity) {
            $Devices = $Identity
        } else {
            $Devices = "*"
        }

        ForEach ($Device in $Devices) {
            Do {
                if ($Response."@odata.nextLink") {
                    $Endpoint = $Response."@odata.nextLink"
                } elseif ($Identity) {
                    $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines?`$filter=id eq '{0}'" -f ($Device)
                } elseif ($Device -eq "*") {
                    $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines"
                } elseif ($Name) {
                    $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines?`$filter=startsWith(ComputerDNSName, '{0}')" -f ($Device)
                } else {
                    Write-Error "You shouldn't be seeing this error. A logical condition that should never occurr has been matched"
                    break
                }
    
                Try {
                    $Response = Invoke-MDATPRestMethod -Method GET -Uri $Endpoint                    
                } Catch {
                    Write-Error "Unable to obtain a list of devices"
                }
    
                $Response.Value `
                   | Select-Object @{Name = 'Id'; Expression = {$_.id}},
                                   @{Name = 'Name'; Expression = {$_.computerDnsName | Select-String -Pattern '^([^\.]+)'  | ForEach-Object { $_.Matches.Value }}},
                                   @{Name = 'FQDN'; Expression = {$_.computerDnsName}},
                                   @{Name = 'Domain'; Expression = {$_.computerDnsName | Select-String -Pattern '^[^\.]+\.(.*)'  | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value }  }},
                                   @{Name = 'FirstSeen'; Expression = {$_.firstSeen}},
                                   @{Name = 'LastSeen'; Expression = {$_.lastSeen}},
                                   @{Name = 'OSPlatform'; Expression = {$_.osPlatform}},
                                   @{Name = 'OSVersion'; Expression = {$_.osVersion}},
                                   @{Name = 'Processor'; Expression = {$_.osProcessor}},
                                   @{Name = 'Version'; Expression = {$_.Version}},
                                   @{Name = 'LastIpAddress'; Expression = {$_.lastIpAddress}},
                                   @{Name = 'LastExternalIpAddress'; Expression = {$_.lastExternalIpAddress}},
                                   @{Name = 'AgentVersion'; Expression = {$_.agentVersion}},
                                   @{Name = 'OSBuild'; Expression = {$_.osBuild}},
                                   @{Name = 'Status'; Expression = {$_.healthStatus}},
                                   @{Name = 'DeviceValue'; Expression = {$_.deviceValue}},
                                   @{Name = 'RBACGroupId'; Expression = {$_.rbacGroupId}},
                                   @{Name = 'RBACGroupName'; Expression = {$_.rbacGroupName}},
                                   @{Name = 'RiskScore'; Expression = {$_.riskScore}},
                                   @{Name = 'ExposureLevel'; Expression = {$_.exposureLevel}},
                                   @{Name = 'DeviceId'; Expression = {$_.aadDeviceId}},
                                   @{Name = 'Tags'; Expression = {$_.machineTags}},
                                   @{Name = 'AVStatus'; Expression = {$_.defenderAvStatus}},
                                   @{Name = 'IPAddresses'; Expression = {$_.ipAddresses}},
                                   @{Name = 'VMMetadata'; Expression = {$_.vmMetadata}}

            } While ($Response."@odata.nextLink")
        }
    }
}
