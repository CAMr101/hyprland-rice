#!/usr/bin/env bash

# Clear any dead loops if the desktop environment or bar terminates the pipeline
trap "kill %1; exit 0" EXIT

zscroll -l 30 \
    --delay 0.5 \
    --update-check true \
    "playerctl -p playerctld metadata --format '{{title}} - {{artist}}'" 2>/dev/null

wait!
