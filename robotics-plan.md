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

**6. If WSLg renders GUIs as a black window — switch to VcXsrv** *(needed on multi-GPU laptops, e.g. Intel + NVIDIA + DisplayLink dock)*

Symptom: turtlesim/RViz/Gazebo windows open but are entirely black, or appear in the taskbar but won't come to the foreground (look for `[WARN:COPY MODE]` in the window title). The fix is to bypass WSLg with a native Windows X server.

```powershell
# On Windows host (PowerShell as Admin)
winget install --id marha.VcXsrv
# Open the firewall for X11 traffic from WSL
New-NetFirewallRule -DisplayName "VcXsrv (WSL X11)" -Direction Inbound `
  -Protocol TCP -LocalPort 6000-6063 -Action Allow -Profile Any
```

Launch VcXsrv with the right flags (or save these into the Startup folder so it auto-starts):
```
"C:\Program Files\VcXsrv\vcxsrv.exe" -multiwindow -clipboard -wgl -ac -noprimary
```

Then in Ubuntu, append to `~/.bashrc` and reload:
```bash
echo 'export DISPLAY=$(ip route show default | awk "{print \$3}"):0' >> ~/.bashrc
echo 'unset WAYLAND_DISPLAY' >> ~/.bashrc
source ~/.bashrc
```

GUI apps now render through VcXsrv (the window title shows an "X" icon instead of the Tux/penguin) and the COPY-MODE bug is gone.

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

<figure class="screenshot">
  <img src="images/phase0-turtlesim.png" alt="TurtleSim window showing a turtle that has drawn a connected pentagon-like path on a blue canvas, rendered through VcXsrv on Windows 11" />
  <figcaption>🐢 Real result from my own Phase 0 run — turtle responding to arrow-key teleop and drawing its path. Window rendered via VcXsrv on Windows 11 (note the "X" icon in the title bar). If your turtle moves and leaves a trail, ROS 2 + your display stack are fully working.</figcaption>
</figure>

---

## 📚 Phase 1 — ROS 2 Fundamentals

![Phase 1 illustration](https://images.unsplash.com/photo-1518770660439-4636190af475?w=1400&h=360&fit=crop&q=80 "Learn the ROS 2 building blocks — nodes, topics, services")

> ⏰ **2–3 weeks** &nbsp;·&nbsp; 🎯 **Goal:** Comfortable with nodes, topics, services, actions, parameters, launch files, tf2, URDF.

### 📋 Step 1 — Create your ROS 2 workspace (do this once)

A *workspace* is just a folder where your ROS 2 packages live and where the `colcon` build tool compiles them. Every ROS 2 project you write will live here.

You'll be typing commands into the **Ubuntu terminal** (not Windows PowerShell). Run each command one at a time, wait for it to finish, then move on.

---

**1.1 Open Ubuntu**

Press the Windows key → type `Ubuntu` → click *Ubuntu 24.04*.

A terminal window opens. The prompt looks like `aviad@HOSTNAME:~$`. The `~` means you're in your home folder (`/home/aviad`). ✅

---

**1.2 Confirm ROS 2 is installed and active**

Type:
```bash
ros2 --help
```

**Expected:** a long list of subcommands (`bag`, `node`, `run`, `topic`, …).

**If you see `ros2: command not found`** → ROS 2 isn't being loaded automatically. Fix it by running these two commands:
```bash
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
```
Then try `ros2 --help` again.

---

**1.3 Create the workspace folder**

```bash
mkdir -p ~/ros2_ws/src
```
Creates `~/ros2_ws/` with an empty `src/` subfolder inside it. The `-p` flag means "create parent folders too, don't error if they exist".

```bash
cd ~/ros2_ws
```
Moves you into the workspace. Your prompt should now end with `~/ros2_ws$`.

> ℹ️ The `src/` subfolder is **mandatory** — `colcon` only looks for packages there. The other folders (`build/`, `install/`, `log/`) will be created automatically the first time you build.

---

**1.4 Install the ROS 2 build tools (one-time)**

You need three packages: **colcon** (the build system), **rosdep** (resolves system dependencies of ROS packages), and **argcomplete** (tab-completion for `ros2`). Run these commands **one at a time, in order**:

**Command 1 of 4** — refresh the apt package index:
```bash
sudo apt update
```
On this machine, `sudo` is configured **passwordless** for the `aviad` user (set up in Phase 0), so it runs immediately. On a fresh install where you set a password during first launch, this is where Ubuntu would ask for it.

**Command 2 of 4** — install the three tool packages:
```bash
sudo apt install -y python3-colcon-common-extensions python3-rosdep python3-argcomplete
```
Takes ~30 seconds. The `-y` means "answer yes to confirmation prompts".

**Command 3 of 4** — initialize the system-wide rosdep database:
```bash
sudo rosdep init
```
**Expected:** `Wrote /etc/ros/rosdep/sources.list.d/20-default.list`.
**If you see** `ERROR: default sources list file already exists` → ignore it, that just means it was already initialized. Move on.

**Command 4 of 4** — pull down the latest dependency mappings (this one is *not* sudo):
```bash
rosdep update
```
Takes ~20 seconds. Lots of `reading in sources list data` lines, ending with `updated cache`.

---

**1.5 Do an empty build to prove the workspace works**

```bash
cd ~/ros2_ws
colcon build --symlink-install
```
Takes ~5 seconds.

**Expected output:** ends with `Summary: 0 packages finished` — that's correct, you don't have any packages yet, you're just confirming `colcon` runs.

Now check the folder contents:
```bash
ls
```
**Expected:** you should see `build  install  log  src` — those three new folders were created by the build. ✅

> 💡 The `--symlink-install` flag means Python files in your packages will be *symlinked* (not copied) into `install/`. So when you edit a `.py` you don't need to rebuild. Always use it during development.

---

**1.6 Make every new terminal auto-load your workspace**

```bash
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
```
Appends one line to your shell startup file. From now on, every Ubuntu terminal you open will automatically know about packages in `~/ros2_ws`.

```bash
source ~/.bashrc
```
Re-loads `.bashrc` in the *current* terminal so you don't have to close it.

> ℹ️ This is called "overlaying" — your workspace sits on top of the system ROS install. Any package you build in `~/ros2_ws/src/` becomes available to `ros2 run`, `ros2 launch`, etc.

---

**1.7 Open the workspace in VS Code**

```bash
cd ~/ros2_ws
code .
```
The first time you run `code` from WSL, it installs the VS Code Server inside Ubuntu (~30 seconds, one-time). VS Code then opens on Windows with a green `>< WSL: Ubuntu-24.04` badge in the bottom-left corner — that confirms it's attached to Ubuntu, not Windows.

Now install the extensions you'll need. Click the **Extensions** icon in the left sidebar (the four-squares icon, or `Ctrl+Shift+X`) and search for and install each of these. **Important:** each one must say *"Install in WSL: Ubuntu-24.04"* on the green button (not just "Install"):

- **Robotics Developer Environment** by Ranch Hand Robotics — the extension pack that replaces the now-deprecated Microsoft `ROS` extension. It bundles the Robot Developer Extension for ROS 2 + URDF/Xacro editor + related tooling. *(If VS Code suggested it as a replacement, accept the suggestion — it's the right one.)*
- **Python** by Microsoft — IntelliSense + debugger
- **CMake Tools** by Microsoft — for C++ packages later

> ⚠️ **Don't install the old `ROS` extension by Microsoft (`ms-iot.vscode-ros`)** — it was archived in September 2025 when the Azure Edge Robotics team was disbanded. The same lead maintainer now ships the modern version through Ranch Hand Robotics, with active ROS 2 + AI/Copilot integration features.

---

**1.8 Smoke-test the whole stack with a stock ROS 2 demo**

You'll run two programs that ship with ROS 2 — a *talker* that publishes messages and a *listener* that subscribes — to confirm everything talks to each other.

**Terminal A** (your current Ubuntu window):
```bash
ros2 run demo_nodes_cpp talker
```
**Expected:** a line printed every second: `[INFO] [talker]: Publishing: 'Hello World: 1'`, then `2`, `3`, …

**Terminal B** — open a *second* Ubuntu window: Windows key → *Ubuntu 24.04* (yes, you can have multiple). Then:
```bash
ros2 run demo_nodes_py listener
```
**Expected:** matching lines: `[INFO] [listener]: I heard: [Hello World: 7]`, with the same numbers showing up.

**✅ If the listener sees the talker's messages, your ROS 2 workspace is fully working and you're ready for Step 2.**

<figure class="screenshot wide">
  <img src="images/phase1-talker-listener.png" alt="Two Ubuntu terminal windows side by side: the left running ros2 run demo_nodes_cpp talker publishing 'Hello World: N' messages, the right running ros2 run demo_nodes_py listener echoing 'I heard: [Hello World: N]' with matching sequence numbers" />
  <figcaption>🎉 My own Step 1.8 result — talker (left) publishing <code>Hello World: 32→60</code>, listener (right) echoing the same sequence. Matching numbers = pub/sub transport working end-to-end across two independent processes.</figcaption>
</figure>

To stop: in each terminal, press `Ctrl+C`.

---

### 📚 Step 2 — Explore the ROS 2 CLI with turtlesim

ROS 2's runtime is built around four core concepts: **nodes** (processes), **topics** (pub/sub streams), **services** (request/response calls), and **parameters** (live config). Plus two glue layers: **launch** (start many nodes at once) and **bag** (record/replay). The fastest way to feel them is to introspect a live system — and `turtlesim` is the perfect playground (tiny but exposes every concept).

You'll need **3 Ubuntu terminals open** for most of this step. I'll call them **Terminal A**, **B**, **C** (open a fourth, D, later).

---

**2.1 Launch turtlesim and visualize the running graph**

**Terminal A** — start turtlesim:
```bash
ros2 run turtlesim turtlesim_node
```
The blue turtle window pops up (rendered via VcXsrv).

**Terminal B** — start the keyboard teleop:
```bash
ros2 run turtlesim turtle_teleop_key
```
Click in this terminal to give it focus, then arrow keys to drive the turtle.

**Terminal C** — view the live system graph:
```bash
rqt_graph
```
A graphical window opens showing two oval nodes (`/turtlesim`, `/teleop_turtle`) connected by an arrow labeled `/turtle1/cmd_vel` (plus a couple of `/turtle1/rotate_absolute/_action/...` arrows for teleop's rotate action). Click the refresh icon (top-left) if it's empty. Those arrows *are* your running system — boxes are nodes, arrows are topics/actions.

<figure class="screenshot wide">
  <img src="images/phase1-rqt-graph.png" alt="rqt_graph window showing two oval nodes, /teleop_turtle and /turtlesim, connected by arrows labeled /turtle1/cmd_vel and two /turtle1/rotate_absolute action topics" />
  <figcaption>🔍 My Step 2.1 result — <code>rqt_graph</code> of the live turtlesim + teleop system. Two nodes, one main pub/sub arrow (<code>/turtle1/cmd_vel</code>), plus the rotate-absolute action wiring.</figcaption>
</figure>

**Why it matters:** every ROS 2 system you'll ever build looks like this. `rqt_graph` is the first tool you reach for when joining an unfamiliar project.

Close the rqt_graph window when done (keep A and B running).

---

**2.2 List and inspect nodes**

In **Terminal C**:
```bash
ros2 node list
```
**Expected:**
```
/teleop_turtle
/turtlesim
```

```bash
ros2 node info /turtlesim
```
**Expected:** a structured dump listing every publisher, subscriber, service, and action the node exposes — `/turtle1/cmd_vel` (subscriber), `/turtle1/pose` (publisher), `/spawn` (service server), etc.

**Why it matters:** when you join a project with 30 unfamiliar nodes, this is how you reverse-engineer it. Same command, every time.

---

**2.3 Inspect topics from the CLI**

```bash
ros2 topic list
```
**Expected:** `/turtle1/cmd_vel`, `/turtle1/pose`, `/turtle1/color_sensor`, `/parameter_events`, `/rosout`.

```bash
ros2 topic echo /turtle1/pose
```
Streams the turtle's `x`, `y`, `theta` continuously. Drive the turtle in Terminal B with the arrow keys and watch the values change live. Press `Ctrl+C` when done watching.

```bash
ros2 topic hz /turtle1/pose
```
Reports the publish rate. **Expected:** `average rate: 62.5`. Ctrl-C.

**Why it matters:** `topic echo` and `hz` are 80% of how you debug a real robot from the terminal — confirm a sensor is publishing and check its rate.

---

**2.4 Publish to a topic — drive the turtle from the CLI**

Instead of using the keyboard teleop, you can inject commands yourself by publishing directly to `/turtle1/cmd_vel`. The message type is `geometry_msgs/Twist` (a linear velocity vector + an angular velocity vector).

Run this in **Terminal C**:

```bash
ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/Twist \
  "{linear: {x: 2.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 1.5}}"
