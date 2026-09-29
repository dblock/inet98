#!/bin/bash
# Crops $DEMO_DIR/rec.mov and writes app/inet98-launcher.mp4 and .gif.
# Needs ffmpeg and gifsicle.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$HERE/../.." && pwd)"
D="${DEMO_DIR:-/tmp/inet98demo}"
START="${START:-3}"
END="${END:-71}"
# Seconds of rec.mov to drop, to shorten the button-hover sequence.
CUT_FROM="${CUT_FROM:-7.9}"
CUT_TO="${CUT_TO:-16.4}"
CROP="trim=$START:$END,select='not(between(t,$CUT_FROM,$CUT_TO))',setpts=N/FRAME_RATE/TB,crop=2000:1964:0:0"

ffmpeg -loglevel error -i "$D/rec.mov" -vf "$CROP,format=yuv420p" \
  -c:v libx264 -preset slow -crf 24 -movflags +faststart -an -y "$APP_DIR/inet98-launcher.mp4"
ffmpeg -loglevel error -i "$D/rec.mov" \
  -vf "$CROP,fps=8,scale=720:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=64:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
  -y "$D/demo.gif"
gifsicle -O3 --lossy=30 "$D/demo.gif" -o "$APP_DIR/inet98-launcher.gif"
ls -la "$APP_DIR/inet98-launcher.mp4" "$APP_DIR/inet98-launcher.gif"
