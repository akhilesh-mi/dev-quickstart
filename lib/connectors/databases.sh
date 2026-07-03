# shellcheck shell=bash
# Databases — MongoDB + PostgreSQL (read-only). VPN required to connect.

_db_file() { printf '%s' "$HOME/.mi_db_creds.env"; }

c_databases_status() { [ -f "$(_db_file)" ]; }

c_databases_setup() {
  pointer databases
  local f; f="$(_db_file)"

  if confirm "Configure MongoDB?"; then
    local uri
    prompt_secret uri "Mongo connection URI (mongodb://user:pass@host:port/db)"
    [ -n "$uri" ] && { write_kv "$f" MI_MONGO_URI "$uri"; ok "Mongo saved"; }
  fi

  if confirm "Configure PostgreSQL?"; then
    local h p db u pw
    prompt_value  h  "PG host"
    prompt_value  p  "PG port" "5432"
    prompt_value  db "PG database"
    prompt_value  u  "PG user"
    prompt_secret pw "PG password"
    write_kv "$f" MI_PG_HOST "$h"
    write_kv "$f" MI_PG_PORT "$p"
    write_kv "$f" MI_PG_DB   "$db"
    write_kv "$f" MI_PG_USER "$u"
    write_kv "$f" MI_PG_PASSWORD "$pw"
    ok "Postgres saved"
  fi

  [ -f "$f" ] && say "Saved → ~/.mi_db_creds.env (0600)"
  dim "Use read-only. Never write, and never put customer PII in output."
}
