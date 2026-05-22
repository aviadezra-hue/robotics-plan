# Robotics Learning Plan — From Simulation to Real Hardware

**Audience:** Senior developer (25 yrs), based in Israel, no prior robotics experience.
**Strategy:** Master the *software stack* in simulation first, then buy hardware with confidence.
**Total time to a working physical robot:** ~3–6 months of part-time work.

---

## Guiding Principles

1. **Simulate before you solder.** Bugs in simulation cost minutes; bugs on hardware cost weeks (and broken motors).
2. **Standard stack = ROS 2.** It's the lingua franca of modern robotics — every serious platform, paper, and job uses it. Skip ROS 1 (EOL May 2025).
3. **Pick one robot archetype first.** Don't try mobile + arm + drone simultaneously. Recommended start: **mobile ground robot (differential drive)** — easiest physics, richest tutorials, cheapest hardware.
4. **Math matters.** You don't need a PhD, but brush up on linear algebra, rigid-body transforms (SE(3)), and basic probability (for SLAM/Kalman filters).

---

## Phase 0 — Environment Setup (1 weekend)

**Goal:** ROS 2 running locally, "Hello, turtle" working.

- **OS:** Ubuntu 22.04 or 24.04 (native dual-boot strongly preferred over WSL2 for graphics/USB later).
  - Alternative: Docker with `osrf/ros:jazzy-desktop-full` if you want to stay on your current OS short-term.
- **Install ROS 2 Jazzy** (current LTS, supported until 2029): https://docs.ros.org/en/jazzy/Installation.html
- **Install Gazebo Harmonic** (the new Gazebo, bundled with Jazzy).
- **Editor:** VS Code with the `ROS` and `Python`/`C++` extensions.
- **Languages:** Python first (fast iteration), C++ later (real-time nodes, controllers).

**Validation checkpoint:** Run `ros2 run turtlesim turtlesim_node` and drive the turtle with `turtle_teleop_key`. If this works, you're set.

---

## Phase 1 — ROS 2 Fundamentals (2–3 weeks)

**Goal:** Comfortable with nodes, topics, services, actions, parameters, launch files, tf2, URDF.

**Primary resource:** Official ROS 2 tutorials — work through *every* beginner + intermediate tutorial:
https://docs.ros.org/en/jazzy/Tutorials.html

**Supplement with one book/course (pick one):**
- 📘 *A Concise Introduction to Robot Programming with ROS 2* — Fairchild & Harman (best for experienced devs).
- 🎥 Articulated Robotics YouTube channel (Josh Newans) — outstanding ROS 2 + Gazebo content, free.
- 🎥 The Construct's free ROS 2 Basics course (browser-based, no install).

**Mini-project deliverable:** Write a ROS 2 package (Python) with:
- A publisher node emitting fake odometry.
- A subscriber that logs and computes velocity.
- A launch file starting both with parameters.
- A custom message type.

---

## Phase 2 — Simulation Deep Dive (3–4 weeks)

**Goal:** Spawn a robot in Gazebo, drive it, read its sensors, visualize in RViz2.

**Pick a simulated robot to learn on:**
- **TurtleBot 4** (preferred — has excellent Gazebo model, mirrors a real robot you can buy later).
- Alternative: build your own URDF from scratch (Articulated Robotics has a great series on this).

**Topics to cover:**
- URDF / Xacro — describing the robot's geometry, joints, inertia.
- Gazebo plugins for differential drive, lidar, camera, IMU.
- RViz2 — visualizing tf trees, point clouds, costmaps.
- `ros2_control` — the standard hardware abstraction layer (do this now so swapping to real hardware later is trivial).

**Mini-project deliverable:** Teleop a simulated TurtleBot around a Gazebo world; visualize its lidar scan in RViz2.

---

## Phase 3 — Navigation & Perception (4–6 weeks)

**Goal:** Autonomous navigation in a known and unknown map.

**Two pillars:**

