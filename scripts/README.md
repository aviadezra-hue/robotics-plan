# scripts/

Helper scripts for running the robotics plan locally on Windows + WSLg.

## `Start-Turtlesim.ps1`
Launches `turtlesim_node` (or `turtle_teleop_key` with `-Teleop`) inside `Ubuntu-24.04` WSL,
then uses Win32 `SetForegroundWindow` to drag the WSLg-rendered window to the front.

WSLg windows often appear hidden or behind other apps on Windows due to focus-stealing
prevention — this script works around that.

### Usage
```powershell
# Terminal 1 — turtle window
.\scripts\Start-Turtlesim.ps1

# Terminal 2 — keyboard control
.\scripts\Start-Turtlesim.ps1 -Teleop
# (then focus the teleop console window and use arrow keys)
```

### Note
The helper pins the window as **always-on-top** at (300, 150), 600×600.
Click it once to focus, then to un-pin run from PowerShell:
```powershell
Add-Type 'using System; using System.Runtime.InteropServices;
public class P { [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int cx, int cy, uint f); }'
# find by title, then SetWindowPos(hwnd, HWND_NOTOPMOST=-2, 0,0,0,0, SWP_NOMOVE|SWP_NOSIZE = 0x13)
```
Or just close the WSL terminal.

### One-time machine setup that's been applied
`C:\Users\avezra\.wslconfig` has `gpuSupport=false` — WSLg's compositor was
glitching in `[WARN:COPY MODE]` on this multi-GPU laptop (Intel Arc + NVIDIA +
DisplayLink), rendering windows as black. Disabling GPU passthrough makes WSLg
use llvmpipe (CPU) for its compositor. Fine for turtlesim & most Phase 1
exercises. For **Phase 2 (Gazebo)** we'll need to re-enable it and select the
NVIDIA adapter explicitly.
