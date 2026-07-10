# shellcheck shell=bash
# Repos — tell Claude WHERE your repos live. Cloning is optional (for devs who
# don't have them yet). Most devs already have the repos, so this just records
# the folder into ~/.mi_workspace.

_repos_conf() { printf '%s' "$ROOT/config/repos.conf"; }

# number of immediate subdirectories that are git repos
_count_git() {  # $1=dir
  local d="$1" n=0 p
  for p in "$d"/*/.git; do [ -d "$p" ] && n=$((n+1)); done
  printf '%s' "$n"
}

# best guess for where the repos already are
_guess_ws() {
  local c
  if [ -f "$HOME/.mi_workspace" ]; then cat "$HOME/.mi_workspace"; return; fi
  for c in "$HOME/Documents/mastersindia" "$HOME/Projects" "$HOME/mastersindia" "$HOME/code" "$HOME/work" "$HOME/repos"; do
    [ -d "$c" ] && [ "$(_count_git "$c")" -ge 1 ] && { printf '%s' "$c"; return; }
  done
  printf '%s' "$HOME/Documents/mastersindia"
}

c_repos_status() {
  local d
  [ -f "$HOME/.mi_workspace" ] || return 1
  d="$(cat "$HOME/.mi_workspace" 2>/dev/null)"
  [ -n "$d" ] && [ -d "$d" ] && [ "$(_count_git "$d")" -ge 1 ]
}

c_repos_setup() {
  say "This just tells Claude where your repos live — so it can read code and run graphify."
  say "If you already have the repos, point at the folder that contains them."
  local dir n
  prompt_value dir "Folder that contains your repos" "$(_guess_ws)"
  dir="${dir/#\~/$HOME}"; dir="${dir%/}"
  [ -z "$dir" ] && { err "a folder path is required"; return 1; }
  mkdir -p "$dir"
  n="$(_count_git "$dir")"

  if [ "$n" -ge 1 ]; then
    printf '%s\n' "$dir" > "$HOME/.mi_workspace"
    ok "Found $n repo(s) in $dir — recorded. Claude will look here."
    return 0
  fi

  warn "No git repos found directly inside $dir."
  if confirm "Do you want to CLONE the repos here now? (needs VPN + GitLab access)"; then
    if _repos_clone "$dir"; then
      printf '%s\n' "$dir" > "$HOME/.mi_workspace"
      ok "Recorded $dir."
    fi
  else
    printf '%s\n' "$dir" > "$HOME/.mi_workspace"
    say "Recorded $dir. This turns green once at least one repo is in it."
    dim "If your repos live elsewhere, re-run and point at that folder instead."
  fi
}

# Optional clone path. Uses config/repos.conf (name | branch) if present.
_repos_clone() {  # $1=dir
  local dir="$1" conf host name branch rest url cloned=0
  conf="$(_repos_conf)"
  if [ ! -f "$conf" ]; then
    warn "No repo list yet. Ask your team for it and add it (one per line) to:"
    say  "  $conf"
    say  "  format:  repo-name | branch"
    return 1
  fi
  prompt_value host "GitLab host (just the host, e.g. 10.200.11.32)" "${MI_GITLAB_HOST:-}"
  host="${host#http://}"; host="${host#https://}"; host="${host%/}"
  [ -z "$host" ] && { err "GitLab host required"; return 1; }
  while IFS='|' read -r name branch rest; do
    name="$(trim "$name")"; branch="$(trim "$branch")"
    [ -z "$name" ] && continue
    case "$name" in \#*) continue;; esac
    url="http://$host/mastersindia/$name.git"
    if [ -d "$dir/$name/.git" ]; then ok "$name already present"; cloned=$((cloned+1)); continue; fi
    say "Cloning $name…"
    if git clone "$url" "$dir/$name"; then
      cloned=$((cloned+1))
      [ -n "$branch" ] && ( cd "$dir/$name" && git checkout "$branch" >/dev/null 2>&1 ) && ok "$name → $branch"
    else
      warn "clone failed for $name (VPN up? GitLab access? credentials cached?)"
    fi
  done < "$conf"
  [ "$cloned" -ge 1 ]
}
