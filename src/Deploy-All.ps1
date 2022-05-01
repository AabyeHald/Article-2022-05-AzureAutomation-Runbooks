<#
.SYNOPSIS
    Deploy the entire Lab/demo environment for the Automation Platform.
.DESCRIPTION
    Deploy the entire Lab/demo environment for the Automation Platform.
    THe platform contains 2 parts: The Automation Platform and the Worker deployment.

    The Automation Platform contains 2 key resources:
    1. Automation Account
    2. Log-Analytics Workspace (linked to the Automation Account)
    These 2 resources will be deployed in separate Resource Groups, with default settings.
    Diagnostics logging will be enabled on the Automation Account, putting all diagnostics into the Log-Analytics Workspace.

    The worker deployment contains:
    1. Vnet
    2. Windows 2019 servers as workers.
    The workers are installed with the MMA and Dependency agents as one would do with normal Azure based VMs.
.PARAMETER PAT
    Personal Access Token to GitHub Repo with Runbooks
.PARAMETER SubscriptionId
    The ID of the target Subscription
.PARAMETER Region
    The name of the target Region
.PARAMETER ResourceGroupNameAutomationAccount
    The Resource Group name for the Automation Account
.PARAMETER AutomationAccountName
    The name of the Automation 
.PARAMETER ResourceGroupNameLogAnalyticsWorkspace
    The Resource Group name for the Log Analytics Workspace
.PARAMETER LogAnalyticsWorkspaceName
    The name of the Log Analytics Workspace
.PARAMETER ResourceGroupNameVirtualNetwork
    The Resource Group name for the Virtual Network containing the workers
.PARAMETER LinkWorkspace
    Should we link the Workspace (Log-Analytics and Automation Account)
.PARAMETER ResourceGroupNameVirtualNetwork
    The Resource Group name for the Virtual Network containing the workers
.PARAMETER VirtualNetworkName
    The name of the Virtual Network
.PARAMETER VirtualNetworkPrefix
    The address space of the virtual network (CIDR Prefix)
.PARAMETER WorkerSubnetPrexix
    The address space for the workers subnet (CIDR Prefix)
.PARAMETER ResourceGroupNameWorker
    The Resource Group name for the workers
.PARAMETER WorkerCount
    The number of workers to deploy
.PARAMETER WorkerName
    The Virtual Machine (Worker) name, without the -001 postfix
