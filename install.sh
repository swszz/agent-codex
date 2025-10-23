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

    # List commands if they exist
    if [ -d "$TARGET_CLAUDE_DIR/commands" ]; then
        print_info "  Commands:"
        find "$TARGET_CLAUDE_DIR/commands" -name "*.md" -type f | while read -r cmd; do
            cmd_name=$(basename "$cmd" .md)
            print_info "    - /$cmd_name"
        done
    fi

    # List skills if they exist
    if [ -d "$TARGET_CLAUDE_DIR/skills" ]; then
        print_info "  Skills:"
        find "$TARGET_CLAUDE_DIR/skills" -maxdepth 1 -type d ! -path "$TARGET_CLAUDE_DIR/skills" | while read -r skill; do
            skill_name=$(basename "$skill")
            print_info "    - $skill_name"
        done
    fi

    print_info ""
    print_success "Installation complete!"
else
    print_error "Installation failed"
    exit 1
fi
