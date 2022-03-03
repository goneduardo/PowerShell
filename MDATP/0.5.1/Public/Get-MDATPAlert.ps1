Function Get-MDATPAlert {
    # [CmdletBinding()]
    # Param(
    #     [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
    #     [array]$Name,

    #     [Parameter(Mandatory=$false)]
    #     [array]$Identity
    # )

    Begin {
        Connect-MDATP
    }

    Process {
         Do {
            if ($Response."@odata.nextLink") {
                $Endpoint = $Response."@odata.nextLink"
            } else {
                $Endpoint = "https://api-us.securitycenter.windows.com/api/alerts"
            }

            $Response = Invoke-MDATPRestMethod -Method GET -Uri $Endpoint
            $Response.value
            
        } While ($Response."@odata.nextLink")
    }
}
