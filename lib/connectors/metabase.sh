# shellcheck shell=bash
# Metabase — session token for the analytics UI/API. VPN may be required.

c_metabase_status() { [ -f "$HOME/.mi_metabase_session" ]; }

c_metabase_setup() {
  pointer metabase
  local url tok
  prompt_value url "Metabase URL (https://...)" "${MI_METABASE_URL:-}"
  say  "Get your session token: log in to Metabase in a browser →"
  say  "  DevTools → Application → Cookies → copy the 'metabase.SESSION' value."
  prompt_secret tok "Metabase session token"
  [ -z "$tok" ] && { err "session token is required"; return 1; }

  write_kv "$HOME/.mi_metabase_session" MI_METABASE_URL     "$url"
  write_kv "$HOME/.mi_metabase_session" MI_METABASE_SESSION "$tok"
  ok "Saved → ~/.mi_metabase_session (0600)"
  dim "Session tokens expire — re-run 'dev-quickstart add metabase' when it stops working."
}
