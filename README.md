# BlinkSynk - FreeRTOS & micro-ROS Raspberry Pi Pico Assignment

This repository contains the complete assignment package for integrating **FreeRTOS** and **micro-ROS** on a Raspberry Pi Pico.

The goal of this assignment is to understand how FreeRTOS tasks can synchronize with each other locally on a microcontroller, and then broadcast their internal state to a ROS 2 network using the XRCE-DDS protocol.

## Step 0: Clone This Repository

Before starting, make sure you download this assignment folder to your computer. If your computer is fresh, you will need to install `git` first:

Open a terminal and run:
```bash
sudo apt update
sudo apt install git -y
cd ~
git clone https://github.com/Faril23netizen/micro_ros_assignment.git
```

## Directory Structure

- `blink_synk/` : The source code for the firmware.
- `microros_ws/` : A pre-compiled micro-ROS Agent workspace (ready to run).
- `scripts/` : Helpful scripts to automate starting the agent and monitoring data.

---

## Prerequisites

Before proceeding, make sure you install the required applications below. If you are starting from a completely clean machine, perform steps 1 and 2 in order.

1. **Raspberry Pi Pico Coding Tools (Pico SDK & Compiler)**
   To program the Pico, you need a C/C++ compiler and the Pico SDK. We have provided an automated script to install them. Open a terminal and run:
   ```bash
   cd ~/micro_ros_assignment/scripts
   ./install_pico_sdk.sh
   ```
   Once finished, **close the old terminal and open a new one**.

2. **ROS 2 Humble**
   To monitor the data from the Pico, you need ROS 2 Humble. We have also provided an automated installer script. Run this in your new terminal:
   ```bash
   cd ~/micro_ros_assignment/scripts
   ./install_ros2.sh
   ```
   As before, make sure to **close the old terminal and open a new one** before moving on to Step 1.

3. **VMware Users (Important!)**
   If you are running Linux inside a VMware virtual machine, you **MUST** manually connect the Pico's USB connection into Linux every time you plug it in:
   - When the Pico is plugged in, click the VMware menu at the top: `VM` -> `Removable Devices`.
   - Look for a device named something like `Raspberry Pi Pico`, `Board CDC`, or `USB Serial Device`.
   - Click **Connect (Disconnect from Host)**.
   - *Note: Repeat this trick every time the Pico is unplugged and re-plugged!*

---

## Step 1: Compiling and Flashing the Firmware

In this assignment, you must compile the firmware from source. Ensure you have the Raspberry Pi Pico C/C++ SDK installed and configured on your system (`PICO_SDK_PATH` must be set).

1. Open a terminal and navigate to the `blink_synk` directory:
   ```bash
   cd ~/micro_ros_assignment/blink_synk
   mkdir build && cd build
   cmake ..
   make -j4
   ```
2. Once compilation is complete, the firmware file `BlinkSynk.uf2` will be generated inside the `build/src/` directory.
3. Press and **hold the BOOTSEL button** on your Raspberry Pi Pico.
4. While holding the button, plug the USB cable into your computer.
5. A new external storage drive named `RPI-RP2` will appear.
6. Copy the file `build/src/BlinkSynk.uf2` into the `RPI-RP2` drive.
7. The Pico will automatically reboot. 

*Diagnostic Check*: The tiny green onboard LED (GPIO 25) should blink rapidly 3 times, then begin blinking slowly. This indicates it is waiting for a connection to the ROS 2 Agent.

---

## Step 2: Running the micro-ROS Agent

To receive the XRCE-DDS messages from the Pico, you need to run the agent. We have provided a script to automate this.

Open a terminal and run:

```bash
cd ~/micro_ros_assignment/scripts/
./run_agent.sh
```

**What the script does:**
- Sources the ROS 2 Humble environment.
- Sources the pre-built `microros_ws` agent.
- Fixes USB device permissions (`/dev/ttyACM0`).
- Starts the `micro_ros_agent`.

*Diagnostic Check*: Once the agent says `Session established`, the slow blinking onboard LED on the Pico will turn **Solid ON**. This means the Pico is successfully connected to the ROS 2 network!

---

## Step 3: Monitoring the LED States

Now that the Pico is connected, it is publishing the FreeRTOS task synchronization states to the ROS 2 network.

Open a **NEW** terminal (leave the agent running in the first terminal), and run:

```bash
cd ~/micro_ros_assignment/scripts/
./monitor_topics.sh
```

You will see the status string from the Pico updating in real-time — including the Name, Student ID, and all 8 LED states.

If you want to view individual topics, you can also manually run:
```bash
ros2 topic echo /blink_synk/status
ros2 topic echo /led_agent/state
ros2 topic echo /led_worker1/state
ros2 topic echo /led_worker2/state
```

