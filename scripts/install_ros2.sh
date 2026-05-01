#!/bin/bash
set -e

echo "========================================================="
echo "   Memulai Instalasi ROS 2 Humble (Super Gampang!)"
echo "========================================================="
echo "Program ini akan meminta password komputermu sesekali."
echo "Ketik passwordmu (ketikan memang tidak akan terlihat) lalu tekan Enter ya!"
echo "========================================================="

# 1. Update and install prerequisites
echo "1. Menyiapkan sistem dasar..."
sudo apt update && sudo apt install locales -y
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# 2. Setup Sources
echo "2. Menambahkan sumber aplikasi ROS 2..."
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y

sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 3. Install ROS 2 and micro-ROS dependencies
echo "3. Mengunduh dan menginstal ROS 2 Humble (Ini agak lama, bisa ditinggal ngemil dulu!)..."
sudo apt update
sudo apt install ros-humble-desktop ros-humble-micro-ros-msgs -y

# 4. Automate source
echo "4. Mengatur agar ROS 2 otomatis aktif setiap buka terminal..."
if ! grep -q "source /opt/ros/humble/setup.bash" ~/.bashrc; then
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
fi

echo "========================================================="
echo "   HORE! ROS 2 Humble Berhasil Diinstal! 🎉"
echo "   Silakan TUTUP terminal ini dan buka terminal BARU."
echo "========================================================="
