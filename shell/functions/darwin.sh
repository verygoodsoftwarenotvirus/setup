# macOS-specific shell functions

# --- Daemon (launchd) helpers ---
# Managed user agents (labels). Add new ones here when you install more.
_setup_daemon_labels=(
  com.mcpjungle.server
)

# Print status of one launchd user agent. Usage: daemon-status [label]
# With no args, prints status of all managed daemons.
daemon-status() {
  local labels
  if [ $# -gt 0 ]; then
    labels=("$@")
  else
    labels=("${_setup_daemon_labels[@]}")
  fi
  local label pid state
  for label in "${labels[@]}"; do
    state="$(launchctl list "$label" 2>/dev/null)" || true
    if [ -n "$state" ]; then
      pid="$(echo "$state" | awk '{print $1}')"
      if [ "$pid" = "-" ] || [ -z "$pid" ]; then
        echo "  $label: loaded, not running (pid -)"
      else
        echo "  $label: loaded, running (pid $pid)"
      fi
    else
      echo "  $label: not loaded"
    fi
  done
}

# Tail stdout log for a daemon (by label). Usage: daemon-logs [label]
# Knows log paths for managed daemons; defaults to com.mcpjungle.server.
daemon-logs() {
  local label="${1:-com.mcpjungle.server}"
  local log_dir
  case "$label" in
    com.mcpjungle.server) log_dir="${HOME}/.local/state/mcpjungle" ;;
    *) echo "Unknown daemon: $label" >&2; return 1 ;;
  esac
  if [ ! -f "$log_dir/stdout.log" ]; then
    echo "No stdout.log at $log_dir" >&2
    return 1
  fi
  tail -f "$log_dir/stdout.log"
}

# pbcopy_file() {
#   cat "$1" | pbcopy
# }