```

**What this means:**
- `--once` → send a single message, then exit (drop it and add `-r 1` for "publish at 1 Hz continuously")
- `/turtle1/cmd_vel` → the topic to publish on
- `geometry_msgs/Twist` → the message type
- `linear.x: 2.0` → move forward at 2 units/sec
- `angular.z: 1.5` → rotate counter-clockwise at 1.5 rad/sec
- Setting both gives you a curve

**Expected:** the turtle curves forward-and-left, leaving a drawn trail behind it.

<figure class="screenshot">
  <img src="images/phase1-cmd-vel-pub.png" alt="TurtleSim window with the yellow turtle in the lower-right area of the blue canvas, with a curved white trail showing the arc the turtle just drove after a single ros2 topic pub command" />
  <figcaption>🐢 My Step 2.4 result — one <code>ros2 topic pub --once</code> command sent <code>linear.x=2.0</code> and <code>angular.z=1.5</code>, and the turtle drew a curve. You just programmed a robot from the command line.</figcaption>
</figure>

Now try the **continuous** variant — drop `--once` and add `-r 1` ("publish at 1 Hz forever"):

```bash
ros2 topic pub -r 1 /turtle1/cmd_vel geometry_msgs/Twist \
  "{linear: {x: 2.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 1.5}}"
