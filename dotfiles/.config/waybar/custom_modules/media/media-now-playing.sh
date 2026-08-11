#!/usr/bin/env bash

# Clear any dead loops if the desktop environment or bar terminates the pipeline
trap " exit 0" EXIT PIPE

MAX_WIDTH=30
DELAY=0.5

# Keep track of the current scrolling character window index position across iterations
scroll_idx=0
last_track=""

# Helper function to print text safely. If the pipe breaks, it exits the script cleanly.
safe_echo() {
    if ! echo "$1"; then
        exit 0
    fi
}

while :; do 
    # Fetch player status securely
    status=$(playerctl -p playerctld status 2>/dev/null)

    # 1. STOPPED STATE: Clear out scroller text and print a clean default label
    if [ -z "$status" ] || [ "$status" == "Stopped" ]; then
        safe_echo " 󰎄 "
        scroll_idx=0
        last_track=""
        sleep 2
        continue
    fi

    # Fetch track metadata safely
    title=$(playerctl -p playerctld metadata title 2>/dev/null)
    artist=$(playerctl -p playerctld metadata artist 2>/dev/null)

    [ -z "$title" ] && title="Unknown Track"
    [ -z "$artist" ] && artist="Unknown Artist"
    track="$title - $artist"

    # Reset scroller window position if you skipped to a completely new track
    if [ "$track" != "$last_track" ]; then
        scroll_idx=0
        last_track="$track"
    fi

    # 2. PAUSED STATE: Slice a static segment of the text and force it to freeze
    if [ "$status" == "Paused" ]; then
        safe_echo " ${track:0:$MAX_WIDTH}"
        sleep 0.5
        continue
    fi

    # 3. PLAYING STATE: Calculate marquee positioning frame shifting inside shell memory
    if [ "$status" == "Playing" ]; then
        text_to_scroll="$track    |    "
        text_len=${#text_to_scroll}

        if [ "$text_len" -le "$MAX_WIDTH" ]; then
            # No need to cycle or frame shift if the text already fits inside your bounds
            safe_echo "$track"
        else
            # Extract a moving character substring window allocation
            scrolled_text=""
            for ((i=0; i<MAX_WIDTH; i++)); do
                pos=$(( (scroll_idx + i) % text_len ))
                scrolled_text+="${text_to_scroll:$pos:1}"
            done

            safe_echo " $scrolled_text"
            
            # Increment frame step allocation
            scroll_idx=$(( (scroll_idx + 1) % text_len ))
        fi
        
        # This sleep acts as your scroll timing mechanism frame rate speed layout
        sleep "$DELAY"
    fi
done

# Run zscroll with native condition matches to handle pausing/stopping
# zscroll -l 30 \
#     --delay 0.5 \
#     --update-check true \
#     "playerctl -p playerctld metadata --format '{{title}} - {{artist}}'" 2>/dev/null

# wait $!
