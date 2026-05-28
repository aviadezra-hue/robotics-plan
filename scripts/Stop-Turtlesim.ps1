# Stop-Turtlesim.ps1 — clean shutdown of turtle + VcXsrv
[CmdletBinding()]
param([switch]$KeepVcXsrv)

Write-Host "Killing any running turtlesim/teleop in WSL..." -ForegroundColor Cyan
wsl -d Ubuntu-24.04 -- bash -c "pgrep -x turtlesim_node | xargs -r kill -9; pgrep -x turtle_teleop_ | xargs -r kill -9; sleep 1; echo cleaned"

if (-not $KeepVcXsrv) {
  Get-Process vcxsrv -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Stopping VcXsrv (PID $($_.Id))" -ForegroundColor Cyan
    Stop-Process -Id $_.Id -Force
  }
}
Write-Host "Done." -ForegroundColor Green