```

**Expected:** the same `linear+angular` velocity is re-applied every second, so the turtle traces a closed circle. Press `Ctrl+C` to stop.

<figure class="screenshot">
  <img src="images/phase1-cmd-vel-pub-r1.png" alt="TurtleSim window: yellow turtle that has drawn a complete white circle on the blue canvas, the result of publishing the same linear+angular velocity at 1Hz continuously" />
  <figcaption>🔁 My result with <code>-r 1</code> — the same Twist message at 1 Hz draws a closed circle. Constant linear + constant angular velocity = circular motion (basic differential-drive kinematics).</figcaption>
</figure>

**Why it matters:** publishing to topics from the CLI is how you smoke-test a controller, manually drive a robot when teleop is broken, or fake a sensor input during bring-up.

---

**2.5 Call services (request/response)**

Topics are streams; **services** are one-off RPC calls.

```bash
ros2 service list
```
**Expected:** `/clear`, `/reset`, `/turtle1/set_pen`, `/turtle1/teleport_absolute`, `/spawn`, `/kill`, plus parameter-related services.

```bash
ros2 service type /turtle1/teleport_absolute
```
**Expected:** `turtlesim/srv/TeleportAbsolute` — every service has a typed request/response definition.

**Teleport the turtle** to the bottom-left corner:
```bash
ros2 service call /turtle1/teleport_absolute turtlesim/srv/TeleportAbsolute \
  "{x: 1.0, y: 1.0, theta: 0.0}"
