---
name: documentation-update
description: Updates project documentation after code changes. Keeps docs in sync with implementation. Use after verification passes.
version: 0.1.0
---

# Documentation Update

Keeps documentation in sync with code changes.

## Trigger

Use when:

- User asks to "update docs" or "sync documentation"
- After verification PASS in dev-cycle

## Input

- Git diff or recent changes
- Existing documentation files

## Output

- Updated documentation files

## Procedure

1. Identify documentation files (README, API docs, etc.)
2. Review the code changes
3. Determine what docs need updates:
   - New features → add documentation
   - Changed behavior → update existing docs
   - Removed features → remove or mark deprecated
4. Update relevant documentation
5. Keep changes minimal and focused

## Scope

Update these if affected:

- README.md
- API documentation
- Architecture docs
- Configuration examples

Do NOT update:

- Auto-generated docs (regenerate instead)
- Changelog (handled separately)
- Version numbers (handled by release process)
