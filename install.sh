#!/usr/bin/env bash
# Puts `dev-quickstart` on your PATH by symlinking setup.sh into ~/.local/bin.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.local/bin"
chmod +x "$ROOT/setup.sh"
ln -sf "$ROOT/setup.sh" "$HOME/.local/bin/dev-quickstart"
echo "Installed: dev-quickstart -> $ROOT/setup.sh"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) echo 'Add this to your ~/.zshrc, then restart your shell:'
     echo '  export PATH="$HOME/.local/bin:$PATH"' ;;
esac

echo "Now run:  dev-quickstart"