```

**Change the pen color to red**, then draw with it from Terminal B:
```bash
ros2 service call /turtle1/set_pen turtlesim/srv/SetPen \
  "{r: 255, g: 0, b: 0, width: 3, 'off': 0}"
```
*(Note: `off` is quoted because it's a YAML reserved word.)*

**Spawn a second turtle:**
```bash
ros2 service call /spawn turtlesim/srv/Spawn \
  "{x: 5.5, y: 5.5, theta: 0.0, name: 'turtle2'}"
```
**Expected:** response `name: turtle2`, and a second turtle appears in the middle of the canvas.

<figure class="screenshot">
  <img src="images/phase1-services.png" alt="TurtleSim window showing two turtles on a blue canvas: turtle1 at the bottom-left after a teleport_absolute call, and turtle2 in the middle next to a previously-drawn circle. A diagonal line shows the teleport jump path." />
  <figcaption>🛰️ My Step 2.5 result — three services in action: <code>teleport_absolute</code> jumped turtle1 to the bottom-left corner (diagonal line is the teleport jump), <code>set_pen</code> changed the trail color, and <code>spawn</code> created turtle2 in the middle. All driven from the command line — no code written yet.</figcaption>
</figure>

**Why it matters:** topics for streams (sensor data, odometry, commands), services for events (calibrate, save map, switch mode). Wrong choice = bad architecture.

---

**2.6 Read and write parameters live**

Parameters are runtime config that a node exposes. They can be set at launch *or* changed live.

```bash
ros2 param list
```
Lists every node's parameters. Under `/turtlesim` you'll see `background_b`, `background_g`, `background_r`, `holonomic`, `use_sim_time`, plus parameter-descriptor entries.

```bash
ros2 param get /turtlesim background_b
```
**Expected:** `Integer value is: 255` (blue, hence the blue canvas).

**Change the canvas color live** to red:
```bash
ros2 param set /turtlesim background_r 255
ros2 param set /turtlesim background_g 0
ros2 param set /turtlesim background_b 0
ros2 service call /clear std_srvs/srv/Empty
```
**Expected:** the canvas redraws red **and any existing turtle trails disappear**. That's intentional — the `/clear` service both wipes the trail history *and* repaints the canvas with the current background color (params alone don't trigger a repaint; `/clear` is what applies them). If you want to keep your drawings, just don't call `/clear` after changing params — the new color will only take effect the next time someone clears.

<figure class="screenshot">
  <img src="images/phase1-params-red.png" alt="TurtleSim window: the canvas has been repainted red after setting the three background_r/g/b parameters and calling the /clear service. Two turtles are visible (turtle1 in the bottom-left, turtle2 in the middle), but all previous trails are gone." />
  <figcaption>🎨 My Step 2.6 result — three <code>ros2 param set</code> commands followed by <code>ros2 service call /clear</code> repainted the canvas red. Trails are gone because <code>/clear</code> wipes them; both turtles survive because they're not part of the canvas drawing.</figcaption>
</figure>

**Dump all params to a YAML file** (great for reproducible configs):
```bash
mkdir -p ~/ros2_ws/configs
ros2 param dump /turtlesim > ~/ros2_ws/configs/turtlesim_params.yaml
cat ~/ros2_ws/configs/turtlesim_params.yaml
```
Later you can restore them with `ros2 param load /turtlesim ~/ros2_ws/configs/turtlesim_params.yaml`.

**Why it matters:** parameters let you tune a node without recompiling. Real robots have hundreds (PID gains, frame names, sensor calibrations).

---

**2.7 Record and replay with `ros2 bag`**

Bag files are the killer feature for debugging — capture all messages on the wire, replay later on your laptop without the robot.

**Terminal D** (open a new Ubuntu window):
```bash
mkdir -p ~/ros2_ws/bags && cd ~/ros2_ws/bags
ros2 bag record /turtle1/cmd_vel -o demo_bag
```
Now drive the turtle around for ~10 seconds in Terminal B (the teleop). Press `Ctrl+C` in Terminal D to stop recording.

Inspect what you captured:
```bash
ros2 bag info demo_bag
```
**Expected:** total duration ~10 s, message count > 0, type `geometry_msgs/msg/Twist`.

**Reset the canvas** so you can see the replay clearly:
```bash
ros2 service call /reset std_srvs/srv/Empty
```

**Replay the bag** — the turtle re-traces your original drive:
```bash
ros2 bag play demo_bag
```
**Expected:** the turtle moves on its own, following the path you originally drove. (Because you recorded the *input* `/turtle1/cmd_vel`, replaying it drives the turtle the same way.)

**Why it matters:** every robotics team uses bags to debug field issues — driver records once on the robot, you replay on your laptop and re-run analysis as many times as you want.

---

**2.8 Compose multiple nodes with `ros2 launch`**

So far you've opened one terminal per node. Launch files bring up many nodes from a single command — that's how every real robot starts up.

Create a small launch file in your workspace:
```bash
mkdir -p ~/ros2_ws/src/launch_demo/launch
cat > ~/ros2_ws/src/launch_demo/launch/turtle_demo.launch.py << 'EOF'
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        Node(
            package='turtlesim',
            executable='turtlesim_node',
            name='sim',
        ),
        Node(
            package='turtlesim',
            executable='mimic',
            name='mimic',
            remappings=[
                ('/input/pose', '/turtle1/pose'),
                ('/output/cmd_vel', '/turtle2/cmd_vel'),
            ],
        ),
    ])
