#!/bin/bash
# Build app/ported into ported/bin/inet98.exe with the win32 Free Pascal
# compiler under Wine. Pass --debug for a console build with line info,
# inet98-debug.exe, which prints start-up exceptions to stderr.
set -euo pipefail
source "$(dirname "$0")/env.sh"

if [ ! -x "$WINE_BIN" ]; then
  echo "Toolchain missing, run scripts/setup.sh first." >&2
  exit 1
fi

MODE_FLAGS=(-WG -O1)
OUT=inet98.exe
LIB=lib/release
if [ "${1:-}" = "--debug" ]; then
  MODE_FLAGS=(-WC -gl -O-)
  OUT=inet98-debug.exe
  LIB=lib/debug
fi

cd "$PORTED_DIR"
mkdir -p "$BIN_DIR/bar" "$LIB"

L="$LAZARUS_DIR"
cd src
wine_run "$FPC_EXE" -Mdelphi -Twin32 -vewn -Sh -B "${MODE_FLAGS[@]}" \
  -dLCL -dLCLwin32 -dSpriteRegistered \
  -Fu"$L\\lcl\\units\\i386-win32\\win32" -Fu"$L\\lcl\\units\\i386-win32" \
  -Fu"$L\\components\\lazutils\\lib\\i386-win32" \
  -Fu"$L\\components\\freetype\\lib\\i386-win32" \
  -Fu'..\sprite' -Fu'..\common.d32' -Fu'..\compat' \
  -FU"..\\${LIB//\//\\}" -o"..\\bin\\$OUT" inet98.lpr \
  | grep -v -e 'Hint:' -e 'Note:'

# Runtime files: the hand cursor and screen-saver picture sit next to the exe;
# option flags live in bar/ (see src/bar-options.txt).
cp hand.cur "$BIN_DIR/"
cp screen.bmp "$BIN_DIR/bar/"
touch "$BIN_DIR/bar/noautoreboot"

test -f "$BIN_DIR/$OUT"
echo "Built $BIN_DIR/$OUT"
