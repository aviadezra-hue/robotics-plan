# 🤖 Robotics Learning Plan

### *From Simulation to Real Hardware*

![ROS 2](https://img.shields.io/badge/ROS_2-Jazzy-22314E?style=for-the-badge&logo=ros&logoColor=white)
![Gazebo](https://img.shields.io/badge/Gazebo-Harmonic-FB6904?style=for-the-badge)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)
![C++](https://img.shields.io/badge/C++-17-00599C?style=for-the-badge&logo=cplusplus&logoColor=white)
![Duration](https://img.shields.io/badge/Duration-3--6_months-success?style=for-the-badge)

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

> ⏰ **1 weekend** &nbsp;·&nbsp; 🎯 **Goal:** ROS 2 running locally, "Hello, turtle" working.

- 🐧 **OS:** Ubuntu 22.04 or 24.04. See **"💻 Setup on a Windows machine"** below for the recommended WSL2 path if you don't want to dual-boot yet.
- 📦 **Install ROS 2 Jazzy** (current LTS, supported until 2029): https://docs.ros.org/en/jazzy/Installation.html
- 🌍 **Install Gazebo Harmonic** (the new Gazebo, bundled with Jazzy).
- 💻 **Editor:** VS Code with the `ROS` and `Python`/`C++` extensions.
- 🐍 **Languages:** Python first (fast iteration), C++ later (real-time nodes, controllers).

> ✅ **Validation checkpoint:** Run `ros2 run turtlesim turtlesim_node` and drive the turtle with `turtle_teleop_key`. If this works, you're set.

### 💻 Setup on a Windows machine

You can absolutely do Phases 0–4 from Windows. Ranked by recommendation:

#### 🥇 WSL2 + WSLg (recommended — start here)

Windows 11 + Ubuntu 24.04 inside WSL2, with WSLg providing built-in Linux GUI support.

- ✅ Stay in Windows; install with: `wsl --install -d Ubuntu-24.04`
- ✅ ROS 2 Jazzy + RViz2 work great out of the box
- ✅ VS Code "Remote - WSL" extension = seamless dev experience
- ⚠️ **Gazebo Harmonic**: works on Win 11 with WSLg + recent NVIDIA/AMD GPU drivers, but can be flaky. Performance is roughly 60–80% of native Ubuntu. Some plugins occasionally crash.
- ⚠️ **USB devices** (real lidars, microcontrollers in Phase 5): need [`usbipd-win`](https://github.com/dorssel/usbipd-win) to forward USB into WSL. Extra friction but well-documented.
- ⚠️ **Real-time control** (later phases): WSL2 cannot run a `RT_PREEMPT` kernel. Serious motor control eventually needs native Linux.

**📋 Setup checklist:**
1. Confirm Windows 11 (Win 10 WSLg works but is noticeably worse).
2. Update GPU drivers — NVIDIA's CUDA-on-WSL driver or AMD Adrenalin latest.
3. `wsl --install -d Ubuntu-24.04` in an admin PowerShell, then reboot.
4. Inside Ubuntu: install ROS 2 Jazzy via the official docs.
5. Install VS Code + the **Remote - WSL** extension on Windows.
6. Test: `ros2 run turtlesim turtlesim_node` — the GUI should pop up automatically via WSLg.

> 🏆 **Verdict:** Best balance of "start today" vs "tools work." Recommended for Phases 0–4.

#### 🥈 Docker Desktop + ROS containers

Run `osrf/ros:jazzy-desktop-full` in Docker.

- ✅ Quick start, isolated, easy to nuke and retry
- ⚠️ GUI apps (RViz, Gazebo) need an X server setup
- ⚠️ Limited GPU passthrough on Windows
- ❌ Worst experience for graphical simulation

> 💡 **Verdict:** Fine for headless ROS 2 fundamentals; painful for Gazebo.

#### 🥉 Native Windows ROS 2

Microsoft officially supports ROS 2 on Windows.

- ✅ No Linux at all
- ❌ **Gazebo Harmonic is not officially supported on Windows** — deal-breaker for Phases 2–4
- ❌ Most tutorials assume Linux; constant translation
- ❌ Smaller community, fewer Stack Overflow answers

> ⚠️ **Verdict:** Don't recommend for a learning journey.

#### 🏆 Dual-boot Ubuntu (gold standard, defer if possible)

- ✅ Best performance, every tool works first-try
- ✅ When you reach real hardware, USB and RT just work
- ❌ Requires partitioning + reboot to switch

> 💡 **Verdict:** Worth it when you commit beyond Phase 2 or buy hardware. Not required to start.

#### 🎯 Recommendation for this plan

**Start on WSL2 today.** If Gazebo gets painful during Phase 2, or when you buy hardware in Phase 5, set up a dual-boot Ubuntu partition. By then you'll know exactly what you need and the migration is trivial (same ROS 2 packages, same code).

---

## 📚 Phase 1 — ROS 2 Fundamentals

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