EOF
```

Kill everything from the previous steps (Ctrl-C in Terminals A, B, D). Then in **Terminal A**:
```bash
ros2 launch ~/ros2_ws/src/launch_demo/launch/turtle_demo.launch.py
```
**Expected:** turtlesim starts. (It still has only turtle1; you can spawn turtle2 below.)

In **Terminal B**, spawn turtle2 and start teleop:
```bash
ros2 service call /spawn turtlesim/srv/Spawn "{x: 2.0, y: 2.0, theta: 0.0, name: 'turtle2'}"
ros2 run turtlesim turtle_teleop_key
```
**Expected:** as you drive `turtle1`, the **`mimic` node** copies its pose onto `turtle2` (note the topic remappings in the launch file). Two turtles, one set of arrow keys.

**Why it matters:** launch files are how you wire complex multi-node systems together — Nav2, MoveIt, your own packages — declaratively, in Python, with arguments and conditions.

Press `Ctrl+C` in each terminal when done.

---

### 🧠 You now know

By the end of Step 2 you should be comfortable with: `ros2 run`, `ros2 node list/info`, `ros2 topic list/info/echo/hz/pub`, `ros2 service list/type/call`, `ros2 param list/get/set/dump/load`, `ros2 bag record/info/play`, `ros2 launch`, and `rqt_graph`. That's the entire daily-driver CLI of a ROS 2 developer.

**Up next:** Step 3 wires this knowledge into your *own* Python package — the `odom_demo` mini-project that's the official Phase 1 deliverable.

---

### 📖 Further reading *(optional reference, not required)*

The walkthrough above covers what you need to move on to the mini-project. If you want deeper background on any specific concept later, these are excellent reference resources — **read them on demand**, don't try to consume them up-front.

| Type | Resource | When to dip in |
|:-:|---|---|
| 📑 | [Official ROS 2 Jazzy tutorials](https://docs.ros.org/en/jazzy/Tutorials.html) | Reference for edge cases and the exact API spec |
| 📘 | *A Concise Introduction to Robot Programming with ROS 2* — Fairchild & Harman | When you want a structured, dev-focused book |
| 🎥 | [Articulated Robotics](https://articulatedrobotics.xyz/) YouTube (Josh Newans) | When you want a visual walkthrough of URDF / Gazebo / Nav2 |
| 🎓 | [The Construct's free ROS 2 Basics](https://www.theconstruct.ai/) | If you want browser-based exercises with no local install |

---

### 🛠️ Step 3 — Write your first ROS 2 package (the mini-project)

🚧 *Coming soon — say "expand Step 3" and I'll inline a full walkthrough: `ros2 pkg create` → publisher node → subscriber node → custom message type → launch file → build & test, ending at the Validation Checkpoint below.*

> 🎯 **Mini-project deliverable:** Write a ROS 2 package (Python) with:
> - A publisher node emitting fake odometry
> - A subscriber that logs and computes velocity
> - A launch file starting both with parameters
> - A custom message type

### ✅ Validation Checkpoint

In one Ubuntu shell, build and launch:
```bash
cd ~/ros2_ws && colcon build --packages-select odom_demo
source install/setup.bash
ros2 launch odom_demo demo.launch.py
```
In a second shell, inspect the live topic:
```bash
source ~/ros2_ws/install/setup.bash
ros2 topic list           # your topic should appear
ros2 topic echo /odom     # see messages streaming
ros2 topic hz /odom       # confirm publish rate matches your timer
ros2 node info /odom_pub  # see your custom msg type listed
```
If both nodes start cleanly, the topic streams at the expected rate, and the subscriber logs computed velocities → **Phase 1 is done**.

<div class="copilot-note">

### 🤖 How Copilot can boost Phase 1

- 🏗️ **Scaffold packages** — say "create a ROS 2 Python package called `odom_demo` with a publisher and subscriber" and I'll generate `setup.py`, `package.xml`, the node files, and an `ament` launch file.
- 📖 **Translate concepts on demand** — explain the difference between topics/services/actions, pub-sub QoS profiles, or how `tf2` time travel works, in the context of your 25-year-dev background.
- 🧩 **Write launch files** in Python — composable, with arguments, conditions, and grouping.
- 🐞 **Decode cryptic ROS errors** — `lookup would require extrapolation into the past`, `failed to load controller`, missing transforms… I'll explain the root cause.
- 📝 **Code review** your first nodes — I'll flag missing QoS, blocking calls in callbacks, unmanaged thread issues.

</div>

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

### ✅ Validation Checkpoint

Launch the simulator, teleop, and RViz2 (three shells):
```bash
# Shell 1 — simulator
ros2 launch turtlebot4_ignition_bringup turtlebot4_ignition.launch.py rviz:=true

