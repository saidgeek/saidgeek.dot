#!/bin/bash
# saidgeek dotfiles installation script

set -e

# Global variables for error handling and logging
LOG_FILE="$HOME/.dotfiles-install.log"
STEP_COUNTER=0
CURRENT_STEP=""
FAILED_STEPS=()
INSTALLED_PACKAGES=()
CREATED_SYMLINKS=()
BACKUP_DIRS=()

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${MAGENTA}[STEP]${NC} $1"
}

# Logging functions
log_step() {
    STEP_COUNTER=$((STEP_COUNTER + 1))
    CURRENT_STEP="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] STEP $STEP_COUNTER: $CURRENT_STEP" | tee -a "$LOG_FILE"
    print_step "Step $STEP_COUNTER: $CURRENT_STEP"
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $CURRENT_STEP" >> "$LOG_FILE"
    print_success "$CURRENT_STEP completed"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $CURRENT_STEP - $1" >> "$LOG_FILE"
    FAILED_STEPS+=("Step $STEP_COUNTER: $CURRENT_STEP")
    print_error "$CURRENT_STEP failed: $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Cleanup function for error handling
cleanup_on_error() {
    local exit_code=$?
    echo ""
    print_error "❌ Installation failed at: $CURRENT_STEP"
    print_error "Exit code: $exit_code"
    
    # Show failed steps
    if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
        echo ""
        print_error "Failed steps:"
        for step in "${FAILED_STEPS[@]}"; do
            echo "  - $step"
        done
    fi
    
    # Show debug information
    echo ""
    print_status "🔍 Debug information:"
    print_status "- Log file: $LOG_FILE"
    print_status "- Current working directory: $(pwd)"
    print_status "- Shell: $SHELL"
    print_status "- OS: $(uname -s)"
    print_status "- Timestamp: $(date)"
    
    # Show partial installation info
    if [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]] || [[ ${#CREATED_SYMLINKS[@]} -gt 0 ]]; then
        echo ""
        print_warning "⚠️  Partial installation detected:"
        if [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]]; then
            print_warning "- ${#INSTALLED_PACKAGES[@]} packages were installed"
        fi
        if [[ ${#CREATED_SYMLINKS[@]} -gt 0 ]]; then
            print_warning "- ${#CREATED_SYMLINKS[@]} symlinks were created"
        fi
        if [[ ${#BACKUP_DIRS[@]} -gt 0 ]]; then
            print_warning "- ${#BACKUP_DIRS[@]} backups were created"
        fi
    fi
    
    # Offer rollback
    echo ""
    print_warning "🔄 Recovery options:"
    print_warning "1. View detailed log: cat $LOG_FILE"
    if [[ ${#BACKUP_DIRS[@]} -gt 0 ]]; then
        print_warning "2. Restore previous config: ./restore.sh --latest"
    fi
    print_warning "3. Try manual installation: see README.md"
    
    exit $exit_code
}

# Set up error trap
trap cleanup_on_error ERR

# Safe execution functions
safe_execute() {
    local command="$1"
    local description="$2"
    
    if [[ -n "$description" ]]; then
        log_step "$description"
    fi
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] EXECUTING: $command" >> "$LOG_FILE"
    
    if eval "$command" >> "$LOG_FILE" 2>&1; then
        if [[ -n "$description" ]]; then
            log_success
        fi
        return 0
    else
        local exit_code=$?
        if [[ -n "$description" ]]; then
            log_error "Command failed: $command"
        fi
        return $exit_code
    fi
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites"
    
    # Check macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script requires macOS"
        return 1
    fi
    
    # Check internet connection
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        log_error "No internet connection detected"
        return 1
    fi
    
    # Check disk space (at least 1GB)
    local available_space=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/G.*//')
    if [[ "${available_space%.*}" -lt 1 ]]; then
        log_error "Insufficient disk space. At least 1GB required"
        return 1
    fi
    
    log_success
    return 0
}

# Function to backup existing configs
backup_config() {
    local config_path="$1"
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    
    if [[ -e "$config_path" ]]; then
        print_warning "Backing up existing config: $config_path"
        if safe_execute "mkdir -p '$backup_dir'" "Creating backup directory"; then
            if safe_execute "mv '$config_path' '$backup_dir/'" "Moving config to backup"; then
                BACKUP_DIRS+=("$backup_dir")
                print_success "Backup created at: $backup_dir"
            else
                return 1
            fi
        else
            return 1
        fi
    fi
}

# Install package safely
install_package_safe() {
    local package_manager="$1"
    local package="$2"
    
    case "$package_manager" in
        "brew")
            if ! brew list "$package" >/dev/null 2>&1; then
                if safe_execute "brew install '$package'" "Installing $package with Homebrew"; then
                    INSTALLED_PACKAGES+=("brew:$package")
                else
                    return 1
                fi
            else
                print_success "$package already installed"
            fi
            ;;
        "cargo")
            local command_name="${package##*:}"
            local package_name="${package%%:*}"
            if ! command_exists "$command_name"; then
                if safe_execute "cargo install '$package_name'" "Installing $package_name with Cargo"; then
                    INSTALLED_PACKAGES+=("cargo:$package_name")
                else
                    return 1
                fi
            else
                print_success "$command_name already installed"
            fi
            ;;
        "cask")
            if ! brew list --cask "$package" >/dev/null 2>&1; then
                if safe_execute "brew install --cask '$package'" "Installing $package with Homebrew Cask"; then
                    INSTALLED_PACKAGES+=("cask:$package")
                else
                    print_warning "Failed to install $package (may not be available)"
                fi
            else
                print_success "$package already installed"
            fi
            ;;
    esac
}

# Create symlink safely
create_symlink_safe() {
    local source="$1"
    local target="$2"
    local config_name="$3"
    
    log_step "Creating symlink for $config_name"
    
    # Backup if exists
    if [[ -e "$target" ]]; then
        backup_config "$target"
    fi
    
    if safe_execute "ln -sf '$source' '$target'" "Linking $config_name"; then
        CREATED_SYMLINKS+=("$target")
        log_success
    else
        return 1
    fi
}

# Rollback function
rollback_installation() {
    print_warning "🔄 Rolling back partial installation..."
    
    # Remove symlinks created
    for symlink in "${CREATED_SYMLINKS[@]}"; do
        if [[ -L "$symlink" ]]; then
            print_status "Removing symlink: $symlink"
            rm "$symlink" || true
        fi
    done
    
    # Ask about removing packages
    if [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]]; then
        echo ""
        read -p "Do you want to remove installed packages? [y/N]: " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for package_info in "${INSTALLED_PACKAGES[@]}"; do
                local manager="${package_info%%:*}"
                local package="${package_info##*:}"
                
                case "$manager" in
                    "brew")
                        print_status "Removing $package via Homebrew"
                        brew uninstall "$package" 2>/dev/null || true
                        ;;
                    "cargo")
                        print_status "Removing $package via Cargo"
                        cargo uninstall "$package" 2>/dev/null || true
                        ;;
                    "cask")
                        print_status "Removing $package via Homebrew Cask"
                        brew uninstall --cask "$package" 2>/dev/null || true
                        ;;
                esac
            done
        fi
    fi
    
    print_success "Rollback completed"
}

# Verification function
verify_installation() {
    log_step "Verifying installation"
    
    local verification_failed=false
    
    # Verify core tools
    local tools=("fish" "nvim" "zellij" "starship" "exa" "zoxide" "rg" "fd" "bat")
    for tool in "${tools[@]}"; do
        if ! command_exists "$tool"; then
            log_error "$tool not found after installation"
            verification_failed=true
        fi
    done
    
    # Verify symlinks
    local configs=("nvim" "fish" "zellij")
    for config in "${configs[@]}"; do
        if [[ ! -L "$HOME/.config/$config" ]]; then
            log_error "Symlink for $config not created"
            verification_failed=true
        fi
    done
    
    # Verify starship config
    if [[ ! -L "$HOME/.config/starship.toml" ]]; then
        log_error "Starship config symlink not created"
        verification_failed=true
    fi
    
    if [[ "$verification_failed" == "true" ]]; then
        log_error "Installation verification failed"
        return 1
    fi
    
    log_success
    return 0
}

# Show installation summary
show_installation_summary() {
    echo ""
    print_success "🎉 Installation Summary"
    echo ""
    
    if [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]]; then
        print_status "📦 Installed packages (${#INSTALLED_PACKAGES[@]}):"
        for package in "${INSTALLED_PACKAGES[@]}"; do
            local manager="${package%%:*}"
            local name="${package##*:}"
            echo "  ✓ $name ($manager)"
        done
    fi
    
    echo ""
    if [[ ${#CREATED_SYMLINKS[@]} -gt 0 ]]; then
        print_status "🔗 Created configurations (${#CREATED_SYMLINKS[@]}):"
        for symlink in "${CREATED_SYMLINKS[@]}"; do
            echo "  ✓ $(basename "$symlink")"
        done
    fi
    
    echo ""
    if [[ ${#BACKUP_DIRS[@]} -gt 0 ]]; then
        print_status "💾 Backup directories created (${#BACKUP_DIRS[@]}):"
        for backup in "${BACKUP_DIRS[@]}"; do
            echo "  📁 $(basename "$backup")"
        done
    fi
    
    echo ""
    print_status "📊 Installation metrics:"
    print_status "- Total steps completed: $STEP_COUNTER"
    print_status "- Log file: $LOG_FILE"
    print_status "- Installation time: $(date)"
}

# Initialize logging
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting dotfiles installation" > "$LOG_FILE"

print_status "🚀 Starting saidgeek dotfiles installation..."
echo ""

# Check prerequisites first
check_prerequisites

# Check if macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Install Homebrew if not present
if ! command_exists brew; then
    log_step "Installing Homebrew"
    if safe_execute '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' "Installing Homebrew"; then
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log_success
    else
        log_error "Homebrew installation failed"
        return 1
    fi
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
safe_execute "brew update" "Updating Homebrew"

# Install core tools via Homebrew
log_step "Installing core development tools via Homebrew"
BREW_PACKAGES=(
    "fish"              # Shell
    "neovim"            # Editor
    "git"               # Version control
    "curl"              # HTTP client
    "wget"              # Download tool
    "tree"              # Directory tree
    "stylua"            # Lua formatter
    "lua"               # Lua runtime
    "node"              # Node.js
    "go"                # Go language
    "rust"              # Rust language
    "lazygit"           # Git TUI
)

for package in "${BREW_PACKAGES[@]}"; do
    install_package_safe "brew" "$package"
done
log_success

# Install Rust tools via Cargo
log_step "Installing Rust-based tools via Cargo"
# Ensure cargo is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

CARGO_PACKAGES=(
    "zellij:zellij"            # Terminal multiplexer
    "starship:starship"        # Prompt
    "exa:exa"                  # ls replacement
    "zoxide:zoxide"            # cd replacement
    "ripgrep:rg"               # grep replacement
    "fd-find:fd"               # find replacement
    "bat:bat"                  # cat replacement
)

for package_info in "${CARGO_PACKAGES[@]}"; do
    install_package_safe "cargo" "$package_info"
done
log_success

# Install Homebrew Cask applications
log_step "Installing GUI applications via Homebrew Cask"
CASK_PACKAGES=(
    "font-jetbrains-mono-nerd-font"    # Nerd Font
    "ghostty"                          # Terminal (if available)
)

for cask in "${CASK_PACKAGES[@]}"; do
    install_package_safe "cask" "$cask"
done
log_success

# Install fnm (Node Version Manager)
if ! command_exists fnm; then
    safe_execute "curl -fsSL https://fnm.vercel.app/install | bash" "Installing fnm (Node Version Manager)"
    export PATH="$HOME/.cargo/bin:$PATH"
else
    print_success "fnm already installed"
fi

# Install Bun
if ! command_exists bun; then
    safe_execute "curl -fsSL https://bun.sh/install | bash" "Installing Bun"
    export PATH="$HOME/.bun/bin:$PATH"
else
    print_success "Bun already installed"
fi

# Clone dotfiles repository if not already present
DOTFILES_DIR="$HOME/.dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
    safe_execute "git clone 'https://github.com/saidgeek/saidgeek.dot.git' '$DOTFILES_DIR'" "Cloning dotfiles repository"
else
    print_success "Dotfiles already cloned"
    safe_execute "cd '$DOTFILES_DIR' && git pull" "Updating dotfiles repository"
fi

# Create symbolic links
log_step "Creating symbolic links for configurations"

# Neovim
create_symlink_safe "$DOTFILES_DIR/nvim" "$HOME/.config/nvim" "Neovim"

# Fish shell
create_symlink_safe "$DOTFILES_DIR/fish" "$HOME/.config/fish" "Fish shell"

# Zellij
create_symlink_safe "$DOTFILES_DIR/zellij" "$HOME/.config/zellij" "Zellij"

# Starship
create_symlink_safe "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml" "Starship"

# Ghostty (if directory exists)
if [[ -d "$DOTFILES_DIR/ghostty" ]]; then
    create_symlink_safe "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty" "Ghostty"
fi

log_success

# Change default shell to Fish
if [[ "$SHELL" != "$(which fish)" ]]; then
    log_step "Changing default shell to Fish"
    # Add fish to allowed shells
    if ! grep -q "$(which fish)" /etc/shells; then
        safe_execute "echo '$(which fish)' | sudo tee -a /etc/shells" "Adding Fish to allowed shells"
    fi
    safe_execute "chsh -s '$(which fish)'" "Setting Fish as default shell"
    log_success
else
    print_success "Fish is already the default shell"
fi

# Install Node.js LTS via fnm
if command_exists fnm; then
    log_step "Installing Node.js LTS via fnm"
    safe_execute "fnm install --lts" "Installing Node.js LTS"
    safe_execute "fnm use lts-latest" "Setting LTS as active"
    safe_execute "fnm alias default lts-latest" "Setting LTS as default"
    log_success
fi

# Final verification
verify_installation

# Show summary
show_installation_summary

echo ""
print_success "🎉 Installation completed successfully!"
print_status ""
print_status "📋 Next steps:"
print_status "1. Restart your terminal or run: exec fish"
print_status "2. Open Neovim to let LazyVim install plugins: nvim"
print_status "3. Install any additional LSPs via Mason: :Mason"
print_status ""
print_status "💡 Your dotfiles are now installed and configured!"
print_status "💾 Backups were created and can be restored with: ./restore.sh --latest"