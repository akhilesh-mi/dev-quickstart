# shellcheck shell=bash
# menu.sh — interactive re-entrant menu + status/dispatch. Sourced by setup.sh.

name_at_index() { # $1=1-based index -> connector name
  local i="$1"
  case "$i" in (*[!0-9]*|"") return 1;; esac
  [ "$i" -ge 1 ] && printf '%s' "${CONNECTORS[$((i-1))]:-}"
}

status_mark() {   # $1=name -> echoes coloured ✓/○
  if "c_${1}_status" >/dev/null 2>&1; then printf '%s✓%s' "$C_GREEN" "$C_RESET"
  else printf '%s○%s' "$C_DIM" "$C_RESET"; fi
}

render_menu() {
  printf '\n'
  printf '%s Masters India — dev-quickstart %s\n' "$C_BOLD" "$C_RESET"
  dim ' Pick the connections you have credentials for. Come back anytime to add more.'
  printf '\n'
  local i=1 name
  for name in "${CONNECTORS[@]}"; do
    printf '  %2d. [%s] %s\n' "$i" "$(status_mark "$name")" "$(label_for "$name")"
    i=$((i+1))
  done
}

print_status() {
  local name
  for name in "${CONNECTORS[@]}"; do
    printf '  [%s] %-28s %s\n' "$(status_mark "$name")" "$(label_for "$name")" "$C_DIM$name$C_RESET"
  done
}

list_connectors_pretty() {
  local name
  for name in "${CONNECTORS[@]}"; do
    printf '  %-14s %s\n' "$name" "$(label_for "$name")"
  done
}

run_connector() {  # $1=name
  local name="$1"
  command -v "c_${name}_setup" >/dev/null 2>&1 || { err "unknown connector: $name"; return 1; }
  printf '\n'; hr
  printf '%s → %s%s\n' "$C_BOLD" "$(label_for "$name")" "$C_RESET"
  if "c_${name}_status" >/dev/null 2>&1; then
    ok "Already configured."
    confirm "Reconfigure?" || return 0
  fi
  "c_${name}_setup"
}

menu_loop() {
  local sel tok name
  while true; do
    render_menu
    printf '\n%sPick numbers (e.g. "1 3 5"), a=all pending, q=save & quit:%s ' "$C_CYAN" "$C_RESET" > /dev/tty
    IFS= read -r sel < /dev/tty || break
    case "$sel" in
      q|Q|"") break ;;
      a|A)
        for name in "${CONNECTORS[@]}"; do
          "c_${name}_status" >/dev/null 2>&1 || run_connector "$name"
        done ;;
      *)
        for tok in $sel; do
          name="$(name_at_index "$tok")" || { warn "not a valid item: $tok"; continue; }
          [ -n "$name" ] && run_connector "$name" || warn "no item $tok"
        done ;;
    esac
  done
}

usage() {
  cat <<EOF
dev-quickstart — set up Masters India dev access for you and your Claude.

  dev-quickstart            open the interactive menu (default)
  dev-quickstart status     show what's configured
  dev-quickstart list       list connector names
  dev-quickstart add NAME   configure one connector (e.g. add databases)
  dev-quickstart claude-md  (re)install the Claude knowledge block
  dev-quickstart help       this help

Credentials are typed in your own terminal and saved to per-user files
(0600) in your home directory. Nothing is committed or sent to chat.
EOF
}
