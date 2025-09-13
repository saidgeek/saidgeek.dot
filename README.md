# saidgeek dotfiles 2025

> Personal development environment configuration files

## Overview

This repository contains my personal dotfiles and configuration files for a modern development environment. All configurations use the **catppuccin-mocha** theme and **JetBrainsMono Nerd Font** for consistency.

## Included Configurations

- **Neovim** - LazyVim-based configuration with custom plugins and settings
- **Fish Shell** - Interactive shell with aliases and custom functions
- **Zellij** - Terminal multiplexer with vim-like keybindings
- **Ghostty** - Additional terminal configuration
- **Starship** - Cross-shell prompt configuration

## Installation

### Automated Installation (Recommended)
The installation script includes comprehensive error handling and logging:

```bash
# Direct installation
curl -fsSL https://raw.githubusercontent.com/saidgeek/saidgeek.dot/main/install.sh | bash

# Or clone first and run locally (recommended for debugging)
git clone https://github.com/saidgeek/saidgeek.dot.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

**Features:**
- ✅ **Error handling**: Stops on first failure with detailed error information
- 📝 **Comprehensive logging**: All operations logged to `~/.dotfiles-install.log`
- 🔄 **Automatic backups**: Original configs backed up before changes
- 🛡️ **Prerequisites check**: Verifies system requirements before starting
- 📊 **Installation summary**: Shows what was installed and configured
- 🔍 **Verification**: Confirms all tools and configs were set up correctly

### Manual Installation
1. Clone this repository to your preferred location:
   ```bash
   git clone https://github.com/saidgeek/saidgeek.dot.git ~/.dotfiles
   ```

2. Install dependencies:
   ```bash
   # Install Rust tools via Cargo
   cargo install zellij starship exa zoxide ripgrep fd-find bat
   
   # Install other tools via Homebrew
   brew install fish neovim git lua stylua node go lazygit
   brew install --cask font-jetbrains-mono-nerd-font
   ```

3. Create symbolic links to the appropriate locations:
   ```bash
   # Neovim
   ln -sf ~/.dotfiles/nvim ~/.config/nvim
   
   # Fish Shell
   ln -sf ~/.dotfiles/fish ~/.config/fish
   
   # Zellij
   ln -sf ~/.dotfiles/zellij ~/.config/zellij
   
   # Other configs
   ln -sf ~/.dotfiles/starship.toml ~/.config/starship.toml
   ```

## Features

- **Consistent theming** across all tools with catppuccin-mocha
- **Optimized keybindings** for efficient workflow
- **Modern tooling** with lazy loading and performance optimizations
- **Rust-based tools** installed via Cargo for better performance
- **Extensible configuration** following best practices

## Error Recovery & Backup

### Automatic Error Handling
If installation fails, the script will:
- 🛑 **Stop immediately** and show exactly where it failed
- 📋 **Display failed steps** and error details
- 📝 **Save debug info** to `~/.dotfiles-install.log` 
- 💡 **Suggest recovery options** including backup restoration

### Backup & Restoration
The installation script automatically backs up your existing configurations. If you need to restore:

**Restore from Latest Backup:**
```bash
./restore.sh --latest
```

**Interactive Backup Selection:**
```bash
./restore.sh --interactive
```

**List Available Backups:**
```bash
./restore.sh --list
```

**View Installation Log:**
```bash
cat ~/.dotfiles-install.log
```

## Testing

Validate configurations before applying:
```bash
# Test Neovim config
lua -e "dofile('nvim/init.lua')"

# Check Lua formatting
stylua --check nvim/

# Verify Rust tools are installed
cargo install --list | grep -E "(zellij|starship|exa|zoxide|ripgrep|fd-find|bat)"
```
