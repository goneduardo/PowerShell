@{
    RootModule = 'MDATP.psm1'
    ModuleVersion = '0.5.1'
    GUID = '6e31d7ce-20e4-4b70-b573-51825b71ef8e'
    Description = 'Provides a wrapper around the Microsoft Defender ATP REST API'

    FunctionsToExport = '*'
    CmdletsToExport = '*'
    VariablesToExport = '*'
    AliasesToExport = '*'

    PrivateData = @{
        PSData = @{
            ExternalModuleDependencies = @("MSAL.PS")
        }
    }
}
