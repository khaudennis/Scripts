# A script to deploy HyperV guests with little interaction with the GUI.
# This is tailored to my HyperV architecture with a standardized FS in place.
# Dennis Khau, 7/1/2021

function Add-HyperVMachine {
    param (
        [Parameter()]
        [string]$VMName = "",
        [string]$StorageType = "default",
        [int]$DataDrives = 1
    )

    $vmName = $VMName
    $storageType = $StorageType
    $driveRoot = ""
    $osDrive = $vmName + "_OS.VHDX"
    $dataDrives = $DataDrives

    if ($storageType -eq "default") {
        $driveRoot = "D:"
    } elseif ($storageType -eq "extended") {
        $driveRoot = "X:"
    } else {
        $driveRoot = "D:"
    }

    try {
        if ([String]::IsNullOrWhiteSpace($vmName)) { throw "Missing VM Name Parameter." }

        New-VM -Name $vmName `
            -Path (Join-Path -Path $driveRoot -ChildPath "HyperV") `
            -NewVHDPath (Join-Path -Path $driveRoot -ChildPath "HyperV\Virtual Hard Disks\$osDrive") `
            -NewVHDSizeBytes (125 * 1073741824) `
            -Generation 2 `
            -MemoryStartupBytes (8 * 1073741824) `
            -SwitchName (Get-VMSwitch | Where{$_.name -match "Primary External vSwitch*"}).Name

        Set-VM -Name $vmName `
            -ProcessorCount 2 `
            -DynamicMemory `
            -MemoryMinimumBytes (4 * 1073741824) `
            -MemoryStartupBytes (4 * 1073741824) `
            -MemoryMaximumBytes (8 * 1073741824) `
            -AutomaticStartAction Start `
            -AutomaticStartDelay 60 `
            -AutomaticStopAction Shutdown

        For ($i=0; $i -lt $dataDrives; $i++)      
        {
            New-VHD -Path (Join-Path -Path $driveRoot -ChildPath ("HyperV\Virtual Hard Disks\" + $vmName + "_DATA0" + ($i + 1) + ".VHDX")) `
            -SizeBytes (100 * 1073741824) `
            -Dynamic
            
            Add-VMHardDiskDrive -VMName $vmName -Path (Join-Path -Path $driveRoot -ChildPath ("HyperV\Virtual Hard Disks\" + $vmName + "_DATA0" + ($i + 1) + ".VHDX"))
        }
    }
    catch {
        Write-Error $_
    }
}