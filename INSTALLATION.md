# Installation Guide

This guide explains how to install **oh-my-claude** into your project.

## Prerequisites

- Bash shell (Linux, macOS, WSL, or Git Bash on Windows)
- Access to Claude Code CLI

## Quick Installation

1. Clone or download this repository
2. Run the installation script with your target project directory:

```bash
./install.sh /path/to/your/project
```

### Example

```bash
# Install oh-my-claude into a project at ~/projects/my-app
./install.sh ~/projects/my-app
```

## What Gets Installed

The installer copies the `.claude` directory from this repository to your target project:

```
your-project/
└── .claude/
    ├── commands/       # Custom slash commands for spec-driven development
    ├── skills/         # Specialized skills (e.g., Korean Public Data API)
    └── templates/      # Documentation templates
```

## Installation Behavior

- If `.claude` directory already exists in the target, the installer will ask for confirmation before overriding
- The installer validates that both source and target directories exist
- Installation preserves all directory structures and file permissions

## Verification

After installation, you can verify it worked by:

1. Navigate to your project directory:
   ```bash
   cd /path/to/your/project
   ```

2. Check that `.claude` directory exists:
   ```bash
   ls -la .claude
   ```

3. Open Claude Code in your project:
   ```bash
   claude .
   ```

4. Try a slash command:
   ```
   /feature.specify [your feature description]
   ```

## Available Features

Once installed, you'll have access to:

### Custom Commands

- `/feature.specify` - Create feature specification from requirements
- `/feature.clarify` - Clarify underspecified areas in spec
- `/feature.checklist` - Generate custom validation checklists
- `/feature.plan` - Generate technical implementation plan
- `/feature.tasks` - Create actionable task list
- `/feature.implement` - Execute implementation
- `/feature.analyze` - Cross-artifact consistency analysis
- `/feature.constitution` - Manage project constitution

### Skills

- `korean-public-data-api` - Extract API schemas from Korean Public Data Portal

## Updating

To update to the latest version:

1. Pull the latest changes from this repository:
   ```bash
   git pull origin main
   ```

2. Re-run the installer (it will override the existing installation):
   ```bash
   ./install.sh /path/to/your/project
   ```

## Uninstallation

To remove oh-my-claude from your project:

```bash
rm -rf /path/to/your/project/.claude
```

## Troubleshooting

### Permission Denied

If you get a "Permission denied" error:

```bash
chmod +x install.sh
./install.sh /path/to/your/project
```

### Target Directory Does Not Exist

The installer requires the target directory to already exist. Create it first:

```bash
mkdir -p /path/to/your/project
./install.sh /path/to/your/project
```

### Source Directory Not Found

Make sure you're running the installer from the oh-my-claude repository root:

```bash
cd /path/to/oh-my-claude
./install.sh /path/to/your/project
```

## Next Steps

After installation:

1. Read the workflow documentation in `CLAUDE.md`
2. Start with a simple feature: `/feature.specify [description]`
3. Follow the complete workflow for complex features

For more information, see:
- [CLAUDE.md](./CLAUDE.md) - Complete workflow and command reference
- [README.md](./README.md) - Repository overview
- [CHANGELOG.md](./CHANGELOG.md) - Version history and updates
