# Family Safety Control Scripts

[![GitHub Last Commit](https://img.shields.io/github/last-commit/plaraje/ms-family-safety-off)](https://github.com/plaraje/ms-family-safety-off/commits)
[![GitHub Stars](https://img.shields.io/github/stars/plaraje/ms-family-safety-off)](https://github.com/plaraje/ms-family-safety-off/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/plaraje/ms-family-safety-off)](https://github.com/plaraje/ms-family-safety-off/issues)

PowerShell scripts to **disable, enable, and check the state** of Windows Family Safety components with **SYSTEM-level privileges**.

---

## Scripts

### `disable.ps1` – Disable Family Safety

* Stops `WpcMon` process
* Disables `FamilySafetyMonitor` and `FamilySafetyRefreshTask` tasks
* Stops and disables `WpcSvc` service (if present)
* Sets registry `Enabled` = `0`
* Blocks execution of `WpcMon.exe`

```powershell
.\disable.ps1
```

> Requests SYSTEM privileges automatically. Reboot recommended.

---

### `enable.ps1` – Enable Family Safety

* Enables the scheduled tasks
* Starts and sets `WpcSvc` service to automatic (if present)
* Sets registry `Enabled` = `1`
* Restores `WpcMon.exe` permissions

```powershell
.\enable.ps1
```

> Requests SYSTEM privileges automatically. Reboot recommended.

---

### `gtstate.ps1` – Get Family Safety State

Displays:

* Scheduled tasks (`State` | `Enabled`)
* Service `WpcSvc` (`Status` | `StartType`)
* Registry `Enabled` value
* `WpcMon.exe` presence
* Running `WpcMon` processes

```powershell
.\gtstate.ps1
```

> Provides a clear, human-readable status report.

---

### Easy Online Alternative

#### Disable
```powershell
Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr https://raw.githubusercontent.com/plaraje/ms-family-safety-off/main/disable.ps1 -UseBasicParsing | iex | pause`""

#### Enable
```powershell
Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr https://raw.githubusercontent.com/plaraje/ms-family-safety-off/main/enable.ps1 -UseBasicParsing | iex | pause`""

#### Get State
```powershell
Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iwr https://raw.githubusercontent.com/plaraje/ms-family-safety-off/main/gtstate.ps1 -UseBasicParsing | iex | pause`""
```

---

## Features

* Fully SYSTEM-compatible, works even when Administrator rights are insufficient.
* Handles tasks universally, ignoring TaskPath inconsistencies.
* Automatic elevation via UAC prompt.
* Easy to use: `disable`, `enable`, and `status check` in one workflow.
