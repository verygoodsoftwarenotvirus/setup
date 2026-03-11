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

# --- Tmux layout helpers ---

# Start a tmux session with layout: left 50%, right side split into top 25% + bottom 25%.
# Usage: tmux-quarter-right [session_name] [left_cmd] [top_right_cmd] [bottom_right_cmd]
# Commands are optional; if omitted, that pane gets a shell.
# Example: tmux-quarter-right dev 'vim' 'htop' 'watch -n 1 nvidia-smi'
# Example: tmux-quarter-right work 'cd ~/proj && nvim' 'gh run watch' 'docker logs -f api'
tmux-quarter-right() {
  local session="${1:-quarter}"
  local left_cmd="${2:-}"
  local top_right_cmd="${3:-}"
  local bottom_right_cmd="${4:-}"

  if tmux has-session -t "$session" 2>/dev/null; then
    echo "Session '$session' already exists. Attach with: tmux attach -t $session" >&2
    return 1
  fi

  tmux new-session -d -s "$session"
  tmux split-window -h -p 50 -t "$session"
  tmux split-window -v -p 50 -t "$session":0.1

  [ -n "$left_cmd" ]       && tmux send-keys -t "$session":0.0 "$left_cmd" C-m
  [ -n "$top_right_cmd" ]  && tmux send-keys -t "$session":0.1 "$top_right_cmd" C-m
  [ -n "$bottom_right_cmd" ] && tmux send-keys -t "$session":0.2 "$bottom_right_cmd" C-m

  tmux select-pane -t "$session":0.0
  tmux attach -t "$session"
}
