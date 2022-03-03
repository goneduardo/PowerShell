function MDATPIsolateDevice {
    <#
    .SYNOPSIS
        Wirtten by: EMG - Eduardo Gonzalez
        Version: 1
        Date: 01-Apr-2021

        The script Isolates a Device 
           
    .DESCRIPTION

        
    .EXAMPLE 
       

    .EXAMPLE
        

    .EXAMPLE
        
    #>

[CmdletBinding()]
    param(
        [parameter(ParameterSetName="HostName")] [string]$HostName='unset',
        [parameter(ParameterSetName="HostID")] [string]$HostID = 'unset',
        [parameter(ParameterSetName="List")][string]$ListPath = 'unset',
        [parameter(ParameterSetName="List",Mandatory=$true)][ValidateSet("ComputerName","ComputerID")][string]$ListContentType='unset',
        [parameter(Mandatory=$true)][string] $Comment='unset',
        [parameter(Mandatory=$true)][ValidateSet("Full","Selective")][string] $IsolationType='Selective',
        [parameter(Mandatory=$false)][switch]$Force,
        [parameter(Mandatory=$false)][switch]$CheckStatus   

    )

    Begin {
        if(Get-Module | Where-Object{$_.name -eq 'MDATP'}){
            Connect-MDATP
        }
        else{
            Write-Host "MDATP was not loaded."
        }

        $Method = 'POST'
       
        $Body = @{Comment=$Comment;IsolationType=$IsolationType} | ConvertTo-Json

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
        $StatusTable = @{}
    }

    Process {
        
            if($ListPath -ne "unset"){
                if(Test-Path($ListPath)){                
                    if($ListContentType -eq 'ComputerName'){
                        Get-Content $ListPath | % {
                            #retrieve id
                            $Name = $_
                            try{                            
                                $Device = Get-MDATPDevice -Name $Name
                                $DeviceID = $Device.id
                                    if($DeviceID -match $RegExID){
                                        if($Force -eq $true){
                                            #perform isolation
                                            $Status =  Isolate -DeviceID $DeviceID, Body $Body, Method $Method -Headers $Headers

                                            if($Status.computerDnsName -ne ""){
                                                $StatusTable.Add($Name, $status.value[0])
                                            }
                                            else{
                                                $StatusTable.Add("$Name", "Failed")
                                            }
                                        }
                                        else{
                                            #Ask for confirmation
                                            $Confirmation = Confirmation -Hostname $Name
                                            if($Confirmation.ToUpper() -eq 'Y'){
                                                #perform isolation
                                                $Status = Isolate -DeviceID $DeviceID, Body $Body, Method $Method -Headers $Headers

                                                if($Status.computerDnsName -ne ""){
                                                
                                                    $StatusTable.Add($Name, $status.value[0])
                                                }
                                                else{
                                                    $StatusTable.Add("$Name", "Failed")
                                                }
                                            }
                                            else{
                                                Write-Host -ForegroundColor Green "Aborting Isolation Action of the $Name."                                            
                                            }
                                        }
                                    }
                                }
                                catch{
                                    Write-Host -ForegroundColor Red "Could not retrieve the ID the host $_."
                                    Write-Host -ForegroundColor Red $Error[0]
                                }                        
                            }
                    }
                    elseif($ListContentType -eq 'ComputerID'){
                        Get-Content $ListPath | % {
                            $DeviceID = $_
                            if($DeviceID -match $RegExID){  #check the ID
                                if($Force -eq $true){
                                    #"perform the isolation"
                                    $Status = Isolate -DeviceID $DeviceID, Body $Body, Method $Method -Headers $Headers

                                    if($Status.computerDnsName -ne ""){
                                        $StatusTable.Add($Name, $status.value[0])
                                    }
                                    else{
                                        $StatusTable.Add("$Name", "Failed")
                                    }
                                }
                                else{
                                    #Ask for confirmation
                                    $Confirmation = Confirmation
                                    if($Confirmation.ToUpper() -eq 'Y'){
                                        #perform isolation
                                        $Status = Isolate -DeviceID $DeviceID, Body $Body, Method $Method -Headers $Headers

                                        if($Status.computerDnsName -ne ""){
                                            $StatusTable.Add($Name, $status.value[0])
                                        }
                                        else{
                                            $StatusTable.Add("$Name", "Failed")
                                        }
                                    }
                                    else{
                                        Write-Host -ForegroundColor Green "Aborting Isolation Action of the $Name."                                    
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
                            #perform isolation
                            $Status = Isolate -DeviceID $DeviceID, Body $Body, Method $Method -Headers $Headers

                            if($Status.computerDnsName -ne ""){
                                $StatusTable.Add($Name, $status.value[0])
                            }
                            else{
                                $StatusTable.Add("$Name", "Failed")
                            }
                        }
                        else{
                            #Ask for confirmation
                            $Confirmation = Confirmation
                            if($Confirmation.ToUpper() -eq 'Y'){
                                #perform isolation
                                $Status = Isolate -DeviceID $DeviceID, Body $Body, Method $Method -Headers $Headers

                                if($Status.computerDnsName -ne ""){
                                    $StatusTable.Add($Name, $status.value[0])
                                }
                                else{
                                    $StatusTable.Add("$Name", "Failed")
                                }
                            }
                            else{
                                Write-Host -ForegroundColor Green "Aborting Isolation Action of the $Name."                            
                            }                        
                        }
                    }    
                }
                catch{

                }
            }
            elseif($ID -ne "unset"){
                if($DeviceID -match $RegExID){
                    if($Force -eq $true){
                        #perform isolation
                        $Status = Isolate -DeviceID $DeviceID, Body $Body, Method $Method -Headers $Headers
                    }
                    else{
                        #Ask for confirmation
                        $Confirmation = Confirmation
                        if($Confirmation.ToUpper() -eq 'Y'){
                            #perform isolation
                            $Status = Isolate -DeviceID $DeviceID, Body $Body, Method $Method -Headers $Headers

                            if($Status.computerDnsName -ne ""){
                                $StatusTable.Add($Name, $status.value[0])
                            }
                            else{
                                $StatusTable.Add("$Name", "Failed")
                            }
                        }
                        else{
                            Write-Host -ForegroundColor Green "Aborting Isolation Action of the $Name."                        
                        }                    
                    }
                }
                else{
                    Write-Error 
                }
            }
        }
    }
}


function Confirmation{
[CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [string]$Hostname
        
    )

    $Confirmation = Read-Host "Are you sure you want to isolate the device $Hostname (Y\N)."    

    Return $Confirmation
}


function Isolate{
[CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [string]$DeviceID,
        [parameter(Mandatory=$true)] [string]$Body,
        [parameter(Mandatory=$true)] [string]$Method,
        [parameter(Mandatory=$true)] [string]$Headers
    )

        $Endpoint = "https://api-eu.securitycenter.windows.com/api/machines/$DeviceID/isolate"

        try{
            #$Status = Invoke-RestMethod -Method $Method -Headers $Headers -Uri $Endpoint -Body $Body
        }
        catch{
            $Status = Write-Error $Error[0]            
        }

        Return $Status


}


Function CheckStatus {
[CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [string]$StatusTable
        
    )


}


#Import-Module "C:\Program Files\WindowsPowerShell\Modules\MDATP\0.5.1\MDATP.psm1"