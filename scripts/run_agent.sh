#!/bin/bash
# run_agent.sh - Start the micro-ROS Agent
# This script connects to the Raspberry Pi Pico via USB serial

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MICROROS_WS="$SCRIPT_DIR/../microros_ws"

# Auto-fix ROS 2 workspace absolute paths dynamically if relocated
OLD_PATH=$(grep -m 1 "COLCON_CURRENT_PREFIX=" "$MICROROS_WS/install/setup.sh" | cut -d= -f2 | tr -d "'\"" | sed 's|/install$||')
if [ "$OLD_PATH" != "$MICROROS_WS" ] && [ -n "$OLD_PATH" ]; then
    echo "Detected workspace relocation. Fixing paths..."
    find "$MICROROS_WS/install" -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.dsv" -o -name "*.py" -o -name "package.xml" -o -name "*.cmake" -o -name "*.repos" \) -exec sed -i "s|$OLD_PATH|$MICROROS_WS|g" {} +
fi

# Source ROS 2 and micro-ROS workspace
source /opt/ros/humble/setup.bash
source "$MICROROS_WS/install/setup.bash"

# Auto-detect serial device
DEVICE=""
if [ -e /dev/ttyACM0 ]; then
    DEVICE="/dev/ttyACM0"
elif [ -e /dev/ttyACM1 ]; then
    DEVICE="/dev/ttyACM1"
else
    echo "ERROR: No Raspberry Pi Pico detected on /dev/ttyACM*"
    echo "Make sure:"
    echo "  1. Pico is plugged in via USB"
    echo "  2. In VMware: VM -> Removable Devices -> Connect the Pico to VM"
    exit 1
fi

# Fix permissions
sudo chmod 666 "$DEVICE" 2>/dev/null

echo "============================================"
echo "  micro-ROS Agent - BlinkSynk"
echo "============================================"
echo "Device : $DEVICE"
echo "Status : Starting..."
echo ""
echo "If the Pico onboard LED is blinking slowly,"
echo "it means it's waiting for this agent."
echo "Once connected, the LED will turn solid ON."
echo ""
echo "Press Ctrl+C to stop."
echo "============================================"

ros2 run micro_ros_agent micro_ros_agent serial --dev "$DEVICE"
