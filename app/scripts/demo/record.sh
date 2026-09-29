#!/bin/bash
# Records the launcher demo to $DEMO_DIR/rec.mov (macOS only).
#
# Needs ffmpeg and cliclick (brew install ffmpeg cliclick), and Screen Recording
# and Accessibility permissions for the terminal. Run from Terminal.app: the
# front Terminal window is minimized while recording and restored afterwards.
# Don't touch the mouse or keyboard while it runs (about 80 seconds).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/../env.sh"
export DEMO_DIR="${DEMO_DIR:-/tmp/inet98demo}"
D="$DEMO_DIR"
SCREEN="${SCREEN:-$(ffmpeg -hide_banner -f avfoundation -list_devices true -i "" 2>&1 | sed -n 's/.*\[\([0-9]*\)\] Capture screen 0.*/\1/p' | head -1)}"
mkdir -p "$D"
rm -f "$D/go" "$D/winid" "$D/saver" "$D/rec.mov"

stop_launcher() {
  python3 - <<'PY'
import socket, time
try:
    s = socket.create_connection(('127.0.0.1', 10895))
    time.sleep(0.3)
    for line in (b'db4ever\r\n', b'TERM\r\n'):
        s.send(line)
        time.sleep(0.8)
except OSError:
    pass
PY
}

SHELL_WIN=$(osascript -e 'tell application "Terminal" to get id of front window')

"$HERE/../run.sh" >/dev/null 2>&1 &
for _ in $(seq 60); do nc -z 127.0.0.1 10895 2>/dev/null && break; sleep 1; done
sleep 3

# Open the remote session window now, cleared and sized, then hide it so no
# shell start-up output or resizing ends up in the recording.
osascript <<OSA
tell application "System Events" to set autohide menu bar of dock preferences to true
tell application "Terminal"
  set t to do script "clear; exec python3 '$HERE/remote.py'"
  set w to front window
  do shell script "echo " & (id of w) & " > '$D/winid'"
  set background color of t to {0, 0, 0}
  set normal text color of t to {0, 60000, 0}
  set cursor color of t to {0, 60000, 0}
  set font size of t to 14
  delay 0.5
  set bounds of w to {240, 50, 1000, 960}
  delay 2
  set visible of w to false
  set miniaturized of window id $SHELL_WIN to true
end tell
OSA
sleep 2

ffmpeg -loglevel error -f avfoundation -capture_cursor 1 -framerate 15 -pixel_format uyvy422 \
  -i "$SCREEN" -t 150 -c:v libx264 -preset ultrafast -crf 18 -y "$D/rec.mov" </dev/null >"$D/ffmpeg.log" 2>&1 &
FF=$!
sleep 3
"$HERE/driver.sh" >"$D/driver.log" 2>&1
sleep 1
kill -INT $FF
wait $FF

W=$(cat "$D/winid" 2>/dev/null)
[ -n "$W" ] && osascript -e "tell application \"Terminal\" to if exists window id $W then close window id $W saving no" >/dev/null 2>&1
stop_launcher
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to false'
osascript -e "tell application \"Terminal\"
  set miniaturized of window id $SHELL_WIN to false
  set index of window id $SHELL_WIN to 1
  activate
end tell"
echo "Recorded $D/rec.mov, now run $HERE/encode.sh"
