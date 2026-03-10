# shell/init.sh -- master loader for shell config (shell-agnostic)
# Source this from your .zshrc, .bashrc, etc.

# Resolve SETUP_DIR: directory containing this repo (parent of shell/)
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  _init_script="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]; then
  _init_script="${(%):-%x}"
else
  _init_script="$0"
fi
SETUP_DIR="$(cd "$(dirname "$_init_script")/.." && pwd)"
export SETUP_DIR
unset _init_script

# Detect OS
case "$(uname -s)" in
  Darwin*)  export SETUP_OS=darwin ;;
  Linux*)   export SETUP_OS=linux ;;
  *)        export SETUP_OS=unknown ;;
esac

# Source env, aliases, functions (common first, then platform-specific)
_source_if_exists() {
  [ -f "$1" ] && [ -s "$1" ] && . "$1"
}

_source_if_exists "$SETUP_DIR/shell/env/common.sh"
_source_if_exists "$SETUP_DIR/shell/env/$SETUP_OS.sh"
_source_if_exists "$SETUP_DIR/shell/aliases/common.sh"
_source_if_exists "$SETUP_DIR/shell/aliases/$SETUP_OS.sh"
_source_if_exists "$SETUP_DIR/shell/functions/common.sh"
_source_if_exists "$SETUP_DIR/shell/functions/$SETUP_OS.sh"