.EXAMPLE
    $DeploymentParameters = @{
        PAT = "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"
        SubscriptionId = "cc367ab3-523d-46b2-806a-1267b35bd7ca"
        Region = "westeurope"

        ResourceGroupNameVirtualNetwork = "rg-weu-Network-demo-001"
        VirtualNetworkName = "vnet-weu-Network-demo-001"
        VirtualNetworkPrefix = "10.0.0.0/24"
        WorkerSubnetName = "snet-weu-Workers-demo-001"
        WorkerSubnetPrexix = "10.0.0.0/28"

        ResourceGroupNameWorker = "rg-weu-Workers-demo-001"
        WorkerCount = 1
        WorkerName = "worker"

        ResourceGroupNameLogAnalyticsWorkspace = "rg-weu-LoggingPlatform-demo-001"
        LogAnalyticsWorkspaceName = "law-weu-LoggingPlatform-demo-001"
        LinkWorkspace = $true

        ResourceGroupNameAutomationAccount = "rg-weu-AutomationPlatform-demo-001"
        AutomationAccountName = "aut-weu-AutomationPlatform-demo-001"

        Verbose = $true
    }

    .\src\Deploy-All.ps1 @DeploymentParameters

    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:02.9613721Z - Initializing Automation Platform deployment
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:02.9710458Z - Setting context: cc367ab3-523d-46b2-806a-1267b35bd7ca
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:06.1999464Z - Context set: cc367ab3-523d-46b2-806a-1267b35bd7ca
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:07.9227495Z - Creating Resource Group: rg-weu-AutomationPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:09.4350260Z - Creating Resource Group: rg-weu-LoggingPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:10.5642581Z - Deploying Automation Platform (Automation Account): aut-weu-AutomationPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:18.2712867Z - Should we link the Log Analytics Workspace and the Automation Account?
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:18.2782069Z - Yes, linking
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:18.2803574Z - Deploying Automation Platform (Log Analytics Workspace): rg-weu-LoggingPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:26.2893406Z - Configuring Diagnostics logging on the Automation Account: aut-weu-AutomationPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:26.6004078Z - Automation Account Resouce Id: /subscriptions/cc367ab3-523d-46b2-806a-1267b35bd7ca/resourceGroups/rg-weu-AutomationPlatform-demo-001/providers/Microsoft.Automation/automationAccounts/aut-weu-AutomationPlatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:27.4457583Z - Log-Analytics Workspace Resouce Id: /subscriptions/cc367ab3-523d-46b2-806a-1267b35bd7ca/resourcegroups/rg-weu-loggingplatform-demo-001/providers/microsoft.operationalinsights/workspaces/law-weu-loggingplatform-demo-001
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:27.4491093Z - Configuring DefaultDiagnostics
    VERBOSE: Deploy-AutomationPlatform.ps1          - 2022-04-22T15:28:36.1642648Z - CorePlatform deployment complete
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:28:36.2556654Z - Initializing Workers deployment
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:28:36.2589800Z - Setting context: cc367ab3-523d-46b2-806a-1267b35bd7ca
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:28:36.9544489Z - Context set: cc367ab3-523d-46b2-806a-1267b35bd7ca
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:28:37.2926147Z - Creating Resource Group: rg-weu-Network-demo-001
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:28:39.2500995Z - Creating Resource Group: rg-weu-Workers-demo-001
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:28:40.0672770Z - Building required subnets
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:28:40.0783405Z - Deploying Workers (Virtual Network): vnet-weu-Network-demo-001
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:28:48.1209722Z - Deploying Workers (Virtual Machines): worker
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:29:32.8081627Z - Retrieving Id and Key from Log Analytics Workspace: law-weu-LoggingPlatform-demo-001
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:29:35.0466315Z - Deploying Extensions to VM: vm-worker-1
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:31:36.9610403Z - Deploying Extensions to VM: vm-worker-2
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:33:09.1595017Z - Deploying Workers (Registering workers): worker
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:33:10.0005017Z - Generating RunCommand Script
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:33:10.2312307Z - Registering VM: vm-worker-1
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:33:10.2745058Z - Registering VM: vm-worker-2
    VERBOSE: Deploy-Workers.ps1             - 2022-04-22T15:33:10.3088000Z - Cleaning up RunCommand Script
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
    # Personal Access Token to GitHub Repo with Runbooks
    [parameter(Mandatory=$true)]
    [string]$PAT,

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

    # Should we link the Workspace (Log-Analytics and Automation Account)
    [parameter(Mandatory=$false)]
    [switch]$LinkWorkspace,

    # The Resource Group name for the Virtual Network containing the workers
    [parameter(Mandatory=$true)]
    [string]$ResourceGroupNameVirtualNetwork,

    # The name of the Virtual Network
    [parameter(Mandatory=$true)]
    [string]$VirtualNetworkName,

    # The address space of the virtual network (CIDR Prefix)
    [parameter(Mandatory=$true)]
    [string]$VirtualNetworkPrefix,

    # The address space for the workers subnet (CIDR Prefix)
    [parameter(Mandatory=$true)]
    [string]$WorkerSubnetPrexix,

    # The workers subnet name
    [parameter(Mandatory=$true)]
    [string]$WorkerSubnetName,

    # The Resource Group name for the workers
    [parameter(Mandatory=$true)]
    [string]$ResourceGroupNameWorker,

    # The number of workers to deploy
    [parameter(Mandatory=$true)]
    [int]$WorkerCount,

    # The Virtual Machine (Worker) name, without the -001 postfix
    [parameter(Mandatory=$true)]
    [string]$WorkerName
)

