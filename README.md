# ai-codex
AI-driven framework for Spec-Driven Development — replaces GitHub's Spec Kit templates to enforce coding principles.

## Installation

To install or update the AI Codex templates and memory files in your project:

```bash
curl -sL https://raw.githubusercontent.com/swszz/ai-codex/main/install.sh | bash
```

Or download and run manually:

```bash
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
- Download the latest release from GitHub
- Extract only the `memory/` and `templates/` directories
- Override files in the installation directory (current directory by default)
