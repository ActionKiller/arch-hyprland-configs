#!/bin/bash

STATE_FILE="/tmp/nightlight_state"

# Handle init case
if [[ "$1" == "--init" ]]; then
    if [ -f "$STATE_FILE" ] && grep -q "on" "$STATE_FILE"; then
        echo ""   # moon
    else
        echo ""   # circle
    fi
    exit 0
fi

# Toggle logic
if [ -f "$STATE_FILE" ]; then
    STATE=$(cat "$STATE_FILE")
else
    STATE="off"
fi

if [ "$STATE" = "off" ]; then
    nohup hyprsunset -t 4000 &>/dev/null &
    echo "on" > "$STATE_FILE"
    echo ""
else
    pkill -x hyprsunset
    echo "off" > "$STATE_FILE"
    echo ""
fi

