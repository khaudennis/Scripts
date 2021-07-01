# A script to deploy HyperV guests with little interaction with the GUI.
# This is tailored to my HyperV architecture with a standardized FS in place.
# Dennis Khau, 7/1/2021

param (
    [string]$vmName = "",
    [string]$storageType = "default",
    [string]$driveRoot = "",
    [string]$osDrive = $vmName + "_OS.VHDX",
    [int]$dataDrives = 1
)

if ($storageType -eq "default") {
    $driveRoot = "D:"
} elseif ($storageType -eq "extended") {
    $driveRoot = "X:"
} else {
    $driveRoot = "D:"
}

try {
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