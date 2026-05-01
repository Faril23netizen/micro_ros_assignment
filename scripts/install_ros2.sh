#!/bin/bash
set -e

echo "========================================================="
echo "   Starting ROS 2 Humble Installation"
echo "========================================================="
echo "This program may ask for your password occasionally."
echo "Type your password (it will be invisible) and press Enter."
echo "========================================================="

# 1. Update and install prerequisites
echo "1. Preparing basic system..."
sudo apt update && sudo apt install locales -y
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# 2. Setup Sources
echo "2. Adding ROS 2 sources..."
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y

sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 3. Install ROS 2 and micro-ROS dependencies
echo "3. Downloading and installing ROS 2 Humble (This may take a while)..."
sudo apt update
sudo apt install ros-humble-desktop ros-humble-micro-ros-msgs -y

# 4. Automate source
echo "4. Configuring ROS 2 to start automatically on new terminals..."
if ! grep -q "source /opt/ros/humble/setup.bash" ~/.bashrc; then
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
fi

echo "========================================================="
echo "   SUCCESS! ROS 2 Humble has been installed! 🎉"
echo "   Please CLOSE this terminal and open a NEW one."
echo "========================================================="
