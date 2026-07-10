#!/usr/bin/env bash
# One-line bootstrap:
#   curl -fsSL https://raw.githubusercontent.com/akhilesh-mi/dev-quickstart/main/boot.sh | bash
# Clones (or updates) dev-quickstart, puts it on your PATH, and opens the menu.
set -euo pipefail

REPO="https://github.com/akhilesh-mi/dev-quickstart.git"
DIR="${DEV_QUICKSTART_DIR:-$HOME/.dev-quickstart}"

if [ -d "$DIR/.git" ]; then
  echo "Updating dev-quickstart…"
  git -C "$DIR" pull --ff-only || true
else
  echo "Fetching dev-quickstart…"
  git clone --depth 1 "$REPO" "$DIR"
fi

exec bash "$DIR/install.sh"