---

## Assignment Task

Your task is to modify the source code to support **8 LEDs** and broadcast your **Name and Student ID** to the ROS 2 network! 

Don't panic! Just follow this step-by-step guide:

### Step 1: Edit `main.cpp`
Open the file `blink_synk/src/main.cpp` in your text editor.

**A. Add New LED States**
Find the code (around line 37) that says `volatile bool led_worker2_state = false;`. Add these lines right below it:
```cpp
volatile bool led_worker3_state = false;
volatile bool led_worker4_state = false;
volatile bool led_worker5_state = false;
volatile bool led_worker6_state = false;
volatile bool led_worker7_state = false;
```

**B. Add Your Name to the Publisher**
Find the `snprintf` function inside `microRosTask` (around line 111). Replace the whole `snprintf` section with this code (don't forget to put your actual Name and ID!):
```cpp
        // Add your Name and ID here!
        snprintf(status_buf, sizeof(status_buf),
            "Name: [YOUR_NAME], ID: [YOUR_ID] | Agent:%s | W1:%s | W2:%s | W3:%s | W4:%s | W5:%s | W6:%s | W7:%s",
            led_agent_state ? "ON " : "OFF",
            led_worker1_state ? "ON " : "OFF",
            led_worker2_state ? "ON " : "OFF",
            led_worker3_state ? "ON " : "OFF",
            led_worker4_state ? "ON " : "OFF",
            led_worker5_state ? "ON " : "OFF",
            led_worker6_state ? "ON " : "OFF",
            led_worker7_state ? "ON " : "OFF" // CAREFUL: No comma on the last line!
        );
```

**C. Create the New Workers**
Find where `worker2` is created inside `void mainTask(void *params)` (around line 130). Add 5 new workers using different GPIO pins (Pins 4 to 8):
```cpp
	BlinkWorker worker3(4); // LED connected to GPIO 4
	BlinkWorker worker4(5); // LED connected to GPIO 5
	BlinkWorker worker5(6); // LED connected to GPIO 6
	BlinkWorker worker6(7); // LED connected to GPIO 7
	BlinkWorker worker7(8); // LED connected to GPIO 8
```

**D. Start the New Workers**
Scroll down slightly and find `worker2.start("Worker 2", TASK_PRIORITY);`. Start the tasks for your new workers right below it:
```cpp
	worker3.start("Worker 3", TASK_PRIORITY);
	worker4.start("Worker 4", TASK_PRIORITY);
	worker5.start("Worker 5", TASK_PRIORITY);
	worker6.start("Worker 6", TASK_PRIORITY);
	worker7.start("Worker 7", TASK_PRIORITY);
```
Save the `main.cpp` file (`Ctrl+S`).

### Step 2: Edit `BlinkWorker.cpp`
Open the file `blink_synk/src/BlinkWorker.cpp`. This file controls when the LEDs turn ON and OFF.

**A. Add External Declarations**
Find the line `extern volatile bool led_worker2_state;` (around line 43). Add these below it:
```cpp
extern volatile bool led_worker3_state;
extern volatile bool led_worker4_state;
extern volatile bool led_worker5_state;
extern volatile bool led_worker6_state;
extern volatile bool led_worker7_state;
```

**B. Update the ON/OFF Logic**
Inside the `while (true)` loop, find `if (xLedPad == 3) led_worker2_state = true;`. Add the logic for your new pins:
```cpp
        if (xLedPad == 4) led_worker3_state = true;
        if (xLedPad == 5) led_worker4_state = true;
        if (xLedPad == 6) led_worker5_state = true;
        if (xLedPad == 7) led_worker6_state = true;
        if (xLedPad == 8) led_worker7_state = true;
```
Scroll down a little bit to find `if (xLedPad == 3) led_worker2_state = false;`. Add the "false" logic below it:
```cpp
        if (xLedPad == 4) led_worker3_state = false;
        if (xLedPad == 5) led_worker4_state = false;
        if (xLedPad == 6) led_worker5_state = false;
        if (xLedPad == 7) led_worker6_state = false;
        if (xLedPad == 8) led_worker7_state = false;
```
Save the `BlinkWorker.cpp` file (`Ctrl+S`).

### Step 3: Recompile and Test!
Now that you have modified the code, open your terminal and recompile:
```bash
cd ~/micro_ros_assignment/blink_synk/build
make -j4
```
If it succeeds without errors, copy the new `BlinkSynk.uf2` file into your Pico just like you did in Step 1.
Run the Agent and Monitor scripts, and you should see your Name and all 8 LEDs proudly displayed on the ROS 2 network! 🚀
