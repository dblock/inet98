#!/bin/bash
# Install the toolchain used to build inet98 on macOS: Wine plus the Windows
# (win32) Lazarus/Free Pascal distribution, into $INET98_TOOLS.
set -euo pipefail
source "$(dirname "$0")/env.sh"

mkdir -p "$INET98_TOOLS"

if ! command -v innoextract >/dev/null; then
  brew install innoextract
fi

# The Homebrew wine casks are disabled (Gatekeeper), so use the WineHQ build Homebrew used to ship.
if [ ! -x "$WINE_BIN" ]; then
  echo "Downloading Wine $WINE_VERSION ..."
  curl -fL -o "$INET98_TOOLS/wine.tar.xz" \
    "https://github.com/Gcenx/macOS_Wine_builds/releases/download/$WINE_VERSION/wine-devel-$WINE_VERSION-osx64.tar.xz"
  tar -xf "$INET98_TOOLS/wine.tar.xz" -C "$INET98_TOOLS"
  rm "$INET98_TOOLS/wine.tar.xz"
  xattr -dr com.apple.quarantine "$WINE_APP" 2>/dev/null || true
fi

if [ ! -d "$WINEPREFIX/drive_c/windows" ]; then
  echo "Creating Wine prefix $WINEPREFIX ..."
  wine_run wineboot -i
fi

# The Lazarus Inno Setup installer crashes under Wine, so unpack it with innoextract instead.
LAZ_ROOT="$WINEPREFIX/drive_c/lazarus"
if [ ! -d "$LAZ_ROOT/lcl/units/i386-win32" ]; then
  echo "Downloading Lazarus $LAZARUS_VERSION (win32) ..."
  tmp="$(mktemp -d)"
  curl -fL -o "$tmp/lazarus.exe" \
    "https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2032%20bits/Lazarus%20$LAZARUS_VERSION/lazarus-$LAZARUS_VERSION-fpc-$FPC_VERSION-win32.exe/download"
  innoextract -s -d "$tmp/x" "$tmp/lazarus.exe"
  rm -rf "$LAZ_ROOT"
  mv "$tmp/x/app" "$LAZ_ROOT"
  rm -rf "$tmp"
fi

FPC_CFG="$LAZARUS_DIR\\fpc\\$FPC_VERSION\\bin\\i386-win32\\fpc.cfg"
if [ ! -f "$LAZ_ROOT/fpc/$FPC_VERSION/bin/i386-win32/fpc.cfg" ]; then
  wine_run "$LAZARUS_DIR\\fpc\\$FPC_VERSION\\bin\\i386-win32\\fpcmkcfg.exe" \
    -d "basepath=$LAZARUS_DIR\\fpc\\$FPC_VERSION" -o "$FPC_CFG"
fi

# The launcher hides buttons whose 1998 program paths don't exist. Create
# stand-ins (Wine's notepad) at those paths so all eleven buttons show.
C="$WINEPREFIX/drive_c"
H="$WINEPREFIX/drive_h"
mkdir -p "$H"
ln -sfn ../drive_h "$WINEPREFIX/dosdevices/h:"
NOTEPAD="$C/windows/notepad.exe"
for f in \
  "$C/Internet Explorer/Iexplore.exe" \
  "$C/Program Files/Netscape/Communicator/Program/netscape.exe" \
  "$C/PcPine/pine.exe" \
  "$C/windows/telnet.exe" \
  "$C/ftp/ws_ftp95.exe" \
  "$H/msoffice.97/office/winword.exe" \
  "$H/msoffice.97/office/excel.exe" \
  "$H/msoffice.97/office/powerpnt.exe" \
  "$H/msoffice.95/winword/winword.exe" \
  "$H/msoffice.95/excel/excel.exe" \
  "$H/msoffice.95/powerpnt/powerpnt.exe"; do
  if [ ! -f "$f" ]; then
    mkdir -p "$(dirname "$f")"
    cp "$NOTEPAD" "$f"
  fi
done

echo "Free Pascal: $(wine_run "$FPC_EXE" -iV)"
echo "Toolchain ready in $INET98_TOOLS"
