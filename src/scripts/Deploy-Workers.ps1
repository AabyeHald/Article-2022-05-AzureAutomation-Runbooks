<#
.SYNOPSIS
    Deployment script for the workers.
.DESCRIPTION
    Deployment script for the workers.
    The worker deployment contains:
    1. Vnet
    2. Windows 2019 servers as workers.
    The workers are installed with the MMA and Dependency agents as one would do with normal Azure based VMs.
.PARAMETER TemplatePath
    The path to the template folder
.PARAMETER SubscriptionId
    The ID of the target Subscription
.PARAMETER Region
    The name of the target Region
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
.PARAMETER ResourceGroupNameLogAnalyticsWorkspace
    The Resource Group name for the Log Analytics Workspace
.PARAMETER LogAnalyticsWorkspaceName
    The name of the Log Analytics Workspace
.PARAMETER ResourceGroupNameAutomationAccount
    The Resource Group name for the Automation Account
.PARAMETER AutomationAccountName
    The name of the Automation Account
.EXAMPLE
    $DeploymentParameters = @{
        TemplatePath = "templates"
        SubscriptionId = "cc367ab3-523d-46b2-806a-1267b35bd7ca"
        Region = "westeurope"

        ResourceGroupNameVirtualNetwork = "rg-weu-Network-demo-001"
        VirtualNetworkName = "vnet-weu-Network-demo-001"
        VirtualNetworkPrefix = "10.0.0.0/24"
        WorkerSubnetName = "snet-weu-Workers-demo-001"
        WorkerSubnetPrexix = "10.0.0.0/28"

        ResourceGroupNameWorker = "rg-weu-Workers-demo-001"
        WorkerCount = 2
        WorkerName = "worker"

        ResourceGroupNameLogAnalyticsWorkspace = "rg-weu-LoggingPlatform-demo-001"
        LogAnalyticsWorkspaceName = "law-weu-LoggingPlatform-demo-001"

        ResourceGroupNameAutomationAccount = "rg-weu-AutomationPlatform-demo-001"
        AutomationAccountName = "aut-weu-AutomationPlatform-demo-001"

        Verbose = $true
    }

    & $ScriptPath\Deploy-Workers.ps1 @DeploymentParameters

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
    # The path to the template folder
    [parameter(Mandatory=$true)]
    [string]$TemplatePath,
    
    # The ID of the target Subscription
    [parameter(Mandatory=$true)]
    [string]$SubscriptionId,

    # The name of the target Region
    [parameter(Mandatory=$true)]
    [string]$Region,

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
    [string]$WorkerName,

    # The Resource Group name for the Log Analytics Workspace
    [parameter(Mandatory=$true)]
    [string]$ResourceGroupNameLogAnalyticsWorkspace,

    # The name of the Log Analytics Workspace
    [parameter(Mandatory=$true)]
    [string]$LogAnalyticsWorkspaceName,

    # The Resource Group name for the Automation Account
    [parameter(Mandatory=$true)]
    [string]$ResourceGroupNameAutomationAccount,

    # The name of the Automation Account
    [parameter(Mandatory=$true)]
    [string]$AutomationAccountName
)

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Initializing Workers deployment"

# Set the correct context
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Setting context: $SubscriptionId"
$null = Set-AzContext -SubscriptionId $SubscriptionId
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Context set: $((Get-AzContext | Select-Object Subscription).Subscription)"

# Create Resource Groups if they do not exist
# Create resource group for virtual network
$null = Get-AzResourceGroup -Name $ResourceGroupNameVirtualNetwork -ErrorVariable NotPresent -ErrorAction SilentlyContinue
if ($NotPresent) {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Creating Resource Group: $ResourceGroupNameVirtualNetwork"
    $null = New-AzResourceGroup -Name $ResourceGroupNameVirtualNetwork -Location $Region -Verbose:$false
}
else {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Resource Group Exists: $ResourceGroupNameVirtualNetwork"
}

# Create resource group for workers
if ($WorkerCount -gt 0) {
    $null = Get-AzResourceGroup -Name $ResourceGroupNameWorker -ErrorVariable NotPresent -ErrorAction SilentlyContinue
    if ($NotPresent) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Creating Resource Group: $ResourceGroupNameWorker"
        $null = New-AzResourceGroup -Name $ResourceGroupNameWorker -Location $Region -Verbose:$false
    }
    else {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Resource Group Exists: $ResourceGroupNameWorker"
    }
}
else {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - No workers to deploy - so no resource group created"
}

# Deploy the Virtual Network
Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Building required subnets"
[System.Collections.ArrayList]$Subnets = @()

