# Cross-platform shell functions

# --- Git helpers ---

# Sync: update root branch then feature branch (checkout root, pull, checkout feature, pull).
# Usage: gsync [feature_branch] [root_branch]
# Defaults: feature_branch=current branch, root_branch=main (so gsync with no args syncs main then returns to current)
gsync() {
  local feature_branch="${1:-$(git branch --show-current)}"
  local root_branch="${2:-main}"
  git checkout "$root_branch" && git pull &&
  git checkout "$feature_branch" && git pull
}

# Clear all stashes.
clear_git_stashes() {
  git stash clear
}

# Reset to HEAD~1. Usage: greset [soft|mixed|hard] [n]
# Default: mixed, 1. Examples: greset soft 2  =>  git reset --soft HEAD~2
greset() {
  local mode="${1:-mixed}"
  local n="${2:-1}"
  case "$mode" in
    soft|mixed|hard) git reset --"$mode" "HEAD~${n}" ;;
    *) echo "usage: greset [soft|mixed|hard] [n]" >&2; return 1 ;;
  esac
}

# Flatten/squash the last n commits into one (soft reset then recommit).
# Usage: gflatten [n]   (default n=2 for "last 2 commits become 1")
gflatten() {
  local n="${1:-2}"
  [ "$n" -lt 2 ] && echo "n must be >= 2" >&2 && return 1
  git reset --soft "HEAD~$n" && git commit -C ORIG_HEAD
}
