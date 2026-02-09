---
name: documentation-update
description: Updates project documentation after code changes. Use when asked to "update docs", "sync documentation", or after verification passes in dev-cycle. Keeps docs in sync with implementation.
metadata:
  version: "0.1.0"
---

# Documentation Update

Keeps documentation in sync with code changes.

## When to Use

- User asks to "update docs" or "sync documentation"
- After verification PASS in dev-cycle
- After any user-facing changes

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)
- Git diff or recent changes

## Procedure

See `.agents/AGENTS.md` for path conventions.

1. **Find relevant rules** in `.agents/rules/`:
   - Documentation
1. **Parse task ID**: Extract phase number from prefix
1. **Locate phase folder**
1. **Identify doc files**: README, API docs, architecture docs, etc.
1. **Review code changes**: Understand what changed
1. **Determine updates needed**:
   - New features → add documentation
   - Changed behavior → update existing docs
   - Removed features → remove or mark deprecated
1. **Update docs**: Keep changes minimal and focused
1. **Verify accuracy**: Ensure examples still work
1. **Update task state** to DOCUMENTED

## Scope

**Update if affected**:

- README.md
- API documentation
- Architecture docs
- Configuration examples

**Do NOT update**:

- Auto-generated docs (regenerate instead)
- Changelog (handled separately)
- Version numbers (handled by release process)

## Error Handling

- No docs exist → report: "No documentation files found to update"
- No code changes to document → skip with: "No changes require documentation updates"

## Important

Only update what's affected by the code changes. Don't rewrite unrelated sections.
