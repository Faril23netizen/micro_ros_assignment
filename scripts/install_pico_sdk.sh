#!/bin/bash
set -e

echo "========================================================="
echo "   Starting Raspberry Pi Pico SDK Installation"
echo "========================================================="
echo "This program may ask for your password occasionally."
echo "Type your password (it will be invisible) and press Enter."
echo "========================================================="

echo "1. Installing basic tools (Compiler, CMake, etc)..."
sudo apt update
sudo apt install -y cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential g++ python3 git

echo "2. Downloading Raspberry Pi Pico SDK..."
# We place it in the user's home directory
cd ~
if [ ! -d "pico-sdk" ]; then
    git clone https://github.com/raspberrypi/pico-sdk.git
    cd pico-sdk
    git submodule update --init
else
    echo "Pico SDK already exists at ~/pico-sdk, skipping download..."
fi

echo "3. Configuring the environment variables..."
if ! grep -q "export PICO_SDK_PATH=~/pico-sdk" ~/.bashrc; then
    echo "export PICO_SDK_PATH=~/pico-sdk" >> ~/.bashrc
fi

echo "========================================================="
echo "   SUCCESS! Pico SDK has been installed! 🎉"
echo "   Please CLOSE this terminal and open a NEW one so that"
echo "   the new settings can take effect."
echo "========================================================="
