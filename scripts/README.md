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
If you see `[WARN:COPY MODE]` in the window title, WSLg fell back to software (CPU) rendering.
Fine for turtlesim; for Gazebo (Phase 2+) we'll want to fix GPU passthrough.
