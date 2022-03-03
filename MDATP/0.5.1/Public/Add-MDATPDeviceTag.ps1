Function Add-MDATPDeviceTag {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [String]$DeviceId = "*",
        [Parameter(Mandatory=$True)]
        [String]$Tags
    )

    Begin {
        Connect-MDATP
    }

    Process {
        $Endpoint = ("https://api-us.securitycenter.windows.com/api/machines/{0}/tags" -f $DeviceId)

        ForEach ($Tag in $Tags) {
            $Body = ConvertTo-Json -InputObject @{ 'Action' = 'Add'; 'Value' = $Tag }
            $Response = Invoke-MDATPRestMethod -Method POST -Uri $Endpoint -Body $Body
        }
    }
}
