# Agent Guidelines for saidgeek.dot

## Build/Test Commands
- No build process required - this is a dotfiles repository
- Test config files by symlinking to actual locations (see README.md)
- Validate Lua syntax: `lua -e "dofile('nvim/init.lua')"`
- Check stylua formatting: `stylua --check nvim/`
- Install dotfiles: `./install.sh` (includes error handling and logging)
- Restore from backup: `./restore.sh --latest` or `./restore.sh --interactive`
- Check installation log: `cat ~/.dotfiles-install.log`
- Verify syntax: `bash -n install.sh` or `bash -n restore.sh`

## Code Style Guidelines

### Lua (Neovim configs)
- 2 spaces indentation, 120 character line limit (see stylua.toml)
- Use double quotes for strings
- Follow LazyVim plugin structure patterns
- Organize configs in logical modules under lua/

### Fish Shell
- Use aliases extensively for common commands
- Maintain interactive session checks with `status is-interactive`
- Group related aliases together with comments

### General Config Files
- Use consistent indentation (tabs for KDL, spaces for Lua/TOML)
- Follow existing naming conventions (snake_case for config keys)
- Maintain catppuccin-mocha theme consistency across all tools
- Use JetBrainsMono Nerd Font consistently

### File Organization
- Keep tool-specific configs in separate directories
- Use descriptive filenames that match their purpose
- Maintain .gitignore files where appropriate