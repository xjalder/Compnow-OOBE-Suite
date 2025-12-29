		
# Installing Windows Update Packages and Modules
Import-Module "$PSScriptRoot\Modules\PSWindowsUpdate\PSWindowsUpdate.psd1"
		

# Setting max number of repeated update attempts
$maxAttempts = 5

Reset-WUComponents

for ($i = 1; $i -le $maxAttempts; $i++) {

	# If last attempt errors, will prompt user for further action
	if ($i -eq $maxAttempts) {
		try {
			Get-WUInstall -MicrosoftUpdate -AcceptAll -AutoReboot -install
		} catch [System.Runtime.InteropServices.COMException] {
			Write-Host "Update Attempt Reached Limit, Seek Assistance"
		}
	# If not-last attempt errors, will report to user that it is retrying
	} else {
		try {
			Get-WUInstall -MicrosoftUpdate -AcceptAll -AutoReboot -install
		} catch [System.Runtime.InteropServices.COMException] {
			Write-Host "Updates Encountered an Error"
			Write-Host "Attempting to Retry"
                      continue
		}
	}
     	
	break	
}

try {
    # Check if there are no updates available or if less than 3 updates are left (likely requiring a reboot)
    if ($updates -eq $null -or $updates.Count -lt 3) {
        & "$PSScriptRoot\finishedUpdates.bat"
    } else {
        Write-Host "Updates not done"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}