#!/bin/bash
# saidgeek dotfiles backup restoration script

set -e

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

print_header() {
    echo -e "${MAGENTA}[RESTORE]${NC} $1"
}

# Function to find the latest backup directory
find_latest_backup() {
    local latest_backup=""
    
    for backup_dir in "$HOME"/.dotfiles-backup-*; do
        if [[ -d "$backup_dir" ]]; then
            if [[ -z "$latest_backup" ]] || [[ "$backup_dir" > "$latest_backup" ]]; then
                latest_backup="$backup_dir"
            fi
        fi
    done
    
    echo "$latest_backup"
}

# Function to list all available backups
list_backups() {
    print_header "Available backups:"
    local count=0
    
    for backup_dir in "$HOME"/.dotfiles-backup-*; do
        if [[ -d "$backup_dir" ]]; then
            count=$((count + 1))
            local basename=$(basename "$backup_dir")
            local date_part=${basename#.dotfiles-backup-}
            local formatted_date=${date_part:0:8}
            local formatted_time=${date_part:9:6}
            
            echo "  ${BLUE}$count.${NC} $basename"
            echo "     ${YELLOW}Date:${NC} ${formatted_date:0:4}-${formatted_date:4:2}-${formatted_date:6:2}"
            echo "     ${YELLOW}Time:${NC} ${formatted_time:0:2}:${formatted_time:2:2}:${formatted_time:4:2}"
            
            # Show contents
            echo "     ${YELLOW}Contents:${NC}"
            if ls -1 "$backup_dir" >/dev/null 2>&1; then
                ls -1 "$backup_dir" | sed 's/^/       /'
            else
                echo "       (empty or unreadable)"
            fi
            echo ""
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        print_warning "No backup directories found"
        print_status "Backup directories should be named: ~/.dotfiles-backup-YYYYMMDD-HHMMSS"
        return 1
    fi
    
    return 0
}

# Function to restore a specific configuration
restore_config() {
    local backup_dir="$1"
    local config_name="$2"
    local target_path="$3"
    
    local backup_path="$backup_dir/$config_name"
    
    if [[ -e "$backup_path" ]]; then
        # Remove current symlink/config
        if [[ -L "$target_path" ]]; then
            print_status "Removing current symlink: $target_path"
            rm "$target_path"
        elif [[ -e "$target_path" ]]; then
            print_warning "Current config exists, moving to temporary location"
            mv "$target_path" "${target_path}.tmp-$(date +%s)"
        fi
        
        # Restore from backup
        print_status "Restoring $config_name to $target_path"
        mv "$backup_path" "$target_path"
        print_success "Restored: $config_name"
        return 0
    else
        print_warning "Backup not found for: $config_name"
        return 1
    fi
}

# Function to restore all configurations from a backup
restore_from_backup() {
    local backup_dir="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        print_error "Backup directory not found: $backup_dir"
        return 1
    fi
    
    print_header "Restoring configurations from: $(basename "$backup_dir")"
    echo ""
    
    local restored_count=0
    
    # Restore each configuration
    restore_config "$backup_dir" "nvim" "$HOME/.config/nvim" && ((restored_count++))
    restore_config "$backup_dir" "fish" "$HOME/.config/fish" && ((restored_count++))
    restore_config "$backup_dir" "zellij" "$HOME/.config/zellij" && ((restored_count++))
    restore_config "$backup_dir" "starship.toml" "$HOME/.config/starship.toml" && ((restored_count++))
    restore_config "$backup_dir" "ghostty" "$HOME/.config/ghostty" && ((restored_count++))
    
    echo ""
    print_success "Restored $restored_count configuration(s)"
    
    # Remove empty backup directory
    if [[ -z "$(ls -A "$backup_dir" 2>/dev/null)" ]]; then
        print_status "Removing empty backup directory"
        rmdir "$backup_dir"
        print_success "Cleaned up: $(basename "$backup_dir")"
    fi
    
    echo ""
    print_success "🎉 Restoration completed!"
    print_status "You may need to restart your terminal or run 'exec fish' to see changes"
}

# Function to restore from the latest backup
restore_latest() {
    local latest_backup=$(find_latest_backup)
    
    if [[ -z "$latest_backup" ]]; then
        print_error "No backup directories found"
        print_status "Backup directories should be named: ~/.dotfiles-backup-YYYYMMDD-HHMMSS"
        exit 1
    fi
    
    local basename=$(basename "$latest_backup")
    local date_part=${basename#.dotfiles-backup-}
    local formatted_date=${date_part:0:8}
    local formatted_time=${date_part:9:6}
    
    print_status "Latest backup found: $basename"
    print_status "Date: ${formatted_date:0:4}-${formatted_date:4:2}-${formatted_date:6:2} ${formatted_time:0:2}:${formatted_time:2:2}:${formatted_time:4:2}"
    echo ""
    
    # Show what will be restored
    print_status "Contents to be restored:"
    ls -1 "$latest_backup" | sed 's/^/  /'
    echo ""
    
    # Confirmation prompt
    print_warning "This will replace your current dotfile configurations!"
    read -p "Do you want to restore from this backup? [y/N]: " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restore_from_backup "$latest_backup"
    else
        print_status "Restoration cancelled"
    fi
}

# Function for interactive backup selection
restore_interactive() {
    if ! list_backups; then
        exit 1
    fi
    
    echo -n "Select backup number to restore (or 'q' to quit): "
    read -r selection
    
    if [[ "$selection" == "q" ]] || [[ "$selection" == "Q" ]]; then
        print_status "Restoration cancelled"
        exit 0
    fi
    
    # Validate selection is a number
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        print_error "Invalid selection. Please enter a number or 'q' to quit."
        exit 1
    fi
    
    # Get the backup directory for the selected number
    local count=0
    local selected_backup=""
    
    for backup_dir in "$HOME"/.dotfiles-backup-*; do
        if [[ -d "$backup_dir" ]]; then
            count=$((count + 1))
            if [[ $count -eq $selection ]]; then
                selected_backup="$backup_dir"
                break
            fi
        fi
    done
    
    if [[ -z "$selected_backup" ]]; then
        print_error "Invalid backup number: $selection"
        exit 1
    fi
    
    # Show what will be restored
    echo ""
    print_status "Selected backup: $(basename "$selected_backup")"
    print_status "Contents to be restored:"
    ls -1 "$selected_backup" | sed 's/^/  /'
    echo ""
    
    # Confirmation prompt
    print_warning "This will replace your current dotfile configurations!"
    read -p "Do you want to restore from this backup? [y/N]: " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restore_from_backup "$selected_backup"
    else
        print_status "Restoration cancelled"
    fi
}

# Function to show help
show_help() {
    echo "🔄 Dotfiles Backup Restoration Tool"
    echo ""
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  --latest, -a      Restore from latest backup (with confirmation)"
    echo "  --interactive, -i Choose backup interactively"
    echo "  --list, -l        List available backups"
    echo "  --help, -h        Show this help"
    echo ""
    echo "Default: Interactive mode"
    echo ""
    echo "This script restores dotfile configurations from backups created by install.sh"
    echo "Backup directories are located at ~/.dotfiles-backup-YYYYMMDD-HHMMSS"
}

# Main execution logic
main() {
    # Parse command line arguments
    case "${1:-}" in
        --list|-l)
            list_backups
            ;;
        --latest|-a)
            restore_latest
            ;;
        --interactive|-i)
            restore_interactive
            ;;
        --help|-h)
            show_help
            ;;
        *)
            if [[ -n "${1:-}" ]]; then
                print_error "Unknown option: $1"
                echo ""
                show_help
                exit 1
            fi
            # Default to interactive mode
            restore_interactive
            ;;
    esac
}

# Run main function with all arguments
main "$@"