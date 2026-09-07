# test.ps1 - Validates Container Environment and Volume Mounts
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.ffff')] ---> PowerShell Scheduler Test Initialized <---"
Write-Output "Running as User: $env:USERNAME"
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"

# Test log directory access
$logPath = "/logs/test_run.log"
try {
    "[$(Get-Date)] Test script successfully wrote to logs." | Out-File -FilePath $logPath -Append
    Write-Output "SUCCESS: Volume read/write access verified at $logPath"
} catch {
    Write-Warning "WARNING: Could not write to logs directory. Check volume permissions. Error: $_"
}

Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.ffff')] ---> Test Completed Successfully <---"