# Shell 2 — teleop
ros2 run teleop_twist_keyboard teleop_twist_keyboard \
  --ros-args -r cmd_vel:=/cmd_vel

# Shell 3 — sanity checks
ros2 topic hz /scan            # lidar should publish at ~5–10 Hz
ros2 topic echo /odom --once   # odometry has a real pose
ros2 run tf2_tools view_frames # generate a tf tree PDF
```
✅ You should see: TurtleBot moving in Gazebo when you press WASD, a live red laser ring around it in RViz2, and a TF tree with `odom → base_link → laser_frame`.

<figure class="screenshot">
  <img src="images/gazebo-robot-result.png" alt="Gazebo simulator window showing a mobile robot in a scene with its depth/lidar sensor casting a blue fan of rays across the floor and a wall" />
  <figcaption>🌍 Success looks like this — your simulated robot lives in a 3D world and its sensors (here, a blue projection from a depth/lidar sensor) react to obstacles in real time. From here it's all software, all the way down.</figcaption>
</figure>

<div class="copilot-note">

### 🤖 How Copilot can boost Phase 2

- 🦴 **Generate URDF/Xacro** — describe your robot in plain English ("differential-drive base 30 cm wide, 8 cm wheels, a Hokuyo lidar on top") and I'll produce the full Xacro with inertia, collision, visual, transmissions.
- ⚙️ **Write `ros2_control` config** — controller manager YAML, `diff_drive_controller`, `joint_state_broadcaster`, plus the Gazebo system plugin.
- 🌍 **Build Gazebo worlds** — generate `.sdf` worlds with walls, doors, lighting, or import a 3D model.
- 🪲 **Debug Gazebo crashes** — paste the stderr; I'll point to plugin mismatches, missing meshes, or TF cycles.
- 🎛️ **Tune simulation params** — physics step size, max contacts, real-time factor.
- 👁️ **Author RViz configs** (`.rviz` files) for your robot.

</div>

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

### ✅ Validation Checkpoint

Map → save → re-localize → autonomous goal:
```bash
# 1) Map with SLAM
ros2 launch turtlebot4_ignition_bringup turtlebot4_ignition.launch.py \
  slam:=true rviz:=true
# Teleop-drive around until the map looks complete, then:
ros2 run nav2_map_server map_saver_cli -f ~/maps/apartment

# 2) Restart in localization + Nav2 mode
ros2 launch turtlebot4_ignition_bringup turtlebot4_ignition.launch.py \
  localization:=true nav2:=true rviz:=true \
  map:=$HOME/maps/apartment.yaml

