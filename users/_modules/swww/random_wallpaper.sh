#!/usr/bin/env bash
set -euxo pipefail

if command -v swww >/dev/null 2>&1; then
  swww img "$(find ~/Pictures/Wallpapers/. -name '*.png' -o -name '*.jpg' | shuf -n1)" --transition-type simple
fi

swww query | while read -r LINE; do
  # Example LINE:
  # : DP-3: 1440x2560, scale: 1, currently displaying: image: /home/max/Pictures/Wallpapers/16_9/2469565d2d302311.jpg
  RESOLUTION=$(awk 'BEGIN { FS = " " } ; { print substr($3, 1, length($3) -1) }' <<<"$LINE")
  OUTPUT=$(awk 'BEGIN { FS = ": " } ; { print $2 }' <<<"$LINE")
  ASPECT_RATIO=$(compute_aspect_ratio "$RESOLUTION")

  IMAGES=$(fd --type f --extension png --extension jpg --extension jpeg '' "$HOME/Pictures/Wallpapers/$ASPECT_RATIO" | shuf -n1)
  # If no were found use 16:9
  if [ -z "$IMAGES" ]; then
    IMAGES=$(fd --type f --extension png --extension jpg --extension jpeg '' "$HOME/Pictures/Wallpapers/16_9" | shuf -n1)
  fi

  swww img "$IMAGES" --transition-type simple --outputs "$OUTPUT"
done
