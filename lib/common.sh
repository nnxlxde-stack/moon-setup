#!/usr/bin/env bash
MOON_LANG_REPO="${MOON_LANG_REPO:-https://github.com/nnxlxde-stack/moon-lang.git}"
MOON_VSCODE_RELEASE_API="${MOON_VSCODE_RELEASE_API:-https://api.github.com/repos/nnxlxde-stack/moon-vscode/releases/latest}"
DEFAULT_INSTALL_DIR="${MOON_INSTALL_DIR:-$HOME/moon}"

step() { echo "==> $*"; }

require_git() { command -v git >/dev/null || { echo "git required" >&2; exit 1; }; }
require_swift() { command -v swift >/dev/null || { echo "Swift 6.3+ required" >&2; exit 1; }; }