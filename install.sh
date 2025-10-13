#!/bin/bash

# Check if claude-code is installed
if ! command -v claude-code &> /dev/null
then
    echo "Claude Code not found. Installing..."
    npm install -g @anthropic-ai/claude-code
else
    echo "Claude Code is already installed."
fi

# Create the commands directory
echo "Creating ~/.claude/commands directory..."
mkdir -p ~/.claude/commands

echo "Installation complete!"