# If are to deploy workers, then create the subnet hashtable
if ($WorkerCount -gt 0) {
    $null = $Subnets.Add(@{
        Name = $WorkerSubnetName
        AddressPrefix = $WorkerSubnetPrexix
    })
}

Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Deploying Workers (Virtual Network): $VirtualNetworkName"
$null = New-AzResourceGroupDeployment -Name "Workers-VNet" -ResourceGroupName $ResourceGroupNameVirtualNetwork `
        -Mode Complete -TemplateFile "$TemplatePath\Workers\VirtualNetwork.json" `
        -VirtualNetworkName $VirtualNetworkName -VirtualNetworkPrefix $VirtualNetworkPrefix `
        -Subnets $Subnets -Force -Verbose:$false

# Deploy the Virtual Machine workers
if ($WorkerCount -gt 0) {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Deploying Workers (Virtual Machines): $WorkerName"
    $null = New-AzResourceGroupDeployment -Name "Workers-VM" -ResourceGroupName $ResourceGroupNameWorker `
            -Mode Complete -TemplateFile "$TemplatePath\Workers\VirtualMachine-Windows.json" `
            -VirtualMachineName $WorkerName -VirtualMachineCount $WorkerCount `
            -ResourceGroupNameVirtualNetwork $ResourceGroupNameVirtualNetwork -VirtualNetworkName $VirtualNetworkName -VirtualMachineSubnetName $WorkerSubnetName `
            -Force -Verbose:$false
    
    # Deploy the MMA and Dependency extensions on the VMs
    # Get the Log Analytics Workspace Id and Key
    $LogAnalyticsWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupNameLogAnalyticsWorkspace -Name $LogAnalyticsWorkspaceName
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Retrieving Id and Key from Log Analytics Workspace: $($LogAnalyticsWorkspace.Name)"
    $LogAnalyticsWorkspaceId = @{
        workspaceId = $LogAnalyticsWorkspace.CustomerId
    }
    $LogAnalyticsWorkspaceKey = @{
        workspaceKey = $(Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $ResourceGroupNameLogAnalyticsWorkspace -Name $LogAnalyticsWorkspace.Name).PrimarySharedKey
    }

    # Loop all Virtual Machines in resource group and deploy extensions
    foreach ($VM in Get-AzVM -ResourceGroupName $ResourceGroupNameWorker) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Deploying Extensions to VM: $($VM.Name)"
        $null = Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" `
            -ResourceGroupName $VM.ResourceGroupName -VMName $VM.Name `
            -Publisher "Microsoft.EnterpriseCloud.Monitoring" `
            -ExtensionType "MicrosoftMonitoringAgent" `
            -TypeHandlerVersion 1.0 `
            -Settings $LogAnalyticsWorkspaceId `
            -ProtectedSettings $LogAnalyticsWorkspaceKey `
            -Location $Region
        $null = Set-AzVMExtension -ExtensionName "Microsoft.Azure.Monitoring.DependencyAgent" `
            -ResourceGroupName $VM.ResourceGroupName -VMName $VM.Name `
            -Publisher "Microsoft.Azure.Monitoring.DependencyAgent" `
            -ExtensionType "DependencyAgentWindows" `
            -TypeHandlerVersion 9.5 `
            -Location $Region `
            -EnableAutomaticUpgrade $true `
            -AsJob
    }
}
else {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - No workers to deploy - so none deployed"
}

# Register the Virtual Machine workers
if ($WorkerCount -gt 0) {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Deploying Workers (Registering workers): $WorkerName"
    $RegistrationInfo = Get-AzAutomationRegistrationInfo -ResourceGroupName $ResourceGroupNameAutomationAccount -AutomationAccountName $AutomationAccountName

    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Generating RunCommand Script"
@"
Import-Module "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\7.3.1417.0\HybridRegistration\HybridRegistration.psd1"
Add-HybridRunbookWorker -GroupName "HybridWorkers" -Url $($RegistrationInfo.Endpoint) -Key $($RegistrationInfo.PrimaryKey)
"@ | Out-File Script.ps1

    foreach ($VM in Get-AzVM -ResourceGroupName $ResourceGroupNameWorker) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Registering VM: $($VM.Name)"
        $null = Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupNameWorker -VMName $VM.Name `
            -ScriptPath ".\Script.ps1" -CommandId "RunPowerShellScript" -AsJob
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) `t`t- $(Get-Date -Format o -AsUTC) - Cleaning up RunCommand Script"
    Remove-Item ".\Script.ps1" -Force
}
