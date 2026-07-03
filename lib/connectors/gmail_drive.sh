# shellcheck shell=bash
# Gmail + Drive — OAuth as yourself (scopes: gmail.send + drive).
# Uses a shared OAuth *client* (credentials.json); each dev mints their own token.

MI_GMAIL_DIR="${MI_GMAIL_DIR:-$HOME/.mi_gmail_ack}"

c_gmail_drive_status() { [ -f "$MI_GMAIL_DIR/token.json" ]; }

c_gmail_drive_setup() {
  pointer gmail_drive
  mkdir -p "$MI_GMAIL_DIR"; chmod 700 "$MI_GMAIL_DIR"

  if [ ! -f "$MI_GMAIL_DIR/credentials.json" ]; then
    warn "Missing the OAuth client file: $MI_GMAIL_DIR/credentials.json"
    say  "Two ways to get it:"
    say  "  1) Ask your contact for the shared credentials.json (recommended), OR"
    say  "  2) Create your own: Google Cloud Console → APIs & Services → Credentials →"
    say  "     Create OAuth client ID → 'Desktop app' → Download JSON."
    say  "Save it as: $MI_GMAIL_DIR/credentials.json  then re-run 'dev-quickstart add gmail_drive'."
    return 0
  fi

  say "Installing Google client libraries (pip --user)…"
  python3 -m pip install --user --quiet google-auth-oauthlib google-api-python-client >/dev/null 2>&1 \
    || warn "pip install reported issues — the OAuth step may still work if libs are present."

  say "Opening the Google consent screen — sign in with YOUR account…"
  if MI_GMAIL_DIR="$MI_GMAIL_DIR" python3 "$ROOT/auth/gmail_auth.py"; then
    ok "Authorized as you → $MI_GMAIL_DIR/token.json (0600)"
  else
    warn "OAuth flow did not complete. Re-run 'dev-quickstart add gmail_drive' to retry."
  fi
}
