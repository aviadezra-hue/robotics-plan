# Resume notes — Aviad's robotics journey

Live plan: **https://aviadezra-hue.github.io/robotics-plan/**
Repo: `C:\Users\avezra\repro-robotics-plan` → `https://github.com/aviadezra-hue/robotics-plan`
Last published commit: `82ad2a3`

## To resume work on the **plan website** (this repo)
Say:
> "Resume my robotics plan. Repo is `C:\Users\avezra\repro-robotics-plan`, published at `https://aviadezra-hue.github.io/robotics-plan/`. Read `RESUME.md` then `robotics-plan.md`."

## ✅ Phase 0 — COMPLETE
Installed and validated on this machine:
- WSL 2.7.3 + Ubuntu 24.04.4 LTS (default user: `aviad`, passwordless sudo, systemd on)
- NVIDIA driver 595.71 / CUDA 13.2 — already CUDA-on-WSL ready, no install needed
- ROS 2 Jazzy desktop-full + ros-gz (Gazebo Harmonic Sim 8.11.0) — 340 packages
- `~/.bashrc` sources `/opt/ros/jazzy/setup.bash`; `ROS_DOMAIN_ID=0`, `RMW_IMPLEMENTATION=rmw_fastrtps_cpp`
- VS Code WSL extension `ms-vscode-remote.remote-wsl` v0.104.3
- `ros2 doctor`: **All 5 checks passed**

**Manual visual confirmation still to do (do on internal display, not DisplayLink dock):**
Open two WSL terminals (Start Menu → Ubuntu 24.04):
- Terminal 1: `ros2 run turtlesim turtlesim_node`
- Terminal 2: `ros2 run turtlesim turtle_teleop_key` — focus this window, press arrow keys, turtle should move.

## To start **Phase 1** (ROS 2 fundamentals)
Say:
> "I finished Phase 0 of my robotics plan. Start Phase 1. Plan is at `C:\Users\avezra\repro-robotics-plan\robotics-plan.md`."

Then in Copilot CLI: `/allow-all`, then `/autopilot`.

## To pick up at any later phase
Say:
> "I finished Phase N of my robotics plan. Help me with Phase <N+1>. Read `robotics-plan.md` for context."

## Where things live
- `robotics-plan.md` — the plan itself (source of truth, embedded into `index.html`)
- `index.html` — self-contained published page (Hero, tile nav, embedded markdown)
- `images/` — phase result screenshots (turtlesim, gazebo, nav2, moveit)
- `README.md` — repo description with Pages link

## To make plan edits and publish
1. Edit `robotics-plan.md`
2. Re-embed: run PowerShell regex replace of `<script type="text/markdown" id="embedded-md">...</script>` block in `index.html` with the new markdown
3. `git add -A && git commit -m "..." && git push` — Pages auto-rebuilds in ~30s

## Personal context for the agent
- Aviad Ezra, senior dev (25 years), Israel 🇮🇱
- Windows 11 Enterprise, build 26200, Intel Core Ultra 7 165H, 63 GB RAM, NVIDIA RTX 500 Ada + Intel Arc Pro, DisplayLink dock present
- `VirtualMachinePlatform` Windows feature already enabled (WSL2-ready)
- Personal GitHub: `aviadezra-hue` (gh CLI authed locally)
- Microsoft EMU: `avezra_microsoft` (can't host public repos — use personal account)
- Preferred specialization track: 🦾 **Manipulation** (MoveIt 2, pick-and-place, vision-driven grasping)
