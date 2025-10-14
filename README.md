# ai-codex
AI-driven framework for Spec-Driven Development — replaces GitHub's Spec Kit templates to enforce coding principles.

## Installation

**Important:** Navigate to your project root directory before running the installation script.

### Step 1: Install spec-kit (Required)

Before installing ai-codex, you need to manually download and install spec-kit:

Please refer to [@github/spec-kit/files/src/specify_cli](https://github.com/github/spec-kit/tree/main/files/src/specify_cli) for installation instructions.

### Step 2: Install AI Codex

To install or update the AI Codex templates and memory files in your project:

```bash
cd /path/to/your/project  # Navigate to project root first
curl -sL https://raw.githubusercontent.com/swszz/ai-codex/main/install.sh | bash
```

Or download and run manually:

```bash
cd /path/to/your/project  # Navigate to project root first
curl -O https://raw.githubusercontent.com/swszz/ai-codex/main/install.sh
chmod +x install.sh
./install.sh
```

### Custom Installation Directory

You can specify a custom installation directory using the `INSTALL_DIR` environment variable:

```bash
INSTALL_DIR=/path/to/your/project ./install.sh
```

The script will:
1. Download the latest release from GitHub
2. Extract and install to `.specify/memory/` and `.specify/templates/` directories
3. Override duplicate files while preserving non-duplicate files in the installation directory (current directory by default)
