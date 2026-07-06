#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_git
require_swift

INSTALL_DIR="${1:-$DEFAULT_INSTALL_DIR}"
LANG_DIR="$INSTALL_DIR/moon-lang"
step "Moon toolchain -> $LANG_DIR"
mkdir -p "$INSTALL_DIR"
if [[ -d "$LANG_DIR/.git" ]]; then
  (cd "$LANG_DIR" && git pull)
else
  git clone "$MOON_LANG_REPO" "$LANG_DIR"
fi
(cd "$LANG_DIR" && swift build)
"$LANG_DIR/.build/debug/moon" version
echo "Add to PATH: $LANG_DIR/.build/debug/moon"