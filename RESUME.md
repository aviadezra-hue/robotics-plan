# Resume notes — Aviad's robotics journey

Live plan: **https://aviadezra-hue.github.io/robotics-plan/**
Repo: `C:\Users\avezra\repro-robotics-plan` → `https://github.com/aviadezra-hue/robotics-plan`

## To resume work on the **plan website** (this repo)
Say:
> "Resume my robotics plan. Repo is `C:\Users\avezra\repro-robotics-plan`, published at `https://aviadezra-hue.github.io/robotics-plan/`. Read `RESUME.md`, then read the plan content directly out of `index.html` (the embedded markdown is the source of truth)."

## ✅ Phase 0 — COMPLETE & VALIDATED
Installed and validated on this machine:
- WSL 2.7.3 + Ubuntu 24.04.4 LTS (default user: `aviad`, passwordless sudo, systemd on)
- NVIDIA driver 595.71 / CUDA 13.2 — already CUDA-on-WSL ready, no install needed
- ROS 2 Jazzy desktop-full + ros-gz (Gazebo Harmonic Sim 8.11.0) — 340 packages
- `~/.bashrc` sources `/opt/ros/jazzy/setup.bash`; sets `DISPLAY=$(host-ip):0`; unsets `WAYLAND_DISPLAY`
- **VcXsrv** as the X server (WSLg is broken on this multi-GPU laptop — `[WARN:COPY MODE]` → black windows)
  - auto-starts at Windows login via shortcut in `%APPDATA%\...\Startup\VcXsrv.lnk`
  - run with: `-multiwindow -clipboard -wgl -ac -noprimary`
- VS Code WSL extension `ms-vscode-remote.remote-wsl` v0.104.3
- `ros2 doctor`: **All 5 checks passed**
- ✅ **Turtlesim visually validated** — `ros2 run turtlesim turtlesim_node` + `turtle_teleop_key`, arrow keys move the turtle

### To run anything GUI in WSL
1. Make sure VcXsrv is running (look for the **X** icon in your Windows tray; if missing, run it from Start Menu).
2. In any Ubuntu terminal: `ros2 run <pkg> <node>`.

## To pick up at any later phase
Say:
> "I finished Phase N of my robotics plan. Help me with Phase <N+1>. The plan is embedded in `index.html` — read it from there."

## Where things live
- **`index.html`** — single source of truth. The plan markdown lives inside `<script type="text/markdown" id="embedded-md">…</script>`. Edit it there.
- `images/` — phase screenshots referenced from the markdown
- `Phase1-ROS2-Internalize.pptx` + `make_phase1_deck.py` — Phase 1 internalization deck (generator script regenerates the deck)
- `todo/` — Microsoft To Do push tooling (lists per phase). Source of truth is `todo/robotics-tasks.json`; push with `todo/push-todo-devicecode.ps1`.
- `README.md` — repo description with Pages link

> **Note:** the standalone `robotics-plan.md` file was removed — `index.html` is now the only place to edit plan content. Anything you change inside the `embedded-md` script tag will go live on the next push (Pages rebuilds in ~30 s).

## To make plan edits and publish
1. Open `index.html`, find the section you want inside `<script type="text/markdown" id="embedded-md">`, and edit the markdown.
2. `git add -A && git commit -m "..." && git push` — Pages auto-rebuilds.

## Personal context for the agent
- Aviad Ezra, senior dev (25 years), Israel 🇮🇱
- Windows 11 Enterprise, build 26200, Intel Core Ultra 7 165H, 63 GB RAM, NVIDIA RTX 500 Ada + Intel Arc Pro, DisplayLink dock present
- `VirtualMachinePlatform` Windows feature already enabled (WSL2-ready)
- Personal GitHub: `aviadezra-hue` (gh CLI authed locally)
- Microsoft EMU: `avezra_microsoft` (can't host public repos — use personal account)
- Preferred specialization track: 🦾 **Manipulation** (MoveIt 2, pick-and-place, vision-driven grasping)
- Microsoft To Do account: `aviadezra@hotmail.com` (lists already populated from `todo/robotics-tasks.json`)
