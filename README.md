# setup

Setup files for my computer. Run `make setup` to configure the entire local development environment.

## Quick Start

```bash
cd /path/to/setup
make setup
```

Then restart your shell or run `exec $SHELL`.

## What Gets Installed

- **Starship** — cross-shell prompt
- **JetBrainsMono Nerd Font** — for icons and glyphs
- **CLI tools** — git, curl, wget, jq, ripgrep, fd, bat, eza, fzf, htop, go
- **journal** — `go install github.com/verygoodsoftwarenotvirus/journal@latest`

## What Gets Linked

- `~/.config/starship.toml` → Starship prompt config
- `~/.config/ghostty/config` → Ghostty terminal config
- `~/.zshrc` → Zsh config (sources shell init)

## Platform Support

- **macOS** — Homebrew for packages and fonts
- **Linux** — apt (Debian/Ubuntu) for packages; fonts from GitHub releases

## Shell Functions, Aliases, and Env

Edit these files to add your own:

| Path | Purpose |
|------|---------|
| `shell/functions/common.sh` | Cross-platform functions |
| `shell/functions/darwin.sh` | macOS-only functions |
| `shell/functions/linux.sh` | Linux-only functions |
| `shell/aliases/common.sh` | Cross-platform aliases |
| `shell/aliases/darwin.sh` | macOS-only aliases |
| `shell/aliases/linux.sh` | Linux-only aliases |
| `shell/env/common.sh` | Cross-platform env vars |
| `shell/env/darwin.sh` | macOS-only env vars |
| `shell/env/linux.sh` | Linux-only env vars |

`shell/init.sh` sources these in order (common first, then platform-specific). It works with zsh and bash.

## Switching Shells

To use this setup with bash instead of zsh, add `source /path/to/setup/shell/init.sh` to your `~/.bashrc`, and optionally install Starship and add `eval "$(starship init bash)"`.

## Make Targets

| Target | Description |
|--------|-------------|
| `make setup` | Run everything |
| `make install-packages` | Install CLI tools |
| `make install-starship` | Install Starship |
| `make install-fonts` | Install Nerd Font |
| `make install-journal` | Install journal app |
| `make link-configs` | Symlink config files |
| `make link-shell` | Symlink ~/.zshrc |
