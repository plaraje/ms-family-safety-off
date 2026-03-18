# ------------------------------------------
# Get Family Safety State (accurate)
# ------------------------------------------

Write-Host "==== FAMILY SAFETY STATE ===="

# ---- Scheduled Tasks ----
Write-Host "`n[*] Scheduled Tasks:"
$tasks = @("FamilySafetyMonitor","FamilySafetyRefreshTask")
Get-ScheduledTask | Where-Object {$_.TaskName -in $tasks} | ForEach-Object {
    $enabled = if ($_.Settings.Enabled) {"True"} else {"False"}
    Write-Host "[TASK] $($_.TaskName) -> State: $($_.State) | Enabled: $enabled"
}

# ---- Service ----
Write-Host "`n[*] Service (WpcSvc):"
$svc = Get-Service -Name "WpcSvc" -ErrorAction SilentlyContinue
if ($svc) {
    Write-Host "[SERVICE] WpcSvc -> Status: $($svc.Status) | StartType: $($svc.StartType)"
} else {
    Write-Host "[SERVICE] WpcSvc not found"
}

# ---- Registry ----
Write-Host "`n[*] Registry:"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Parental Controls"
try {
    $val = Get-ItemProperty -Path $regPath -Name "Enabled" -ErrorAction Stop
    Write-Host "[REG] Enabled = $($val.Enabled)"
} catch {
    Write-Host "[REG] Enabled = (not set)"
}

# ---- WpcMon.exe ----
Write-Host "`n[*] WpcMon.exe:"
$exe = "C:\Windows\System32\WpcMon.exe"
if (Test-Path $exe) { Write-Host "[EXE] FOUND" } else { Write-Host "[EXE] NOT FOUND" }

# ---- Running processes ----
Write-Host "`n[*] Running processes:"
$proc = Get-Process WpcMon -ErrorAction SilentlyContinue
if ($proc) { Write-Host "[PROC] WpcMon is running" } else { Write-Host "[PROC] WpcMon is NOT running" }

Write-Host "`n==== END ===="