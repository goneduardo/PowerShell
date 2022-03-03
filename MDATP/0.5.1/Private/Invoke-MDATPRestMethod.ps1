Function Invoke-MDATPRestMethod {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Method,

        [Parameter(Mandatory=$true)]
        [string]$Uri,

        [Parameter(Mandatory=$false)]
        [string]$Body
    )

    Process {
        $headers = @{
            'Content-Type' = 'application/json'
            'Accept' = 'application/json'
            'Authorization' = "Bearer $($MDATPSession.AccessToken)"
        }

        Write-Debug "Requesting: $Uri"
        Invoke-RestMethod -Method $Method -Headers $Headers -Body $Body -Uri $Uri
    }
}
