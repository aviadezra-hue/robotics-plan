# Robotics learning → Microsoft To Do

This folder pushes your phase-by-phase robotics plan into **Microsoft To Do**
under your `aviadezra@hotmail.com` account.

## What it creates

One To Do **list** per phase (7 lists total):

- 🤖 Robotics — Phase 0: Environment Setup
- 🤖 Robotics — Phase 1: ROS 2 Fundamentals
- 🤖 Robotics — Phase 2: Simulation Deep Dive
- 🤖 Robotics — Phase 3: Navigation & Perception
- 🤖 Robotics — Phase 4: Manipulation (MoveIt 2)
- 🤖 Robotics — Phase 5: Buy Hardware
- 🤖 Robotics — Phase 6: Sim-to-Real Bridge

Each list contains one **task per step** (matching the steps on the published
site) with the per-step micro-actions added as **checklist subitems** inside
each task.

## How to push

1. Open PowerShell on Windows.
2. `cd C:\Users\avezra\repro-robotics-plan\todo`
3. Dry-run first to preview:
   ```powershell
   .\push-todo.ps1 -WhatIf
   ```
4. Real run:
   ```powershell
   .\push-todo.ps1
   ```
5. A browser window opens. **Sign in as `aviadezra@hotmail.com`** and consent
   to the `Tasks.ReadWrite` permission (this is the Microsoft Graph PowerShell
   SDK's well-known public client app — no app registration needed on your end).
6. The script creates the lists, then the tasks, then the checklist subitems.
7. Open the **Microsoft To Do** app (web / Windows / iOS / Android) — the new
   lists appear in your sidebar within seconds.

The script is **idempotent**: re-running it reuses any existing list with a
matching name and skips any task whose title already exists. So if you edit
`robotics-tasks.json` to add a task, just re-run the script — only the new
items get pushed.

## Editing the tasks

`robotics-tasks.json` is the single source of truth. Add / rename / reorder
tasks there; subitems live under `subitems`. Then re-run `.\push-todo.ps1`.

## Why a script, not direct API integration

The CLI tool that authored this doesn't have an MSA token for your account.
Running the script locally means your credentials never leave your machine —
the browser-based device sign-in happens between you and Microsoft directly.
