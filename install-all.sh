#!/usr/bin/env bash
# Moon ecosystem installer (macOS/Linux)
# Usage: curl -fsSL https://raw.githubusercontent.com/nnxlxde-stack/moon-setup/main/install-all.sh | bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
"$ROOT/scripts/install-moon.sh"
"$ROOT/scripts/install-vscode.sh"
"$ROOT/scripts/verify.sh"
echo ""
echo "Done. Docs: https://github.com/nnxlxde-stack/moon-lang/blob/main/docs/index.html"