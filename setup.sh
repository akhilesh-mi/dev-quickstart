#!/usr/bin/env bash
# dev-quickstart — set up Masters India dev access for you and your Claude.
# Run this in YOUR OWN terminal so credential prompts stay off the screen and
# out of any chat transcript. Re-run anytime to add or repair connections.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/common.sh"
for _f in "$ROOT"/lib/connectors/*.sh; do . "$_f"; done
. "$ROOT/lib/menu.sh"

# ordered list of connector names, from config/connectors.conf
CONNECTORS=()
while IFS= read -r _n; do CONNECTORS+=("$_n"); done < <(list_connector_names)

main() {
  local cmd="${1:-menu}"
  case "$cmd" in
    menu|"")      menu_loop; maybe_install_claude_block
                  printf '\n'; hr; say "Here's what's set up:"; print_status
                  printf '\n'; ok "Done. Re-run 'dev-quickstart' anytime to add more."
                  dim "Now start a fresh Claude Code session — it'll pick these up automatically." ;;
    status)       print_status ;;
    list)         list_connectors_pretty ;;
    add)          shift; if [ -n "${1:-}" ]; then run_connector "$1"; maybe_install_claude_block; else err "usage: dev-quickstart add <name>"; return 1; fi ;;
    claude-md)    install_claude_block ;;
    -h|--help|help) usage ;;
    *)            err "unknown command: $cmd"; usage; return 1 ;;
  esac
}

main "$@"
