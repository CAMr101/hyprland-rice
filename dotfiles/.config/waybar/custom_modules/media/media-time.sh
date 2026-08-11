#!/usr/bin/env bash

# Automatically kill the stream if Waybar restarts or closes the module
trap "exit 0" PIPE

# Follow player updates dynamically. If a player closes, it falls back cleanly.
playerctl -p playerctld metadata --format '{{duration(position)}}/{{duration(mpris:length)}}' -F 2>/dev/null | while read -r line; do
    if [ -n "$line" ]; then
        echo "$line"
    else
        echo ""
    fi
done
