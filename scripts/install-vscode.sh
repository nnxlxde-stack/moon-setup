#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/lib/common.sh"

command -v code >/dev/null || { echo "VS Code 'code' CLI required" >&2; exit 1; }

VSIX="${1:-}"
if [[ -z "$VSIX" ]]; then
  step "Downloading latest moon-vscode release"
  url=$(curl -fsSL -H "User-Agent: moon-setup" "$MOON_VSCODE_RELEASE_API" \
    | python3 -c "import json,sys; r=json.load(sys.stdin); print(next(a['browser_download_url'] for a in r['assets'] if a['name'].endswith('.vsix')))")
  VSIX="$(mktemp /tmp/vscode-moon-XXXX.vsix)"
  curl -fsSL "$url" -o "$VSIX"
fi

step "Installing $VSIX"
code --install-extension "$VSIX" --force
echo "Moon VS Code extension installed."