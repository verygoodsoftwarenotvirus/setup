# Dev environment setup - run `make setup` from repo root

SHELL := /bin/bash
SETUP_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
UNAME_S := $(shell uname -s)

# Normalize OS to darwin or linux
ifeq ($(UNAME_S),Darwin)
  PLATFORM := darwin
else ifeq ($(UNAME_S),Linux)
  PLATFORM := linux
else
  PLATFORM := unknown
endif

.PHONY: setup install-packages install-starship install-fonts install-journal link-configs link-shell

setup: install-packages install-starship install-fonts install-journal link-configs link-shell
	@echo "Setup complete. Restart your shell or run: exec \$$SHELL"

install-packages:
	@echo "Installing packages..."
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) packages

install-starship:
	@echo "Installing Starship..."
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) starship

install-fonts:
	@echo "Installing Nerd Font..."
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) fonts

install-journal:
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) journal

link-configs:
	@echo "Linking config files..."
	@mkdir -p ~/.config ~/.config/ghostty
	@if [ ! -L ~/.config/starship.toml ] || [ "$$(readlink ~/.config/starship.toml)" != "$(SETUP_DIR)/config/starship.toml" ]; then \
		rm -f ~/.config/starship.toml; \
		ln -sf "$(SETUP_DIR)/config/starship.toml" ~/.config/starship.toml; \
		echo "  Linked ~/.config/starship.toml"; \
	fi
	@if [ ! -L ~/.config/ghostty/config ] || [ "$$(readlink ~/.config/ghostty/config)" != "$(SETUP_DIR)/config/ghostty/config" ]; then \
		rm -f ~/.config/ghostty/config; \
		ln -sf "$(SETUP_DIR)/config/ghostty/config" ~/.config/ghostty/config; \
		echo "  Linked ~/.config/ghostty/config"; \
	fi

link-shell:
	@echo "Linking shell config..."
	@if [ ! -L ~/.zshrc ] || [ "$$(readlink ~/.zshrc)" != "$(SETUP_DIR)/config/zshrc" ]; then \
		rm -f ~/.zshrc; \
		ln -sf "$(SETUP_DIR)/config/zshrc" ~/.zshrc; \
		echo "  Linked ~/.zshrc"; \
	fi
