# This script create the initial web application and application pool in IIS.
# Includes setting log path instead of default W3SVCXXX, create network shares and assigns ACL/permissions.
# Dennis Khau, 1/2019

param (
    [switch]$IsNodeApp = $FALSE,
    [string]$NodeRootFile = "app.js",
    [string]$Server,
    [string]$AppName,
    [string]$HostHeader = "",
    [Int32]$Port = 80
)

TRY
{
    if (-Not (Get-Module WebAdministration)) { Import-Module -Name WebAdministration -EA 'Stop' -Verbose:$FALSE }
    if (-Not (([string]::IsNullOrEmpty($Server)) -Or ([string]::IsNullOrEmpty($AppName))))
    {
        ### DO NOT MODIFY ###
        $rootDrive = "E:\"
        $rootAppDirectory = $rootDrive + $AppName
        $appDirectory =  $rootDrive + $AppName + "\" + "Wwwroot\"
        $logDirectory = $rootDrive + "LogFiles\" + $AppName

	    if ($IsNodeApp -eq $TRUE)
        {
            $checkIISnode = Test-Path "C:\Program Files (x86)\iisnode\iisnode.dll" -PathType Leaf
            $checkNode = node -v

            if ((($checkIISnode -eq $FALSE) -Or ([string]::IsNullOrEmpty($checkNode))))
            {
                throw "IISnode or NodeJS not found. Please verify both applications are installed before continuing."
                # TODO:  Download and install IISnode and NodeJS
            }
        }

        # Create application directory in FS
        New-Item -ItemType directory -Path $appDirectory
	    if ($?) { Write-Host "SUCCESS:  $appDirectory Created" } else { throw "Error Encountered" }
	
	    if (Get-SMBShare -Name $AppName -ea 0) { Remove-SmbShare -Name $AppName -Force }
        New-SMBShare -Name $AppName -Path $rootAppDirectory –FullAccess "Admins" -ChangeAccess "Developers"
	    if ($?) { Write-Host "SUCCESS:  SMB Share Created" } else { throw "Error Encountered" }

	    # Create and configure application in IIS
	    if (-Not (Test-Path IIS:\AppPools\$AppName))
		{
			New-WebAppPool $AppName -Force
			if ($?) { Write-Host "SUCCESS:  IIS Web Application Pool $AppName Created" } else { throw "Error Encountered" }
		} else { Write-Host "SUCCESS:  IIS Web Application Pool $AppName Exists" }
	
		if (-Not (Test-Path IIS:\Sites\$AppName))
		{
			New-WebSite -Name $AppName -PhysicalPath $appDirectory -ApplicationPool $AppName -HostHeader $HostHeader -Port $Port -Force
			if ($?) { Write-Host "SUCCESS:  IIS $AppName Created" } else { throw "Error Encountered" }
		} else { Write-Host "SUCCESS:  IIS $AppName Exists" }
		
	    ### UNTESTED ###
        # Create handler mapping for IISNode (NodeJS apps only)
        if ($IsNodeApp –eq $TRUE)
        {
			# TODO:  Still needs work...
            #New-WebHandler -Name "iisnode" -Path $NodeRootFile -Modules iisnode -PSPath $AppName
		    #if ($?) { Write-Host "SUCCESS:  IIS Handler Module Created" } else { throw "Error Encountered" }
		
		    cd $appDirectory
		    npm i
		    if ($?) { Write-Host "SUCCESS:  NPM Packages Installed" } else { throw "Error Encountered" }
        }

        # Set application directory permissions
        $acl = Get-Acl $rootAppDirectory
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS AppPool\$AppName", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($AccessRule)
        $acl | Set-Acl -Path $rootAppDirectory
	    if ($?) { Write-Host "SUCCESS:  ACL $rootAppDirectory Created" } else { throw "Error Encountered" }
    
	    # Set default log directory
        Set-ItemProperty "IIS:\Sites\$AppName" -Name logFile -Value @{directory=$logDirectory}
	    if ($?) { Write-Host "SUCCESS:  Set $logDirectory as IIS Log Directory" } else { throw "Error Encountered" }
    } else {
        throw "Required Parameter Missing"
    }
} CATCH {
    Write-Error $_
}