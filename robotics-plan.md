# 🤖 Aviad Ezra's Robotics Learning Plan

### *Tailored for a senior dev in 🇮🇱 Israel · From Simulation to Real Hardware*

> **👤 Audience:** Senior developer (25 yrs), based in 🇮🇱 Israel, new to robotics.
> **🎯 Strategy:** Master the *software stack* in simulation first, then buy hardware with confidence.
> **⏱️ Time to working physical robot:** ~3–6 months of part-time work.

---

## 🧭 Guiding Principles

| # | Principle | Why it matters |
|:-:|---|---|
| 1️⃣ | **Simulate before you solder** | Bugs in simulation cost minutes; bugs on hardware cost weeks (and broken motors). |
| 2️⃣ | **Standard stack = ROS 2** | Lingua franca of modern robotics — every serious platform, paper, and job uses it. Skip ROS 1 (EOL May 2025). |
| 3️⃣ | **Pick one robot archetype first** | Don't try mobile + arm + drone simultaneously. Recommended start: **mobile ground robot (differential drive)** — easiest physics, richest tutorials, cheapest hardware. |
| 4️⃣ | **Math matters** | Brush up on linear algebra, rigid-body transforms (SE(3)), and basic probability (for SLAM/Kalman filters). |

---

## 🛠️ Phase 0 — Environment Setup

![Phase 0 illustration](https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1400&h=360&fit=crop&q=80 "Set up your Linux + ROS 2 environment")

> ⏰ **1 weekend** &nbsp;·&nbsp; 🎯 **Goal:** ROS 2 + Gazebo running inside WSL2 on your Windows 11 laptop, "Hello, turtle" working.

We're going **WSL2 + WSLg + Ubuntu 24.04** — keeps you on Windows, gets you a real Linux for ROS, and WSLg gives you the GUI windows (RViz/Gazebo) for free.

### 📋 Step-by-step setup

**1. Confirm prerequisites** (open PowerShell as Administrator)
```powershell
winver           # must be Windows 11 (build 22000+)
wsl --status     # if "not installed", that's expected — next step fixes it
```

**2. Install WSL + Ubuntu 24.04**
```powershell
wsl --install -d Ubuntu-24.04
```
Reboot when prompted. On first launch, set a Linux username + password (any value — local only).

