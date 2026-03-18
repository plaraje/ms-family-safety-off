# ------------------------------------------
# Disable Family Safety (SYSTEM, universal tasks)
# ------------------------------------------

# Ensure Admin / elevate
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Temp script to run as SYSTEM
$temp = "$env:TEMP\fs_disable_system.ps1"

@'
Write-Host "[*] Running as SYSTEM..."

# Stop WpcMon
Get-Process WpcMon -ErrorAction SilentlyContinue | Stop-Process -Force

# Disable tasks (universal, ignores TaskPath)
$tasks = @("FamilySafetyMonitor","FamilySafetyRefreshTask")
Get-ScheduledTask | Where-Object {$_.TaskName -in $tasks} | ForEach-Object {
    try { Disable-ScheduledTask -InputObject $_; Write-Host "[OK] Disabled $($_.TaskName)" } catch { Write-Host "[WARN] Could not disable $($_.TaskName)" }
}

# Service
if (Get-Service -Name "WpcSvc" -ErrorAction SilentlyContinue) {
    Stop-Service WpcSvc -Force
    Set-Service WpcSvc -StartupType Disabled
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\WpcSvc" -Name "Start" -Value 4
    Write-Host "[OK] Service disabled"
} else { Write-Host "[INFO] WpcSvc not present" }

# Registry
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Parental Controls"
if (!(Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
New-ItemProperty -Path $regPath -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null
Write-Host "[OK] Registry set to 0"

# Block WpcMon
$exe = "C:\Windows\System32\WpcMon.exe"
if (Test-Path $exe) { takeown /f $exe | Out-Null; icacls $exe /deny Everyone:RX | Out-Null; Write-Host "[OK] WpcMon blocked" }

Write-Host "[OK] DONE"
'@ | Out-File -Encoding UTF8 $temp

# Schedule SYSTEM task 1 min in the future
$time = (Get-Date).AddMinutes(1).ToString("HH:mm")
$taskName = "FS_Disable_System"

schtasks /Create /TN $taskName /TR "powershell -ExecutionPolicy Bypass -File `"$temp`"" /SC ONCE /ST $time /RL HIGHEST /RU SYSTEM /F | Out-Null
schtasks /Run /TN $taskName | Out-Null

Start-Sleep 5
schtasks /Delete /TN $taskName /F | Out-Null
Remove-Item $temp -Force

Write-Host "[OK] Completed with SYSTEM privileges"