#!/bin/bash
# monitor_topics.sh - Monitor all BlinkSynk LED states in one view

source /opt/ros/humble/setup.bash

echo "============================================"
echo "  BlinkSynk - LED Status Monitor"
echo "============================================"
echo ""
echo "Listening to /blink_synk/status ..."
echo "You should see all 3 LED states updating in real-time."
echo ""
echo "Press Ctrl+C to stop."
echo "============================================"

ros2 topic echo /blink_synk/status
