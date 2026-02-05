#!/bin/bash
# Setup script for Linux/macOS - creates symlinks for Cursor auto-discovery
# Run from workspace root (where .agents/ lives)
set -e

cd "$(dirname "$0")/.."

mkdir -p .cursor

rm -rf .cursor/skills .cursor/agents

ln -s ../.agents/skills .cursor/skills
ln -s ../.agents/agents .cursor/agents

echo "Setup complete. Cursor will now discover skills and agents from .agents/"
