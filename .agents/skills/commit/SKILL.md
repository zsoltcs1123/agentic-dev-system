---
name: commit
description: Stages and commits changes for a task with a descriptive message. Updates task state.
version: 0.1.0
---

# Commit

Stages and commits changes for a completed task.

## Trigger

Use when:

- User asks to "commit task-XXX"
- Dev-cycle invokes the commit step

## Input

- Task ID
- Code changes (staged or unstaged)

## Output

- Git commit with descriptive message

## Procedure

1. Run `git status` to review pending changes
2. Stage relevant changes (`git add`)
3. Compose a descriptive commit message referencing the task
4. Commit changes
5. Update task state to COMMITTED

## Commit Message Format

```
{type}: {short description} (task-{id})

{Optional body with details}
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

## Guidelines

- Do not commit files that contain secrets
- Do not force push or amend unless explicitly requested
- Only commit changes related to the task
