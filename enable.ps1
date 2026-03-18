# ------------------------------------------
# Enable Family Safety (SYSTEM, universal tasks)
# ------------------------------------------

# Ensure Admin / elevate
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Temp script to run as SYSTEM
$temp = "$env:TEMP\fs_enable_system.ps1"

@'
Write-Host "[*] Running as SYSTEM..."

# Enable tasks (universal)
$tasks = @("FamilySafetyMonitor","FamilySafetyRefreshTask")
Get-ScheduledTask | Where-Object {$_.TaskName -in $tasks} | ForEach-Object {
    try { Enable-ScheduledTask -InputObject $_; Write-Host "[OK] Enabled $($_.TaskName)" } catch { Write-Host "[WARN] Could not enable $($_.TaskName)" }
}

# Service
if (Get-Service -Name "WpcSvc" -ErrorAction SilentlyContinue) {
    Set-Service WpcSvc -StartupType Automatic
    Start-Service WpcSvc
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\WpcSvc" -Name "Start" -Value 2
    Write-Host "[OK] Service enabled"
} else { Write-Host "[INFO] WpcSvc not present" }

# Registry
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Parental Controls"
if (!(Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
New-ItemProperty -Path $regPath -Name "Enabled" -Value 1 -PropertyType DWORD -Force | Out-Null
Write-Host "[OK] Registry set to 1"

# Restore WpcMon
$exe = "C:\Windows\System32\WpcMon.exe"
if (Test-Path $exe) { icacls $exe /remove:d Everyone | Out-Null; Write-Host "[OK] WpcMon permissions restored" }

Write-Host "[OK] DONE"
'@ | Out-File -Encoding UTF8 $temp

# Schedule SYSTEM task 1 min in the future
$time = (Get-Date).AddMinutes(1).ToString("HH:mm")
$taskName = "FS_Enable_System"

schtasks /Create /TN $taskName /TR "powershell -ExecutionPolicy Bypass -File `"$temp`"" /SC ONCE /ST $time /RL HIGHEST /RU SYSTEM /F | Out-Null
schtasks /Run /TN $taskName | Out-Null

Start-Sleep 5
schtasks /Delete /TN $taskName /F | Out-Null
Remove-Item $temp -Force

Write-Host "[OK] Completed with SYSTEM privileges"