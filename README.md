# BlinkSynk - FreeRTOS & micro-ROS Raspberry Pi Pico Assignment

This repository contains the complete assignment package for integrating **FreeRTOS** and **micro-ROS** on a Raspberry Pi Pico.

The goal of this assignment is to understand how FreeRTOS tasks can synchronize with each other locally on a microcontroller, and then broadcast their internal state to a ROS 2 network using the XRCE-DDS protocol.

## Step 0: Clone This Repository

Sebelum memulai, pastikan kamu sudah mengunduh folder tugas ini ke komputermu. Karena komputer kamu mungkin masih baru, instal `git` terlebih dahulu:

Buka terminal dan jalankan:
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

Sebelum memulai, pastikan kamu sudah menginstal beberapa aplikasi wajib di bawah ini. Jika kamu menggunakan komputer kosong (belum terinstal apa-apa), kerjakan langkah 1 dan 2 secara berurutan.

1. **Peralatan Coding Raspberry Pi Pico (Pico SDK & Compiler)**
   Untuk bisa memprogram Pico, kamu butuh *compiler* dan kumpulan kode dasar Pico (SDK). Kami sudah menyiapkan program otomatis untuk menginstalnya. Buka terminal dan jalankan:
   ```bash
   cd ~/micro_ros_assignment/scripts
   ./install_pico_sdk.sh
   ```
   Setelah selesai, **tutup terminal lama dan buka terminal baru**.

2. **ROS 2 Humble**
   Untuk melihat data dari Pico, kamu butuh ROS 2 Humble. Kami juga menyiapkan program otomatisnya. Cukup jalankan perintah ini di terminal baru:
   ```bash
   cd ~/micro_ros_assignment/scripts
   ./install_ros2.sh
   ```
   Sama seperti sebelumnya, setelah selesai pastikan kamu **menutup terminal lama dan membuka terminal baru** sebelum masuk ke Step 1.

3. **VMware Users (Penting!)**
   Jika kamu menggunakan Linux di dalam aplikasi VMware, kamu **wajib** menyambungkan koneksi USB Pico ke dalam Linux setiap kali kamu mencolokkan kabelnya:
   - Saat Pico dicolokkan, klik menu VMware di bagian atas: `VM` -> `Removable Devices`.
   - Cari perangkat yang namanya mirip `Raspberry Pi Pico`, `Board CDC`, atau `USB Serial Device`.
   - Klik **Connect (Disconnect from Host)**.
   - *Catatan: Lakukan trik ini berulang-ulang setiap kali Pico dicabut-colok!*

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

You will see the states of all 3 LEDs updating in real-time, matching the physical blinking on the Raspberry Pi Pico.

If you want to view individual topics, you can also manually run:
```bash
ros2 topic echo /led_agent/state
ros2 topic echo /led_worker1/state
ros2 topic echo /led_worker2/state
```

---

## Assignment Task

Your task is to modify the source code in the `blink_synk` directory to achieve the following:

1. **Expand to 8 LEDs**: Currently, the system synchronizes 3 LEDs. You need to modify the code to synchronize a total of 8 LEDs using FreeRTOS tasks.
2. **Add Your Name and Student ID**: Modify the combined ROS 2 String topic (`/blink_synk/status`) to broadcast your Name and Student ID along with the LED states.

**Tips for the Assignment:**
- Look into `blink_synk/src/main.cpp` to see how tasks are created and how the micro-ROS publisher is set up.
- Look into `blink_synk/src/BlinkWorker.cpp` and `blink_synk/src/BlinkAgent.cpp` to understand how the LED logic and FreeRTOS semaphores/notifications are currently implemented.
- Don't forget to recompile the firmware (`make -j4` inside the `build` directory) and re-flash the Pico every time you make changes to the code.

Happy Hacking!
