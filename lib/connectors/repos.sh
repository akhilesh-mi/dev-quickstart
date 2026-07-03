# shellcheck shell=bash
# Source repos (GitLab). Reads config/repos.conf (name | prod-branch).

_repos_workspace() { printf '%s' "${MI_WORKSPACE:-$HOME/Documents/mastersindia}"; }
_repos_conf()      { printf '%s' "$ROOT/config/repos.conf"; }

c_repos_status() {
  local ws conf name branch rest
  conf="$(_repos_conf)"; ws="$(_repos_workspace)"
  [ -f "$conf" ] || return 1
  while IFS='|' read -r name branch rest; do
    name="$(trim "$name")"; [ -z "$name" ] && continue
    case "$name" in \#*) continue;; esac
    [ -d "$ws/$name/.git" ] && return 0
  done < "$conf"
  return 1
}

c_repos_setup() {
  pointer repos
  local conf ws host name branch rest url
  conf="$(_repos_conf)"

  if [ ! -f "$conf" ]; then
    warn "No repos.conf yet — it lists which repos to clone and their prod branches."
    say  "Get the list from your contact, then create it:"
    say  "  cp \"$ROOT/config/repos.conf.example\" \"$conf\""
    if confirm "Create repos.conf from the example now (you'll edit it after)?"; then
      cp "$ROOT/config/repos.conf.example" "$conf"
      ok "Created $conf — edit it with real repo names + branches, then re-run 'dev-quickstart add repos'."
    fi
    return 0
  fi

  prompt_value host "GitLab host (e.g. gitlab.internal or the VPN IP)" "${MI_GITLAB_HOST:-}"
  [ -z "$host" ] && { err "GitLab host is required (ask your contact)."; return 1; }
  prompt_value ws "Workspace directory to clone into" "$(_repos_workspace)"
  mkdir -p "$ws"

  while IFS='|' read -r name branch rest; do
    name="$(trim "$name")"; branch="$(trim "$branch")"
    [ -z "$name" ] && continue
    case "$name" in \#*) continue;; esac
    url="http://$host/mastersindia/$name.git"
    if [ -d "$ws/$name/.git" ]; then
      ok "$name already cloned"
    else
      say "Cloning $name ..."
      if ! git clone "$url" "$ws/$name"; then
        warn "clone failed for $name — VPN up? GitLab access granted? credentials cached?"
        continue
      fi
    fi
    if [ -n "$branch" ]; then
      ( cd "$ws/$name" && git checkout "$branch" >/dev/null 2>&1 && git pull --ff-only >/dev/null 2>&1 ) \
        && ok "$name → $branch (up to date)" \
        || warn "$name: couldn't switch to '$branch'"
    fi
  done < "$conf"
  dim "Tip: each repo may carry its own graphify-out/ graph — ask codebase questions with 'graphify query'."
}
