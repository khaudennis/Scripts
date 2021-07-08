# Deploys a web app from source to destination by moving files.
# This script DOES NOT CREATE AN IIS WEB APPLICATION.
# Dennis Khau, 4/2019

param (
    [string]$Source,
    [string]$Destination,
    [switch]$IsNodeApp = $FALSE
)

$excludeExt = @('*.pdb','*.config')

TRY
{
    if (-Not (Get-Module WebAdministration)) { Import-Module -Name WebAdministration -EA 'Stop' -Verbose:$FALSE }
    if (-Not (([string]::IsNullOrEmpty($Source)) -Or ([string]::IsNullOrEmpty($Destination))))
    {
        if ($IsNodeApp -eq $TRUE)
        {
            $checkIISnode = Test-Path "C:\Program Files (x86)\iisnode\iisnode.dll" -PathType Leaf
            $checkNode = node -v

            if ((($checkIISnode -eq $FALSE) -Or ([string]::IsNullOrEmpty($checkNode))))
            {
                throw "IISnode or NodeJS not found. Please verify both applications are installed before continuing."
            }
        }

        Get-ChildItem $Source -Recurse -Exclude $excludeExt | Copy-Item -Destination { Join-Path $Destination $_.FullName.Substring($Source.length) }
        if ($?) { Write-Host "SUCCESS:  Moved $Source to $Destination Successfully" } else { throw "Error Encountered" }

        if ($IsNodeApp –eq $TRUE)
        {		
		    cd $Destination
		    npm i
		    if ($?) { Write-Host "SUCCESS:  NPM Packages Installed" } else { throw "Error Encountered" }
            
            $configPath = "$Destination\Web.config"
            if (Test-Path $configPath -PathType Leaf)
            {    
                $xml = [xml](Get-Content $configPath)
                $select = Select-Xml -Xml $xml -XPath "//configuration/system.webServer/iisnode" | Select-Object –ExpandProperty Node                
                #Write-Output $select.nodeProcessCommandLine
                if (([string]::IsNullOrEmpty($select.nodeProcessCommandLine)))
                {
                    Write-Host "nodeProcessCommandLine not declared. Adding to Web.config..."
                }
            } else {
                throw "Web.config not found!"
            }
        }
    } else {
        throw "Required Parameter Missing"
    }
} CATCH {
    Write-Error $_
}
