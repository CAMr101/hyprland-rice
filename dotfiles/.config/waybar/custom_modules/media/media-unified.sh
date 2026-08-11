#!/usr/bin/env bash

# Clear any trapped child processes when exiting
trap "exit 0" EXIT

frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")
anim_idx=0
scroll_idx=0
max_width=20

while :; do
  # Strict 0.1s timeout prevents hanging during song switches
  status=$(timeout 0.1 playerctl status 2>/dev/null)
  
  if [ -z "$status" ]; then
    echo '{"text": "", "class": "stopped"}'
    scroll_idx=0
    sleep 1
    continue
  fi

  # Pull data safely using native bash clean assignments
  title=$(timeout 0.1 playerctl metadata title 2>/dev/null)
  artist=$(timeout 0.1 playerctl metadata artist 2>/dev/null)
  time_info=$(timeout 0.1 playerctl metadata --format '{{duration(position)}}/{{duration(mpris:length)}}' 2>/dev/null)

  # Fallback formatting if metadata is empty
  [ -z "$title" ] && title="Unknown Title"
  [ -z "$artist" ] && artist="Unknown Artist"
  track="$title - $artist"

  # Handle Animation Frame
  if [ "$status" == "Playing" ]; then
    icon="${frames[$anim_idx]}"
    anim_idx=$(( (anim_idx + 1) % ${#frames[@]} ))
  elif [ "$status" == "Paused" ]; then
    icon=""
  else
    icon=""
  fi

  # Strict JSON escaping using sed for special characters and quotes
  clean_track=$(echo "$track" | sed 's/"/\\"/g; s/\\/\\\\/g')
  text_to_scroll="$clean_track   |   "
  text_len=${#text_to_scroll}
  
  # Scroller Logic
  if [ "$text_len" -gt "$max_width" ] && [ "$status" == "Playing" ]; then
    scrolled_text=""
    for ((i=0; i<max_width; i++)); do
      pos=$(( (scroll_idx + i) % text_len ))
      scrolled_text+="${text_to_scroll:$pos:1}"
    done
    scroll_idx=$(( (scroll_idx + 1) % text_len ))
  else
    scrolled_text="${clean_track:0:$max_width}"
  fi

  # Format output payload
  full_display="$icon  $scrolled_text  [$time_info]"
  
  # Print the strict JSON format Waybar demands
  printf '{"text": "%s", "class": "%s"}\n' "$full_display" "${status,,}"

  sleep 0.2
done
