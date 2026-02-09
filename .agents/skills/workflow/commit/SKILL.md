---
name: commit
description: Stages and commits changes for a task with a descriptive message. Use when asked to "commit task-XXX", "commit changes", or as commit step in dev-cycle. Updates task state.
metadata:
  version: "0.1.0"
---

# Commit

Stages and commits changes for a completed task.

## When to Use

- User asks to "commit task-XXX" or "commit changes"
- Dev-cycle invokes the commit step
- Changes are ready to be recorded

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`)
- Code changes (staged or unstaged)

## Procedure

See `.agents/AGENTS.md` for path conventions.

1. **Parse task ID**: Extract phase number from prefix
2. **Locate phase folder**
3. **Review changes**: Run `git status` to see pending changes
4. **Stage changes**: `git add` relevant files only
5. **Compose message**: Follow format below, reference task ID
6. **Commit**: Create commit with descriptive message
7. **Update task state** to COMMITTED in `{phase-folder}/tasks/{task-id}/{task-id}-state.json`

## Commit Message Format

```
{type}: {short description} ({task-id})

{Optional body with details}
```

**Types**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

## Error Handling

- Nothing to commit → report: "No changes to commit"
- Untracked secret files detected → warn and exclude from commit

## Important

- Do not commit files containing secrets (.env, credentials, keys)
- Do not force push or amend unless explicitly requested
- Only commit changes related to the task
- Review diff before committing
