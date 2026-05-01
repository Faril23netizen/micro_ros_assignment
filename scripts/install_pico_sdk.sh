#!/bin/bash
set -e

echo "========================================================="
echo "   Memulai Instalasi Peralatan Coding Raspberry Pi Pico"
echo "========================================================="
echo "Program ini akan meminta password komputermu sesekali."
echo "Ketik passwordmu (tidak terlihat) dan tekan Enter."
echo "========================================================="

echo "1. Menginstal alat-alat dasar (Compiler, CMake, dll)..."
sudo apt update
sudo apt install -y cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential g++ python3 git

echo "2. Mengunduh Raspberry Pi Pico SDK..."
# Kita taruh di folder home mahasiswa
cd ~
if [ ! -d "pico-sdk" ]; then
    git clone https://github.com/raspberrypi/pico-sdk.git
    cd pico-sdk
    git submodule update --init
else
    echo "Pico SDK sudah ada di ~/pico-sdk, melewati proses unduh..."
fi

echo "3. Mengatur agar komputer selalu tahu di mana letak Pico SDK..."
if ! grep -q "export PICO_SDK_PATH=~/pico-sdk" ~/.bashrc; then
    echo "export PICO_SDK_PATH=~/pico-sdk" >> ~/.bashrc
fi

echo "========================================================="
echo "   HORE! Peralatan Pico Berhasil Diinstal! 🎉"
echo "   Silakan TUTUP terminal ini dan buka terminal BARU agar"
echo "   pengaturan terbaru bisa langsung aktif."
echo "========================================================="
