# shellcheck shell=bash
# Graphify — knowledge-graph CLI for asking codebase questions cheaply.

c_graphify_status() { command -v graphify >/dev/null 2>&1; }

c_graphify_setup() {
  if command -v graphify >/dev/null 2>&1; then
    ok "graphify already installed: $(command -v graphify)"
    return 0
  fi
  pointer graphify
  warn "graphify not found on PATH."
  say  "Make sure ~/.local/bin is on your PATH:"
  say  '  export PATH="$HOME/.local/bin:$PATH"   # add to ~/.zshrc'
  if confirm "Try installing from PyPI with 'pip3 install --user graphify'?"; then
    if python3 -m pip install --user graphify; then
      ok "Installed. Re-open your shell or re-run PATH export above."
    else
      warn "pip install failed — graphify may be an internal tool. Ask your contact for install steps."
    fi
  fi
}