# 3) In RViz2: click "Nav2 Goal", click a point on the map
ros2 topic echo /behavior_tree_log --once   # see the BT firing
```
✅ Robot autonomously plans + drives + avoids obstacles + announces "Goal succeeded" at the target. Reproducible 3 times in a row = **Phase 3 done**.

<figure class="screenshot">
  <img src="images/nav2-result.png" alt="RViz2 showing a Nav2 demo: an occupancy-grid map with cyan/pink costmap inflation layers, AMCL particle cloud around the robot, and a planned path from start to goal" />
  <figcaption>🧭 Success looks like this — RViz2 showing your map (occupancy grid), the costmap inflation layers (cyan → pink → purple), the AMCL particle swarm (green dots) localizing your robot, and a planned path. Click <em>Navigation2 Goal</em>, click a point, watch it drive.</figcaption>
</figure>

<div class="copilot-note">

### 🤖 How Copilot can boost Phase 3

- 🗺️ **Generate Nav2 config** — full `nav2_params.yaml` tuned for your robot footprint, lidar range, max velocity. I'll explain every parameter so you actually understand it.
- 🌳 **Write/modify behavior trees** — XML BTs for recovery behaviors, custom action/condition nodes in Python or C++.
- 🧠 **Tune SLAM** — `slam_toolbox` configs for online async vs lifelong mapping, loop-closure thresholds, scan match resolution.
- 🛰️ **Debug localization failures** — diagnose AMCL particle clouds, jumpy TFs, costmap inflation issues from your screenshots.
- 📊 **Build evaluation scripts** — automated nav success-rate testing across many start/goal pairs.
- 🎨 **Visualize costmaps** — explain the layer stack, write custom costmap plugins.

</div>

---

## 🦾 Phase 4 — Specialize in Manipulation

![Phase 4 illustration](https://images.unsplash.com/photo-1561557944-6e7860d1a7eb?w=1400&h=360&fit=crop&q=80 "Manipulation — arms, grippers, motion planning, grasping")

> ⏰ **6–10 weeks** &nbsp;·&nbsp; 🎯 **Goal:** Plan and execute collision-free arm motions, then build a full pick-and-place pipeline in simulation.

> ✅ **Why manipulation for you:** highest density of industrial/commercial jobs, deepest math (kinematics, dynamics, optimization, contact), and the gap between hobby and pro is real — so 25 years of engineering experience pays off fast.

> 💡 Other valid tracks if your interest pulls elsewhere: 🚗 mobile (continue Phase 3), 🚁 drones (PX4 + ROS 2), 🧠 RL (NVIDIA Isaac Lab), 👁️ vision (YOLO + RGB-D). Same plan structure applies — swap MoveIt for the equivalent stack.

### 📚 The 4 things to actually learn

| # | Topic | Why it matters | Where to start |
|:-:|---|---|---|
| 1 | **🧮 Kinematics & dynamics** | The language of arms — FK, IK, Jacobians, singularities | [Modern Robotics (Lynch & Park)](https://hades.mech.northwestern.edu/index.php/Modern_Robotics) — free book + Coursera |
| 2 | **🦿 MoveIt 2** | The de-facto ROS 2 motion-planning framework | [MoveIt 2 tutorials](https://moveit.picknik.ai/main/index.html) |
| 3 | **🤏 Grasping & MTC** | Going from "move to pose" to "grab that object" | [MoveIt Task Constructor](https://github.com/moveit/moveit_task_constructor) |
| 4 | **👁️ Perception → pose** | Closing the loop: RGB-D → object → grasp pose | [Open3D](https://www.open3d.org/) + [GPD](https://github.com/atenpas/gpd) |

### 🤖 Pick your simulated arm

| Tier | Arm | Why | Real-world cost |
|:-:|---|---|---|
| 🥇 | **Franka Emika Panda** (FR3) | The default MoveIt demo robot — every tutorial uses it. Best ecosystem. | ~$15K (free in sim) |
| 🥈 | **Universal Robots UR5e / UR10e** | What you'll meet in industry. `ur_robot_driver` is rock solid. | ~$35K (free in sim) |
| 🥉 | **WidowX 250 S** | Affordable real arm if you want to buy one later (Phase 5) | ~$2.4K (buyable) |

> 💡 **Start with Panda in sim** — every tutorial works out of the box. Switch to UR later for industry skills, or WidowX if you plan to buy real hardware.

### 🗓️ Suggested 8-week roadmap

**Weeks 1–2 · Foundations**
- 🧠 Modern Robotics ch. 3–6: rigid-body motions, FK, velocity kinematics, IK
- 📦 Install MoveIt 2 + Panda demo: `ros2 launch moveit2_tutorials demo.launch.py`
- 🎮 In RViz, drag the end-effector, hit **Plan & Execute**, watch IK solve

**Weeks 3–4 · MoveIt programmatic API**
- 🐍 `moveit_py` (Python) — joint-space goals, pose goals, Cartesian paths
- 🚧 Add collision objects (the green box in the screenshot below)
- 📐 Constrained planning: orientation locked (e.g., keep a glass upright)

**Weeks 5–6 · Pick-and-place with MTC**
- 🧱 MoveIt Task Constructor stages: approach → pre-grasp → close gripper → lift → place
- 🦾 Spawn Panda + gripper + table + 3 cubes in Gazebo
- 🎯 Pick each cube, stack them. 10/10 successful runs = ✅ done

**Weeks 7–8 · Vision-driven grasping**
- 🎥 Add an RGB-D camera (sim) — `/depth/points` PointCloud2
- 🔍 Segment table + objects (Open3D plane fit + Euclidean clustering)
- ✋ Generate grasp poses (GPD or hand-crafted top-down grasps)
- 🤝 Feed pose → MTC → execute. Now your robot picks up things it has never seen before.

### 🛠️ Tools you'll live in

- 🦿 **MoveIt 2** — planning, IK, collision checking, trajectory execution
- 🌍 **Gazebo (Harmonic)** — physics sim
- 🎛️ **`ros2_control`** — joint-trajectory controllers, gripper command interfaces
- 🐍 **`moveit_py`** — Python bindings for fast prototyping
- 📊 **RViz2 MotionPlanning plugin** — your debugger
- 🧪 **MoveIt Task Constructor (MTC)** — composable manipulation pipelines

> 🎯 **Mini-project deliverable:** Vision-driven pick-and-place — Panda picks an unknown object from clutter on a table using only an RGB-D camera + MTC, and places it in a target zone.

### ✅ Validation Checkpoint

Run the demo, then add complexity step by step:
```bash
# 1) Baseline — Panda demo + MotionPlanning panel in RViz
ros2 launch moveit2_tutorials demo.launch.py

