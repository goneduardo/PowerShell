Function Connect-MDATP {
    #Import-Module MSAL.PS
     Import-Module C:\Tools\__PowerShell\msal.ps.4.2.1.1\MSAL.PS.psd1
    # Tutorial: https://blog.kloud.com.au/2019/10/31/microsoft-graph-using-msal-with-powershell/

    $Arguments = @{
        ClientID = "9815a1af-9ae0-429b-b7c4-1eb476505c94"
        TenantID = "4341df80-fbe6-41bf-89b0-e6e2379c9c23"
        Scopes = @("https://securitycenter.microsoft.com/mtp/.default")
    }

    $Session = Get-MsalToken @Arguments
    Set-Variable -Scope Global -Name MDATPSession -Value $Session
}
