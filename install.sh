#!/bin/bash

# AI Codex Installer
# Downloads the latest release and extracts memory/ and templates/ directories

set -e

REPO_OWNER="swszz"
REPO_NAME="ai-codex"
INSTALL_DIR="${INSTALL_DIR:-.}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "AI Codex Installer"
echo "=================="
echo ""

# Check dependencies
command -v curl >/dev/null 2>&1 || { printf "${RED}Error: curl is required but not installed.${NC}\n" >&2; exit 1; }

# Get latest release info
echo "Fetching latest release information..."
RELEASE_INFO=$(curl -sL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" 2>/dev/null)

if [ -z "$RELEASE_INFO" ]; then
    printf "${YELLOW}Warning: Could not fetch release info from API${NC}\n"
    echo "Using latest code from main branch instead..."
    RELEASE_TAG="latest"
    DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/main.tar.gz"
    FILE_TYPE="tar.gz"
else
    # Extract download URL for the ZIP asset
    DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url": *"[^"]*\.zip"' | sed 's/"browser_download_url": *"\([^"]*\)"/\1/')
    RELEASE_TAG=$(echo "$RELEASE_INFO" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\([^"]*\)"/\1/')

    # If ZIP asset found
    if [ -n "$DOWNLOAD_URL" ]; then
        FILE_TYPE="zip"
        command -v unzip >/dev/null 2>&1 || { printf "${RED}Error: unzip is required but not installed.${NC}\n" >&2; exit 1; }
    else
        # Try tarball
        printf "${YELLOW}Warning: No ZIP asset found${NC}\n"
        TARBALL_URL=$(echo "$RELEASE_INFO" | grep -o '"tarball_url": *"[^"]*"' | sed 's/"tarball_url": *"\([^"]*\)"/\1/')
        if [ -n "$TARBALL_URL" ]; then
            DOWNLOAD_URL="$TARBALL_URL"
            FILE_TYPE="tar.gz"
            command -v tar >/dev/null 2>&1 || { printf "${RED}Error: tar is required but not installed.${NC}\n" >&2; exit 1; }
        else
            echo "Using latest code from main branch instead..."
            RELEASE_TAG="latest"
            DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/main.tar.gz"
            FILE_TYPE="tar.gz"
            command -v tar >/dev/null 2>&1 || { printf "${RED}Error: tar is required but not installed.${NC}\n" >&2; exit 1; }
        fi
    fi
fi

printf "${GREEN}Release: ${RELEASE_TAG}${NC}\n"
echo "Download URL: ${DOWNLOAD_URL}"
echo ""

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download release
echo "Downloading release archive..."
if [ "$FILE_TYPE" = "zip" ]; then
    curl -sL -o "${TEMP_DIR}/release.zip" "$DOWNLOAD_URL"
else
    curl -sL -o "${TEMP_DIR}/release.tar.gz" "$DOWNLOAD_URL"
fi

# Extract archive
echo "Extracting archive..."
mkdir -p "${TEMP_DIR}/extracted"
if [ "$FILE_TYPE" = "zip" ]; then
    unzip -q "${TEMP_DIR}/release.zip" -d "${TEMP_DIR}/extracted"
    # ZIP releases extract directly without a root folder
    EXTRACTED_ROOT="${TEMP_DIR}/extracted"
else
    tar -xzf "${TEMP_DIR}/release.tar.gz" -C "${TEMP_DIR}/extracted"
    # Tarball releases have a root folder
    EXTRACTED_ROOT=$(find "${TEMP_DIR}/extracted" -maxdepth 1 -type d -not -path "${TEMP_DIR}/extracted" | head -n 1)
fi

# Copy memory and templates directories
echo ""
echo "Installing files to: ${INSTALL_DIR}"

if [ -d "${EXTRACTED_ROOT}/memory" ]; then
    if [ -d "${INSTALL_DIR}/memory" ]; then
        printf "${YELLOW}Overriding memory/ directory...${NC}\n"
    else
        printf "${YELLOW}Creating memory/ directory...${NC}\n"
    fi
    mkdir -p "${INSTALL_DIR}/memory"
    cp -rf "${EXTRACTED_ROOT}/memory/"* "${INSTALL_DIR}/memory/" 2>/dev/null || true
    printf "${GREEN}✓ memory/ installed${NC}\n"
else
    printf "${YELLOW}Warning: memory/ directory not found in release${NC}\n"
fi

if [ -d "${EXTRACTED_ROOT}/templates" ]; then
    if [ -d "${INSTALL_DIR}/templates" ]; then
        printf "${YELLOW}Overriding templates/ directory...${NC}\n"
    else
        printf "${YELLOW}Creating templates/ directory...${NC}\n"
    fi
    mkdir -p "${INSTALL_DIR}/templates"
    cp -rf "${EXTRACTED_ROOT}/templates/"* "${INSTALL_DIR}/templates/" 2>/dev/null || true
    printf "${GREEN}✓ templates/ installed${NC}\n"
else
    printf "${YELLOW}Warning: templates/ directory not found in release${NC}\n"
fi

echo ""
printf "${GREEN}Installation complete!${NC}\n"
echo ""
echo "Installed directories:"
echo "  - ${INSTALL_DIR}/memory/"
echo "  - ${INSTALL_DIR}/templates/"
echo ""
echo "You can override the installation directory by setting INSTALL_DIR:"
echo "  INSTALL_DIR=/path/to/dir ./install.sh"
