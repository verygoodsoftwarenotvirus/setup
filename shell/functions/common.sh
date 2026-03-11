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
