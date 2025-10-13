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
command -v curl >/dev/null 2>&1 || { echo -e "${RED}Error: curl is required but not installed.${NC}" >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo -e "${RED}Error: tar is required but not installed.${NC}" >&2; exit 1; }

# Get latest release info
echo "Fetching latest release information..."
RELEASE_INFO=$(curl -sL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" 2>/dev/null)

if [ -z "$RELEASE_INFO" ]; then
    echo -e "${YELLOW}Warning: Could not fetch release info from API${NC}"
    echo "Using latest code from main branch instead..."
    RELEASE_TAG="latest"
    DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/main.tar.gz"
else
    # Extract download URL for the ZIP asset
    DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url": *"[^"]*\.zip"' | sed 's/"browser_download_url": *"\([^"]*\)"/\1/')
    RELEASE_TAG=$(echo "$RELEASE_INFO" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\([^"]*\)"/\1/')

    # If no asset found, use tarball
    if [ -z "$DOWNLOAD_URL" ]; then
        echo -e "${YELLOW}Warning: No release asset found${NC}"
        TARBALL_URL=$(echo "$RELEASE_INFO" | grep -o '"tarball_url": *"[^"]*"' | sed 's/"tarball_url": *"\([^"]*\)"/\1/')
        if [ -n "$TARBALL_URL" ]; then
            DOWNLOAD_URL="$TARBALL_URL"
        else
            echo "Using latest code from main branch instead..."
            RELEASE_TAG="latest"
            DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/main.tar.gz"
        fi
    fi
fi

echo -e "${GREEN}Release: ${RELEASE_TAG}${NC}"
echo "Download URL: ${DOWNLOAD_URL}"
echo ""

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download release
echo "Downloading release archive..."
curl -sL -o "${TEMP_DIR}/release.tar.gz" "$DOWNLOAD_URL"

# Extract archive
echo "Extracting archive..."
mkdir -p "${TEMP_DIR}/extracted"
tar -xzf "${TEMP_DIR}/release.tar.gz" -C "${TEMP_DIR}/extracted"

# Find the root directory in the extracted archive (GitHub adds a root folder)
EXTRACTED_ROOT=$(find "${TEMP_DIR}/extracted" -maxdepth 1 -type d -not -path "${TEMP_DIR}/extracted" | head -n 1)

# Copy memory and templates directories
echo ""
echo "Installing files to: ${INSTALL_DIR}"

if [ -d "${EXTRACTED_ROOT}/memory" ]; then
    echo -e "${YELLOW}Copying memory/ directory...${NC}"
    mkdir -p "${INSTALL_DIR}/memory"
    cp -r "${EXTRACTED_ROOT}/memory/"* "${INSTALL_DIR}/memory/" 2>/dev/null || true
    echo -e "${GREEN}✓ memory/ installed${NC}"
else
    echo -e "${YELLOW}Warning: memory/ directory not found in release${NC}"
fi

if [ -d "${EXTRACTED_ROOT}/templates" ]; then
    echo -e "${YELLOW}Copying templates/ directory...${NC}"
    mkdir -p "${INSTALL_DIR}/templates"
    cp -r "${EXTRACTED_ROOT}/templates/"* "${INSTALL_DIR}/templates/" 2>/dev/null || true
    echo -e "${GREEN}✓ templates/ installed${NC}"
else
    echo -e "${YELLOW}Warning: templates/ directory not found in release${NC}"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Installed directories:"
echo "  - ${INSTALL_DIR}/memory/"
echo "  - ${INSTALL_DIR}/templates/"
echo ""
echo "You can override the installation directory by setting INSTALL_DIR:"
echo "  INSTALL_DIR=/path/to/dir ./install.sh"
