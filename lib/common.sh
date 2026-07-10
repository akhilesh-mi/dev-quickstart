# shellcheck shell=bash
# common.sh — shared helpers for dev-quickstart. Sourced by setup.sh (which sets $ROOT).

CONNECTORS_FILE="$ROOT/config/connectors.conf"

# ---- colors -----------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_CYAN=$'\033[36m'
else
  C_RESET=; C_DIM=; C_BOLD=; C_GREEN=; C_YELLOW=; C_RED=; C_CYAN=
fi

say()  { printf '%s\n' "$*"; }
dim()  { printf '%s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }
ok()   { printf '%s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '%s✗%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
hr()   { printf '%s%s%s\n' "$C_DIM" "────────────────────────────────────────────────────────" "$C_RESET"; }

trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"; printf '%s' "$s"; }

# ---- interactive prompts (always read from the terminal) --------------------
prompt_value() {  # $1=varname  $2=prompt  $3=default
  local __var="$1" __p="$2" __def="${3:-}" __in
  if [ -n "$__def" ]; then printf '%s [%s]: ' "$__p" "$__def" > /dev/tty
  else printf '%s: ' "$__p" > /dev/tty; fi
  IFS= read -r __in < /dev/tty || true
  [ -z "$__in" ] && __in="$__def"
  printf -v "$__var" '%s' "$__in"
}

prompt_secret() { # $1=varname  $2=prompt  (input hidden)
  local __var="$1" __p="$2" __in
  printf '%s: ' "$__p" > /dev/tty
  IFS= read -rs __in < /dev/tty || true
  printf '\n' > /dev/tty
  printf -v "$__var" '%s' "$__in"
}

confirm() {       # $1=question  -> 0 for yes
  local __in
  printf '%s [y/N]: ' "$1" > /dev/tty
  IFS= read -r __in < /dev/tty || true
  case "$__in" in [yY]|[yY][eE][sS]) return 0;; *) return 1;; esac
}

# ---- credential files -------------------------------------------------------
# Upsert KEY=VALUE into an env file, creating it 0600.
write_kv() {      # $1=file  $2=key  $3=value
  local file="$1" key="$2" val="$3" tmp
  touch "$file"; chmod 600 "$file"
  tmp="$(mktemp "${TMPDIR:-/tmp}/dq.XXXXXX")"
  grep -v -E "^${key}=" "$file" > "$tmp" 2>/dev/null || true
  printf '%s=%s\n' "$key" "$val" >> "$tmp"
  mv "$tmp" "$file"; chmod 600 "$file"
}

# ---- connector registry (config/connectors.conf) ---------------------------
# format:  name | label | contact | help_url | note
_conf_field() {   # $1=name  $2=field-number
  awk -F'|' -v n="$1" -v f="$2" '
    /^[[:space:]]*#/ { next }
    {
      k=$1; gsub(/^[[:space:]]+|[[:space:]]+$/,"",k)
      if (k==n) { v=$f; gsub(/^[[:space:]]+|[[:space:]]+$/,"",v); print v; exit }
    }' "$CONNECTORS_FILE"
}
label_for()   { _conf_field "$1" 2; }
contact_for() { _conf_field "$1" 3; }
help_for()    { _conf_field "$1" 4; }
note_for()    { _conf_field "$1" 5; }

list_connector_names() {
  awk -F'|' '/^[[:space:]]*#/{next} { k=$1; gsub(/^[[:space:]]+|[[:space:]]+$/,"",k); if (k!="") print k }' "$CONNECTORS_FILE"
}

# Print the "where do I get access" pointer for a connector.
pointer() {       # $1=name
  local c h n
  n="$(note_for "$1")";  [ -n "$n" ] && dim "  · $n"
  h="$(help_for "$1")";  [ -n "$h" ] && dim "  · Help: $h"
  c="$(contact_for "$1")"; [ -n "$c" ] && dim "  · Need access? Contact: $c"
}

# ---- MCP helpers ------------------------------------------------------------
# True if an MCP server is REGISTERED (config only — no slow/flaky health check).
_mcp_registered() {   # $1 = egrep name pattern, e.g. "notion" or "atlassian|jira"
  local f
  for f in "$HOME/.claude.json" "$HOME/.claude/settings.json"; do
    [ -f "$f" ] && grep -qiE "\"($1)\"[[:space:]]*:" "$f" && return 0
  done
  command -v claude >/dev/null 2>&1 && claude mcp list 2>/dev/null | grep -qiE "$1"
}

# ---- global CLAUDE.md block -------------------------------------------------
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CLAUDE_BEGIN="<!-- dev-quickstart:begin -->"
CLAUDE_END="<!-- dev-quickstart:end -->"

install_claude_block() {
  local block="$ROOT/claude/CLAUDE.block.md" tmp
  [ -f "$block" ] || { err "missing $block"; return 1; }
  mkdir -p "$HOME/.claude"
  touch "$CLAUDE_MD"
  tmp="$(mktemp "${TMPDIR:-/tmp}/dq.XXXXXX")"
  # strip any previous block, then append the fresh one
  awk -v b="$CLAUDE_BEGIN" -v e="$CLAUDE_END" '
    $0==b {skip=1} skip==0 {print} $0==e {skip=0}' "$CLAUDE_MD" > "$tmp"
  # drop trailing blank lines then add block
  printf '\n' >> "$tmp"
  cat "$block" >> "$tmp"
  mv "$tmp" "$CLAUDE_MD"
  ok "Installed dev-quickstart knowledge into $CLAUDE_MD"
}

maybe_install_claude_block() {
  if ! grep -q "$CLAUDE_BEGIN" "$CLAUDE_MD" 2>/dev/null; then
    install_claude_block
  fi
}
