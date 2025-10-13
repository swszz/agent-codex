#!/bin/bash

# Check if claude-code is installed
if ! command -v claude-code &> /dev/null
then
    echo "Claude Code not found. Installing..."
    npm install -g @anthropic-ai/claude-code
else
    echo "Claude Code is already installed."
fi

# Create the .claude directory structure
echo "Creating ~/.claude directory structure..."

# Create main directories
mkdir -p ~/.claude/steering
mkdir -p ~/.claude/specs
mkdir -p ~/.claude/commands
mkdir -p ~/.claude/templates
mkdir -p ~/.claude/scripts

# Create steering files (empty markdown files)
touch ~/.claude/steering/product.md
touch ~/.claude/steering/tech.md
touch ~/.claude/steering/structure.md

# Create spec-config.json
touch ~/.claude/spec-config.json

echo "Installation complete!"
