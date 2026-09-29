#!/bin/bash
# Drives the launcher with cliclick while record.sh records the screen.
# Coordinates are in points for a 1512x982 display with the bar at the top left.
set -euo pipefail
D="${DEMO_DIR:-/tmp/inet98demo}"
rm -f "$D/saver" "$D/go"

# Activate the launcher; buttons only react to hover when it's the active app.
cliclick m:600,500 w:1000 m:150,640 w:500 c:150,640 w:800
for y in 168 194 218 244 268 300 325 350 380 405 430; do cliclick m:150,$y w:900; done

# Keyboard backdoor: -stats, then the password in the Password Required dialog.
cliclick m:150,640 w:500 c:150,640 w:800
cliclick t:-stats w:300 kp:return w:1500
cliclick m:824,489 w:400 c:824,489 w:400 t:cfv2cpo w:800 kp:return w:2500

# Remote admin session: show the pre-opened Terminal window and start remote.py.
W=$(cat "$D/winid")
osascript -e "tell application \"Terminal\" to set visible of window id $W to true"
touch "$D/go"
cliclick m:620,900

# Dismiss the screen saver a few seconds after SAVER is sent.
while [ ! -f "$D/saver" ]; do sleep 0.2; done
sleep 4
cliclick m:600,700 w:200 m:640,720
sleep 12
