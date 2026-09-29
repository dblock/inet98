#!/bin/bash
# Run the ported launcher under Wine. Pass --debug to run inet98-debug.exe.
set -euo pipefail
source "$(dirname "$0")/env.sh"

EXE=inet98.exe
[ "${1:-}" = "--debug" ] && EXE=inet98-debug.exe

if [ ! -f "$BIN_DIR/$EXE" ]; then
  echo "$BIN_DIR/$EXE not found, run scripts/build.sh ${1:-} first." >&2
  exit 1
fi

# Options are read from bar/ relative to the working directory.
cd "$BIN_DIR"
echo "Remote control: nc 127.0.0.1 10895 (Ctrl+C here to quit)"
wine_run "$EXE"
