Function Request-MDATPAVScan {
[CmdletBinding()]
    param(
        [parameter(ParameterSetName="HostName")] [string]$HostName='unset',
        [parameter(ParameterSetName="HostID")] [string]$HostID = 'unset',
        [parameter(ParameterSetName="List")][string]$ListPath = 'unset',
        [parameter(ParameterSetName="List",Mandatory=$true)][ValidateSet("ComputerName","ComputerID")][string]$ListContentType='unset',
        [parameter(Mandatory=$true)][string] $Comment='unset',
        [parameter(Mandatory=$true)][ValidateSet("Full","Quick")][string] $ScanType='Quick',
        [parameter(Mandatory=$false)][switch]$Force,
        [parameter(Mandatory=$false)][switch]$CheckStatus   

    )

    Begin {
     
        Import-Module "C:\Program Files\WindowsPowerShell\Modules\MDATP\0.5.1\MDATP.psm1" -Force
        
        Connect-MDATP

        $Method = 'POST'
       
        $Body = @{Comment=$Comment;ScanType=$ScanType} | ConvertTo-Json

       	$Headers = @{
    	   'Content-Type' = 'application/json'
	       'Accept' = 'application/json'
	       'Authorization' = "Bearer $($MDATPSession.AccessToken)"
        }

        $RegExID = "[\w\W\d]{40}" 
        $DeviceID = ""
        $Name = ""
        $Status = ""
        $Confirmation = 'N'
        
        $ArrStatusObj = @()

        $StatusObj = New-Object psobject
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name id -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name type -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name title -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name requestor -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name requestorComment -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name status -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name scope -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name machineId -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name computerDnsName -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name creationDateTimeUtc -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name lastUpdateDateTimeUtc -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name cancellationRequestor -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name cancellationComment -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name cancellationDateTimeUtc -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name relatedFileInfo -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name commands -Value $null
        Add-Member -InputObject $StatusObj -MemberType NoteProperty -Name troubleshootInfo -Value $null 

    }

    Process {
        
            if($ListPath -ne "unset"){
                if(Test-Path($ListPath)){                
                    if($ListContentType -eq 'ComputerName'){
                        Get-Content $ListPath | % {                                

                            #retrieve id
                            $Name = $_
                            Write-Host $Name
                            try{                            
                                $Device = Get-MDATPDevice -Name $Name
                                $DeviceID = $Device.id
                                    if($DeviceID -match $RegExID){
                                        if($Force -eq $true){
                                            #perform AVScan
                                            $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/runAntiVirusScan"

                                            try{
                                                $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
                                            }
                                            catch{
                                                $Status = Write-Error $Error[0]            
                                            }                        

                                            if($Status.computerDnsName -ne "-"){
                                                $StatusObj.id = $Status.id
                                                $StatusObj.type = $Status.type
                                                $StatusObj.title = $Status.title
                                                $StatusObj.requestor = $Status.requestor
                                                $StatusObj.requestorComment = $Status.requestorComment
                                                $StatusObj.status = $Status.status
                                                $StatusObj.scope = $Status.scope
                                                $StatusObj.machineId = $Status.machineId
                                                $StatusObj.computerDnsName = $Status.computerDnsName
                                                $StatusObj.creationDateTimeUtc = $Status.creationDateTimeUtc
                                                $StatusObj.lastUpdateDateTimeUtc = $Status.lastUpdateDateTimeUtc
                                                $StatusObj.cancellationRequestor = $Status.cancellationRequestor
                                                $StatusObj.cancellationComment = $Status.cancellationComment
                                                $StatusObj.cancellationDateTimeUtc = $Status.cancellationDateTimeUtc
                                                $StatusObj.relatedFileInfo = $Status.relatedFileInfo
                                                $StatusObj.commands = $Status.commands
                                                $StatusObj.troubleshootInfo = $Status.troubleshootInfo

                                                $ArrStatusObj += $StatusObj
                                            }
                                            else{
                                                $StatusObj.id = '-'
                                                $StatusObj.type = '-'
                                                $StatusObj.title = '-'
                                                $StatusObj.requestor = '-'
                                                $StatusObj.requestorComment = '-'
                                                $StatusObj.status = "Failed"
                                                $StatusObj.machineId = '-'
                                                $StatusObj.computerDnsName = $Name
                                                $StatusObj.creationDateTimeUtc = '-'
                                                $StatusObj.lastUpdateDateTimeUtc = '-'
                                                $StatusObj.cancellationRequestor = '-'
                                                $StatusObj.cancellationComment = '-'
                                                $StatusObj.cancellationDateTimeUtc = '-'
                                                $StatusObj.relatedFileInfo = '-'
                                                $StatusObj.commands = '-'
                                                $StatusObj.troubleshootInfo = '-'

                                                $ArrStatusObj += $StatusObj
                                                
                                            }
                                        }
                                        else{
                                            #Ask for confirmation
                                            $Confirmation = Confirmation -Hostname $Name
                                            if($Confirmation.ToUpper() -eq 'Y'){
                                                #perform AVScan
                                                $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/runAntiVirusScan"

                                                try{
                                                    $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
                                                }
                                                catch{
                                                    $Status = Write-Error $Error[0]            
                                                }                        

                                                if($Status.computerDnsName -ne "-"){
                                                
                                                    $StatusObj.id = $Status.id
                                                    $StatusObj.type = $Status.type
                                                    $StatusObj.title = $Status.title
                                                    $StatusObj.requestor = $Status.requestor
                                                    $StatusObj.requestorComment = $Status.requestorComment
                                                    $StatusObj.status = $Status.status
                                                    $StatusObj.scope = $Status.scope
                                                    $StatusObj.machineId = $Status.machineId
                                                    $StatusObj.computerDnsName = $Status.computerDnsName
                                                    $StatusObj.creationDateTimeUtc = $Status.creationDateTimeUtc
                                                    $StatusObj.lastUpdateDateTimeUtc = $Status.lastUpdateDateTimeUtc
                                                    $StatusObj.cancellationRequestor = $Status.cancellationRequestor
                                                    $StatusObj.cancellationComment = $Status.cancellationComment
                                                    $StatusObj.cancellationDateTimeUtc = $Status.cancellationDateTimeUtc
                                                    $StatusObj.relatedFileInfo = $Status.relatedFileInfo
                                                    $StatusObj.commands = $Status.commands
                                                    $StatusObj.troubleshootInfo = $Status.troubleshootInfo

                                                    $ArrStatusObj += $StatusObj
                                                }
                                                else{
                                                    $StatusObj.id = '-'
                                                    $StatusObj.type = '-'
                                                    $StatusObj.title = '-'
                                                    $StatusObj.requestor = '-'
                                                    $StatusObj.requestorComment = '-'
                                                    $StatusObj.status = "Failed"
                                                    $StatusObj.machineId = '-'
                                                    $StatusObj.computerDnsName = $Name
                                                    $StatusObj.creationDateTimeUtc = '-'
                                                    $StatusObj.lastUpdateDateTimeUtc = '-'
                                                    $StatusObj.cancellationRequestor = '-'
                                                    $StatusObj.cancellationComment = '-'
                                                    $StatusObj.cancellationDateTimeUtc = '-'
                                                    $StatusObj.relatedFileInfo = '-'
                                                    $StatusObj.commands = '-'
                                                    $StatusObj.troubleshootInfo = '-'

                                                    $ArrStatusObj += $StatusObj
                                                }
                                            }
                                            else{
                                                Write-Host -ForegroundColor Green "Aborting AV Scan Action of the $Name."                                            
                                            }
                                        }
                                    }
                                }
                                catch{
                                    Write-Host -ForegroundColor Red "Could not retrieve the ID the host $_."
                                    Write-Host -ForegroundColor Red $Error[0]
                                }                        

                                ($StatusObj | Get-Member | Where-Object {$_.MemberType -eq 'NoteProperty'}).name |%{$StatusObj.$_ = $null}
                            }
                            $ArrStatusObj
                    }
                    elseif($ListContentType -eq 'ComputerID'){
                        Get-Content $ListPath | % {
                            $DeviceID = $_
                            if($DeviceID -match $RegExID){  #check the ID
                                if($Force -eq $true){
                                    #"perform the AVScan"
                                    $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/runAntiVirusScan"

                                    try{
                                        $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
                                    }
                                    catch{
                                        $Status = Write-Error $Error[0]            
                                    }                        

                                    if($Status.computerDnsName -ne "-"){
                                        $StatusObj.id = $Status.id
                                        $StatusObj.type = $Status.type
                                        $StatusObj.title = $Status.title
                                        $StatusObj.requestor = $Status.requestor
                                        $StatusObj.requestorComment = $Status.requestorComment
                                        $StatusObj.status = $Status.status
                                        $StatusObj.scope = $Status.scope
                                        $StatusObj.machineId = $Status.machineId
                                        $StatusObj.computerDnsName = $Status.computerDnsName
                                        $StatusObj.creationDateTimeUtc = $Status.creationDateTimeUtc
                                        $StatusObj.lastUpdateDateTimeUtc = $Status.lastUpdateDateTimeUtc
                                        $StatusObj.cancellationRequestor = $Status.cancellationRequestor
                                        $StatusObj.cancellationComment = $Status.cancellationComment
                                        $StatusObj.cancellationDateTimeUtc = $Status.cancellationDateTimeUtc
                                        $StatusObj.relatedFileInfo = $Status.relatedFileInfo
                                        $StatusObj.commands = $Status.commands
                                        $StatusObj.troubleshootInfo = $Status.troubleshootInfo

                                        $ArrStatusObj += $StatusObj
                                    }
                                    else{
                                        $StatusObj.id = '-'
                                        $StatusObj.type = '-'
                                        $StatusObj.title = '-'
                                        $StatusObj.requestor = '-'
                                        $StatusObj.requestorComment = '-'
                                        $StatusObj.status = "Failed"
                                        $StatusObj.machineId = '-'
                                        $StatusObj.computerDnsName = $Name
                                        $StatusObj.creationDateTimeUtc = '-'
                                        $StatusObj.lastUpdateDateTimeUtc = '-'
                                        $StatusObj.cancellationRequestor = '-'
                                        $StatusObj.cancellationComment = '-'
                                        $StatusObj.cancellationDateTimeUtc = '-'
                                        $StatusObj.relatedFileInfo = '-'
                                        $StatusObj.commands = '-'
                                        $StatusObj.troubleshootInfo = '-'

                                        $ArrStatusObj += $StatusObj
                                                
                                    }
                                }
                                else{
                                    #Ask for confirmation
                                    $Confirmation = Confirmation
                                    if($Confirmation.ToUpper() -eq 'Y'){
                                        #perform AVScan
                                        $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/runAntiVirusScan"

                                        try{
                                            $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
                                        }
                                        catch{
                                            $Status = Write-Error $Error[0]            
                                        }                        

                                        if($Status.computerDnsName -ne "-"){                                                
                                            $StatusObj.id = $Status.id
                                            $StatusObj.type = $Status.type
                                            $StatusObj.title = $Status.title
                                            $StatusObj.requestor = $Status.requestor
                                            $StatusObj.requestorComment = $Status.requestorComment
                                            $StatusObj.scope = $Status.scope
                                            $StatusObj.status = $Status.status
                                            $StatusObj.machineId = $Status.machineId
                                            $StatusObj.computerDnsName = $Status.computerDnsName
                                            $StatusObj.creationDateTimeUtc = $Status.creationDateTimeUtc
                                            $StatusObj.lastUpdateDateTimeUtc = $Status.lastUpdateDateTimeUtc
                                            $StatusObj.cancellationRequestor = $Status.cancellationRequestor
                                            $StatusObj.cancellationComment = $Status.cancellationComment
                                            $StatusObj.cancellationDateTimeUtc = $Status.cancellationDateTimeUtc
                                            $StatusObj.relatedFileInfo = $Status.relatedFileInfo
                                            $StatusObj.commands = $Status.commands
                                            $StatusObj.troubleshootInfo = $Status.troubleshootInfo

                                            $ArrStatusObj += $StatusObj
                                        }
                                        else{
                                            $StatusObj.id = '-'
                                            $StatusObj.type = '-'
                                            $StatusObj.title = '-'
                                            $StatusObj.requestor = '-'
                                            $StatusObj.requestorComment = '-'
                                            $StatusObj.status = "Failed"
                                            $StatusObj.machineId = '-'
                                            $StatusObj.computerDnsName = $Name
                                            $StatusObj.creationDateTimeUtc = '-'
                                            $StatusObj.lastUpdateDateTimeUtc = '-'
                                            $StatusObj.cancellationRequestor = '-'
                                            $StatusObj.cancellationComment = '-'
                                            $StatusObj.cancellationDateTimeUtc = '-'
                                            $StatusObj.relatedFileInfo = '-'
                                            $StatusObj.commands = '-'
                                            $StatusObj.troubleshootInfo = '-'

                                            $ArrStatusObj += $StatusObj
                                        }
                                    }
                                }
                                else{
                                    Write-Host -ForegroundColor Green "Aborting AV Scan Action of the $Name."                                    
                                }
                                }
                            }
                
                        }
                    }
                else{
                    Write-Host -ForegroundColor Red "The Path specified is incorrect."
                    break
                }
            }
            elseif($HostName -ne "unset"){
                $Name = $Hostname
                try{
                    $Device = Get-MDATPDevice -Name $Name
                    $DeviceID = $Device.id
                    if($DeviceID -match $RegExID){
                        if($Force -eq $true){
                            #perform AVScan
                            
                            Write-Host "Request AV Scan"

                            $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/runAntiVirusScan"

                                try{
                                    $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
                                }
                                catch{
                                    $Status = Write-Error $Error[0]            
                                }

                            if($Status.computerDnsName -ne "-"){
                                $StatusObj.id = $Status.id
                                $StatusObj.type = $Status.type
                                $StatusObj.title = $Status.title
                                $StatusObj.requestor = $Status.requestor
                                $StatusObj.requestorComment = $Status.requestorComment
                                $StatusObj.scope = $Status.scope
                                $StatusObj.status = $Status.status
                                $StatusObj.machineId = $Status.machineId
                                $StatusObj.computerDnsName = $Status.computerDnsName
                                $StatusObj.creationDateTimeUtc = $Status.creationDateTimeUtc
                                $StatusObj.lastUpdateDateTimeUtc = $Status.lastUpdateDateTimeUtc
                                $StatusObj.cancellationRequestor = $Status.cancellationRequestor
                                $StatusObj.cancellationComment = $Status.cancellationComment
                                $StatusObj.cancellationDateTimeUtc = $Status.cancellationDateTimeUtc
                                $StatusObj.relatedFileInfo = $Status.relatedFileInfo
                                $StatusObj.commands = $Status.commands
                                $StatusObj.troubleshootInfo = $Status.troubleshootInfo

                                $ArrStatusObj += $StatusObj
                            }
                            else{
                                $StatusObj.id = '-'
                                $StatusObj.type = '-'
                                $StatusObj.title = '-'
                                $StatusObj.requestor = '-'
                                $StatusObj.requestorComment = '-'
                                $StatusObj.status = "Failed"
                                $StatusObj.machineId = '-'
                                $StatusObj.computerDnsName = $Name
                                $StatusObj.creationDateTimeUtc = '-'
                                $StatusObj.lastUpdateDateTimeUtc = '-'
                                $StatusObj.cancellationRequestor = '-'
                                $StatusObj.cancellationComment = '-'
                                $StatusObj.cancellationDateTimeUtc = '-'
                                $StatusObj.relatedFileInfo = '-'
                                $StatusObj.commands = '-'
                                $StatusObj.troubleshootInfo = '-'

                                $ArrStatusObj += $StatusObj
                                                
                            }
                        }
                        else{
                            #Ask for confirmation
                            $Confirmation = Confirmation -Hostname $Name
                            if($Confirmation.ToUpper() -eq 'Y'){
                                #Request AV Scan

                                $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/runAntiVirusScan"

                                try{
                                    $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
                                }
                                catch{
                                    $Status = Write-Error $Error[0]            
                                }                                

                                if($Status.computerDnsName -ne "-"){
                                                
                                    $StatusObj.id = $Status.id
                                    $StatusObj.type = $Status.type
                                    $StatusObj.title = $Status.title
                                    $StatusObj.requestor = $Status.requestor
                                    $StatusObj.requestorComment = $Status.requestorComment
                                    $StatusObj.scope = $Status.scope
                                    $StatusObj.status = $Status.status
                                    $StatusObj.machineId = $Status.machineId
                                    $StatusObj.computerDnsName = $Status.computerDnsName
                                    $StatusObj.creationDateTimeUtc = $Status.creationDateTimeUtc
                                    $StatusObj.lastUpdateDateTimeUtc = $Status.lastUpdateDateTimeUtc
                                    $StatusObj.cancellationRequestor = $Status.cancellationRequestor
                                    $StatusObj.cancellationComment = $Status.cancellationComment
                                    $StatusObj.cancellationDateTimeUtc = $Status.cancellationDateTimeUtc
                                    $StatusObj.relatedFileInfo = $Status.relatedFileInfo
                                    $StatusObj.commands = $Status.commands
                                    $StatusObj.troubleshootInfo = $Status.troubleshootInfo

                                    $ArrStatusObj += $StatusObj
                                }
                                else{
                                    $StatusObj.id = '-'
                                    $StatusObj.type = '-'
                                    $StatusObj.title = '-'
                                    $StatusObj.requestor = '-'
                                    $StatusObj.requestorComment = '-'
                                    $StatusObj.status = "Failed"
                                    $StatusObj.machineId = '-'
                                    $StatusObj.computerDnsName = $Name
                                    $StatusObj.creationDateTimeUtc = '-'
                                    $StatusObj.lastUpdateDateTimeUtc = '-'
                                    $StatusObj.cancellationRequestor = '-'
                                    $StatusObj.cancellationComment = '-'
                                    $StatusObj.cancellationDateTimeUtc = '-'
                                    $StatusObj.relatedFileInfo = '-'
                                    $StatusObj.commands = '-'
                                    $StatusObj.troubleshootInfo = '-'

                                    $ArrStatusObj += $StatusObj
                                }
                            }
                            else{
                                Write-Host -ForegroundColor Green "Aborting AV Scan Action of the $Name."                            
                            }                        
                        }
                    }    
                }
                catch{

                }
            }
            elseif($HostID -ne "unset"){
                if($HostID -match $RegExID){
                    if($Force -eq $true){
                        #perform AVScan
                        
                        $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$HostID/runAntiVirusScan"

                        try{
                            $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
                        }
                        catch{
                            $Status = Write-Error $Error[0]            
                        }       
                    }
                    else{
                        #Ask for confirmation
                        $Confirmation = Confirmation -Hostname $HostID
                        if($Confirmation.ToUpper() -eq 'Y'){
                            #perform AVScan                            

                            $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$HostID/runAntiVirusScan"

                            try{
                                $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
                            }
                            catch{
                                $Status = Write-Error $Error[0]            
                            }       

                            if($Status.computerDnsName -ne "-"){
                                                
                                $StatusObj.id = $Status.id
                                $StatusObj.type = $Status.type
                                $StatusObj.title = $Status.title
                                $StatusObj.requestor = $Status.requestor
                                $StatusObj.requestorComment = $Status.requestorComment
                                $StatusObj.scope = $Status.scope
                                $StatusObj.status = $Status.status
                                $StatusObj.machineId = $Status.machineId
                                $StatusObj.computerDnsName = $Status.computerDnsName
                                $StatusObj.creationDateTimeUtc = $Status.creationDateTimeUtc
                                $StatusObj.lastUpdateDateTimeUtc = $Status.lastUpdateDateTimeUtc
                                $StatusObj.cancellationRequestor = $Status.cancellationRequestor
                                $StatusObj.cancellationComment = $Status.cancellationComment
                                $StatusObj.cancellationDateTimeUtc = $Status.cancellationDateTimeUtc
                                $StatusObj.relatedFileInfo = $Status.relatedFileInfo
                                $StatusObj.commands = $Status.commands
                                $StatusObj.troubleshootInfo = $Status.troubleshootInfo

                                $ArrStatusObj += $StatusObj
                            }
                            else{
                                $StatusObj.id = '-'
                                $StatusObj.type = '-'
                                $StatusObj.title = '-'
                                $StatusObj.requestor = '-'
                                $StatusObj.requestorComment = '-'
                                $StatusObj.status = "Failed"
                                $StatusObj.machineId = '-'
                                $StatusObj.computerDnsName = $Name
                                $StatusObj.creationDateTimeUtc = '-'
                                $StatusObj.lastUpdateDateTimeUtc = '-'
                                $StatusObj.cancellationRequestor = '-'
                                $StatusObj.cancellationComment = '-'
                                $StatusObj.cancellationDateTimeUtc = '-'
                                $StatusObj.relatedFileInfo = '-'
                                $StatusObj.commands = '-'
                                $StatusObj.troubleshootInfo = '-'

                                $ArrStatusObj += $StatusObj
                            }
                        }
                        else{
                            Write-Host -ForegroundColor Green "Aborting AV Scan Action of the $Name."                        
                        }                    
                    }
                }
                else{
                    Write-Error "Host ID format incorrect."
                }
            }
      

    #if(CheckStatus){
     #   $Pending = $false

      #  do{fddd
                

     #   }while($Pending -eq $true)

    #}

    Write-Host $ArrStatusObj
}

}

function Confirmation{
[CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [string]$Hostname
        
    )

    $Confirmation = Read-Host "Are you sure you want to Scan the device $Hostname (Y\N)."    

    Return $Confirmation
}


function AVScan{
[CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] $DeviceID,
        [parameter(Mandatory=$true)] $Body,
        [parameter(Mandatory=$true)] $Method,
        [parameter(Mandatory=$true)] $Headers
    )

        $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/runAntiVirusScan"

         

        try{
            $Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
        }
        catch{
            $Status = Write-Error $Error[0]            
        }

        Write-Output $Status

        Return $Status


}


Function CheckStatus {
[CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [string]$StatusTable
        
    )

    $method = "GET"

    $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$ID/machineactions"

    $Status = Invoke-RestMethod -Method $method -Headers $headers -Uri $Endpoint


}
