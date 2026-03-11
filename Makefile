# Dev environment setup - run `make setup` from repo root
# Top-level: make prompt | apps | aliases | functions | setup (= all four)

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

# Where to write combined shell files (common + platform concatenated)
SETUP_GENERATED := $(HOME)/.config/setup

.PHONY: setup prompt apps aliases functions
.PHONY: install-packages install-starship install-fonts install-browsh install-journal install-env-vars install-mcpjungle-service
.PHONY: link-starship link-shell link-ghostty build-env build-aliases build-functions

setup: prompt apps aliases functions
	@echo "Setup complete. Restart your shell or run: exec \$$SHELL"

# --- Top-level targets (each can be run alone) ---

prompt: install-starship link-starship link-shell

apps: install-packages install-fonts install-browsh install-journal install-env-vars link-ghostty build-env

aliases: link-shell build-aliases

functions: link-shell build-functions

# --- Prompt: Starship binary + config ---

install-starship:
	@echo "Installing Starship..."
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) starship

link-starship:
	@echo "Linking Starship config..."
	@mkdir -p ~/.config
	@if [ ! -L ~/.config/starship.toml ] || [ "$$(readlink ~/.config/starship.toml)" != "$(SETUP_DIR)/config/starship.toml" ]; then \
		rm -f ~/.config/starship.toml; \
		ln -sf "$(SETUP_DIR)/config/starship.toml" ~/.config/starship.toml; \
		echo "  Linked ~/.config/starship.toml"; \
	fi

# --- Apps: packages, fonts, tools, env template, terminal config ---

install-packages:
	@echo "Installing packages..."
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) packages

install-fonts:
	@echo "Installing Nerd Font..."
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) fonts

install-browsh:
	@echo "Installing Browsh..."
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) browsh

install-journal:
	@$(SETUP_DIR)/scripts/setup.sh $(PLATFORM) journal

install-env-vars:
	@if [ ! -f "$$HOME/.env_vars.sh" ]; then \
		cp "$(SETUP_DIR)/config/env_vars.sh.template" "$$HOME/.env_vars.sh"; \
		echo "  Created $$HOME/.env_vars.sh (fill in secrets; not committed)"; \
	else \
		echo "  $$HOME/.env_vars.sh already exists, skipping"; \
	fi

install-mcpjungle-service:
	@$(SETUP_DIR)/scripts/install-mcpjungle-service.sh

link-ghostty:
	@echo "Linking Ghostty config..."
	@mkdir -p ~/.config/ghostty
	@if [ ! -L ~/.config/ghostty/config ] || [ "$$(readlink ~/.config/ghostty/config)" != "$(SETUP_DIR)/config/ghostty/config" ]; then \
		rm -f ~/.config/ghostty/config; \
		ln -sf "$(SETUP_DIR)/config/ghostty/config" ~/.config/ghostty/config; \
		echo "  Linked ~/.config/ghostty/config"; \
	fi

# --- Shell: .zshrc (sources init.sh → env, aliases, functions) ---

link-shell:
	@echo "Linking shell config..."
	@if [ ! -L ~/.zshrc ] || [ "$$(readlink ~/.zshrc)" != "$(SETUP_DIR)/config/zshrc" ]; then \
		rm -f ~/.zshrc; \
		ln -sf "$(SETUP_DIR)/config/zshrc" ~/.zshrc; \
		echo "  Linked ~/.zshrc"; \
	fi

# Combined shell files: common.sh + platform.sh → one file (sourced by init.sh)
build-env:
	@mkdir -p $(SETUP_GENERATED)
	@echo "Building env.sh (common + $(PLATFORM))..."
	@cat "$(SETUP_DIR)/shell/env/common.sh" > "$(SETUP_GENERATED)/env.sh"
	@[ -f "$(SETUP_DIR)/shell/env/$(PLATFORM).sh" ] && cat "$(SETUP_DIR)/shell/env/$(PLATFORM).sh" >> "$(SETUP_GENERATED)/env.sh" || true
	@echo "  -> $(SETUP_GENERATED)/env.sh"

build-aliases:
	@mkdir -p $(SETUP_GENERATED)
	@echo "Building aliases.sh (common + $(PLATFORM))..."
	@cat "$(SETUP_DIR)/shell/aliases/common.sh" > "$(SETUP_GENERATED)/aliases.sh"
	@[ -f "$(SETUP_DIR)/shell/aliases/$(PLATFORM).sh" ] && cat "$(SETUP_DIR)/shell/aliases/$(PLATFORM).sh" >> "$(SETUP_GENERATED)/aliases.sh" || true
	@echo "  -> $(SETUP_GENERATED)/aliases.sh"

build-functions:
	@mkdir -p $(SETUP_GENERATED)
	@echo "Building functions.sh (common + $(PLATFORM))..."
	@cat "$(SETUP_DIR)/shell/functions/common.sh" > "$(SETUP_GENERATED)/functions.sh"
	@[ -f "$(SETUP_DIR)/shell/functions/$(PLATFORM).sh" ] && cat "$(SETUP_DIR)/shell/functions/$(PLATFORM).sh" >> "$(SETUP_GENERATED)/functions.sh" || true
	@echo "  -> $(SETUP_GENERATED)/functions.sh"
