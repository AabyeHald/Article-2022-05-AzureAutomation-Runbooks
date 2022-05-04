# Azure Automation - Runbooks (Lab/Demo Environment)
[![GitHub](https://img.shields.io/github/license/AabyeHald/Article-2022-05-AzureAutomation-Runbooks?style=plastic)](https://github.com/AabyeHald/Article-2022-05-AzureAutomation-Runbooks/blob/main/LICENSE)

This is a very simple automation platform, based on Azure Automation and Log-Analytics. This type of platform is in my mind central for operating Azure at any kind of scale - hence it is essential to fully understand what it can do, which in engineering terms means kicking some tires and getting the hands dirty.

This repository is accompanied by the article: [Azure Automation - Runbooks](https://blog.aabyehald.com/article/Azure-Automation-Runbooks/) - Not published yet

In this README, it is enough to state that the deployed platform contains the following components:

**Automation Platform**
- Automation Account
- Log-Analytics Workspace, linked to the Automation Account

**Workers**
- Virtual Network
- One or more Hybrid Workers, based on Windows Server 2019
- MMA agent extensions are used instead of AMA agent extensions, as the AMA agents does not yet (at this time) support VMInsights.

## Prerequisites
The following prerequisites needs to be met before the repository can be used:

- PowerShell Core (Should work with PowerShell 5.x, but not tested)
- PowerShell Module: Az (Az.Resources, Az.Accounts, Az.Compute)
- Azure Subscription
- User Account assigned the RBAC Owner role on the Azure Subscription
- GitHub account and PAT with the correct [permissions](https://docs.microsoft.com/en-us/azure/automation/source-control-integration#personal-access-token-pat-permissions)

## Howto Deploy
If the prerequisites are met, the actual deployment should be easy.

Clone this repository to a repository in your own GitHub Account, this will provide the "backend" for the Source Control, then make a copy of the repository available locally for script execution.

Building a parameter object with all the input parameters, then run the script. Only the PAT and RepoURL are required to be changed to match you environment.<br>
Assuming you are in the ```src``` folder and that you have a connected terminal (using ```Connect-AzAccount```), this is how to deploy:

```
$DeploymentParameters = @{
    PAT = "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"
    RepoURL = "https://github.com/AabyeHald/Article-2022-05-AzureAutomation-Runbooks.git"

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

.\Deploy-All.ps1 @DeploymentParameters
```

Depending on your choice of parameters, after the script execution has completed, you will end up with 4 Resource Groups in the targeted subscription.

# Filestructure
```
Article-2022-05-AzureAutomation-Runbooks
│   LICENSE
│   README.md
│   
├───build                                       # Build script folder
│       build.wiki.ps1                          # Script to build the wiki
│       
└───src                                         # Sourcecode folder
    │   Deploy-All.ps1                          # Deploy all script, that uses the other deployment scripts for deployment
    │   
    ├───runbooks                                # Runbook folder, contents to be synced to Azure Automation Account
    │       DemoRunbook.ps1
    │       
    ├───scripts                                 # Deployment scripts
    │       Deploy-AutomationPlatform.ps1       # Deployment script for the Azure based Automation Platform
    │       Deploy-Workers.ps1                  # Deployment script for the Hybrid Workers
    │
    └───templates                               # ARM template folder
        ├───AutomationPlatform                  # ARM templates for the Azure based Automation Platform
        │       AutomationAccount.json
        │       LogAnalyticsWorkspace.json
        │
        └───Workers                             # ARM templates for the Hybrid Workers
                VirtualMachine-Windows.json
                VirtualNetwork.json
```