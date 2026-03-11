#!/usr/bin/env bash
# setup.sh -- install packages, fonts, Starship; called by Makefile
# Usage: ./setup.sh <darwin|linux> <command>
# Commands: packages, fonts, starship, journal

set -e

OS="${1:?Usage: $0 <darwin|linux> <command>}"
CMD="${2:?Usage: $0 <darwin|linux> <command>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

run_packages() {
  case "$OS" in
    darwin)
      if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew not found. Install from https://brew.sh"
        exit 1
      fi
      brew bundle install --file="$SETUP_DIR/Brewfile" --quiet
      ;;
    linux)
      sudo apt-get update
      sudo apt-get install -y git curl wget jq ripgrep fd-find bat eza fzf htop unzip ncdu nnn btop kubectl
      ;;
    *) echo "Unknown OS: $OS"; exit 1 ;;
  esac
}

run_fonts() {
  case "$OS" in
    darwin)
      # Font is in Brewfile; install-packages already ran brew bundle
      if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew required for font install on macOS"
        exit 1
      fi
      brew bundle install --file="$SETUP_DIR/Brewfile" --quiet
      ;;
    linux)
      FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/JetBrainsMono"
      mkdir -p "$FONT_DIR"
      FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
      if [ -z "$(find "$FONT_DIR" -name "*.ttf" 2>/dev/null | head -1)" ]; then
        echo "Downloading JetBrainsMono Nerd Font..."
        TMP_ZIP="$(mktemp)"
        curl -sL "$FONT_URL" -o "$TMP_ZIP"
        unzip -o "$TMP_ZIP" -d "$FONT_DIR"
        rm -f "$TMP_ZIP"
        fc-cache -fv 2>/dev/null || true
      else
        echo "JetBrainsMono Nerd Font already installed"
      fi
      ;;
    *) echo "Unknown OS: $OS"; exit 1 ;;
  esac
}

run_starship() {
  if command -v starship >/dev/null 2>&1; then
    echo "Starship already installed"
    return
  fi
  echo "Installing Starship..."
  sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y
}

run_journal() {
  case "$OS" in
    darwin)
      if ! command -v go >/dev/null 2>&1; then
        echo "Go is required. Run 'make install-packages' first."
        exit 1
      fi
      ;;
    linux)
      if ! command -v go >/dev/null 2>&1; then
        echo "Installing Go..."
        GO_VERSION="1.23.4"
        GO_ARCH="linux-amd64"
        [ "$(uname -m)" = "aarch64" ] && GO_ARCH="linux-arm64"
        GO_TAR="go${GO_VERSION}.${GO_ARCH}.tar.gz"
        curl -sL "https://go.dev/dl/${GO_TAR}" -o /tmp/"${GO_TAR}"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/"${GO_TAR}"
        rm -f /tmp/"${GO_TAR}"
        export PATH="/usr/local/go/bin:$PATH"
      fi
      ;;
    *) echo "Unknown OS: $OS"; exit 1 ;;
  esac
  echo "Installing journal..."
  # Unset GOROOT so Go uses the installation matching the binary (avoids 1.26.0 vs 1.26.1 mismatch)
  # Clear caches that may contain artifacts from a different Go version
  (unset GOROOT; go clean -cache -modcache 2>/dev/null || true)
  (unset GOROOT; go install github.com/verygoodsoftwarenotvirus/journal@latest)
}

case "$CMD" in
  packages) run_packages ;;
  fonts)    run_fonts ;;
  starship) run_starship ;;
  journal)  run_journal ;;
  *) echo "Unknown command: $CMD"; exit 1 ;;
esac
