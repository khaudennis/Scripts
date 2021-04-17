# Deploying Azure Resource Group, Part 1 of Deploying an Azure App Service
# Dennis Khau, 4/2021

# Connect PowerShell with Connect-AzAccount
# List Azure Subscriptions with Get-AzSubscription
# Target Azure Subscription with Set-AzContext –SubscriptionId {SubscriptionId}

param (
    [string]$Application = "HelloWorld",
    [string]$Environment = "Development",
	[string]$EnvironmentAbbr = "Dev",
	[string]$Region = "East US 2",
	[string]$RegionAbbr = "EUS2",
	[string]$ResourceNo = "001",
	[string]$TagCreatedBy = "dennis@dennisdoes.net",
	[string]$TagApplication = "Hello World Application",
	[string]$TagProjectName = "Hello World"
)

TRY
{
	if (-Not (Get-Module Az)) { Install-Module -Name Az -AllowClobber -SkipPublisherCheck -EA 'Stop' -Verbose:$FALSE }
	
	$tagCreatedDate = (Get-Date -Format "MM/dd/yyyy").ToString()
	$tags = @{"CreatedBy"="$TagCreatedBy"; "CreatedDate"="$tagCreatedDate"; "Environment"="$Environment"; "Application"="$TagApplication"; "ProjectName"="$TagProjectName" }
	
	$resourceGroupName = "RG-$($Application)-$($EnvironmentAbbr)-$($RegionAbbr)-$($ResourceNo)"
	# Get-AzResourceGroup -Name $resourceGroupName -ErrorVariable notCreated -ErrorAction SilentlyContinue
	# if ($notCreated)
	# {
		New-AzResourceGroup -Name "$resourceGroupName" -Location "$Region" -Tag $tags
		if ($?) { Write-Host "SUCCESS:  $($resourceGroupName) Created" } else { throw "Failed creating resource group" }
	# }
} CATCH {
	Write-Error $_
}