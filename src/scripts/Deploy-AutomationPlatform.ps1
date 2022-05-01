<#
.SYNOPSIS
    Deployment script for the Automation Platform.
.DESCRIPTION
    Deployment script for the Automation Platform.
    The Automation Platform contains 2 key resources:
    1. Automation Account
    2. Log-Analytics Workspace (linked to the Automation Account)
    These 2 resources will be deployed in separate Resource Groups, with default settings.
    Diagnostics logging will be enabled on the Automation Account, putting all diagnostics into the Log-Analytics Workspace.
.PARAMETER TemplatePath
    The path to the template folder
.PARAMETER SubscriptionId
    The ID of the target Subscription
.PARAMETER Region
    The name of the target Region
.PARAMETER ResourceGroupNameAutomationAccount
    The Resource Group name for the Automation Account
.PARAMETER AutomationAccountName
    The name of the Automation Account
.PARAMETER ResourceGroupNameLogAnalyticsWorkspace
    The Resource Group name for the Log Analytics Workspace
.PARAMETER LogAnalyticsWorkspaceName
    The name of the Log Analytics Workspace
.PARAMETER LinkWorkspace
    Should we link the Workspace? (Log-Analytics and Automation Account)
.EXAMPLE
    $DeploymentParameters = @{
        TemplatePath = "templates"
        SubscriptionId = "cc367ab3-523d-46b2-806a-1267b35bd7ca"
        Region = "westeurope"

        ResourceGroupNameAutomationAccount = "rg-weu-AutomationPlatform-demo-001"
        AutomationAccountName = "aut-weu-AutomationPlatform-demo-001"

        ResourceGroupNameLogAnalyticsWorkspace = "rg-weu-LoggingPlatform-demo-001"
        LogAnalyticsWorkspaceName = "law-weu-LoggingPlatform-demo-001"
        LinkWorkspace = $true

        Verbose = $true
    }
    .\scripts\Deploy-AutomationPlatform.ps1 @DeploymentParameters

    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:42:49.1642267Z - Initializing Automation Platform deployment
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:42:49.1665048Z - Setting context: cc367ab3-523d-46b2-806a-1267b35bd7ca
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:42:51.8315230Z - Context set: cc367ab3-523d-46b2-806a-1267b35bd7ca
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:42:53.4690653Z - Creating Resource Group: rg-weu-AutomationPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:42:56.0291508Z - Creating Resource Group: rg-weu-LoggingPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:42:58.3843818Z - Deploying Automation Platform (Automation Account): aut-weu-AutomationPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:43:07.6005133Z - Should we link the Log Analytics Workspace and the Automation Account?
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:43:07.6032761Z - Yes, linking
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:43:07.6062601Z - Deploying Automation Platform (Log Analytics Workspace): rg-weu-LoggingPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:43:21.9372352Z - Configuring Diagnostics logging on the Automation Account: aut-weu-AutomationPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:43:22.8597678Z - Automation Account Resouce Id: /subscriptions/cc367ab3-523d-46b2-806a-1267b35bd7ca/resourceGroups/rg-weu-AutomationPlatform-demo-001/providers/Microsoft.Automation/automationAccounts/aut-weu-AutomationPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:43:24.4986033Z - Log-Analytics Workspace Resouce Id: /subscriptions/cc367ab3-523d-46b2-806a-1267b35bd7ca/resourcegroups/rg-weu-loggingplatform-demo-001/providers/microsoft.operationalinsights/workspaces/law-weu-loggingplatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:43:24.5013550Z - Configuring DefaultDiagnostics
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-17T14:43:33.1235187Z - CorePlatform deployment complete
.INPUTS
    None. This function does not accept pipeline inputs.
.OUTPUTS
    None, unless -Verbose switch is added.
.NOTES
    Tested using:
    - PowerShell Core 7.2.2
    - Modules: Az (version 7.4.0)
#>
param (
    # The path to the template folder
    [parameter(Mandatory=$true)]
    [string]$TemplatePath,

    # The ID of the target Subscription
    [parameter(Mandatory=$true)]
    [string]$SubscriptionId,

    # The name of the target Region
    [parameter(Mandatory=$true)]
    [string]$Region,

    # The Resource Group name for the Automation Account
    [parameter(Mandatory=$true)]
    [string]$ResourceGroupNameAutomationAccount,

    # The name of the Automation Account
    [parameter(Mandatory=$true)]
    [string]$AutomationAccountName,

    # The Resource Group name for the Log Analytics Workspace
    [parameter(Mandatory=$true)]
    [string]$ResourceGroupNameLogAnalyticsWorkspace,

    # The name of the Log Analytics Workspace
    [parameter(Mandatory=$true)]
    [string]$LogAnalyticsWorkspaceName,

    # Should we link the Workspace? (Log-Analytics and Automation Account)
    [parameter(Mandatory=$false)]
    [switch]$LinkWorkspace
)

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Initializing Automation Platform deployment"