**3. Update GPU drivers (host Windows)**
- 🟢 NVIDIA: install the latest [CUDA-on-WSL driver](https://developer.nvidia.com/cuda/wsl)
- 🔴 AMD: latest Adrenalin
- 🔵 Intel: latest from intel.com/download

**4. Install ROS 2 Jazzy + Gazebo inside Ubuntu**

From the Ubuntu shell:
```bash
# Enable universe + add ROS 2 apt key
sudo apt update && sudo apt install -y software-properties-common curl
sudo add-apt-repository universe
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install desktop bundle (RViz2, demos, etc.) + Gazebo
sudo apt update
sudo apt install -y ros-jazzy-desktop-full ros-jazzy-ros-gz

# Source ROS in every new shell
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

**5. VS Code with Remote-WSL**
- Install [VS Code](https://code.visualstudio.com/) on Windows (already done ✅)
- Install the **WSL** extension (formerly "Remote - WSL")
- From Ubuntu shell: `code .` opens VS Code attached to WSL

### ✅ Validation checkpoint
From the Ubuntu shell:
```bash
ros2 run turtlesim turtlesim_node
```
A blue window with a little turtle should pop up on your Windows desktop (via WSLg). In a second Ubuntu shell:
```bash
ros2 run turtlesim turtle_teleop_key
```
Use the arrow keys — if the turtle moves, **Phase 0 is done**.

### 🛟 Common WSL2 debugging gotchas

| Symptom | Fix |
|---|---|
| ❌ `wsl --install` errors with `0x8007007e` or hangs | Update Windows fully, ensure virtualization is enabled in BIOS (`systeminfo` → look for "Virtualization Enabled In Firmware: Yes") |
| ❌ Turtlesim window never appears | Run `wsl --update` from Windows PowerShell; restart WSL: `wsl --shutdown` then reopen Ubuntu |
| ❌ Gazebo opens but renders black / 1 FPS | GPU driver not WSL-aware. Reinstall the CUDA-on-WSL (NVIDIA) or latest Adrenalin (AMD) driver on **Windows host**, not inside Ubuntu |
| ❌ Audio / GPU acceleration missing | `wsl --update` then `wsl --shutdown`; confirm WSLg with `wslg --version` |
| ❌ DNS / apt update fails | Edit `/etc/wsl.conf` (in Ubuntu): add `[network]\ngenerateResolvConf = false`, then write `/etc/resolv.conf` with `nameserver 8.8.8.8`. Restart WSL. |
| ❌ Cannot access Windows files / slow | Keep ROS workspaces under `~/` (the Linux filesystem), **not** under `/mnt/c/`. Cross-filesystem I/O is 10–100× slower. |
| ❌ "WSLg failed to start" on external monitor (DisplayLink) | Move the WSLg window to the **internal laptop display** for now; DisplayLink + WSLg have known issues |
| ❌ USB devices (lidars, microcontrollers) not visible | Install [`usbipd-win`](https://github.com/dorssel/usbipd-win) on Windows host, then `usbipd attach --busid <id> --wsl` |
| ❌ `command not found: ros2` after a new terminal | The `source /opt/ros/jazzy/setup.bash` line wasn't added to `~/.bashrc` — re-run step 4's last block |
| ⚠️ Real-time motor control later (Phase 6) | WSL2 can't do `RT_PREEMPT`. For hard-real-time needs you'll eventually want native Ubuntu — but you can defer that for many months. |

> 🏆 **Verdict:** WSL2 + WSLg covers Phases 0–4 comfortably on your Win 11 + Core Ultra 7 + RTX 500 Ada laptop. If Gazebo ever becomes painful, or you need RT_PREEMPT for real hardware, set up dual-boot Ubuntu at that point — your ROS code will move over unchanged.

---

## 📚 Phase 1 — ROS 2 Fundamentals

![Phase 1 illustration](https://images.unsplash.com/photo-1518770660439-4636190af475?w=1400&h=360&fit=crop&q=80 "Learn the ROS 2 building blocks — nodes, topics, services")

> ⏰ **2–3 weeks** &nbsp;·&nbsp; 🎯 **Goal:** Comfortable with nodes, topics, services, actions, parameters, launch files, tf2, URDF.

📖 **Primary resource:** Official ROS 2 tutorials — work through *every* beginner + intermediate tutorial:
👉 https://docs.ros.org/en/jazzy/Tutorials.html

**Supplement with one resource (pick one):**

| Type | Resource | Notes |
|:-:|---|---|
| 📘 | *A Concise Introduction to Robot Programming with ROS 2* — Fairchild & Harman | Best for experienced devs |
| 🎥 | [Articulated Robotics](https://articulatedrobotics.xyz/) YouTube (Josh Newans) | Outstanding ROS 2 + Gazebo content, free |
| 🎓 | [The Construct's free ROS 2 Basics](https://www.theconstruct.ai/) | Browser-based, no install |

> 🎯 **Mini-project deliverable:** Write a ROS 2 package (Python) with:
> - A publisher node emitting fake odometry
> - A subscriber that logs and computes velocity
> - A launch file starting both with parameters
> - A custom message type

---

## 🌍 Phase 2 — Simulation Deep Dive

![Phase 2 illustration](https://images.unsplash.com/photo-1581090700227-1e37b190418e?w=1400&h=360&fit=crop&q=80 "Spawn and control robots in a Gazebo simulated world")

> ⏰ **3–4 weeks** &nbsp;·&nbsp; 🎯 **Goal:** Spawn a robot in Gazebo, drive it, read its sensors, visualize in RViz2.

🤖 **Pick a simulated robot to learn on:**

- ⭐ **TurtleBot 4** (preferred — has excellent Gazebo model, mirrors a real robot you can buy later)
- 🔧 Alternative: build your own URDF from scratch (Articulated Robotics has a great series on this)

🧩 **Topics to cover:**

- 📐 **URDF / Xacro** — describing the robot's geometry, joints, inertia
- 🔌 **Gazebo plugins** for differential drive, lidar, camera, IMU
- 👁️ **RViz2** — visualizing tf trees, point clouds, costmaps
- 🎛️ **`ros2_control`** — the standard hardware abstraction layer (do this now so swapping to real hardware later is trivial)

> 🎯 **Mini-project deliverable:** Teleop a simulated TurtleBot around a Gazebo world; visualize its lidar scan in RViz2.

---

## 🧭 Phase 3 — Navigation & Perception

![Phase 3 illustration](https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=1400&h=360&fit=crop&q=80 "Build maps, localize and navigate autonomously")

> ⏰ **4–6 weeks** &nbsp;·&nbsp; 🎯 **Goal:** Autonomous navigation in a known and unknown map.

**Two pillars:**

### 🗺️ 1. Nav2

The ROS 2 navigation stack — 👉 https://navigation.ros.org/

- Run the Nav2 + TurtleBot 4 tutorial in simulation
- Understand: costmaps, global/local planners, behavior trees, recovery behaviors

### 📡 2. SLAM — Mapping + Localization

- 🗺️ `slam_toolbox` for 2D lidar SLAM
- 📍 `nav2_amcl` for localization in a known map
- 🔮 Optional next step: RTAB-Map for visual/3D SLAM

> 🎯 **Mini-project deliverable:** In simulation, drive the robot to map an environment, save the map, restart, localize, and send navigation goals from RViz2 — fully autonomous.

---

## 🎯 Phase 4 — Pick a Specialization

![Phase 4 illustration](https://images.unsplash.com/photo-1561557944-6e7860d1a7eb?w=1400&h=360&fit=crop&q=80 "Pick a track — manipulation, mobile, drones, RL, or vision")

> 🎯 **Goal:** Choose **one** track based on interest.

| Track | What you'll learn | Sim tools |
|---|---|---|
| 🦾 **Manipulation** (arms) | MoveIt 2, inverse kinematics, motion planning, grasping | Gazebo + MoveIt, or Isaac Sim |
| 🚗 **Mobile robots** (continue) | Multi-robot, outdoor nav, GPS fusion (robot_localization) | Gazebo |
| 🚁 **Drones** | PX4 + ROS 2 bridge, attitude control | Gazebo + PX4 SITL |
| 🧠 **Reinforcement learning** | Sim-to-real transfer, policy learning | NVIDIA Isaac Lab |
| 👁️ **Computer vision** | YOLO + ROS 2, depth cameras, visual servoing | Gazebo with RGB-D plugin |

> 💡 **For an experienced developer**, I'd recommend **🦾 manipulation** — it's where most industrial/commercial robotics jobs are, and the math is meaty enough to stay interesting.

---

## 🛒 Phase 5 — Buy Hardware

![Phase 5 illustration](https://images.unsplash.com/photo-1546776230-bb86256870ce?w=1400&h=360&fit=crop&q=80 "Choose your first real robot — TurtleBot, arm, or drone")

> ⏰ **After ~3 months of sim work**

**🎯 Selection criteria — in order:**

1. ✅ Has an *officially supported* ROS 2 driver
2. 🌟 Active community / recent commits
3. 📦 Replacement parts available in Israel or shippable
4. 💰 Within your budget for a *learning* robot — don't buy your dream machine first

### 🤖 Recommended first physical robots (by track)

#### 🚗 Mobile ground robot

| Tier | Robot | Price | Notes |
|:-:|---|---|---|
| 🥇 | **TurtleBot 4 Lite** | ~$1,300 | Official ROS 2 reference platform, matches what you simulated. Best beginner choice. |
| 💰 | **LeoRover** / **Husarion ROSbot 2R** | $2K+ | Slightly more capable, outdoor-ish |
| 🛠️ | **DIY:** Raspberry Pi 5 + RPLidar A1 + chassis | ~$300 | Much more learning per shekel, but expect frustration |

#### 🦾 Arm

| Tier | Robot | Price | Notes |
|:-:|---|---|---|
| 🥇 | **WidowX 250 S** (Trossen Robotics) | ~$2,400 | Well-supported in ROS 2/MoveIt |
| 💰 | **SO-100 / SO-ARM100** by Hugging Face LeRobot | ~$120 (parts) | 3D-printed, bleeding edge but cheap and phenomenal learning project |
| 🏭 | **uFactory xArm Lite 6** | ~$5K | Industrial-flavor, real-world relevant |

#### 🚁 Drone

- **Holybro X500 V2 + Pixhawk 6C** — standard PX4 + ROS 2 dev kit

### 🇮🇱 Israel-specific shipping notes

- 📦 Most US/EU robotics vendors ship to Israel but watch for VAT (17%) + customs above ~$75 USD declared value
- 🏪 **Local options:** RobotShop ships to IL; some Aliexpress sellers stock chassis/motors with reasonable delivery
- 🖨️ For 3D-printed builds (SO-ARM100), local makerspaces (XLN in Tel Aviv, Hackerspace TLV) have printers
- ⚠️ Lidar units and lithium batteries occasionally get held in customs — declare honestly

---

## 🔗 Phase 6 — Sim-to-Real Bridge

![Phase 6 illustration](https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=1400&h=360&fit=crop&q=80 "Bring what you built in simulation into the real world")

> ⏰ **2–4 weeks after hardware arrives**

**🚧 Expected pain points and how to handle them:**

- 📡 **Calibration:** real sensors are noisy; tune your filters with real data
- 🎛️ **`ros2_control` hardware interface:** if you used it in sim, swapping is mostly config
- ⏱️ **Timing/latency:** the real world is not deterministic. Use RT_PREEMPT kernel if needed
- 🔋 **Power management:** batteries die at the worst times. Add voltage monitoring early

> 🏁 **Validation milestone:** reproduce your Phase 3 autonomous-navigation milestone on the real robot in your apartment.

---

## 🎓 Ongoing Learning & Community

### 📖 Books

- 📕 *[Modern Robotics](http://hades.mech.northwestern.edu/index.php/Modern_Robotics)* by Kevin Lynch (free book + Coursera) — the canonical theory text
- 📗 *Probabilistic Robotics* by Thrun et al. — for when you want to *understand* SLAM, not just run it

### 🌐 Communities

- 💬 [ROS Discourse](https://discourse.ros.org/) — official forum, very active
- 🤖 [r/ROS](https://www.reddit.com/r/ROS/), [r/robotics](https://www.reddit.com/r/robotics/) on Reddit
- 🇮🇱 **Israeli community:** IROB (Israel Robotics Association), Technion & TAU robotics labs occasionally host open talks, ROS Israel meetup group (irregular but real)

### 🎓 Free advanced courses

- 🏛️ [MIT 6.4210 (Robotic Manipulation)](https://manipulation.csail.mit.edu/) by Russ Tedrake — uses Drake instead of ROS, but the lectures are world-class

---

## 📅 Suggested Weekly Cadence

| When | What | Duration |
|---|---|:-:|
| 📆 **Weekdays** | Reading/tutorials | 30–60 min |
| 🗓️ **Weekends** | Focused build/debug session, mini-project for that phase | 3–4 hours |

> ⏱️ **At this pace:** Phase 0–3 done in ~3 months, hardware ordered, by month 5–6 you have a working autonomous robot in your home.

---

## ✅ Quick-Start Checklist (do this week)

- [ ] 🐧 Install Ubuntu 24.04 (dual-boot) or set up WSL2
- [ ] 📦 Install ROS 2 Jazzy + Gazebo Harmonic
- [ ] 🐢 Run the turtlesim hello-world
- [ ] 📺 Subscribe to [Articulated Robotics](https://articulatedrobotics.xyz/) on YouTube
- [ ] 🔖 Bookmark https://docs.ros.org/en/jazzy/ and https://navigation.ros.org/
- [ ] 🎯 Decide your Phase 4 specialization tentatively (you can change later)
