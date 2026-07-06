#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/lib/common.sh"
INSTALL_DIR="${MOON_INSTALL_DIR:-$HOME/moon}"
MOON="$INSTALL_DIR/moon-lang/.build/debug/moon"

step "Verifying Moon installation"
if [[ -x "$MOON" ]]; then
  "$MOON" version
elif command -v moon >/dev/null; then
  moon version
else
  echo "moon CLI not found. Run install-moon.sh first."
fi

if command -v code >/dev/null; then
  if code --list-extensions 2>/dev/null | grep -qi moon; then
    echo "VS Code extension: installed"
  else
    echo "Moon VS Code extension not installed."
  fi
fi