# Set the correct context
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Setting context: $SubscriptionId"
$null = Set-AzContext -SubscriptionId $SubscriptionId
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Context set: $((Get-AzContext | Select-Object Subscription).Subscription)"

# Create Resource Groups if they do not exist
$null = Get-AzResourceGroup -Name $ResourceGroupNameAutomationAccount -ErrorVariable NotPresent -ErrorAction SilentlyContinue
if ($NotPresent) {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Creating Resource Group: $ResourceGroupNameAutomationAccount"
    $null = New-AzResourceGroup -Name $ResourceGroupNameAutomationAccount -Location $Region -Verbose:$false
}
else {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Resource Group Exists: $ResourceGroupNameAutomationAccount"
}

$null = Get-AzResourceGroup -Name $ResourceGroupNameLogAnalyticsWorkspace -ErrorVariable NotPresent -ErrorAction SilentlyContinue
if ($NotPresent) {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Creating Resource Group: $ResourceGroupNameLogAnalyticsWorkspace"
    $null = New-AzResourceGroup -Name $ResourceGroupNameLogAnalyticsWorkspace -Location $Region -Verbose:$false
}
else {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Resource Group Exists: $ResourceGroupNameLogAnalyticsWorkspace"
}

# Deploy the Automation Account
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Deploying Automation Platform (Automation Account): $AutomationAccountName"
$null = New-AzResourceGroupDeployment -Name "AutomationPlatform-Aut" -ResourceGroupName $ResourceGroupNameAutomationAccount `
        -Mode Complete -TemplateFile "$TemplatePath\AutomationPlatform\AutomationAccount.json" `
        -AutomationAccountName $AutomationAccountName -Force -Verbose:$false

# Deploy the Log Analytics Workspace
# Handle potential linking of workspace
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Should we link the Log Analytics Workspace and the Automation Account?"
if ($LinkWorkspace) {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Yes, linking"
    $AutomationAccountNameParameter = $AutomationAccountName
}
else {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - No, not linking"
    $AutomationAccountNameParameter = ""
}

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Deploying Automation Platform (Log Analytics Workspace): $ResourceGroupNameLogAnalyticsWorkspace"
$null = New-AzResourceGroupDeployment -Name "AutomationPlatform-Law" -ResourceGroupName $ResourceGroupNameLogAnalyticsWorkspace `
        -Mode Complete -TemplateFile "$TemplatePath\AutomationPlatform\LogAnalyticsWorkspace.json" `
        -LogAnalyticsWorkspaceName $LogAnalyticsWorkspaceName `
        -ResourceGroupNameAutomationAccount $ResourceGroupNameAutomationAccount `
        -AutomationAccountName $AutomationAccountNameParameter -Force -Verbose:$false
        
# Configure Diagnostics logging for the Automation Account
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Configuring Diagnostics logging on the Automation Account: $AutomationAccountName"

$AutomationAccountId = $(Get-AzResource -Name $AutomationAccountName -ResourceGroupName $ResourceGroupNameAutomationAccount).ResourceId
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Automation Account Resouce Id: $AutomationAccountId"

$LogAnalyticsWorkspaceId = $(Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupNameLogAnalyticsWorkspace -Name $LogAnalyticsWorkspaceName).ResourceId
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Log-Analytics Workspace Resouce Id: $LogAnalyticsWorkspaceId"

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Configuring DefaultDiagnostics"
$null = Set-AzDiagnosticSetting -ResourceId $AutomationAccountId -WorkspaceId $LogAnalyticsWorkspaceId -Name "DefaultDiagnostics" -Enabled $true -EnableMetrics $true
$null = Set-AzDiagnosticSetting -ResourceId $AutomationAccountId -WorkspaceId $LogAnalyticsWorkspaceId -Name "DefaultDiagnostics" -Enabled $true -Category JobLogs,JobStreams,DscNodeStatus

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - CorePlatform deployment complete"