#!/bin/bash

# oh-my-claude installer
# Copies .claude directory to target directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.claude"

# Function to print colored messages
print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

print_info() {
    echo "$1"
}

# Check if target directory is provided
if [ -z "$1" ]; then
    print_error "Target directory not specified"
    echo "Usage: $0 /path/to/target/directory"
    exit 1
fi

TARGET_DIR="$1"

# Validate source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory '$SOURCE_DIR' not found"
    exit 1
fi

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory '$TARGET_DIR' does not exist"
    exit 1
fi

# Resolve absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
TARGET_CLAUDE_DIR="$TARGET_DIR/.claude"

# Check if .claude already exists in target
if [ -d "$TARGET_CLAUDE_DIR" ]; then
    print_warning ".claude directory already exists in $TARGET_DIR"
    read -p "Do you want to override it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    print_info "Removing existing .claude directory..."
    rm -rf "$TARGET_CLAUDE_DIR"
fi

# Copy .claude directory
print_info "Installing oh-my-claude to $TARGET_DIR..."
cp -r "$SOURCE_DIR" "$TARGET_CLAUDE_DIR"

# Verify installation
if [ -d "$TARGET_CLAUDE_DIR" ]; then
    print_success "Successfully installed oh-my-claude!"
    print_info ""
    print_info "Installation details:"
    print_info "  Source: $SOURCE_DIR"
    print_info "  Target: $TARGET_CLAUDE_DIR"
    print_info ""
    print_info "Available features:"

    # Dynamically list all subdirectories and their contents in .claude
    for item in "$TARGET_CLAUDE_DIR"/*; do
        if [ -e "$item" ]; then
            item_name=$(basename "$item")

            # Capitalize first letter for display
            display_name=$(echo "$item_name" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

            if [ -d "$item" ]; then
                # It's a directory
                print_info "  $display_name:"

                # Count items to check if directory has content
                item_count=$(find "$item" -mindepth 1 -maxdepth 1 | wc -l)

                if [ "$item_count" -eq 0 ]; then
                    print_info "    (empty)"
                else
                    # For commands directory, list .md files recursively and subdirectories
                    if [ "$item_name" = "commands" ]; then
                        # List all .md files recursively under commands
                        find "$item" -name "*.md" -type f 2>/dev/null | while read -r file; do
                            # Get relative path from commands directory
                            rel_path="${file#$item/}"
                            # Remove .md extension
                            cmd_name="${rel_path%.md}"
                            print_info "    - /$cmd_name"
                        done
                    else
                        # List .md files (excluding AGENT.md and SKILL.md)
                        find "$item" -maxdepth 1 -name "*.md" -type f 2>/dev/null | while read -r file; do
                            file_name=$(basename "$file" .md)
                            # Skip meta files
                            if [ "$file_name" != "AGENT" ] && [ "$file_name" != "SKILL" ]; then
                                print_info "    - $file_name"
                            fi
                        done

                        # List subdirectories (for skills, agents, etc.)
                        find "$item" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r subdir; do
                            subdir_name=$(basename "$subdir")
                            print_info "    - $subdir_name"
                        done
                    fi
                fi
            elif [ -f "$item" ]; then
                # It's a file (skip hidden files or specific files)
                if [[ ! "$item_name" =~ ^\. ]]; then
                    print_info "  Files:"
                    print_info "    - $item_name"
                fi
            fi
        fi
    done

    print_info ""
    print_success "Installation complete!"
else
    print_error "Installation failed"
    exit 1
fi
