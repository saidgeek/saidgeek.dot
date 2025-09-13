# saidgeek dotfiles 2025

> Personal development environment configuration files

## Overview

This repository contains my personal dotfiles and configuration files for a modern development environment. All configurations use the **catppuccin-mocha** theme and **JetBrainsMono Nerd Font** for consistency.

## Included Configurations

- **Neovim** - LazyVim-based configuration with custom plugins and settings
- **Fish Shell** - Interactive shell with aliases and custom functions
- **Wezterm** - Terminal emulator with transparency and custom styling
- **Zellij** - Terminal multiplexer with vim-like keybindings
- **Ghostty** - Additional terminal configuration
- **Zed** - Code editor settings and keymaps
- **Starship** - Cross-shell prompt configuration

## Installation

1. Clone this repository to your preferred location:

   ```bash
   git clone https://github.com/saidgeek/saidgeek.dot.git ~/.dotfiles
   ```

2. Create symbolic links to the appropriate locations:

   ```bash
   # Neovim
   ln -sf ~/.dotfiles/nvim ~/.config/nvim

   # Fish Shell
   ln -sf ~/.dotfiles/fish ~/.config/fish

   # Wezterm
   ln -sf ~/.dotfiles/wezterm ~/.config/wezterm

   # Zellij
   ln -sf ~/.dotfiles/zellij ~/.config/zellij

   # Other configs
   ln -sf ~/.dotfiles/starship.toml ~/.config/starship.toml
   ```

## Features

- **Consistent theming** across all tools with catppuccin-mocha
- **Optimized keybindings** for efficient workflow
- **Modern tooling** with lazy loading and performance optimizations
- **Extensible configuration** following best practices
