# shellcheck shell=bash
# Company VPN (L2TP). Stores the shared secret; VPN gates most internal tools.

c_vpn_status() { [ -f "$HOME/.mi_vpn_secret" ]; }

c_vpn_setup() {
  pointer vpn
  local server secret
  prompt_value  server "VPN server host/IP"
  prompt_secret secret "VPN L2TP shared secret"
  [ -z "$secret" ] && { err "shared secret is required"; return 1; }

  printf '%s\n' "$secret" > "$HOME/.mi_vpn_secret"
  chmod 600 "$HOME/.mi_vpn_secret"
  write_kv "$HOME/.mi_vpn.env" MI_VPN_SERVER "$server"
  ok "Saved shared secret → ~/.mi_vpn_secret (0600)"

  say "Finish setup in macOS System Settings → Network → VPN → Add VPN (L2TP over IPsec):"
  say "  • Server address: $server"
  say "  • Shared secret : (the value you just entered)"
  say "  • Username/password: your own VPN account"
  dim "Your VPN login is personal — this tool never asks for it."
}
