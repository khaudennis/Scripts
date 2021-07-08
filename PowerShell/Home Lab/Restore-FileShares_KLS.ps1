# Restore directories, network shares and its respective permissions on HM02/FF.
# Dennis Khau, 6/28/2021

$primaryRoot = "d:\Shares"
$secondaryRoot = "x:\Shares"
$primaryDirectories = @('Family')
$secondaryDirectories = @('Archive','Backup','Business','Home','Pictures','Public','Temp')
$aclAll = @('ad\backup privileges','ad\domain admins','ad\domain users','administrators')
$aclNoUsers = @('ad\backup privileges','ad\domain admins','administrators')
$aclPrimary = @('ad\domain admins','ad\domain users','administrators')
$aclUsers = @('ad\domain users')

Try {
    md $primaryRoot -ErrorAction SilentlyContinue
    $acl = Get-Acl $primaryRoot
    $acl.SetAccessRuleProtection($true,$false)        
    $acl.Access | %{$acl.RemoveAccessRule($_)}
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    $acl | Set-Acl $primaryRoot

    md $secondaryRoot -ErrorAction SilentlyContinue
    $acl = Get-Acl $secondaryRoot
    $acl.SetAccessRuleProtection($true,$false)
    $acl.Access | %{$acl.RemoveAccessRule($_)}
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    $acl | Set-Acl $secondaryRoot

    For ($i=0; $i -lt $primaryDirectories.Length; $i++) {        
        $sharePath = Join-Path -Path $primaryRoot -ChildPath $primaryDirectories[$i]
        md $sharePath -ErrorAction SilentlyContinue

        Switch ($primaryDirectories[$i])
        {
            'Family' { 
                New-SMBShare -Name $primaryDirectories[$i] -Path $sharePath -FullAccess $aclPrimary
                # # -ChangeAccess domain\group `
                # # -ReadAccess "domain\group"

                For ($i=0; $i -lt $aclPrimary.Length; $i++) {  
                    $acl = Get-Acl $sharePath
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($aclPrimary[$i], "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Set-Acl $sharePath $acl
                }

                break
            }
        }
    }

    For ($i=0; $i -lt $secondaryDirectories.Length; $i++) {
        $sharePath = Join-Path -Path $secondaryRoot -ChildPath $secondaryDirectories[$i]      
        md $sharePath -ErrorAction SilentlyContinue

        Switch ($secondaryDirectories[$i])
        {
            'Archive' {
                New-SMBShare -Name $secondaryDirectories[$i] -Path $sharePath -FullAccess $aclNoUsers

                Foreach ($group in $aclNoUsers) {  
                    $acl = Get-Acl $sharePath
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Set-Acl $sharePath $acl
                }

                break
            }

            'Backup' {
                New-SMBShare -Name $secondaryDirectories[$i] -Path $sharePath -FullAccess $aclNoUsers -ReadAccess $aclUsers

                Foreach ($group in $aclNoUsers) {  
                    $acl = Get-Acl $sharePath
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Set-Acl $sharePath $acl
                }

                Foreach ($group in $aclUsers) {  
                    $acl = Get-Acl $sharePath
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "Read", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Set-Acl $sharePath $acl
                }

                break
            }

            'Business' {
                New-SMBShare -Name $secondaryDirectories[$i] -Path $sharePath -FullAccess $aclAll

                Foreach ($group in $aclAll) {  
                    $acl = Get-Acl $sharePath
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Set-Acl $sharePath $acl
                }

                break
            }

            'Home' {
                New-SMBShare -Name $secondaryDirectories[$i] -Path $sharePath -FullAccess 'administrators'

                #Custom Ruling
                $acl = Get-Acl $sharePath
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("ad\domain admins", "Read", "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule)
                Set-Acl $sharePath $acl

                $acl = Get-Acl $sharePath
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("ad\domain users", "Read", "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule)
                Set-Acl $sharePath $acl

                $acl = Get-Acl $sharePath
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule)
                Set-Acl $sharePath $acl

                break
            }

            'Pictures' {
                New-SMBShare -Name $secondaryDirectories[$i] -Path $sharePath -FullAccess $aclAll

                Foreach ($group in $aclAll) {  
                    $acl = Get-Acl $sharePath
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Set-Acl $sharePath $acl
                }

                break
            }

            'Public' {
                New-SMBShare -Name $secondaryDirectories[$i] -Path $sharePath -FullAccess $aclAll -ReadAccess "HYPERMAN03$"

                Foreach ($group in $aclAll) {  
                    $acl = Get-Acl $sharePath
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Set-Acl $sharePath $acl
                }

                #Custom Ruling
                $acl = Get-Acl $sharePath
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("HYPERMAN03$", "Read", "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($rule)
                Set-Acl $sharePath $acl

                break
            }

            'Temp' {
                New-SMBShare -Name $secondaryDirectories[$i] -Path $sharePath -FullAccess $aclAll

                Foreach ($group in $aclAll) {  
                    $acl = Get-Acl $sharePath
                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                    $acl.SetAccessRule($rule)
                    Set-Acl $sharePath $acl
                }

                break
            }
        }
    }

} Catch {
    Write-Error $_
}