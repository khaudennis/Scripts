# A script to move driver files for AMD GPUs from the host machine to a designated VM guest to utilize GPU-P.
# Tested, working between Windows 10 hosts and Windows 10 guests. I've not been able to get it to work on Server 2019 host to Windows 10 guests.
# This is tailored to my HyperV architecture with a standardized FS in place.  I've create a generalized script here at https://github.com/khaudennis/Scripts/tree/master/PowerShell/Home%20Lab/2021_DKhau_Deploy_AMD_Drivers_for_GPU-P_Public.ps1
# Dennis Khau, 7/1/2021

function Set-Gpup {
    param (
        [Parameter()]
        [string]$VMName = "",
        [string]$StorageType = "default"
    )

    $drivers = @('Windows\system32\amd_comgr.dll',
            'Windows\system32\amdave64.dll',
            'Windows\system32\amdgfxinfo64.dll',
            'Windows\system32\amdhip64.dll',
            'Windows\system32\amdihk64.dll',
            'Windows\system32\AMDKernelEvents.man',
            'Windows\system32\amdlogum.exe',
            'Windows\system32\amdlvr64.dll',
            'Windows\system32\amdmcl64.dll',
            'Windows\system32\amdmiracast.dll',
            'Windows\system32\amdpcom64.dll',
            'Windows\system32\amdxc64.dll',
            'Windows\system32\amf-mft-mjpeg-decoder64.dll',
            'Windows\system32\amfrt64.dll',
            'Windows\system32\ati2erec.dll',
            'Windows\system32\atiadlxx.dll',
            'Windows\system32\atiapfxx.blb',
            'Windows\system32\aticfx64.dll',
            'Windows\system32\atidemgy.dll',
            'Windows\system32\atidxx64.dll',
            'Windows\system32\atieah64.exe',
            'Windows\system32\atieclxx.exe',
            'Windows\system32\atig6txx.dll',
            'Windows\system32\atimpc64.dll',
            'Windows\system32\atimuixx.dll',
            'Windows\system32\atisamu64.dll',
            'Windows\system32\atiumd6a.cap',
            'Windows\system32\ativvsva.dat',
            'Windows\system32\ativvsvl.dat',
            'Windows\system32\clinfo.exe',
            'Windows\system32\detoured.dll',
            'Windows\system32\dgtrayicon.exe',
            'Windows\system32\EEURestart.exe',
            'Windows\system32\GameManager64.dll',
            'Windows\system32\kapp_ci.sbin',
            'Windows\system32\kapp_si.sbin',
            'Windows\system32\mantle64.dll',
            'Windows\system32\mantleaxl64.dll',
            'Windows\system32\mcl64.dll',
            'Windows\system32\OpenCL.dll',
            'Windows\system32\Rapidfire64.dll',
            'Windows\system32\RapidFireServer64.dll',
            'Windows\system32\samu_krnl_ci.sbin',
            'Windows\system32\samu_krnl_isv_ci.sbin',
            'Windows\system32\vulkan-1.dll',
            'Windows\system32\vulkan-1-999-0-0-0.dll',
            'Windows\system32\vulkaninfo.exe',
            'Windows\system32\vulkaninfo-1-999-0-0-0.exe',
            'Windows\SysWOW64\amd_comgr32.dll',
            'Windows\SysWOW64\amdave32.dll',
            'Windows\SysWOW64\amdgfxinfo32.dll',
            'Windows\SysWOW64\amdihk32.dll',
            'Windows\SysWOW64\amdlvr32.dll',
            'Windows\SysWOW64\amdmcl32.dll',
            'Windows\SysWOW64\amdpcom32.dll',
            'Windows\SysWOW64\amdxc32.dll',
            'Windows\SysWOW64\amf-mft-mjpeg-decoder32.dll',
            'Windows\SysWOW64\amfrt32.dll',
            'Windows\SysWOW64\atiadlxx.dll',
            'Windows\SysWOW64\atiadlxy.dll',
            'Windows\SysWOW64\atiapfxx.blb',
            'Windows\SysWOW64\aticfx32.dll',
            'Windows\SysWOW64\atidxx32.dll',
            'Windows\SysWOW64\atieah32.exe',
            'Windows\SysWOW64\atigktxx.dll',
            'Windows\SysWOW64\atimpc32.dll',
            'Windows\SysWOW64\atisamu32.dll',
            'Windows\SysWOW64\atiumdva.cap',
            'Windows\SysWOW64\ativvsva.dat',
            'Windows\SysWOW64\ativvsvl.dat',
            'Windows\SysWOW64\detoured.dll',
            'Windows\SysWOW64\GameManager32.dll',
            'Windows\SysWOW64\mantle32.dll',
            'Windows\SysWOW64\mantleaxl32.dll',
            'Windows\SysWOW64\mcl32.dll',
            'Windows\SysWOW64\OpenCL.dll',
            'Windows\SysWOW64\Rapidfire.dll',
            'Windows\SysWOW64\RapidFireServer.dll',
            'Windows\SysWOW64\vulkan-1.dll',
            'Windows\SysWOW64\vulkan-1-999-0-0-0.dll',
            'Windows\SysWOW64\vulkaninfo.exe',
            'Windows\SysWOW64\vulkaninfo-1-999-0-0-0.exe',
            'Windows\system32\AMD\amdkmpfd\',
            'Windows\System32\DriverStore\FileRepository\u0358464.inf_amd64_7acaccafba92993d\')

    $vmName = $VMName
    $storageType = $StorageType
    $driveRoot = ""
    $osDrive = $vmName + "_OS.VHDX"

    if ($storageType -eq "default") {
        $driveRoot = "D:"
    } elseif ($storageType -eq "extended") {
        $driveRoot = "X:"
    } else {
        $driveRoot = "D:"
    }

    try {
        if ([String]::IsNullOrWhiteSpace($vmName)) { throw "Missing VM Name Parameter." }

        Mount-VHD -Path (Join-Path -Path $driveRoot -ChildPath "HyperV\Virtual Hard Disks\$osDrive") 

        $mountedDrive = Get-DiskImage (Join-Path -Path $driveRoot -ChildPath "HyperV\Virtual Hard Disks\$osDrive") | Get-Disk | Get-Partition | Where-Object {$_.DriveLetter -ne "`0"} | Select-Object -Property DriveLetter

        foreach ($drive in $drivers)
        {
            if ($drive -like "*\DriverStore\FileRepository*") {
                mkdir (Join-Path -Path ($mountedDrive.DriveLetter + ":") -ChildPath "Windows\System32\HostDriverStore")
                mkdir (Join-Path -Path ($mountedDrive.DriveLetter + ":") -ChildPath "Windows\System32\HostDriverStore\FileRepository")
                Copy-Item -Path (Join-Path -Path "c:" -ChildPath $drive) -Destination (Join-Path -Path ($mountedDrive.DriveLetter + ":") -ChildPath "Windows\System32\HostDriverStore\FileRepository") -Recurse -force
            } else {
                Copy-Item -Path (Join-Path -Path "c:" -ChildPath $drive) -Destination (Join-Path -Path ($mountedDrive.DriveLetter + ":") -ChildPath $drive) -Recurse -force
            }    
        }

        Dismount-VHD -Path (Join-Path -Path $driveRoot -ChildPath "HyperV\Virtual Hard Disks\$osDrive")

        Remove-VMGpuPartitionAdapter -VMName $vmName
        Add-VMGpuPartitionAdapter -VMName $vmName
        Set-VMGpuPartitionAdapter -VMName $vmName -MinPartitionVRAM 1
        Set-VMGpuPartitionAdapter -VMName $vmName -MaxPartitionVRAM 11
        Set-VMGpuPartitionAdapter -VMName $vmName -OptimalPartitionVRAM 10
        Set-VMGpuPartitionAdapter -VMName $vmName -MinPartitionEncode 1
        Set-VMGpuPartitionAdapter -VMName $vmName -MaxPartitionEncode 11
        Set-VMGpuPartitionAdapter -VMName $vmName -OptimalPartitionEncode 10
        Set-VMGpuPartitionAdapter -VMName $vmName -MinPartitionDecode 1
        Set-VMGpuPartitionAdapter -VMName $vmName -MaxPartitionDecode 11
        Set-VMGpuPartitionAdapter -VMName $vmName -OptimalPartitionDecode 10
        Set-VMGpuPartitionAdapter -VMName $vmName -MinPartitionCompute 1
        Set-VMGpuPartitionAdapter -VMName $vmName -MaxPartitionCompute 11
        Set-VMGpuPartitionAdapter -VMName $vmName -OptimalPartitionCompute 10
        Set-VM -GuestControlledCacheTypes $true -VMName $vmName
        Set-VM -LowMemoryMappedIoSpace 1Gb -VMName $vmName
        Set-VM -HighMemoryMappedIoSpace 32GB -VMName $vmName
        Start-VM -Name $vmName
    }
    catch {
        Write-Error $_
    }
}