# 2) Programmatic motion (your code)
ros2 run my_panda_pkg pose_goal_demo.py

# 3) Pick & place pipeline (MTC)
ros2 launch my_panda_pkg pick_place.launch.py
ros2 topic echo /execute_task_solution/_action/status --once

# 4) Vision-driven (final boss)
ros2 launch my_panda_pkg vision_pick.launch.py
```
✅ Achieved when: vision pipeline runs end-to-end, Panda picks a never-before-seen object from clutter, places it in the target zone — **10/10 successful runs** = Phase 4 done.

<figure class="screenshot">
  <img src="images/moveit-result.png" alt="RViz2 showing a Franka Emika Panda robot arm next to a green collision box, planned via MoveIt 2" />
  <figcaption>🦾 Success looks like this — your Panda arm in RViz2 with a collision object in the scene. Once you can drag the end-effector, hit <em>Plan &amp; Execute</em>, and watch MoveIt route around obstacles, you've crossed into manipulation.</figcaption>
</figure>

<div class="copilot-note">

### 🤖 How Copilot can boost Phase 4 (manipulation)

- 🦿 **Generate full MoveIt config packages** — SRDF, controllers, kinematics solver choice (KDL / TracIK / pick_ik), planning pipelines (OMPL / Pilz / STOMP). Faster than the setup_assistant GUI and gives you something to read.
- 🧮 **Derive & code IK/FK by hand** — when you want to actually understand what MoveIt does under the hood. I'll walk you through the Modern Robotics math line by line.
- 🤏 **Write MoveIt Task Constructor pipelines** — full pick-and-place stage trees in C++ or Python, with grasp generation and approach/retreat planning.
- 🎥 **Wire up perception → grasping** — `pcl_ros` / Open3D pipelines: point cloud → segment → cluster → fit primitives → emit grasp `PoseStamped`.
- 🪲 **Debug planning failures** — paste the OMPL log or `move_group` errors; I'll diagnose collision matrix issues, IK timeouts, joint-limit violations, octomap inflation.
- 🧪 **Author headless test scenarios** — `pytest` + `launch_testing` to run "spawn cubes, attempt pick, assert success" in CI.
- 📚 **Curate a week-by-week study plan** — Modern Robotics chapter pairings with hands-on MoveIt exercises so theory and code reinforce each other.

</div>

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

<div class="copilot-note">

### 🤖 How Copilot can boost Phase 5

- 🛒 **Compare options** — paste 2–3 robot spec sheets; I'll build a side-by-side decision matrix weighted to your goals.
- 📜 **Translate manufacturer docs** — Chinese/Japanese supplier datasheets → English summary with electrical/protocol gotchas.
- 🇮🇱 **Israel-specific guidance** — estimate landed cost (USD + VAT + customs), suggest customs broker phrasing for lithium batteries / lidar declarations.
- 🔧 **DIY build plans** — pick parts list with Aliexpress/RobotShop links, generate CAD or scrappy plywood chassis sketches, BOM with shipping ETA.
- 🧾 **Generate purchase justification** if you're expensing — written for an enterprise procurement audience.

</div>

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

<div class="copilot-note">

### 🤖 How Copilot can boost Phase 6

- 🔄 **Sim-to-real config diff** — point me at your sim launch + your hardware driver; I'll generate the unified `ros2_control` config that swaps cleanly.
- 📡 **Sensor calibration scripts** — IMU bias estimation, camera intrinsics (`camera_calibration`), lidar-to-base extrinsics, time-sync between sensors.
- 🐛 **Debug from logs** — paste `ros2 bag` snippets or controller_manager errors; I'll find the bad TF, the dropped message, the off-by-one timer.
- ⚡ **Real-time tuning** — explain RT_PREEMPT vs Xenomai, write `chrt`/cgroup setup, pinpoint priority inversions.
- 🔋 **Power & safety** — generate a battery monitoring node, e-stop wiring/code, watchdog timers on critical loops.
- 📈 **Performance profiling** — convert ROS 2 traces to flame graphs, identify slow callbacks.

</div>

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

