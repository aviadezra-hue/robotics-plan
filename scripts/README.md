# scripts/

Helper scripts for running the robotics plan locally on Windows + WSL.

## Why these exist
WSLg on this multi-GPU laptop (Intel Arc Pro + NVIDIA RTX 500 + DisplayLink dock)
falls into a broken `[WARN:COPY MODE]` state and renders Qt/X11 windows as
all-black framebuffers. Workaround: use **VcXsrv** as a real Windows-native
X server, bypassing WSLg entirely.

## One-time setup (already done on this machine)

1. **VcXsrv** installed: `winget install --id marha.VcXsrv`
2. **Windows Firewall** rule "VcXsrv (WSL X11)" allows TCP 6000–6063 inbound.
3. **`~/.bashrc`** in WSL exports `DISPLAY` pointing to the Windows host gateway
   and unsets `WAYLAND_DISPLAY`.

## `Start-Turtlesim.ps1`
Launches a turtlesim node inside `Ubuntu-24.04` WSL and forces the window to the
foreground (pinned topmost at 300, 150, 600×600). Auto-starts VcXsrv if needed.

```powershell
# Terminal A — turtle window
.\scripts\Start-Turtlesim.ps1

# Terminal B — keyboard control (focus this PowerShell window and use arrows)
.\scripts\Start-Turtlesim.ps1 -Teleop
```

## `Stop-Turtlesim.ps1`
Kill the WSL turtle processes (and VcXsrv unless `-KeepVcXsrv`).

```powershell
.\scripts\Stop-Turtlesim.ps1
.\scripts\Stop-Turtlesim.ps1 -KeepVcXsrv
```

## For Phase 2 (Gazebo)
Gazebo Harmonic via VcXsrv with `-wgl` may work for basic sims. For
GPU-accelerated 3D we may need to revisit (re-enable WSLg GPU, or run Gazebo
headless and visualize via RViz/foxglove from Windows side).
