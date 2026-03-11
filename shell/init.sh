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

# Source env, aliases, functions. Prefer combined files from make (common+platform in one file).
_source_if_exists() {
  [ -f "$1" ] && [ -s "$1" ] && . "$1"
}

# Private env vars (secrets, tokens). Template: config/env_vars.sh.template → ~/.env_vars.sh via make setup
_source_if_exists "$HOME/.env_vars.sh"

SETUP_GENERATED="${HOME}/.config/setup"
if [ -f "$SETUP_GENERATED/env.sh" ]; then
  . "$SETUP_GENERATED/env.sh"
else
  _source_if_exists "$SETUP_DIR/shell/env/common.sh"
  _source_if_exists "$SETUP_DIR/shell/env/$SETUP_OS.sh"
fi
if [ -f "$SETUP_GENERATED/aliases.sh" ]; then
  . "$SETUP_GENERATED/aliases.sh"
else
  _source_if_exists "$SETUP_DIR/shell/aliases/common.sh"
  _source_if_exists "$SETUP_DIR/shell/aliases/$SETUP_OS.sh"
fi
if [ -f "$SETUP_GENERATED/functions.sh" ]; then
  . "$SETUP_GENERATED/functions.sh"
else
  _source_if_exists "$SETUP_DIR/shell/functions/common.sh"
  _source_if_exists "$SETUP_DIR/shell/functions/$SETUP_OS.sh"
fi
