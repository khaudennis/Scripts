# Part 2 of Deploying an Azure App Service.
# Dennis Khau, 4/2021

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
	$planName = "Plan-$($Application)-$($EnvironmentAbbr)-$($RegionAbbr)-$($ResourceNo)"
	New-AzAppServicePlan -ResourceGroupName "$resourceGroupName" -Name "$planName" -Location "$Region" -Tier "Basic" -Tag $tags
	if ($?) { Write-Host "SUCCESS:  $($planName) Created" } else { throw "Failed creating app service plan" }
		
	$appName = "App-$($Application)-$($EnvironmentAbbr)-$($RegionAbbr)-$($ResourceNo)"
	New-AzWebApp -ResourceGroupName "$resourceGroupName" -Name "$appName" -Location "$Region" -AppServicePlan "$planName"
	if ($?) { Write-Host "SUCCESS:  $($appName) Created" } else { throw "Failed creating app service" }
} CATCH {
	Write-Error $_
}