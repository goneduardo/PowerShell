function Continue {



}

function Check-MDATPActionStatus {
[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [String]$HostName,

        [parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$ID,

        [parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [string]$List
    )

    Begin {
        Connect-MDATP

        $Method = 'GET'

       	$headers = @{
    	 'Content-Type' = 'application/json'
	     'Accept' = 'application/json'
	     'Authorization' = "Bearer $($MDATPSession.AccessToken)"
        }
    }

    Process {
                
        if($ID -eq "" -and $HostName -ne ""){
            try {
                $Device = Get-MDATPDevice -Name $HostName
                $DeviceID = $Device.id
                Write-Host $DeviceID
            }
            catch{
                Write-Error $Error[0]
                break            
            }
        }        
        elseif($ID -ne ""){
            Write-Host "ID provided"
            $DeviceID = $ID
        }

        $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/machineactions"

        try{
            $Status = Invoke-RestMethod -Method $method -Headers $headers -Uri $Endpoint
        }
        catch{
            Write-Error $Error[0]
            break
        }

        $Status.Value[0] `
            | Select-Object @{Name = 'Task Id'  ; Expression = {$_.id}},
                            @{Name = 'Task Type'; Expression = {$_.type}},
                            @{Name = 'Task Scope'; Expression = {$_.scope}},
                            @{Name = 'Requestor'; Expression = {$_.Requestor}},
                            @{Name = 'Requestor Comment'; Expression = {$_.RequestorComment}},
                            @{Name = 'Task Status'; Expression = {$_.Status}},
                            @{Name = 'Computer Name'; Expression = {$_.computerDnsName}},
                            @{Name = 'Request DateTime UTC'; Expression = {$_.creationDateTimeUtc}},
                            @{Name = 'Last Update DateTime UTC'; Expression = {$_.lastUpdateDateTimeUtc}}
        
    }
}