# Who are we and where are we?
$RootPath = Split-Path -Parent $MyInvocation.MyCommand.Source
$ScriptPath = Join-Path -Path $RootPath -ChildPath "scripts"
$TemplatePath = Join-Path -Path $RootPath -ChildPath "templates"

# Set the deployment parameters
$DeploymentParameters = @{
    TemplatePath = $TemplatePath
    SubscriptionId = $SubscriptionId
    Region = $Region

    ResourceGroupNameAutomationAccount = $ResourceGroupNameAutomationAccount
    AutomationAccountName = $AutomationAccountName

    ResourceGroupNameLogAnalyticsWorkspace = $ResourceGroupNameLogAnalyticsWorkspace
    LogAnalyticsWorkspaceName = $LogAnalyticsWorkspaceName
    LinkWorkspace = $LinkWorkspace

    Verbose = $true
}

& $ScriptPath\Deploy-AutomationPlatform.ps1 @DeploymentParameters


# Set the deployment parameters
$DeploymentParameters = @{
    TemplatePath = $TemplatePath
    SubscriptionId = $SubscriptionId
    Region = $Region

    ResourceGroupNameVirtualNetwork = $ResourceGroupNameVirtualNetwork
    VirtualNetworkName = $VirtualNetworkName
    VirtualNetworkPrefix = $VirtualNetworkPrefix
    WorkerSubnetName = $WorkerSubnetName
    WorkerSubnetPrexix = $WorkerSubnetPrexix

    ResourceGroupNameWorker = $ResourceGroupNameWorker
    WorkerCount = $WorkerCount
    WorkerName = $WorkerName

    ResourceGroupNameLogAnalyticsWorkspace = $ResourceGroupNameLogAnalyticsWorkspace
    LogAnalyticsWorkspaceName = $LogAnalyticsWorkspaceName

    ResourceGroupNameAutomationAccount = $ResourceGroupNameAutomationAccount
    AutomationAccountName = $AutomationAccountName

    Verbose = $true
}

& $ScriptPath\Deploy-Workers.ps1 @DeploymentParameters

# Configure Source Control
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Configuring Source Control"
$RepoURL = "https://github.com/AabyeHald/Article-2022-05-AzureAutomation-Runbooks.git"
$RunbookPath = "/src/runbooks"
$Branch = "main"
$AccessToken = ConvertTo-SecureString -String $PAT -AsPlainText -Force

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Granting Automation Account Contributor on own Resource Group"
$AutomationAccount = Get-AzAutomationAccount -ResourceGroupName $ResourceGroupNameAutomationAccount -Name $AutomationAccountName
$CurrentRole = Get-AzRoleAssignment -ObjectId $AutomationAccount.Identity.PrincipalId | Where-Object Scope -like $(Get-AzResourceGroup -Name $ResourceGroupNameAutomationAccount).ResourceId
if ($CurrentRole.RoleDefinitionName -ne "Contributor") {
    $null = New-AzRoleAssignment -ObjectId $AutomationAccount.Identity.PrincipalId `
        -ResourceGroupName $AutomationAccount.ResourceGroupName -RoleDefinitionName "Contributor"
}
else {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Role already exists"
}

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Linking Automation Account to git"
$null = New-AzAutomationSourceControl -Name "DemoRunbooks" -RepoUrl $RepoURL `
    -SourceType GitHub -FolderPath $RunbookPath `
    -Branch $Branch -AccessToken $AccessToken -EnableAutoSync `
    -ResourceGroupName $ResourceGroupNameAutomationAccount -AutomationAccountName $AutomationAccountName

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Starting initial sync"
$null = Start-AzAutomationSourceControlSyncJob -SourceControlName "DemoRunbooks" `
    -ResourceGroupName $ResourceGroupNameAutomationAccount -AutomationAccountName $AutomationAccountName
