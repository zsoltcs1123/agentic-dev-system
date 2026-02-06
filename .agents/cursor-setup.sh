#!/bin/bash
# Setup script for Linux/macOS - creates symlinks for Cursor auto-discovery
# Cursor requires flat skill folders under .cursor/skills/, so we create
# per-skill symlinks from the nested .agents/skills/ structure.
# Run from workspace root (where .agents/ lives)
set -e

cd "$(dirname "$0")/.."

mkdir -p .cursor/skills

rm -rf .cursor/agents
ln -s ../.agents/agents .cursor/agents

find .agents/skills -name "SKILL.md" -exec dirname {} \; | while read -r skill_dir; do
    skill_name=$(basename "$skill_dir")
    target=".cursor/skills/$skill_name"
    rm -rf "$target"
    ln -s "../../$skill_dir" "$target"
    echo "  Linked: $skill_name -> $skill_dir"
done

echo "Setup complete. Cursor will now discover skills and agents from .agents/"
