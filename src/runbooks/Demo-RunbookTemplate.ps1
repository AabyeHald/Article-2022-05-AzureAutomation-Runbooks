    <#
    .SYNOPSIS
        Template Runbook for use with the Azure Resource Manager API.
    .DESCRIPTION
        Template Runbook for use with the Azure Resource Manager API.
        The included functionality is:
        - Setting the Verbose preference to "Continue", so the runbook will not squawk during normal operations.
        - Disable credential caching, avoiding potential concurrency issues.
        - Handle local and Azure execution.
        - Authenticate using Azure Service Principal, Managed Identity or if executed locally normal User Credentials.
        - Handle authentication or connection related errors as stopping errors.
    .PARAMETER ConnectionName
        Use this Azure Automation Connection, requires connection and SPN configuration
    .INPUTS
        None. This function does not accept pipeline inputs.
    .OUTPUTS
        None, unless -Verbose switch is added.
    .NOTES
        Tested using:
        - PowerShell Core 7.2.3
        - Modules: Az (version 7.4.0)
    #>
    param (
        # Use this Azure Automation Connection, requires connection and SPN configuration
        [parameter(Mandatory=$false)]
        [string]$ConnectionName
    )
    # Set the Verbose preference - this will make the script stay silent when run as Runbook
    $VerbosePreference = "Continue"

    # Make all errors terminating, unless otherwise specified individually
    $ErrorActionPreference = "Stop"

    # Make sure context is scoped to process
    Write-Verbose -Message "$(Get-Date -Format FileDateTimeUniversal) `t- Initializing Runbook, disabling credential caching"
    $null = Disable-AzContextAutosave -Scope Process

    # Figure out if we are running in Azure Automation and connect accordingly
    Write-Verbose -Message "$(Get-Date -Format FileDateTimeUniversal) `t- Connect to Azure Resource Manager"
    if ($PSPrivateMetadata.JobId.Guid) {
        # We are in Azure Automation
        Write-Verbose -Message "$(Get-Date -Format FileDateTimeUniversal) `t- We are running in Azure Automation"
        if ($ConnectionName) {
            # Connect using Azure Automation Connection
            Write-Verbose -Message "$(Get-Date -Format FileDateTimeUniversal) `t- Retrieve connection $ConnectionName"
            $Connection = Get-AutomationConnection -Name $ConnectionName
            Write-Verbose -Message "$(Get-Date -Format FileDateTimeUniversal) `t- Connecting to Azure tenant: $($Connection.TenantID)"
            $null = Connect-AzAccount -ServicePrincipal `
                -Tenant $Connection.TenantID `
                -ApplicationId $Connection.ApplicationID `
                -CertificateThumbprint $Connection.CertificateThumbprint    
        }
        else {
            # Connect using Azure Automation Managed Identity
            Write-Verbose -Message "$(Get-Date -Format FileDateTimeUniversal) `t- Connect using Managed Identity"
            $null = Connect-AzAccount -Identity
        }
    }
    else {
        # We are local - make sure we have a connection
        Write-Verbose -Message "$(Get-Date -Format FileDateTimeUniversal) `t- We are running local"
        $null = Get-AzAccessToken -ErrorVariable ResultError -ErrorAction SilentlyContinue
        if ($ResultError) {
            Write-Verbose -Message "$(Get-Date -Format FileDateTimeUniversal) `t- We do not have a connection, fix that"
            $null = Connect-AzAccount
        }
    }