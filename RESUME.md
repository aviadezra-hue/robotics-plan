# Resume notes — Aviad's robotics journey

Live plan: **https://aviadezra-hue.github.io/robotics-plan/**
Repo: `C:\Users\avezra\repro-robotics-plan` → `https://github.com/aviadezra-hue/robotics-plan`
Last published commit: `82ad2a3`

## To resume work on the **plan website** (this repo)
Say:
> "Resume my robotics plan. Repo is `C:\Users\avezra\repro-robotics-plan`, published at `https://aviadezra-hue.github.io/robotics-plan/`. Read `RESUME.md` then `robotics-plan.md`."

## To start **actually building robots** (Phase 0)
Say:
> "I'm ready to start Phase 0 of my robotics plan. Run it for me in autopilot mode. Plan is at `C:\Users\avezra\repro-robotics-plan\robotics-plan.md`."

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
