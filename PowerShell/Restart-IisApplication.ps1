# Restarts a web application in IIS.
# Dennis Khau, X/2018

param (
    [string]$Site,
    [string]$Pool = ""
)

TRY
{
    if (-Not (Get-Module WebAdministration)) { Import-Module -Name WebAdministration -EA 'Stop' -Verbose:$FALSE }
	$Pool = (Get-Item "IIS:\Sites\$Site"| Select-Object applicationPool).applicationPool
	Restart-WebAppPool $Pool
	Stop-WebSite $Site
	Start-WebSite $Site
} CATCH {
	Write-Error $_
}