1. **Nav2** (https://navigation.ros.org/) — the ROS 2 navigation stack.
   - Run the Nav2 + TurtleBot 4 tutorial in simulation.
   - Understand: costmaps, global/local planners, behavior trees, recovery behaviors.

2. **SLAM** — mapping + localization.
   - `slam_toolbox` for 2D lidar SLAM.
   - `nav2_amcl` for localization in a known map.
   - Optional next step: RTAB-Map for visual/3D SLAM.

**Mini-project deliverable:** In simulation, drive the robot to map an environment, save the map, restart, localize, and send navigation goals from RViz2 — fully autonomous.

---

## Phase 4 — Pick a Specialization (ongoing)

Choose **one** based on interest:

| Track | What you'll learn | Sim tools |
|---|---|---|
| **Manipulation** (arms) | MoveIt 2, inverse kinematics, motion planning, grasping | Gazebo + MoveIt, or Isaac Sim |
| **Mobile robots** (continue) | Multi-robot, outdoor nav, GPS fusion (robot_localization) | Gazebo |
| **Drones** | PX4 + ROS 2 bridge, attitude control | Gazebo + PX4 SITL |
| **Reinforcement learning** | Sim-to-real transfer, policy learning | NVIDIA Isaac Lab |
| **Computer vision** | YOLO + ROS 2, depth cameras, visual servoing | Gazebo with RGB-D plugin |

**For an experienced developer**, I'd recommend **manipulation** — it's where most industrial/commercial robotics jobs are, and the math is meaty enough to stay interesting.

---

## Phase 5 — Buy Hardware (after ~3 months of sim work)

**Selection criteria — in order:**
1. Has an *officially supported* ROS 2 driver.
2. Active community / recent commits.
3. Replacement parts available in Israel or shippable.
4. Within your budget for a *learning* robot — don't buy your dream machine first.

### Recommended first physical robots (by track)

**Mobile ground robot:**
- 🥇 **TurtleBot 4 Lite** (~$1,300 USD) — official ROS 2 reference platform, matches what you simulated. Best beginner choice.
- 💰 **LeoRover** or **Husarion ROSbot 2R** — slightly more capable, outdoor-ish.
- 🛠️ **DIY:** Raspberry Pi 5 + RPLidar A1 + a chassis from Aliexpress (~$300). Much more learning per shekel, but expect frustration.

**Arm:**
- 🥇 **WidowX 250 S** (Trossen Robotics, ~$2,400) — well-supported in ROS 2/MoveIt.
- 💰 **SO-100 / SO-ARM100** by Hugging Face LeRobot (~$120 in parts, 3D-printed) — bleeding edge but cheap and a phenomenal learning project.
- Industrial taste: **uFactory xArm Lite 6** (~$5K) — overkill but real-world relevant.

**Drone:**
- **Holybro X500 V2 + Pixhawk 6C** — standard PX4 + ROS 2 dev kit.

### Israel-specific shipping notes
- Most US/EU robotics vendors ship to Israel but watch for VAT (17%) + customs above ~$75 USD declared value.
- **Local options:** RobotShop ships to IL; some Aliexpress sellers stock chassis/motors with reasonable delivery. For 3D-printed builds (SO-ARM100), local makerspaces (XLN in Tel Aviv, Hackerspace TLV) have printers.
- Lidar units and lithium batteries occasionally get held in customs — declare honestly.

---

## Phase 6 — Sim-to-Real Bridge (after hardware arrives, 2–4 weeks)

Expected pain points and how to handle them:
- **Calibration:** real sensors are noisy; tune your filters with real data.
- **`ros2_control` hardware interface:** if you used it in sim, swapping is mostly config.
- **Timing/latency:** the real world is not deterministic. Use RT_PREEMPT kernel if needed.
- **Power management:** batteries die at the worst times. Add voltage monitoring early.

**Validation milestone:** reproduce your Phase 3 autonomous-navigation milestone on the real robot in your apartment.

---

## Ongoing Learning & Community

- 📖 *Modern Robotics* by Kevin Lynch (free book + Coursera) — the canonical theory text.
- 📖 *Probabilistic Robotics* by Thrun et al. — for when you want to *understand* SLAM, not just run it.
- 🌐 https://discourse.ros.org/ — official forum, very active.
- 🌐 r/ROS, r/robotics on Reddit.
- 🇮🇱 **Israeli community:** IROB (Israel Robotics Association), Technion & TAU robotics labs occasionally host open talks, ROS Israel meetup group (irregular but real).
- 🎓 Free advanced courses: MIT 6.4210 (Robotic Manipulation, Russ Tedrake) — uses Drake instead of ROS, but the lectures are world-class.

---

## Suggested Weekly Cadence

- **Weekdays:** 30–60 min of reading/tutorials.
- **Weekends:** 3–4 hour focused session — building, debugging, the mini-project for that phase.

At this pace: Phase 0–3 done in ~3 months, hardware ordered, by month 5–6 you have a working autonomous robot in your home.

---

## Quick-Start Checklist (do this week)

- [ ] Install Ubuntu 24.04 (dual-boot) or set up Docker.
- [ ] Install ROS 2 Jazzy + Gazebo Harmonic.
- [ ] Run the turtlesim hello-world.
- [ ] Subscribe to Articulated Robotics on YouTube.
- [ ] Bookmark https://docs.ros.org/en/jazzy/ and https://navigation.ros.org/.
- [ ] Decide your Phase 4 specialization tentatively (you can change later).
