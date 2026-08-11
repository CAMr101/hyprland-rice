#!/usr/bin/env bash

animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")

# Automatically exit if Waybar stops reading the script output
trap "exit 0" PIPE

while :; do
  # Strict 0.05s timeout stops the DBus freeze during track switches
  status=$(timeout 0.05 playerctl -p playerctld metadata --format '{{status}}' 2>/dev/null)

  if [ "$status" == "Playing" ]; then
      for frame in "${animation_frames[@]}"; do
          echo "$frame"
          sleep 0.15
      done
  elif [ "$status" == "Paused" ]; then
      echo ""
      sleep 0.5
  else
      echo ""
      sleep 1.0
  fi
done
