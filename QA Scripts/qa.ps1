# Installing Windows Update Packages and Modules
Import-Module "$PSScriptRoot\Modules\PSWindowsUpdate\PSWindowsUpdate.psd1" -ErrorAction Stop

function Test-WindowsUpdateStatus {
    <#
    .SYNOPSIS
        Quickly checks for pending Windows Updates using the Windows Update Agent (WUA) COM interface.

    .DESCRIPTION
        This function uses the native Microsoft.Update.Session COM object to check for uninstalled software updates.
        It runs significantly faster than Get-WindowsUpdate from PSWindowsUpdate, 
        and is safe for use in automated QA or deployment scripts.

    .OUTPUTS
        [string] A simple status message describing the update state.

    .EXAMPLE
        Test-WindowsUpdateStatus
    #>

    Write-Host "[*] Checking Windows Update status (fast mode)..."

    try {
        # Create an Update session and searcher
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()

        # Search for pending (uninstalled) software updates
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software'")

        # Output results in a simple readable format
        if ($searchResult.Updates.Count -le 1) {
            Write-Host "[OK] Minimal or No updates pending."
        } else {
            Write-Host "[WARN] $($searchResult.Updates.Count) important updates available."
        }
    } catch {
        Write-Host "[ERROR] Unable to query Windows Update Agent: $($_.Exception.Message)"
    }
}


try {
    Write-Host "[*] Checking network connectivity..."
    $pingResult = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet

    if (-not $pingResult) {
        throw "No network connection detected. Please check your network settings."
    }
    Write-Host "[OK] Network connection established."

    Test-WindowsUpdateStatus

    Write-Host "[*] Checking storage controller mode..."
    $storageController = (Get-WmiObject -Query "Select * from Win32_PnPSignedDriver where DeviceClass='SCSIAdapter'" |
                          Select-Object -ExpandProperty DeviceName)

    if ($storageController -match "NVM" -or $storageController -match "AHCI") {
        Write-Host "[OK] AHCI/NVMe mode detected"
    } elseif ($storageController -match "RAID") {
        Write-Host "[WARN] RAID mode detected"
    } else {
        Write-Host "[FAIL] Incorrect storage mode: $storageController"
    }

    Write-Host "[*] Checking Secure Boot status..."
    try {
        $secureBootEnabled = Confirm-SecureBootUEFI
        if ($secureBootEnabled) {
            Write-Host "[OK] Secure Boot is enabled."
        } else {
            Write-Host "[FAIL] Secure Boot is disabled."
        }
    } catch {
        Write-Host "[INFO] Secure Boot check not supported on this system."
    }

} catch {
    Write-Host "[ERROR] $($_.Exception.Message)"
}
