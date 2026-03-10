#!/usr/bin/env bash
# setup.sh -- install packages, fonts, Starship; called by Makefile
# Usage: ./setup.sh <darwin|linux> <command>
# Commands: packages, fonts, starship

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
      brew install git curl wget jq ripgrep fd bat eza fzf htop
      ;;
    linux)
      sudo apt-get update
      sudo apt-get install -y git curl wget jq ripgrep fd-find bat eza fzf htop unzip
      ;;
    *) echo "Unknown OS: $OS"; exit 1 ;;
  esac
}

run_fonts() {
  case "$OS" in
    darwin)
      if command -v brew >/dev/null 2>&1; then
        brew tap homebrew/cask-fonts
        brew install --cask font-jetbrains-mono-nerd-font
      else
        echo "Homebrew required for font install on macOS"
        exit 1
      fi
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

case "$CMD" in
  packages) run_packages ;;
  fonts)    run_fonts ;;
  starship) run_starship ;;
  *) echo "Unknown command: $CMD"; exit 1 ;;
esac
