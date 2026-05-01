#!/bin/bash
# monitor_topics.sh - Monitor all BlinkSynk LED states in one view

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MICROROS_WS="$SCRIPT_DIR/../microros_ws"

# Auto-fix ROS 2 workspace absolute paths dynamically if relocated
OLD_PATH=$(grep -m 1 "COLCON_CURRENT_PREFIX=" "$MICROROS_WS/install/setup.sh" | cut -d= -f2 | tr -d "'\"" | sed 's|/install$||')
if [ "$OLD_PATH" != "$MICROROS_WS" ] && [ -n "$OLD_PATH" ]; then
    find "$MICROROS_WS/install" -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.dsv" -o -name "*.py" -o -name "package.xml" -o -name "*.cmake" -o -name "*.repos" \) -exec sed -i "s|$OLD_PATH|$MICROROS_WS|g" {} +
fi

source /opt/ros/humble/setup.bash
source "$MICROROS_WS/install/setup.bash"

echo "============================================"
echo "  BlinkSynk - LED Status Monitor"
echo "============================================"
echo ""
echo "Listening to /blink_synk/status ..."
echo "You should see all 8 LED states updating in real-time."
echo ""
echo "Press Ctrl+C to stop."
echo "============================================"

ros2 topic echo /blink_synk/status
