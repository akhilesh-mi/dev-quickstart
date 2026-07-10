#!/usr/bin/env bash
# Puts `dev-quickstart` on your PATH, then opens the menu.
# Set DQ_NO_RUN=1 to install without launching.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.local/bin"
chmod +x "$ROOT/setup.sh"
ln -sf "$ROOT/setup.sh" "$HOME/.local/bin/dev-quickstart"
echo "Installed: dev-quickstart -> $ROOT/setup.sh"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) echo 'Add this to your ~/.zshrc so `dev-quickstart` works next time:'
     echo '  export PATH="$HOME/.local/bin:$PATH"' ;;
esac

if [ -z "${DQ_NO_RUN:-}" ] && [ -r /dev/tty ]; then
  exec "$ROOT/setup.sh"
else
  echo "Run:  dev-quickstart"
fi
