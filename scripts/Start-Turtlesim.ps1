# Start-Turtlesim.ps1 — launch turtlesim in WSL and force its window to foreground
# Usage:
#   .\Start-Turtlesim.ps1                # launches turtlesim_node
#   .\Start-Turtlesim.ps1 -Teleop        # launches turtle_teleop_key

[CmdletBinding()]
param(
  [switch]$Teleop
)

$ErrorActionPreference = "Stop"

# --- Ensure VcXsrv X server is running (bypasses WSLg COPY MODE bug) ---
$vcxsrvPath = "C:\Program Files\VcXsrv\vcxsrv.exe"
if (-not (Test-Path $vcxsrvPath)) {
  Write-Warning "VcXsrv not installed at $vcxsrvPath. Install with: winget install --id marha.VcXsrv"
  Write-Warning "Continuing — will try WSLg (may render as black window)."
} elseif (-not (Get-Process vcxsrv -ErrorAction SilentlyContinue)) {
  Write-Host "Starting VcXsrv..." -ForegroundColor DarkCyan
  Start-Process -FilePath $vcxsrvPath -ArgumentList "-multiwindow","-clipboard","-wgl","-ac","-noprimary"
  Start-Sleep -Seconds 2
}

Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WslWin {
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr lp);
  [DllImport("user32.dll")] public static extern int  GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool c);
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
  [DllImport("user32.dll")] public static extern bool InvalidateRect(IntPtr h, IntPtr rect, bool erase);
  [DllImport("user32.dll")] public static extern bool RedrawWindow(IntPtr h, IntPtr rect, IntPtr region, uint flags);
  [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
  public delegate bool EnumWindowsProc(IntPtr h, IntPtr lp);
}
'@ -ErrorAction SilentlyContinue

function Find-WindowByTitle([string]$needle) {
  $script:found = [IntPtr]::Zero
  $cb = [WslWin+EnumWindowsProc]{
    param($h, $lp)
    if (-not [WslWin]::IsWindowVisible($h)) { return $true }
    $sb = New-Object System.Text.StringBuilder 256
    [WslWin]::GetWindowText($h, $sb, 256) | Out-Null
    if ($sb.ToString() -match $needle) { $script:found = $h; return $false }
    return $true
  }
  [WslWin]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
  return $script:found
}

function Force-Foreground([IntPtr]$h) {
  [WslWin]::ShowWindow($h, 9) | Out-Null   # SW_RESTORE
  # Pin as topmost so nothing can hide it; HWND_TOPMOST = -1, SWP_SHOWWINDOW = 0x40
  $topmost = [IntPtr]([Int64]-1)
  [WslWin]::SetWindowPos($h, $topmost, 300, 150, 600, 600, 0x40) | Out-Null
  # Force a repaint - some WSLg windows have stale framebuffer until invalidated
  [WslWin]::RedrawWindow($h, [IntPtr]::Zero, [IntPtr]::Zero, 0x0085) | Out-Null
  $fg = [WslWin]::GetForegroundWindow()
  $procId = [uint32]0
  $fgThread = [WslWin]::GetWindowThreadProcessId($fg, [ref]$procId)
  $myThread = [WslWin]::GetCurrentThreadId()
  [WslWin]::AttachThreadInput($fgThread, $myThread, $true) | Out-Null
  $ok = [WslWin]::SetForegroundWindow($h)
  [WslWin]::AttachThreadInput($fgThread, $myThread, $false) | Out-Null
  return $ok
}

$node  = if ($Teleop) { "turtle_teleop_key" } else { "turtlesim_node" }
$match = "TurtleSim"

Write-Host "Launching $node in WSL Ubuntu-24.04..." -ForegroundColor Cyan
$cmd = "source /opt/ros/jazzy/setup.bash && ros2 run turtlesim $node"
$job = Start-Job -ScriptBlock {
  param($c)
  wsl.exe -d Ubuntu-24.04 -- bash -ic $c 2>&1
} -ArgumentList $cmd
Write-Host "Background job: $($job.Id)" -ForegroundColor DarkGray

Write-Host "Waiting for window..." -ForegroundColor Cyan
$hwnd = [IntPtr]::Zero
for ($i = 0; $i -lt 30; $i++) {
  Start-Sleep -Milliseconds 500
  $hwnd = Find-WindowByTitle $match
  if ($hwnd -ne [IntPtr]::Zero) { break }
}

if ($hwnd -eq [IntPtr]::Zero) {
  Write-Warning "No window matching '$match' appeared within 15s."
  exit 1
}

$title = New-Object System.Text.StringBuilder 256
[WslWin]::GetWindowText($hwnd, $title, 256) | Out-Null
Write-Host "Found: $($title.ToString())" -ForegroundColor Green
$ok = Force-Foreground $hwnd
if ($ok) { Write-Host "Brought to foreground." -ForegroundColor Green }
else     { Write-Warning "SetForegroundWindow refused - click the taskbar icon manually." }
