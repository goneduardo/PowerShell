Function Search-MDATP {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)]
        [string]$Query
    )

    Begin {
        Connect-MDATP
    }

    Process {
        Do {
            if ($Response."@odata.nextLink") {
                $Endpoint = $Response."@odata.nextLink"
            } else {
                $Endpoint = "https://api.securitycenter.microsoft.com/api/advancedqueries/run"
            }

            Try {
                $Body = ConvertTo-Json -InputObject @{ 'Query' = $Query }
                $Response = Invoke-MDATPRestMethod -Method POST -Uri $Endpoint -Body $Body

                $Response.Results
            } Catch {
                Write-Error "Unable to search advanced hunting"
            }
        } While ($Response."@odata.nextLink")
    }
}
