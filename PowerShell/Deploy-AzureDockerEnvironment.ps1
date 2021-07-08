# Deploying an Docker Application to Azure.
# Dennis Khau, 4/2021

param (
    [string]$Application = "swarm-dev-eus2-001",
    [string]$Environment = "Development",
	[string]$EnvironmentAbbr = "Dev",
	[string]$Region = "East US 2",
	[string]$RegionAbbr = "EUS2",
	[string]$ResourceNo = "001",
	[string]$TagCreatedBy = "dennis@dennisdoes.net",
	[string]$TagCreatedDate,
	[string]$TagApplication = "Containers for Load Testing",
	[string]$TagProjectName = "Containers"
)

TRY
{
	if (-Not (Get-Module Az)) { Install-Module -Name Az -AllowClobber -SkipPublisherCheck -EA 'Stop' -Verbose:$FALSE }
	
	$tagCreatedDate = (Get-Date -Format "MM/dd/yyyy").ToString()
	$tags = @{"CreatedBy"="$TagCreatedBy"; "CreatedDate"="$tagCreatedDate"; "Environment"="$Environment"; "Application"="$TagApplication"; "ProjectName"="$TagProjectName" }
	
	$ResourceGroupName = "RG-$TagProjectName-$EnvironmentAbbr-$RegionAbbr-$ResourceNo"
	New-AzResourceGroup -Name "$ResourceGroupName" -Location "$Region" -Tag $tags
	
	#WIP
} CATCH {
	Write-Error $_
}